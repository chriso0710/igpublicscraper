require "igpublicscraper/client"

module IGPublicScraper
  def self.new(options = {})
    IGPublicScraper::Client.new(options)
  end
end
