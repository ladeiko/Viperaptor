require 'viperaptor/template/processor/template_declaration.rb'
require 'viperaptor/template/installer/local_installer.rb'
require 'viperaptor/template/installer/remote_installer.rb'
require 'viperaptor/template/installer/catalog_installer.rb'
require 'viperaptor/template/helpers/catalog_downloader.rb'
require 'viperaptor/template/helpers/catalog_terminator'
require 'git'

module Viperaptor

  # Incapsulates logic of processing templates declaration section from Rambafile
  class TemplateProcessor

    def initialize(catalog_downloader, installer_factory)
      @catalog_downloader = catalog_downloader
      @installer_factory = installer_factory
    end

    # This method parses Rambafile, serializes templates hashes into model objects and install them
    def install_templates(rambafile)
      # We always clear previously installed templates to avoid conflicts in different versions
      clear_installed_templates

      templates = rambafile[TEMPLATES_KEY] || []

      # Mapping hashes to model objects
      templates = templates.map { |template_hash|
        Viperaptor::TemplateDeclaration.new(template_hash)
      }

      catalogs = rambafile[CATALOGS_KEY] || []

      # If there is at least one template from catalogs, we should update our local copy of the catalog
      update_catalogs_if_needed(catalogs, templates)

      templates.each do |template_declaration|
        strategy = @installer_factory.installer_for_type(template_declaration.type)
        template_declaration.install(strategy)
      end
    end

    private

    # Clears all of the currently installed templates
    def clear_installed_templates
      install_path = Pathname.new(Rambafile.suffix(TEMPLATES_FOLDER))
      FileUtils.rm_rf(Dir.glob(install_path))
    end

    # Clones remote template catalogs to the local directory
    def update_catalogs_if_needed(catalogs, templates)
      needs_update = templates.any? {|template| template.type == TemplateDeclarationType::CATALOG_TEMPLATE}

      return unless needs_update

      terminator = CatalogTerminator.new
      terminator.remove_all_catalogs
      puts('Updating shared catalogs specs...')

      catalogs.each do |catalog_url|
        @catalog_downloader.download_catalog(catalog_url.split('/').last, catalog_url)
      end

      return unless catalogs != nil && catalogs.count > 0

      catalogs.each do |catalog_url|
        catalog_name = catalog_url.split('://').last
        catalog_name = catalog_name.gsub('/', '-');
        @catalog_downloader.download_catalog(catalog_name, catalog_url)
      end
    end
  end
end