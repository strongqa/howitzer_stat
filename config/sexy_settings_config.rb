require 'sexy_settings'
SexySettings.configure do |config|
  config.path_to_project = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  config.path_to_default_settings = File.join(config.path_to_project, 'config', "default.yml")
  config.path_to_custom_settings = File.join(config.path_to_project, 'config', "custom.yml")
end

module HowitzerStat
  def self.settings
    @settings ||= SexySettings::Base.instance
  end
end