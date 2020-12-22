require "tty-prompt"

module Viperaptor

  # Provides methods for validating Rambafile contents
  class RambafileValidator
    # Method validates Rambafile contents
    # @param path [String] The path to a Rambafile
    #
    # @return [Void]
    def validate(path)
      file_contents = open(path).read
      preferences = file_contents.empty? ? {} : YAML.load(file_contents).to_hash
    end
  end

  class Rambafile

    def self.exist
      Dir[RAMBAFILE_NAME + "*"].count > 0
    end

    def self.suffix(name)
      self.rambafile
      name + @@rambafile_name_suffix
    end

    def self.rambafile

      if @@rambafile == nil

        files = Dir[RAMBAFILE_NAME + "*"]

        if files.count == 0
          puts("No Rambafile found".red)
          exit
        end

        if files.count == 1
          @@rambafile_name = files[0]
        else
          prompt = TTY::Prompt.new
          choices = files.sort
          @@rambafile_name = prompt.select("Select Rambafile?", choices, per_page: choices.count)
        end

        @@rambafile_name_suffix = @@rambafile_name[RAMBAFILE_NAME.length..-1]

        self.validate
        @@rambafile = YAML.load_file(@@rambafile_name)
        self.load_defaults
      end

      @@rambafile
    end

    private

    def self.validate
      rambafile_validator = Viperaptor::RambafileValidator.new
      rambafile_validator.validate(@@rambafile_name)
    end

    def self.load_defaults
      @@rambafile[CATALOGS_KEY] = rambafile[CATALOGS_KEY] || []
      @@rambafile[TEMPLATES_KEY] = rambafile[TEMPLATES_KEY] || []
      @@rambafile[COMPANY_KEY] = @@rambafile[COMPANY_KEY] || ''
    end

    @@rambafile_name = nil
    @@rambafile = nil

  end

end
