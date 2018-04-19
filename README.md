# IGPublicScraper

Simple client for public Instagram hashtag and location searches.
It uses available JSON data from Instagram's public pages. 
It needs no approved application, no API key and no Instagram user or login. 
It does not rely on browser automation (Selenium etc.) so it is fast. It makes parallel requests with Typhoeus Hydra.

## Notes

* Use this gem responsively and at your own risk. 
* This library exclusively makes request to public Instagram pages. There is no official Instagram API or Instagram user involved. 
* Do not use this gem for commercial projects. The public Instagram endpoints used are uncertain and may change any time. 
* Instagram's public pages implement rate limiting, so you may get back http status code 429, telling you to wait a few minutes before making more requests.

## Installation

```ruby
gem 'igpublicscraper'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install igpublicscraper

## Usage

See specs in 

```ruby
client = IGPublicScraper.new

# get media for the specified tag
res = client.get_medias_by_tag('japanesefood')
# => {"recent" => [...], "popularity" => [...]}
```

## Contributing

This gem is inspired from and originally based on https://github.com/YuzuruS/instagram_user, but heavily modified and without Instagram login and without browser automation.
Contribution are welcome.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the InstagramUser project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/chriso0710/igpublicscraper/blob/master/CODE_OF_CONDUCT.md).
