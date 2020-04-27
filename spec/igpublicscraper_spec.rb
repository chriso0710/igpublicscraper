require "spec_helper"
require "igpublicscraper"

RSpec.describe IGPublicScraper do
  before do
    @client = IGPublicScraper.new
  end

  it "has a version number" do
    expect(IGPublicScraper::VERSION).not_to be nil
  end

  it "gets post from shortcode (Bc2miZShxDY)" do
    post = @client.get_post_by_shortcode('Bc2miZShxDY')
    expect(post).to be_an_instance_of(IGPublicScraper::Post)
    expect(post.owner).to be_an_instance_of(IGPublicScraper::Owner)
    expect(post.owner.username).to_not be_nil
    expect(post.owner.profile_pic_url).to match(/cdninstagram.com/)
    expect(post.details).to be_an_instance_of(IGPublicScraper::Shortcode)
    expect(post.url).to match(/cdninstagram.com/)
    expect(post.timestamp).to_not be_nil
    expect(post.text).to_not be_nil
    expect(post.id).to_not be_nil
    expect(post.shortcode).to_not be_nil
  end

  it "searches hashtag as hash, not found" do
    tags = @client.get_medias_by_tag('some_tag_which_cannot_be_found')
    expect(tags['recent'].count == 0).to eq true
    expect(tags['popularity'].count == 0).to eq true
  end

  it "searches recent hashtag with details, returns post model, #hamburg, 3 times" do
    3.times do
      posts = @client.get_recent_posts_by_tag('hamburg')
      @client.get_details(posts)
      puts "got #{posts.count}"
      expect(posts.count > 0).to eq true
    end
  end

  it "searches hashtag as hash, #hamburg" do
    tags = @client.get_medias_by_tag('hamburg')
    puts "recent #{tags['recent'].count}"
    puts "popular #{tags['popularity'].count}"
    expect(tags['recent'].count > 0).to eq true
    expect(tags['popularity'].count > 0).to eq true
  end

  it "searches recent hashtag with details, returns post model, #hamburg" do
    posts = @client.get_recent_posts_by_tag('hamburg')
    puts "got #{posts.count}"
    expect(posts.count > 0).to eq true
    @client.get_details(posts)
    posts.each { |p| expect(p).to be_an_instance_of(IGPublicScraper::Post) }
  end

  it "searches popular hashtag with details, returns post model, #video" do
    posts = @client.get_popular_posts_by_tag('video')
    puts "got #{posts.count}"
    expect(posts.count > 0).to eq true
    @client.get_details(posts)
    post = posts.first
    expect(post.owner).to be_an_instance_of(IGPublicScraper::Owner)
    expect(post.owner.username).to_not be_nil
    expect(post.owner.profile_pic_url).to match(/cdninstagram.com/)
    expect(post.details).to be_an_instance_of(IGPublicScraper::Shortcode)
    expect(post.url).to match(/cdninstagram.com/)
    expect(post.timestamp).to_not be_nil
    expect(post.text).to_not be_nil
    expect(post.id).to_not be_nil
    expect(post.shortcode).to_not be_nil
  end

  it "searches hashtag as hash, special character umlaut, #münchen" do
    tags = @client.get_medias_by_tag('münchen')
    puts "recent #{tags['recent'].count}"
    puts "popular #{tags['popularity'].count}"
    expect(tags['recent'].count > 0).to eq true
    expect(tags['popularity'].count > 0).to eq true
  end

  it "searches hashtag as hash, paging 3 times, #münchen" do
    tags = @client.get_medias_by_tag('münchen', 3)
    puts "recent #{tags['recent'].count}"
    puts "popular #{tags['popularity'].count}"
    expect(tags['recent'].count > 100).to eq true
    expect(tags['popularity'].count > 0).to eq true
  end

  it "searches location as hash, New York (id 212988663)" do
    locs = @client.get_medias_by_location('212988663')
    puts "got #{locs.count}"
    expect(locs.count > 0).to eq true
  end

  it "searches location as hash, Hamburg (id 213110159), paging 3 times" do
    locs = @client.get_medias_by_location('213110159', 3)
    puts "got #{locs.count}"
    expect(locs.count > 0).to eq true
  end

  it "searches location with details, returns post model, Brandenburger Tor (id 213310140)" do
    posts = @client.get_posts_by_location('213310140')
    puts "got #{posts.count}"
    expect(posts.count > 0).to eq true
    @client.get_details(posts)
    posts.each { |p| expect(p).to be_an_instance_of(IGPublicScraper::Post) }
  end

end

