require 'viperaptor/template/helpers/catalog_downloader'
require 'viperaptor/template/helpers/catalog_template_list_helper'

module Viperaptor::CLI
  class Template < Thor
    include Viperaptor

    desc 'list', 'Prints out the list of all templates available in the shared GitHub catalog'
    def list
      templates = TemplateHelper.global_templates
      templates.each do |template_name|
        puts(template_name)
      end
    end
  end
end