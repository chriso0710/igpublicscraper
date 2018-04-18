require "spec_helper"
require "instagram_user"
require "pp"

RSpec.describe InstagramUser do
  before do
    @client = InstagramUser.new
  end

  it "has a version number" do
    expect(InstagramUser::VERSION).not_to be nil
  end

  it "hashtag suche mit details #hamburg, 5 mal" do
    5.times do
        posts = @client.get_recent_posts_by_tag('hamburg')
        @client.get_details(posts)
        posts.each do |p|
            puts p.print if !p.owner
        end
    end
  end

  it "hashtag suche ohne model #hamburg" do
    tags = @client.get_medias_by_tag('hamburg')
    expect(tags['recent'].count > 0).to eq true
    expect(tags['popularity'].count > 0).to eq true
    puts "recent #{tags['recent'].count}"
    puts "popular #{tags['popularity'].count}"
  end

  it "hashtag suche mit model details #hamburg" do
    posts = @client.get_recent_posts_by_tag('hamburg')
    expect(posts.count > 0).to eq true
    @client.get_details(posts)
    posts.each do |p|
        puts p.print if !p.owner
    end
  end

  it "hashtag suche mit model details #fitness" do
    posts = @client.get_recent_posts_by_tag('fitness')
    expect(posts.count > 0).to eq true
    @client.get_details(posts)
    posts.each do |p|
        puts p.print if !p.owner
    end
  end

  it "hashtag suche ohne model mit umlaut #münchen" do
    tags = @client.get_medias_by_tag('münchen')
    expect(tags['recent'].count > 0).to eq true
    expect(tags['popularity'].count > 0).to eq true
  end

  it "hashtag suche mit model #video" do
    # @client = InstagramUser.new(:debug => true)
    posts = @client.get_recent_posts_by_tag('video')
    expect(posts.count > 0).to eq true
    @client.get_details(posts)
  end

  it "hashtag suche ohne model, paging 3 mal #münchen" do
    tags = @client.get_medias_by_tag('münchen', 3)
    puts "recent #{tags['recent'].count}"
    puts "popular #{tags['popularity'].count}"
    expect(tags['recent'].count > 100).to eq true
    expect(tags['popularity'].count > 0).to eq true
  end

end

