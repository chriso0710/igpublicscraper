require 'json'
require 'typhoeus'
require 'instagram_user/version'
require 'instagram_user/model'
require 'uri'

module InstagramUser

    BASE_URL              = 'https://www.instagram.com/graphql/query/?query_hash=%s&variables=%s'.freeze
    SHORTCODE             = 'https://www.instagram.com/p/%s/?__a=1'.freeze
    MEDIA_JSON_BY_TAG_URL = 'https://www.instagram.com/explore/tags/%s/?__a=1&max_id=%s'.freeze
    AGENT                 = "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10"

    class Client

        def initialize(options = {})
            @options = options
            Typhoeus::Config.user_agent = AGENT
        end

        def debug(response)
            puts "#{response.effective_url} #{response.code}"
            if @options[:debug] 
                json = JSON.parse(response.body) 
                puts JSON.pretty_generate(json) 
            end
        end

        def valid_json?(json)
            begin
                JSON.parse(json)
                return true
            rescue JSON::ParserError => e
                return false
            end
        end

        def get_medias_by_tag(tag_name, req_num = 1)
            max_id = nil
            tags   = {"recent" => [], "popularity" => []}

            req_num.times do
                url = URI.encode(format MEDIA_JSON_BY_TAG_URL, tag_name, max_id)
                response = Typhoeus.get(url)
                debug(response)
                json = JSON.parse(response.body) if valid_json?(response.body)
                if response.code == 200 && json && json["graphql"]
                    hastags = json["graphql"]["hashtag"]
                    tags["recent"]    += hastags["edge_hashtag_to_media"]["edges"]
                    tags["popularity"] = hastags["edge_hashtag_to_top_posts"]["edges"] if max_id.nil?
                    break unless hastags["edge_hashtag_to_media"]["page_info"]["has_next_page"]
                    max_id = hastags["edge_hashtag_to_media"]["page_info"]["end_cursor"]
                end
            end
            tags
        end

        def get_recent_posts_by_tag(tag_name)
            tags = get_medias_by_tag(tag_name)
            posts = []
            tags['recent'].each do |t|
                posts << InstagramUser::Post.new(t)
            end
            posts
        end

        def shortcode_request(post)
            url = URI.encode(format SHORTCODE, post.shortcode)
            Typhoeus::Request.new(url)    
        end

        def get_details(posts)
            hydra = Typhoeus::Hydra.new
            requests = posts.map do |p|
                request = shortcode_request(p)
                hydra.queue(request)
                request
            end
            hydra.run

            responses = requests.map { |r|
                debug(r.response)
                if r.response.code == 200
                    json = JSON.parse(r.response.body) if valid_json?(r.response.body)
                    if json then
                        shortcode = InstagramUser::Shortcode.new(json)
                        if post = posts.detect{ |p| p.shortcode == shortcode.shortcode }
                            post.details = shortcode
                        end
                    end
                end
            }
            posts
        end

    end

end