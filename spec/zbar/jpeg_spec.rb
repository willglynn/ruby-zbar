require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ZBar::JPEG do
  subject { described_class }
  
  describe "available?" do
    specify "should be a boolean" do
      (!!subject.available?).should == (subject.available?)
    end

    specify "should memoize the result" do
      result = Object.new
      subject.instance_variable_set(:@available, result)
      subject.available?.should == result
    end
  end

  describe "bugged?" do
    specify "should be a boolean" do
      (!!subject.bugged?).should == (subject.bugged?)
    end
    
    specify "should memoize the result" do
      result = Object.new
      subject.instance_variable_set(:@bugged, result)
      subject.bugged?.should == result
    end
    
    specify "should be false if JPEG support is unavailable" do
      subject.instance_variable_set(:@bugged, nil)
      subject.should_receive(:available?).and_return(false)
      subject.bugged?.should == false
    end
  end
end
