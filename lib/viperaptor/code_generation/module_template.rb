require "viperaptor/helpers/template_helper.rb"
require "tty-prompt"

module Viperaptor

  # Represents a single Viperaptor module template
  class ModuleTemplate
    attr_reader :template_name, :template_path, :code_files, :test_files, :dependencies, :custom_parameters

    def load_custom_parameters_from_spec(spec)
      custom_parameters = spec[TEMPLATE_CUSTOM_PARAMETERS_KEY]
      result = {}
      unless custom_parameters.nil?
        custom_parameters.sort_by { |a| (a["order"] || 0) }.each do |desc|
          skip = false

          if !desc["only_if"].nil? && desc["only_if"].is_a?(Hash)
            desc["only_if"].each do |key, value|
              if value.is_a?(Array)
                if result[key].nil?
                  puts("ERROR: Required custom_parameter '#{key}' not defined".red)
                  exit(1)
                end

                if !value.include?(result[key])
                  skip = true
                  break
                end
              end
            end
          end

          if !skip
            if !desc["only_if"].nil? && desc["only_if_not"].is_a?(Hash)
              desc["only_if"].each do |key, value|
                if value.is_a?(Array)
                  if result[key].nil?
                    break
                  end

                  if value.include?(result[key])
                    skip = true
                    break
                  end
                end
              end
            end
          end

          if !skip
            if desc["options"].instance_of?(Array)
              prompt = TTY::Prompt.new
              choices = desc["options"]
              value = prompt.select("#{desc["description"]}?", choices, per_page: choices.count)

              case value
              when "yes"
                value = "true"
              when "no"
                value = "false"
              else
                #
              end

              result[desc["name"]] = value
            elsif desc["options"].nil?
              prompt = TTY::Prompt.new
              value = prompt.ask("#{desc["description"]}?")
              result[desc["name"]] = value
            else
              puts("ERROR: Invalid variable 'options' of template custom parameter '#{desc["name"]}'".red)
              exit(1)
            end
          end
        end
      end
      return result
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

      viperaptor = spec[TEMPLATE_VIPERAPTOR_KEY]
      if !viperaptor.nil? && Gem::Version.new(Viperaptor::VERSION) < Gem::Version.new(viperaptor)
        puts("ERROR: Your viperaptor version is '#{Viperaptor::VERSION}' template requires '#{viperaptor}'. Please update it.".red)
        exit(1)
      end

      custom_parameters = load_custom_parameters_from_spec(spec)

      if !custom_parameters.empty? && !options.nil?
        spec_source = IO.read(spec_path)
        spec_template = Liquid::Template.parse(spec_source)

        if options["custom_parameters"].nil?
          options["custom_parameters"] = {}
        end

        new_options = options["custom_parameters"].merge(custom_parameters)

        new_options.each_key do |k|
          options["custom_parameters"][k] = new_options[k]
        end

        spec_content = spec_template.render(options)
        spec = YAML.load(spec_content)
      end

      @custom_parameters = options["custom_parameters"]
      @code_files = spec[TEMPLATE_CODE_FILES_KEY]
      @test_files = spec[TEMPLATE_TEST_FILES_KEY]
      @template_name = spec[TEMPLATE_NAME_KEY]
      @template_path = TemplateHelper.obtain_path(name)
      @dependencies = spec[TEMPLATE_DEPENDENCIES_KEY]
    end
  end
end
