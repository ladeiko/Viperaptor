require 'viperaptor/template/installer/abstract_installer.rb'
require 'viperaptor/template/helpers/rambaspec_validator.rb'

module Viperaptor

  # Incapsulates the logic of verifying and installing local templates
  class LocalInstaller < AbstractInstaller
    def install_template(template_declaration)
      template_name = template_declaration.name
      puts("Installing #{template_name}...")

      local_path = template_declaration.local
      rambaspec_exist = Viperaptor::RambaspecValidator.validate_spec_existance(template_name, local_path)

      unless rambaspec_exist
        error_description = "Cannot find #{template_name + RAMBASPEC_EXTENSION} in the specified directory. Try another path or name.".red
        raise StandardError.new(error_description)
      end

      rambaspec_valid = Viperaptor::RambaspecValidator.validate_spec(template_name, local_path)
      unless rambaspec_valid
        error_description = "#{template_name + RAMBASPEC_EXTENSION} is not valid.".red
        raise StandardError.new(error_description)
      end

      install_path = Pathname.new(Rambafile.suffix(TEMPLATES_FOLDER))
                         .join(template_name)
      FileUtils.mkdir_p install_path
      FileUtils.copy_entry(local_path, install_path)
    end
  end
end