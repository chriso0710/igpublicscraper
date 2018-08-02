require 'json'
require 'typhoeus'
require 'igpublicscraper/version'
require 'igpublicscraper/model'
require 'uri'

module IGPublicScraper

    SHORTCODE_URL         = 'https://www.instagram.com/p/%s/?__a=1'.freeze
    EXPLORETAGS_URL       = 'https://www.instagram.com/explore/tags/%s/?__a=1&max_id=%s'.freeze
    EXPLORELOCATIONS_URL  = 'https://www.instagram.com/explore/locations/%s/?__a=1&max_id=%s'.freeze
    AGENT                 = "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10".freeze

    class Client

        def initialize(options = {})
            @options = options
            Typhoeus::Config.user_agent = AGENT
            # Typhoeus::Config.verbose = true
        end

        def debug(response)
            puts "#{response.effective_url} #{response.code} #{response.return_code}"
            if @options[:debug] 
                json = JSON.parse(response.body) 
                puts JSON.pretty_generate(json) 
            end
        end

        def valid_json?(json)
            # instagram response body not always contains valid json!
            begin
                JSON.parse(json)
                return true
            rescue JSON::ParserError
                return false
            end
        end

        def get_medias_by_tag(tag_name, req_num = 1)
            max_id = nil
            tags = {"recent" => [], "popularity" => []}

            req_num.times do
                url = URI.encode(format EXPLORETAGS_URL, tag_name, max_id)
                response = Typhoeus.get(url)
                debug(response)
                json = JSON.parse(response.body) if valid_json?(response.body)
                if response.code == 200 && json
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
            tags['recent'].map { |t| IGPublicScraper::Post.new(t) }
        end

        def get_popular_posts_by_tag(tag_name)
            tags = get_medias_by_tag(tag_name)
            tags['popularity'].map { |t| IGPublicScraper::Post.new(t) }
        end

        def get_medias_by_location(location_id, req_num = 1)
            max_id = nil
            locations = []

            req_num.times do
                url = URI.encode(format EXPLORELOCATIONS_URL, location_id, max_id)
                response = Typhoeus.get(url)
                debug(response)
                json = JSON.parse(response.body) if valid_json?(response.body)
                if response.code == 200 && json
                    haslocations = json["graphql"]["location"]
                    locations += haslocations["edge_location_to_media"]["edges"]
                    break unless haslocations["edge_location_to_media"]["page_info"]["has_next_page"]
                    max_id = haslocations["edge_location_to_media"]["page_info"]["end_cursor"]
                end
            end
            locations
        end

        def get_posts_by_location(location_id)
            locations = get_medias_by_location(location_id)
            locations.map { |t| IGPublicScraper::Post.new(t) }
        end

        def get_post_by_shortcode(short)
            url = URI.encode(format SHORTCODE_URL, short)
            response = Typhoeus.get(url)
            debug(response)
            json = JSON.parse(response.body) if valid_json?(response.body)
            if response.code == 200 && json
                post = IGPublicScraper::Post.new(json["graphql"], "shortcode_media")
                shortcode = IGPublicScraper::Shortcode.new(json)
                post.details = shortcode
            end
            post
        end

        def shortcode_request(post)
            url = URI.encode(format SHORTCODE_URL, post.shortcode)
            Typhoeus::Request.new(url)    
        end

        def get_details(posts)
            hydra = Typhoeus::Hydra.new(max_concurrency: @options[:max_concurrency] || 20)
            requests = posts.map do |p|
                request = shortcode_request(p)
                hydra.queue(request)
                request
            end
            hydra.run

            requests.map do |r|
                debug(r.response)
                json = JSON.parse(r.response.body) if valid_json?(r.response.body)
                if r.response.code == 200 && json
                    shortcode = IGPublicScraper::Shortcode.new(json)
                    if post = posts.detect{ |p| p.shortcode == shortcode.shortcode }
                        post.details = shortcode
                    end
                end
            end
            posts
        end

    end

end