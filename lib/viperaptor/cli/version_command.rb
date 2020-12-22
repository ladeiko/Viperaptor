require 'thor'
require 'viperaptor/version.rb'

module Viperaptor::CLI
  class Application < Thor
    include Viperaptor

    desc 'version', 'Prints out Viperaptor current version'
    def version
      options = {}
      options['Version'] = Viperaptor::VERSION.green
      options['Release date'] = Viperaptor::RELEASE_DATE.green
      options['Change notes'] = Viperaptor::RELEASE_LINK.green

      values = []

      options.each do |title, value|
        values.push("#{title}: #{value}")
      end

      output = values.join("\n")
      puts(output)
    end
  end
end