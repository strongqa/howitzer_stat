class CucumberParser
  include Singleton

  def initialize
    smart_chdir do
      options = "-r features -f progress --tags ~@wip --dry-run".split(/\s+/)
      stdout = StringIO.new
      main = Cucumber::Cli::Main.new(options, STDIN, stdout)
      @runtime = Cucumber::Runtime.new(main.configuration)
    end
  end

  def run
    smart_chdir do
      @runtime.run!
      prepare_page_matchers
      @parsed_data = parse_features
      @page_matchers.each do |page, matcher|
        API.data_cacher.set(page, filter_features_by_page(matcher))
      end
    end
  end

  private

  def filter_features_by_page(matcher)
    res = {}
    res[:features] = Marshal.load(Marshal.dump(@parsed_data[:features])).select do |feature|
      used_feature = false
      feature[:scenarios] = feature[:scenarios].select do |scenario|
        used_scenario = false
        background = scenario[:background]
        background && background[:steps].each do |step|
          if !step[:pre_req] && matcher === step[:name]
            step[:used] = true
            used_scenario = true
            used_feature = true
          end
        end
        scenario[:steps].each do |step|
          if !step[:pre_req] && matcher === step[:name]
            step[:used] = true
            used_scenario = true
            used_feature = true
          end
        end
        used_scenario
      end
      used_feature
    end
    res
  end

  def prepare_page_matchers
    @page_matchers = API.page_identifier.all_pages.sort.reverse.inject({}) do |res, page|
      under_scored_str = page.gsub(/([^\^])([A-Z])/,'\1 \2').downcase
      res[page] = /#{Regexp.escape(under_scored_str)}:?\s*\z/i
      res
    end
  end

  def smart_chdir
    dir = Dir.pwd
    Dir.chdir API.settings.path_to_source
    yield
    Dir.chdir dir
  end

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
        steps: set_pre_req_or_no(parse_steps(feature_element))
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

  def set_pre_req_or_no(steps)
    last_prereq = false
    steps.map do |step|
      new_keyword = step[:keyword].to_s.upcase.strip
      if new_keyword == 'GIVEN' || (last_prereq && new_keyword == 'AND')
        step[:pre_req] = true
        last_prereq = true
      else
        last_prereq = false
      end
      step
    end
  end
end

module API
  def self.cucumber_parser
    @cp ||= CucumberParser.instance
  end
end