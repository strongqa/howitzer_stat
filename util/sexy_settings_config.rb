SexySettings.configure do |config|
  config.path_to_project = __dir__
  config.path_to_default_settings = File.join(__dir__, '..', 'config', "default.yml")
  config.path_to_custom_settings = File.join(__dir__, '..', 'config', "custom.yml")
end

module API
  def self.settings
    @settings ||= SexySettings::Base.instance
  end
end