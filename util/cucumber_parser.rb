#####
# TODO remove me after debug
require 'rubygems'
require 'bundler/setup'

Bundler.require
#####

require 'json'
require 'cucumber/cli/main'
require_relative './sexy_settings_config'

class CucumberParser
  def initialize(args)
    main = Cucumber::Cli::Main.new(args)
    @runtime = Cucumber::Runtime.new(main.configuration)
  end

  def run
    @runtime.run!
    parse_features
  end

  private

  def parse_features
    res = {features: []}
    @runtime.send(:features).each do |feature|
      res[:features] << {
        name: feature.short_name,
        description: feature.description,
        path_to_file: feature.file,
        line: feature.line,
        tags: feature.source_tag_names,
        scenarios: parse_scenarios(feature)
      }
    end
    res
  end

  def parse_scenarios(feature)
    res = []
    feature.feature_elements.each do |feature_element|
      res << {
        background: parse_background(feature_element),
        comment: feature_element.instance_variable_get(:@comment).instance_variable_get(:@value),
        tags: feature_element.source_tag_names,
        keyword: feature_element.instance_variable_get(:@keyword),
        title: feature_element.title,
        description: feature_element.description,
        path_to_file: feature_element.file,
        line: feature_element.line,
        steps: parse_steps(feature_element)
      }
    end
    res
  end

  def parse_background(feature_element)
    background = feature_element.instance_variable_get(:@background)
    return nil if background.nil? || background.is_a?(Cucumber::Ast:: EmptyBackground)
    {
      path_to_file: background.location.file,
      line: background.location.line,
      keyword: background.instance_variable_get(:@keyword),
      title: background.title,
      description: background.description,
      steps: parse_steps(background)
    }
  end

  def parse_multiline_arg(step)
    return nil if step.multiline_arg.nil?
    ma = step.multiline_arg
    if ma.is_a?(Cucumber::Ast::Table)
      {type: :table, content: ma.raw}
    elsif ma.is_a?(Cucumber::Ast::DocString)
      {type: :doc_string, content: ma.to_s}
    else
      nil
    end
  end

  def parse_steps(feature_element)
    res = []
    feature_element.raw_steps.each do |step|
      res << {
          path_to_file: step.file,
          line: step.line,
          keyword: step.keyword,
          name: step.name,
          multiline_arg: parse_multiline_arg(step)
      }
    end
    res
  end
end


#TODO move line below to appropriate ruby file

Dir.chdir API.settings.path_to_source

options = "-r features --expand --tags ~@wip --lines --no-snippets --dry-run".split(/\s+/)

puts CucumberParser.new(options).run.to_json

exit 1