require 'git'
require 'fileutils'

module Viperaptor

  # Provides the functionality to download template catalogs from the remote repository
  class CatalogDownloader

    def external_catalogs_filepaths

      catalogs_path = Pathname.new(ENV['HOME'])
                              .join(APP_HOME_DIR)
                              .join(CATALOGS_DIR)

      return [] unless catalogs_path.exist?

      catalogs_path.children.select { |child|
        child.directory? && child.split.last.to_s[0] != '.'
      }
    end

    # Updates all of the template catalogs and returns their filepaths.
    # If there is a Rambafile in the current directory, it also updates all of the catalogs specified there.
    #
    # @return [Array] An array of filepaths to downloaded catalogs
    def update_all_catalogs_and_return_filepaths(throttled = false)
      does_rambafile_exist = Rambafile.exist

      if does_rambafile_exist
        rambafile = Rambafile.rambafile
        catalogs = rambafile[CATALOGS_KEY]
      end

      # terminator = CatalogTerminator.new
      # terminator.remove_all_catalogs

      repos = (Viperaptor::UserPreferences.obtain_custom_catalogs_repos || []) + PREDEFINED_CATALOG_REPOS

      catalog_paths = repos.map do |repo|
        name = repo.split('/').last

        catalogs_local_path = Pathname.new(ENV['HOME'])
                                      .join(APP_HOME_DIR)
                                      .join(CATALOGS_DIR)
        current_catalog_path = catalogs_local_path
                                 .join(name)

        if !current_catalog_path.exist? || !throttled || (Time.now - current_catalog_path.mtime) > 3600.0 * 12.0
          download_catalog(name, repo)
        end

        current_catalog_path
      end

      if catalogs != nil && catalogs.count > 0
        catalogs.each do |catalog_url|

          name = catalog_url.split('://').last
          name = name.gsub('/', '-');

          catalogs_local_path = Pathname.new(ENV['HOME'])
                                        .join(APP_HOME_DIR)
                                        .join(CATALOGS_DIR)
          current_catalog_path = catalogs_local_path
                                   .join(name)

          if !current_catalog_path.exist? || !throttled || (Time.now - current_catalog_path.mtime) > 3600.0 * 12.0
            download_catalog(name, catalog_url)
          end

          catalog_paths.push(current_catalog_path)
        end
      end
      return catalog_paths
    end

    # Clones a template catalog from a remote repository
    #
    # @param name [String] The name of the template catalog
    # @param url [String] The url of the repository
    #
    # @return [Pathname] A filepath to the downloaded catalog
    def download_catalog(name, url)

      catalogs_local_path = Pathname.new(ENV['HOME'])
                               .join(APP_HOME_DIR)
                               .join(CATALOGS_DIR)
      current_catalog_path = catalogs_local_path
                                 .join(name)

      puts("Updating #{name} specs (#{url})...")

      git_dir = current_catalog_path.join('.git')

      if File.directory?(git_dir)
        g = Git.open(current_catalog_path)
        g.pull
        FileUtils.touch current_catalog_path
      else
        FileUtils.rm_rf current_catalog_path
        Git.clone(url, name, :path => catalogs_local_path)
      end

      return current_catalog_path
    end
  end
end