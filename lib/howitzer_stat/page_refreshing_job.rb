module HowitzerStat
  class PageRefreshingJob

    def perform
      new_stat = gather_stat
      unless Thread.main['page_stat'] == new_stat
        HowitzerStat.page_identifier.parse_pages
        Thread.main['page_stat'] = new_stat
      end
    end

    private
    def gather_stat
      Dir[File.join(HowitzerStat.settings.path_to_source, 'pages', '**', '*_page.rb')].inject({}) do |res, f|
        res[f] = IO.read(f).hash
        res
      end
    end
  end
end