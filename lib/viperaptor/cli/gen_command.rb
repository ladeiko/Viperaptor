require 'thor'
require "tty-prompt"
require 'set'
require 'viperaptor/helpers/print_table.rb'
require 'viperaptor/helpers/rambafile.rb'
require 'viperaptor/helpers/xcodeproj_helper.rb'
require 'viperaptor/helpers/dependency_checker.rb'
require 'viperaptor/helpers/gen_command_table_parameters_formatter.rb'
require 'viperaptor/helpers/module_validator.rb'
require 'viperaptor/helpers/module_info_generator.rb'

module Viperaptor::CLI
  class Application < Thor

    include Viperaptor

    desc 'gen [MODULE_NAME] [TEMPLATE_NAME]', 'Creates a new VIPER module with a given name from a specific template'
    method_option :description, :aliases => '-d', :desc => 'Provides a full description to the module'
    method_option :author, :desc => 'Specifies the author name for generated module'
    method_option :project_targets, :desc => 'Specifies project targets for adding new module files'
    method_option :project_file_path, :desc => 'Specifies a location in the filesystem for new files'
    method_option :project_group_path, :desc => 'Specifies a location in Xcode groups for new files'
    method_option :module_path, :desc => 'Specifies a location (both in the filesystem and Xcode) for new files'
    method_option :test_targets, :desc => 'Specifies project targets for adding new test files'
    method_option :test_file_path, :desc => 'Specifies a location in the filesystem for new test files'
    method_option :test_group_path, :desc => 'Specifies a location in Xcode groups for new test files'
    method_option :test_path, :desc => 'Specifies a location (both in the filesystem and Xcode) for new test files'
    method_option :custom_parameters, :type => :hash, :default => {}, :desc => 'Specifies extra parameters in format `key1:value1 key2:value2` for usage during code generation'
    def gen(module_name = nil, template_name = nil)
      does_rambafile_exist = Rambafile.exist

      unless does_rambafile_exist
        puts('Rambafile not found! Run `viperaptor setup` in the working directory instead!'.red)
        return
      end

      setup_username_command = Viperaptor::CLI::SetupUsernameCommand.new
      setup_username_command.setup_username

      rambafile = Rambafile.rambafile

      if module_name == nil
        prompt = TTY::Prompt.new
        module_name = prompt.ask("Enter the name of module?") do |q|
          q.required true
          q.validate /^[A-Z]\w*$/
        end
      end

      templates = rambafile[TEMPLATES_KEY] || []
      templates_as_set = Set.new(templates.map { |t| t["name"] })
      templates = templates.concat(TemplateHelper.global_templates.select { |t| !templates_as_set.include?(t) }.map { |name| { "name" => name } }).sort_by { |t| t["name"] }

      filter = rambafile[TEMPLATES_FILTER_KEY] || ''

      if !filter.kind_of?(Array)
        filter = [filter]
      end

      filter = filter.map { |f| f.strip }.select { |f| !f.empty? }
      negative_filters = filter.select { |f| f.start_with?('!') }.map { |f| f[1...] }.map { |f| Regexp.new(f, Regexp::IGNORECASE) }
      positive_filters = filter.select { |f| !f.start_with?('!') }.map { |f| Regexp.new(f, Regexp::IGNORECASE) }
      original_templates = templates

      if original_templates.count == 0
        puts("No any templates found. Add templates catalog or templates to Rambafile.".red)
        exit
      end

      templates = templates.select do |t|

        if filter.count == 0
          next true
        end

        negative_filters.none? { |f| f.match(t["name"]) } && (positive_filters.count == 0 || positive_filters.any? { |f| f.match(t["name"]) })
      end

      if templates.count == 0
        puts("No templates found. Try to modify *templates_filter*.".red)
        exit
      end

      if template_name == nil
        prompt = TTY::Prompt.new
        choices = templates.map { |t| t["name"] }
        index = 1
        history = Viperaptor::UserPreferences.obtain_templates_history
        if history.count > 0
          matching = choices.find_index(history[0])
          if matching != nil
            index = matching + 1
          end
        end
        template_name = prompt.select("Select template?", choices, per_page: choices.count, default: index)
        Viperaptor::UserPreferences.add_template_to_history(template_name)
      end

      code_module = CodeModule.new(module_name, rambafile, options)

      module_validator = ModuleValidator.new
      module_validator.validate(code_module)

      module_info = ModuleInfoGenerator.new(code_module)
      template = ModuleTemplate.new(template_name, module_info.scope)

      parameters = GenCommandTableParametersFormatter.prepare_parameters_for_displaying(code_module, template_name)
      PrintTable.print_values(
          values: parameters,
          title: "Summary for gen #{module_name}"
      )

      DependencyChecker.check_all_required_dependencies_has_in_podfile(template.dependencies, code_module.podfile_path)
      DependencyChecker.check_all_required_dependencies_has_in_cartfile(template.dependencies, code_module.cartfile_path)

      project = XcodeprojHelper.obtain_project(code_module.xcodeproj_path)
      module_group_already_exists = XcodeprojHelper.module_with_group_path_already_exists(project, code_module.project_group_path)

      if module_group_already_exists
        replace_exists_module = yes?("#{module_name} module already exists. Replace? (yes/no)")
      
        unless replace_exists_module
          return
        end
      end

      generator = Viperaptor::ModuleGenerator.new
      generator.generate_module(module_name, code_module, template)
    end

  end
end