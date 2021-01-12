require 'viperaptor/constants/user_preferences_constants.rb'

module Viperaptor

  # A class that provides methods for working with user-specific information.
  # Currently it has methods for obtaining and saving username, later it may be improved to something more general.
  class UserPreferences

    def self.obtain_templates_history
      path = obtain_user_preferences_path

      file_contents = open(path).read
      preferences = file_contents.empty? ? {} : YAML.load(file_contents).to_hash

      return preferences[USER_PREFERENCES_TEMPLATES_HISTORY_KEY] || []
    end

    def self.add_template_to_history(template_name)
      path = obtain_user_preferences_path

      file_contents = open(path).read
      preferences = file_contents.empty? ? {} : YAML.load(file_contents).to_hash

      history = preferences[USER_PREFERENCES_TEMPLATES_HISTORY_KEY] || []
      if history.count == 0 && history[0] != template_name
        history.unshift(template_name)
        max_history = 60
        if history.count > max_history
          history = history.slice(0, max_history)
        end
      end
      preferences[USER_PREFERENCES_TEMPLATES_HISTORY_KEY] = history

      File.open(path, 'w+') { |f| f.write(preferences.to_yaml) }
    end

    def self.obtain_custom_catalogs_repos
      path = obtain_user_preferences_path

      file_contents = open(path).read
      preferences = file_contents.empty? ? {} : YAML.load(file_contents).to_hash

      return preferences[USER_PREFERENCES_CATALOGS_KEY]
    end

    def self.obtain_username
      path = obtain_user_preferences_path

      file_contents = open(path).read
      preferences = file_contents.empty? ? {} : YAML.load(file_contents).to_hash

      return preferences[USER_PREFERENCES_USERNAME_KEY]
    end

    def self.save_username(username)
      path = obtain_user_preferences_path

      file_contents = open(path).read
      preferences = file_contents.empty? ? {} : YAML.load(file_contents).to_hash

      preferences[USER_PREFERENCES_USERNAME_KEY] = username
      File.open(path, 'w+') { |f| f.write(preferences.to_yaml) }
    end

    private

    def self.obtain_user_preferences_path
      home_path = Pathname.new(ENV['HOME'])
                 .join(APP_HOME_DIR)

      path_exists = Dir.exist?(home_path)

      unless path_exists
        FileUtils.mkdir_p home_path
      end

      preferences_path = home_path.join(USER_PREFERENCES_FILE)
      preferences_exist = File.file?(preferences_path)

      unless preferences_exist
        File.open(preferences_path, 'w+') { |f| f.write('') }
      end

      return preferences_path
    end
  end
end