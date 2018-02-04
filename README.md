# InstagramUser

[![Gem Version](https://img.shields.io/gem/v/instagram_user.svg?style=flat)](http://badge.fury.io/rb/instagram_user)
[![Build Status](https://img.shields.io/travis/YuzuruS/instagram_user.svg?style=flat)](https://travis-ci.org/YuzuruS/instagram_user)
[![Coverage Status](https://img.shields.io/coveralls/YuzuruS/instagram_user.svg?style=flat)](https://coveralls.io/r/YuzuruS/instagram_user?branch=master)
[![Code Climate](https://img.shields.io/codeclimate/github/YuzuruS/instagram_user.svg?style=flat)](https://codeclimate.com/github/YuzuruS/instagram_user)

Client for the Instagram Web Service without Instagram API.  
Implemented in Ruby using the Selenium and Mechanize module.

## Installation


```ruby
gem 'instagram_user'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install instagram_user

## Usage

```ruby
cli = InstagramUser.new(user_name: 'YOUR_USER_NAME', password: 'YOUR_PASSWORD')

# Get the follow list for the specified user
follows = cli.get_follows('yuzuru_dev')
# => ["yudsuzuk", "instagram"]

# Get the follower list for the specified user
followers = cli.get_followers('yuzuru_dev')
# => ["yudsuzuk"]

# Follow the specified user
res = cli.create_follow('yuzuru_dev')
# => true or false

# Unfollow the specified user
res = cli.delete_follow('yuzuru_dev')
# => true or false
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the InstagramUser project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/YuzuruS/instagram_user/blob/master/CODE_OF_CONDUCT.md).
