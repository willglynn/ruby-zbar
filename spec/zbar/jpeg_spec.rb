require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ZBar::JPEG do
  subject { described_class }
  
  describe "available?" do
    specify "should be a boolean" do
      expect(!!subject.available?).to eq(subject.available?)
    end

    specify "should memoize the result" do
      result = Object.new
      subject.instance_variable_set(:@available, result)
      expect(subject.available?).to eq(result)
    end
  end

  describe "bugged?" do
    specify "should be a boolean" do
      expect(!!subject.bugged?).to eq(subject.bugged?)
    end
    
    specify "should memoize the result" do
      result = Object.new
      subject.instance_variable_set(:@bugged, result)
      expect(subject.bugged?).to eq(result)
    end
    
    specify "should be false if JPEG support is unavailable" do
      subject.instance_variable_set(:@bugged, nil)
      expect(subject).to receive(:available?).and_return(false)
      expect(subject.bugged?).to eq(false)
    end
  end
end
