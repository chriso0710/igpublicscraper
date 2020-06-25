lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "igpublicscraper/version"

Gem::Specification.new do |spec|
  spec.name          = "igpublicscraper"
  spec.version       = IGPublicScraper::VERSION
  spec.authors       = ["Christian Ott"]
  spec.email         = ["co@hayvalley.io"]

  spec.summary       = "Client for public Instagram hashtag and location searches"
  spec.description   = "Uses json data from Instagram's public pages. Needs no API key and no browser automation."
  spec.homepage      = "https://github.com/chriso0710/igpublicscraper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency 'excon'
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "terminal-notifier"
  spec.add_development_dependency "terminal-notifier-guard"
  spec.add_development_dependency "ffi", ">= 1.9.24"
end
