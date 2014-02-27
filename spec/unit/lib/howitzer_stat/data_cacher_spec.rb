require 'spec_helper'
require "#{lib_path}/howitzer_stat/data_cacher"

describe "HowitzerStat::DataCacher" do
  let(:dc) { HowitzerStat::DataCacher.instance }
  let(:data) { dc.instance_variable_get(:@data) }
  let(:empty_hash) { Hash.new({})}
  before { dc.instance_variable_set(:@data, {cucumber: empty_hash, rspec: empty_hash}) }
  describe "constructor" do
    it { expect(data).to eql({cucumber: {}, rspec: {}}) }
    it { expect(data[:cucumber][:a]).to eql({}) }
    it { expect(data[:rspec][:a]).to eql({}) }
  end

  describe "#empty_cucumber" do
    subject { dc.empty_cucumber }
    before do
      data[:cucumber][:a] = 1
      data[:cucumber][:b] = 2
    end
    it do
      subject
      expect(data[:cucumber]).to eql({})
    end
    it { expect(subject).to eql({}) }
    it do
      subject
      expect(data[:cucumber][:a]).to eql({})
    end
  end

  describe "#empty_rspec" do
    subject { dc.empty_rspec }
    before { data[:rspec] = {a: 1, b: 2} }
    it do
      subject
      expect(data[:rspec]).to eql({})
    end
    it { expect(subject).to eql({}) }
    it do
      subject
      expect(data[:rspec][:a]).to eql({})
    end
  end

  describe "#page_cached?" do
    subject { dc.page_cached?(*args) }
    before do
      data[:cucumber]['TestPage1'] = double
      data[:rspec]['TestPage2'] = double
    end
    context "when 'type' specified" do
      let(:args) { [page_name, :rspec ] }
      context "when class is symbol" do
        context "when page is cached" do
          let(:page_name) { :TestPage2 }
          it { expect(subject).to be_true }
        end
        context "when page is not cached" do
          let(:page_name) { :TestPage3 }
          it { expect(subject).to be_false }
        end
      end
      context "when class is string" do
        context "and class name is empty" do
          let(:page_name) { '' }
          it { expect(subject).to be_false }
        end
        context "and class name is not empty" do
          let(:page_name) { 'TestPage2' }
          it { expect(subject).to be_true }
        end
      end
      context "when class is nil" do
        let(:page_name) { nil }
        it { expect(subject).to be_false }
      end
      context "when class is ruby class" do
        let(:page_name) do
           Class.new do
             def self.to_s
               'TestPage2'
             end
           end
        end
        it { expect(subject).to be_true }
      end
    end
    context "when 'type' default" do
      let(:args) { [page_name ] }
      context "when class is symbol" do
        context "when page is cached" do
          let(:page_name) { :TestPage1 }
          it { expect(subject).to be_true }
        end
        context "when page is not cached" do
          let(:page_name) { :TestPage4 }
          it { expect(subject).to be_false }
        end
      end
    end
  end

end

describe "HowitzerStat" do
  describe ".data_cacherr" do
    subject { HowitzerStat.data_cacher }
    it { expect(subject.object_id).to eql(HowitzerStat.data_cacher.object_id)}
    it { expect(subject).to be_a(HowitzerStat::DataCacher) }
  end
end
