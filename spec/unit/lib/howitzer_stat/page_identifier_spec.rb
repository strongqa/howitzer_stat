require 'spec_helper'
require "#{lib_path}/howitzer_stat/page_identifier.rb"

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
    context "when url and title present"
    context "when test page"
    context "when real page"
  end
end