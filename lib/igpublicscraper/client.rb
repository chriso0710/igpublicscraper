require 'json'
require 'excon'
require 'igpublicscraper/version'
require 'igpublicscraper/model'
require 'uri'

module IGPublicScraper

    INSTAGRAM_URL         = 'https://www.instagram.com'.freeze
    SHORTCODE_PATH        = '/p/%s/?__a=1'.freeze
    EXPLORETAGS_PATH      = '/explore/tags/%s/?__a=1&max_id=%s'.freeze
    EXPLORELOCATIONS_PATH = '/explore/locations/%s/?__a=1&max_id=%s'.freeze
    USER_AGENT            = "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10".freeze

    class Client

        def initialize(options = {})
            # ENV:
            # EXCON_DEBUG=true
            # HTTP_PROXY=http://proxy
            default_options = { :idempotent => true, 
                                :persistent => true, 
                                :headers => { 'User-Agent' => USER_AGENT } }
            @options = default_options.merge(options)
            @connection = Excon.new(INSTAGRAM_URL, @options)
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
                path = URI.encode(format EXPLORETAGS_PATH, tag_name, max_id)
                response = @connection.get(:path => path)
                json = JSON.parse(response.body) if valid_json?(response.body)
                if response.status == 200 && json
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
                path = URI.encode(format EXPLORELOCATIONS_PATH, location_id, max_id)
                response = @connection.get(:path => path)
                json = JSON.parse(response.body) if valid_json?(response.body)
                if response.status == 200 && json
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
            path = URI.encode(format SHORTCODE_PATH, short)
            response = @connection.get(:path => path)
            json = JSON.parse(response.body) if valid_json?(response.body)
            if response.status == 200 && json
                post = IGPublicScraper::Post.new(json["graphql"], "shortcode_media")
                shortcode = IGPublicScraper::Shortcode.new(json)
                post.details = shortcode
            end
            post
        end

        def get_details(posts)
            requests = posts.map do |p|
                path = URI.encode(format SHORTCODE_PATH, p.shortcode)
                {:method => :get, :path => path}
            end
            responses = @connection.batch_requests(requests)

            responses.each do |r|
                json = JSON.parse(r.body) if valid_json?(r.body)
                if r.status == 200 && json
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