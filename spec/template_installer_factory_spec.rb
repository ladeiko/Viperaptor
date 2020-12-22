require_relative 'spec_helper'
require 'viperaptor/template/installer/template_installer_factory'
require 'viperaptor/template/processor/template_declaration'

describe 'TemplateInstallerFactory' do
  describe 'method installer_for_type' do
    subject(:factory) { Viperaptor::TemplateInstallerFactory.new }
    it 'returns local installer' do
      installer = factory.installer_for_type(Viperaptor::TemplateDeclarationType::LOCAL_TEMPLATE)
      result = installer.is_a?(Viperaptor::LocalInstaller)

      expect(result).to eq(true)
    end

    it 'returns remote installer' do
      installer = factory.installer_for_type(Viperaptor::TemplateDeclarationType::REMOTE_TEMPLATE)
      result = installer.is_a?(Viperaptor::RemoteInstaller)

      expect(result).to eq(true)
    end

    it 'returns catalog installer' do
      installer = factory.installer_for_type(Viperaptor::TemplateDeclarationType::CATALOG_TEMPLATE)
      result = installer.is_a?(Viperaptor::CatalogInstaller)

      expect(result).to eq(true)
    end
  end

end
