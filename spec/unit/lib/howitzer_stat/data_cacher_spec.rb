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

end

describe "HowitzerStat" do
  describe ".data_cacherr" do
    subject { HowitzerStat.data_cacher }
    it { expect(subject.object_id).to eql(HowitzerStat.data_cacher.object_id)}
    it { expect(subject).to be_a(HowitzerStat::DataCacher) }
  end
end
