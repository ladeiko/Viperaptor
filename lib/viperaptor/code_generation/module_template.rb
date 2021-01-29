require 'viperaptor/helpers/template_helper.rb'
require "tty-prompt"

module Viperaptor

  # Represents a single Viperaptor module template
  class ModuleTemplate
    attr_reader :template_name, :template_path, :code_files, :test_files, :dependencies

    def initialize(name, options = nil)
      spec_path = TemplateHelper.obtain_spec(name)

      unless options
        spec = YAML.load_file(spec_path)
      else
        spec_source = IO.read(spec_path)
        spec_template = Liquid::Template.parse(spec_source)
        spec_content = spec_template.render(options)
        spec = YAML.load(spec_content)
      end

      variables = spec[TEMPLATE_VARIABLES_KEY]
      @variables = {}
      unless variables.nil?
        variables.map do |desc|
          if !desc["single_select"].nil?
            prompt = TTY::Prompt.new
            choices = desc["single_select"]
            value = prompt.select("Select #{desc["description"]}?", choices, per_page: choices.count)
            @variables[desc["name"]] = value
          else
            puts("ERROR: Invalid variable type of template custom variable #{desc.name}".red)
            exit(1)
          end
        end
      end

      @code_files = spec[TEMPLATE_CODE_FILES_KEY]
      @test_files = spec[TEMPLATE_TEST_FILES_KEY]
      @template_name = spec[TEMPLATE_NAME_KEY]
      @template_path = TemplateHelper.obtain_path(name)
      @dependencies = spec[TEMPLATE_DEPENDENCIES_KEY]
    end
  end
end