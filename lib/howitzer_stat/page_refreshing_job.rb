module HowitzerStat
  class PageRefreshingJob

    def self.perform
      new_stat = gather_stat
      unless @stat == new_stat
        HowitzerStat.page_identifier.parse_pages
        @stat = new_stat
      end
    end

    class << self
      private
      def gather_stat
        Dir[File.join(HowitzerStat.settings.path_to_source, 'pages', '**', '*_page.rb')].inject({}) do |res, f|
          res[f] = IO.read(f).hash
          res
        end
      end
    end
  end
end