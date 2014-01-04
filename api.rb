require 'rubygems'
require 'bundler/setup'
require 'singleton'

Bundler.require

class DataCacher
  HASH_EXAMPLE = [
    {
      feature: {
        name: '...',
        description: '...',
        path_to_file: '...',
        line: 1
      },
      scenarios: [
        {
          scenario: {name: '...', line: 10},
          steps: [
            { text: '...', line: 11, used: 'yes'},
            { text: '...', line: 12, used: 'no'}
          ]
        }
      ]
    }
  ]

  include Singleton
  def initialize
    @data = {}
    @data.default = {}
    @data['testpage'] = HASH_EXAMPLE
  end

  def page_cached?(page_class)
    key = normalize_page_class(page_class)
    @data.key? key
  end

  def cached_pages
    @data.keys
  end

  def set(page_class, stat)
    key = normalize_page_class(page_class)
    @data[key] = stat if key
  end

  def get(page_class)
    key = normalize_page_class(page_class)
    @data[key]
  end

  private

  def normalize_page_class(page_class)
    page_class = page_class.to_s
    if page_class.empty? || page_class.nil?
      nil
    else
      page_class
    end
  end
end

SexySettings.configure do |config|
  config.path_to_project = __dir__
  config.path_to_default_settings = File.join(__dir__, 'config', "default.yml")
  config.path_to_custom_settings = File.join(__dir__, 'config', "custom.yml")
end

class HowitzerStat < Sinatra::Base
  set :methodoverride, true

  # -- Sinatra helpers --

  def self.put_or_post(*a, &b)
    put *a, &b
    post *a, &b
  end

  helpers do
    def json_status(code, reason)
      status code
      {
          :status => code,
          :reason => reason
      }.to_json
    end

    def accept_params(params, *fields)
      h = { }
      fields.each do |name|
        h[name] = params[name] if params[name]
      end
      h
    end

    def dc
      DataCacher.instance
    end

    def api_settings
      SexySettings::Base.instance
    end

    def identify_page(url, title)
      "TestPage" || "UnknownPage" #TODO Implement me
    end
  end

  # --  API  --

  get '/pages/:page_class', :provides => :json do
    content_type :json
    if dc.page_cached?(params[:page_class])
      status 200
      dc.get(params[:page_class]).to_json
    else
      json_status 404, "Page '#{params[:page_class]}' was not found"
    end
  end

  get '/page_classes', :provides => :json do
    content_type :json
    status 200
    if params[:url] && params[:title]
      {page: identify_page(params[:url], params[:title])}.to_json
    else
      dc.cached_pages.to_json
    end
  end

  # -- misc handlers: error, not_found, etc. --
  get "*" do
    status 404
  end

  put_or_post "*" do
    status 404
  end

  delete "*" do
    status 404
  end

  #not_found do
  #  json_status 404, "Not found"
  #end

  error do
    json_status 500, env['sinatra.error'].message
  end
end