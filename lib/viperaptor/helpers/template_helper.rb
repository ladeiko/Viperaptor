module Viperaptor
  # Provides a number of helper methods for manipulating Viperaptor template files
  class TemplateHelper

    def self.detect_template_location(template_name)

      catalogs_path = Pathname.new(ENV['HOME'])
                              .join(APP_HOME_DIR)
                              .join(CATALOGS_DIR)

      catalog_template_list_helper = CatalogTemplateListHelper.new

      catalogs = catalogs_path.children.select { |child|
        child.directory? && child.split.last.to_s[0] != '.'
      }

      catalog = ([
        Pathname.new(Dir.getwd).join(Rambafile.suffix(TEMPLATES_FOLDER)),
      ] + catalogs)
       .detect do |catalog_path|
        next if !catalog_path.exist?
        templates = catalog_template_list_helper.obtain_all_templates_from_a_catalog(catalog_path)
        templates.include?(template_name)
      end

      return nil if catalog == nil

      path = catalog_template_list_helper.template_path(catalog, template_name)

      error_description = "Cannot find template named '#{template_name}'! Add it to the Rambafile and run *viperaptor template install*".red
      raise StandardError, error_description if path.nil?

      path
    end

    # Returns a file path for a specific template .rambaspec file
    # @param template_name [String] The Viperaptor template name
    #
    # @return [Pathname]
    def self.obtain_spec(template_name)
      template_path = self.obtain_path(template_name)
      spec_path = template_path.join(template_name + RAMBASPEC_EXTENSION)

      spec_path
    end

    # Returns a file path for a specific template folder
    # @param template_name [String] The Viperaptor template name
    #
    # @return [Pathname]
    def self.obtain_path(template_name)
      path = self.detect_template_location(template_name)

      error_description = "Cannot find template named #{template_name}! Add it to the Rambafile and run *viperaptor template install*".red
      raise StandardError, error_description unless path != nil && path.exist?

      path
    end

    def self.global_templates

      downloader = CatalogDownloader.new
      catalog_template_list_helper = CatalogTemplateListHelper.new

      templates = []
      catalog_paths = downloader.update_all_catalogs_and_return_filepaths(true)
      catalog_paths.each do |path|
        templates += catalog_template_list_helper.obtain_all_templates_from_a_catalog(path)
        templates = templates.uniq
      end

      templates.sort
    end

  end
end
