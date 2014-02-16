require File.expand_path('lib/howitzer_stat', File.dirname(__FILE__))
set :environment, ENV["RACK_ENV"].to_sym
run HowitzerStat::WebServer