require 'spec_helper'
require "#{lib_path}/howitzer_stat/page_identifier"

describe "HowitzerStat::PageIdentifier" do
  let(:pi) { HowitzerStat::PageIdentifier.instance }
  before { pi.instance_variable_set(:@validations, validations) }
  describe "#all_pages" do
    subject { pi.all_pages }
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

  describe "#identify_page" do
    subject { pi.identify_page(url, title) }
    context "when url or title missing" do
      let(:validations) { {} }
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
      let(:validations) do
        {
          "Test1Page" => { url: /test1/, title: 'Test1 page' },
          "Test2Page" => { url: /test2/, title: 'Test2 page' }
        }
      end
      context "when real page" do
        context "when title and url match" do
          let(:url) { "http://test.com/test1/index.html" }
          let(:title) {'Test1 page' }
          it { expect(subject).to eql(["Test1Page"]) }
        end
        context "when title match and url does not" do
          let(:url) { "http://test.com/test3/index.html" }
          let(:title) {'Test1 page' }
          it { expect(subject).to eql([]) }
        end
        context "when title does not match and url do" do
          let(:url) { "http://test.com/test1/index.html" }
          let(:title) {'Test3 page' }
          it { expect(subject).to eql([]) }
        end
      end
      context "when test page" do
        let(:url) { "http://test.com/test?page=#{page}" }
        let(:title) { 'HowitzerStat' }
        context "when page present" do
          let(:page) { "Test1Page" }
          it { expect(subject).to eql(["Test1Page"]) }
        end
        context "when page absent" do
          let(:page) { "Test3Page" }
          it { expect(subject).to eql([]) }
        end
      end
    end
  end

  describe "#parse_pages"
end

describe "HowitzerStat" do
  describe ".page_identifier" do
    subject { HowitzerStat.page_identifier }
    it { expect(subject.object_id).to eql(HowitzerStat.page_identifier.object_id)}
    it { expect(subject).to be_a(HowitzerStat::PageIdentifier) }
  end
end