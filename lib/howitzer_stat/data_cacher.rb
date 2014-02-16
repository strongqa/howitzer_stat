module HowitzerStat
  class DataCacher
    include Singleton
    attr_reader :data

    def initialize
      puts "DataCacher initialization ...."
      @data = {cucumber: {}, rspec: {}}
      @data[:cucumber].default = {}
      @data[:rspec].default = {}
    end

    def empty_cucumber
      @data[:cucumber] = {}
    end

    def empty_rspec
      @data[:rspec] = {}
    end

    def page_cached?(page_class, type=:cucumber)
      key = normalize_page_class(page_class)
      @data[type].key? key
    end

    def cached_pages(type=:cucumber)
      @data[type].keys
    end

    def set_all(stat, type=:cucumber)
      data = stat.inject({}) do |res, (page_class, value)|
        key = normalize_page_class(page_class)
        res[key] = value if key
        res
      end
      @data[type] = data
    end

    def set(page_class, stat, type=:cucumber)
      key = normalize_page_class(page_class)
      @data[type][key] = stat if key
    end

    def get(page_class, type=:cucumber)
      key = normalize_page_class(page_class)
      @data[type][key]
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

  def self.data_cacher
    DataCacher.instance
  end
end