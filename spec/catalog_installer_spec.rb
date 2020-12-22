require_relative 'spec_helper'
require 'viperaptor/template/processor/template_declaration'

describe 'method install_template' do

  it 'should install template from shared catalog' do
    template_name = 'test'
    catalog_path = Pathname.new(ENV['HOME'])
                       .join(Viperaptor::APP_HOME_DIR)
                       .join(Viperaptor::CATALOGS_DIR)
                       .join(Viperaptor::PREDEFINED_CATALOG_REPOS[0].split('/').last)
    template_path = catalog_path.join(template_name)

    template_install_path = Pathname.new(Rambafile.suffix(Viperaptor::TEMPLATES_FOLDER))
                                .join(template_name)

    allow(Viperaptor::RambaspecValidator).to receive(:validate_spec).and_return(true)
    allow(Viperaptor::RambaspecValidator).to receive(:validate_spec_existance).and_return(true)
    FakeFS do
      FileUtils.mkdir_p template_path

      declaration = Viperaptor::TemplateDeclaration.new({Viperaptor::TEMPLATE_DECLARATION_NAME_KEY => 'test'})
      installer = Viperaptor::CatalogInstaller.new
      installer.install_template(declaration)

      result = Dir.exist?(template_install_path)
      expect(result).to eq(true)
    end
  end

  it 'should install template from other catalog' do
    template_name = 'test'
    catalog_name = 'custom_catalog'
    shared_catalog_path = Pathname.new(ENV['HOME'])
                       .join(Viperaptor::APP_HOME_DIR)
                       .join(Viperaptor::CATALOGS_DIR)
                       .join(Viperaptor::PREDEFINED_CATALOG_REPOS[0].split('/').last)
    catalog_path = Pathname.new(ENV['HOME'])
                       .join(Viperaptor::APP_HOME_DIR)
                       .join(Viperaptor::CATALOGS_DIR)
                       .join(catalog_name)
    template_path = catalog_path.join(template_name)

    template_install_path = Pathname.new(Rambafile.suffix(Viperaptor::TEMPLATES_FOLDER))
                                .join(template_name)

    allow(Viperaptor::RambaspecValidator).to receive(:validate_spec).and_return(true)
    allow(Viperaptor::RambaspecValidator).to receive(:validate_spec_existance) do |name, path|
      result = false
      if template_path.to_s == path.to_s
        result = true
      end
      result
    end

    FakeFS do
      FileUtils.mkdir_p template_path
      FileUtils.mkdir_p shared_catalog_path

      declaration = Viperaptor::TemplateDeclaration.new({Viperaptor::TEMPLATE_DECLARATION_NAME_KEY => 'test'})
      installer = Viperaptor::CatalogInstaller.new
      installer.install_template(declaration)

      result = Dir.exist?(template_install_path)
      expect(result).to eq(true)
    end
  end
end