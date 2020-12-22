require 'viperaptor/template/installer/abstract_installer.rb'
require 'viperaptor/template/helpers/rambaspec_validator.rb'
require 'git'
require 'fileutils'
require 'tmpdir'

module Viperaptor

  # Incapsulates the logic of fetching remote templates, verifying and installing them
  class RemoteInstaller < AbstractInstaller
    def install_template(template_declaration)
      template_name = template_declaration.name
      puts("Installing #{template_name}...")

      repo_url = template_declaration.git
      repo_branch = template_declaration.branch

      Dir.mktmpdir do |temp_path|
        template_dir = Pathname.new(temp_path).join(template_name)

        if repo_branch != nil
          Git.export(repo_url, template_name, :branch => repo_branch, :path => temp_path)
        else
          Git.clone(repo_url, template_name, :path => temp_path)
        end

        template_path = "#{template_dir}"

        rambaspec_exist = Viperaptor::RambaspecValidator.validate_spec_existance(template_name, template_path)
        unless rambaspec_exist
          FileUtils.rm_rf(temp_path)
          error_description = "Cannot find #{template_name + RAMBASPEC_EXTENSION} in the root directory of specified repository.".red
          raise StandardError.new(error_description)
        end

        rambaspec_valid = Viperaptor::RambaspecValidator.validate_spec(template_name, template_path)
        unless rambaspec_valid
          error_description = "#{template_name + RAMBASPEC_EXTENSION} is not valid.".red
          raise StandardError.new(error_description)
        end

        install_path = Pathname.new(Rambafile.suffix(TEMPLATES_FOLDER))
                          .join(template_name)
        FileUtils.mkdir_p install_path
        FileUtils.copy_entry(template_path, install_path)

      end

    end
  end
end