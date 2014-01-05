require_relative './sexy_settings_config'

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