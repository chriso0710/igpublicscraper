# IGPublicScraper

Simple client for public Instagram hashtag and location searches.
It uses available JSON data from Instagram's public pages. 
It needs no approved application, no API key and no Instagram user or login. 
It does not rely on browser automation (Selenium etc.) so it is fast. It makes requests using Excon. It sets the user agent string for Excon to a common browser.

This gem is inspired from [Instagram Data Scraping from Public API](https://medium.com/@h4t0n/instagram-data-scraping-550c5f2fb6f1) and originally based on the [Instagram_User](https://github.com/YuzuruS/instagram_user) gem, but heavily modified to avoid Instagram login and browser automation.

## Notes

* Use this gem responsively and at your own risk. 
* This library exclusively makes request to public Instagram pages. There is no official Instagram API or Instagram user involved. 
* This library will not get any private media of Instagram users.
* Do not use this gem for commercial projects. The public Instagram endpoints used are uncertain and may change any time. 
* The number of results may vary as this is not an official endpoint.
* Instagrams public pages implement rate limiting, so you may get back http status code 429, telling you to wait a few minutes before making more requests.

## Installation

```ruby
gem 'igpublicscraper'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install igpublicscraper

## Usage

```ruby
# new client
client = IGPublicScraper.new
# new client in debug mode, pretty prints response JSON body 
client = IGPublicScraper.new(:debug => true)

# get media for the specified tag
res = client.get_medias_by_tag('hamburg')
# => {"recent" => [...], "popularity" => [...]}

# get media for the specified location id (Hamburg), page 3 times
res = client.get_medias_by_location('213110159', 3)
# => array of media hash

# get recents posts for the specified tag
posts = client.get_recent_posts_by_tag('video')
# => array of posts

# get popular posts for the specified tag
posts = client.get_popular_posts_by_tag('fitness')
# => array of posts
# get details like owner and video from shortcode pages
client.get_details(posts)
# => array of posts with shortcode details
# print fields
post = posts.first
puts "#{post.id} #{post.shortcode} #{post.owner.username if owner} #{post.video?} #{Time.at(post.timestamp)} #{post.url} #{post.text_short}"

# get posts for the specified location id (New York)
posts = client.get_posts_by_location('212988663')
# => array of posts
# get details like owner and video from shortcode page
client.get_details(posts)
# => array of posts with shortcode details

# get single post for shortcode with details
post = client.get_post_by_shortcode('Bc2miZShxDY')
# => single post
```

See more examples in spec directory.

## Contributing

All contributions are welcome. Please provide tests.

Run tests with ```rspec``` or ```rake```.

## License

This gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the project’s codebase and issue tracker is expected to follow the [code of conduct](https://github.com/chriso0710/igpublicscraper/blob/master/CODE_OF_CONDUCT.md).
