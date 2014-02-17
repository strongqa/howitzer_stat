module HowitzerStat
  class CacheRefreshingJob

    def self.perform
      new_stat = gather_stat
      unless @stat == new_stat
        HowitzerStat::CucumberParser.new.run
        @stat = new_stat
      end
    end

    class << self
      private
      def gather_stat
        Dir[File.join(HowitzerStat.settings.path_to_source, 'features', '**', '*.feature')].inject({}) do |res, f|
          res[f] = IO.read(f).hash
          res
        end
      end
    end
  end
end