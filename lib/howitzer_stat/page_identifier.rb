module HowitzerStat
  class PageIdentifier
    NoValidationError = Class.new(StandardError)
    TEST_URL_REGEXP = /\/test\?page=(\w+)/
    TEST_TITLE = 'HowitzerStat'

    include Singleton
    def initialize
      puts "PageIdentifier initialization ...."
      @validations = {}
    end

    def all_pages
      @validations.keys
    end

    def identify_page(url, title)
      raise ArgumentError, "Url and title can not be blank. Actual: url=#{url}, title=#{title}" if url.nil? || url.empty? || title.nil? || title.empty?
      return [test_page(url)] if test_page?(url, title)
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

    def parse_pages
      HowitzerStat.log("Parsing pages...") do
        res = {}
        Dir[File.join(HowitzerStat.settings.path_to_source, 'pages', '**', '*_page.rb')].each do |f|
          source = remove_comments(IO.read(f))
          page_name = parse_page_name(source)
          next unless page_name
          res[page_name] = parse_validations(source)
        end
        p res
        @validations = res
      end
    end

    private

    def test_page?(url, title)
      TEST_URL_REGEXP === url && title == TEST_TITLE
    end

    def test_page(url)
      page_name = url[TEST_URL_REGEXP, 1]
      page_name if @validations.key?(page_name)
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

  def self.page_identifier
    PageIdentifier.instance
  end
end