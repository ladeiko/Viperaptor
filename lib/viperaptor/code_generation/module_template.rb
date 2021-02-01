require 'viperaptor/helpers/template_helper.rb'
require "tty-prompt"

module Viperaptor

  # Represents a single Viperaptor module template
  class ModuleTemplate
    attr_reader :template_name, :template_path, :code_files, :test_files, :dependencies, :custom_parameters

    def load_variables_from_spec(spec)
      custom_parameters = spec[TEMPLATE_CUSTOM_PARAMETERS_KEY]
      @custom_parameters = {}
      unless custom_parameters.nil?
        custom_parameters.sort_by { |a| (a['order'] || 0) }.map do |desc|
          if desc["type"].is_a?(Array)
            prompt = TTY::Prompt.new
            choices = desc["type"]
            value = prompt.select("Select #{desc["description"]}?", choices, per_page: choices.count)
            @custom_parameters[desc["name"]] = value
          elsif desc["type"] == 'boolean'
            prompt = TTY::Prompt.new
            value = prompt.yes?("#{desc["description"]}?")
            @custom_parameters[desc["name"]] = value
          elsif desc["type"] == 'text'
            prompt = TTY::Prompt.new
            value = prompt.ask("#{desc["description"]}?")
            @custom_parameters[desc["name"]] = value
          else
            puts("ERROR: Invalid variable type of template custom parameter '#{desc['name']}'".red)
            exit(1)
          end
        end
      end
    end

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

      load_variables_from_spec(spec)
      if !@custom_parameters.empty? && !options.nil?
        spec_source = IO.read(spec_path)
        spec_template = Liquid::Template.parse(spec_source)
        spec_content = spec_template.render(options.merge(@custom_parameters))
        spec = YAML.load(spec_content)
      end

      @code_files = spec[TEMPLATE_CODE_FILES_KEY]
      @test_files = spec[TEMPLATE_TEST_FILES_KEY]
      @template_name = spec[TEMPLATE_NAME_KEY]
      @template_path = TemplateHelper.obtain_path(name)
      @dependencies = spec[TEMPLATE_DEPENDENCIES_KEY]
    end
  end
end