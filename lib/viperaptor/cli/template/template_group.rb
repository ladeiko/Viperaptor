require 'viperaptor/cli/template/template_install_command.rb'
require 'viperaptor/cli/template/template_create_command.rb'
require 'viperaptor/cli/template/template_list_command.rb'
require 'viperaptor/cli/template/template_search_command.rb'

module Viperaptor::CLI
  class Application < Thor
    register(Viperaptor::CLI::Template, 'template', 'template <command>', 'Provides a set of commands for working with templates')
  end

  class Template < Thor

  end
end