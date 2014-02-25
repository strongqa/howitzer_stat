require 'spec_helper'
require "#{lib_path}/howitzer_stat/page_identifier.rb"
#

describe "HowitzerStat::PageIdentifier" do
  let(:pi) { HowitzerStat::PageIdentifier.instance }
describe "#all_pages" do
  subject { pi.all_pages }
  before { pi.instance_variable_set(:@validations, validations) }
  context "when empty validations" do
    let(:validations) { {} }
    it { expect(subject).to eql([])}
  end
  context "when validations present" do
    let(:validations) do
      {
          "Test1Page" => { url: /test1/, title: 'Test1 page' },
          "Test2Page" => { url: /test2/, title: 'Test2 page' }
      }
    end
    it { expect(subject).to eql(['Test1Page', 'Test2Page']) }
  end
end
#def identify_page(url, title)
#  raise ArgumentError, "Url and title can not be blank. Actual: url=#{url}, title=#{title}" if url.nil? || url.empty? || title.nil? || title.empty?
#  return [test_page(url)] if test_page?(url, title)
#  @validations.inject([]) do |res, (page, validation_data)|
#    is_found = case [!!validation_data[:url], !!validation_data[:title]]
#                 when [true, true]
#                   validation_data[:url] === url && validation_data[:title] === title
#                 when [true, false]
#                   validation_data[:url] === url
#                 when [false, true]
#                   validation_data[:title] === title
#                 when [false, false]
#                   raise NoValidationError, "No any page validation was found for '#{page}' page"
#                 else nil
#               end
#    res << page if is_found
#    res
#  end
#end

describe "#identify_page" do
  subject { pi.identify_page(url, title) }
  context "when url or title missing" do
    context "when url nil" do
      let(:url) { nil }
      let(:title) {'test_title' }
      it { expect{ subject }.to raise_error(ArgumentError, "Url and title can not be blank. Actual: url=#{url}, title=#{title}") }
    end
    context "when url empty" do
      let(:url) {''}
      let(:title) { 'test_title' }
      it { expect{ subject }.to raise_error(ArgumentError, "Url and title can not be blank. Actual: url=#{url}, title=#{title}") }
    end
    context "when title nil" do
      let(:url) {'http://some-url.com'}
      let(:title) { nil }
      it { expect{ subject }.to raise_error(ArgumentError, "Url and title can not be blank. Actual: url=#{url}, title=#{title}") }
    end
    context "when title empty" do
      let(:url) { 'http://some-url.com' }
      let(:title) { '' }
      it { expect{ subject }.to raise_error(ArgumentError, "Url and title can not be blank. Actual: url=#{url}, title=#{title}") }
    end
  end
  context "when url and title present" do
    context "when test page" do
      let(:url) { '/test?page=Test1Page' }
      let(:title) { 'HowitzerStat' }
      #let(:validations) do
      #  {
      #      "Test1Page" => { url: /test1/, title: 'Test1 page' },
      #      "Test2Page" => { url: /test2/, title: 'Test2 page' }
      #  }
      #end
      it { expect(subject).to eq('Test1Page') }
    end
    context "when real page" do

    end
  end
end
end