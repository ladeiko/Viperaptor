module Viperaptor::CLI
  class Template < Thor

    desc 'install', 'Installs all the templates specified in the Rambafile from the current directory'
    def install
      does_rambafile_exist = Rambafile.exist

      unless does_rambafile_exist
        puts('Rambafile not found! Run `viperaptor setup` in the working directory instead!'.red)
        return
      end

      catalog_downloader = Viperaptor::CatalogDownloader.new
      installer_factory = Viperaptor::TemplateInstallerFactory.new
      template_processor = Viperaptor::TemplateProcessor.new(catalog_downloader, installer_factory)

      rambafile = Rambafile.rambafile
      template_processor.install_templates(rambafile)
    end
  end
end