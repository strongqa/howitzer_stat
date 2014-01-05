require 'rubygems'
require 'bundler/setup'
require 'singleton'

Bundler.require

SexySettings.configure do |config|
  config.path_to_project = __dir__
  config.path_to_default_settings = File.join(__dir__, 'config', "default.yml")
  config.path_to_custom_settings = File.join(__dir__, 'config', "custom.yml")
end

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

class PageIdentifier
  NoValidationError = Class.new(StandardError)
  include Singleton
  def initialize
    @api_settings = SexySettings::Base.instance
    @validations = {}
    parse_pages
  end

  def identify_page(url, title)
    raise ArgumentError, "Url and title can not be blank. Actual: url=#{url}, title=#{title}" if url.nil? || url.empty? || title.nil? || title.empty?
    @validations.inject([]) do |res, (page, validation_data)|
      is_found = case [!!validation_data[:url], !!validation_data[:title]]
                   when [true, true]
                     validation_data[:url] === url && validation_data[:title] === title
                   when [true, false]
                     validation_data[:url] === url
                   when [false, true]
                     validation_data[:title] === title
                   when [false, false]
                     raise NoValidationError, "No any page validation was found for '#{page}' page"
                   else nil
                 end
      res << page if is_found
      res
    end
  end

  private

  def parse_pages
    Dir[File.join(@api_settings.path_to_source, 'pages', '**', '*_page.rb')].each do |f|
      source = remove_comments(IO.read(f))
      page_name = parse_page_name(source)
      @validations[page_name] = parse_validations(source)
    end
  end

  def remove_comments(source)
    source.gsub(/^\s*#.*$/, '')
  end

  def parse_page_name(source)
    source[/\s*class\s+(.*?)[\s<$]/, 1]
  end

  def parse_validations(source)
    [:url, :title].inject({}) do |res, type|
      regexp_str = parse_validation(source, type)
      res[type] = /#{regexp_str}/ unless regexp_str.nil?
      res
    end
  end

  def parse_validation(source, type)
    pattern = source[/^\s*validates\s+:#{type}\s*,\s*(?:pattern:|:pattern\s*=>)\s*(.*)\s*$/, 1]
    return nil unless pattern
    inner_pattern = pattern[/^\/(.+)\/$/, 1]
    unless inner_pattern
      inner_pattern = source[/^\s*#{pattern}\s*=\s*\/(.+)\/\s*$/, 1]
    end
    inner_pattern
  end

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

    def pi
      PageIdentifier.instance
    end

    def api_settings
      SexySettings::Base.instance
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
      {page: pi.identify_page(params[:url], params[:title])}.to_json
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