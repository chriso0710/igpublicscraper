module InstagramUser

    class Post

        def initialize(ighash)
            @h = ighash["node"]
        end

        def shortcode
            @h["shortcode"]
        end

        def id
            @h["id"]
        end

        def text
            edge = @h["edge_media_to_caption"]["edges"].first
            edge ? edge["node"]["text"].gsub(/\s+/, ' ').strip : nil
        end

        def text_short
            "#{text[0...30]}..." if text
        end

        def url
            if details
                video? ? details.video_url : display_url
            else
                display_url
            end
        end

        def display_url
            @h["display_url"]
        end

        def ownerid
            @h["owner"]["id"]
        end

        def video?
            @h["is_video"]
        end

        def timestamp
            @h["taken_at_timestamp"]
        end

        def details
            @shortcode
        end

        def owner
            @shortcode.owner if @shortcode
        end

        def details=(shortcode)
            @shortcode = shortcode
        end

        def print
            "#{id} #{shortcode} #{owner} #{video?} #{Time.at(timestamp)} #{url} #{text_short}"
        end

    end

    class Shortcode

        def initialize(ighash)
            @h = ighash["graphql"]["shortcode_media"]
        end

        def shortcode
            @h["shortcode"]
        end

        def id
            @h["id"]
        end

        def owner
            @owner ||= InstagramUser::Owner.new(@h)
        end

        def video_url
            @h["video_url"]
        end

    end

    class Owner

        def initialize(ighash)
            @h = ighash["owner"]
        end

        def id
            @h["id"]
        end

        def profile_pic_url
            @h["profile_pic_url"]
        end

        def username
            @h["username"]
        end

    end

end