module HowitzerStat
  class CacheRefreshingJob

    def perform
      new_stat = gather_stat
      unless Thread.main['cache_stat'] == new_stat
        HowitzerStat::CucumberParser.new.run
        Thread.main['cache_stat'] = new_stat
      end
    end

    private
    def gather_stat
      Dir[File.join(HowitzerStat.settings.path_to_source, 'features', '**', '*.feature')].inject({}) do |res, f|
        res[f] = IO.read(f).hash
        res
      end
    end
  end
end