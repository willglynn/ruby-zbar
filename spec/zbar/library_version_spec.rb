require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ZBar::LibraryVersion do
  let(:major) { 10 }
  let(:minor) { 99 }
  let(:library_version) { described_class.new(major, minor) }
  subject { library_version }
  
  its(:major) { should be_kind_of Fixnum }
  its(:minor) { should be_kind_of Fixnum }
  
  describe "to_s" do
    subject { library_version.to_s }
    it { should be_kind_of String }
    it "is formatted as major.minor" do
      should == "#{major}.#{minor}"
    end
  end
  
  describe "comparisons" do
    let(:bigger_major) { described_class.new(major + 1, minor)}
    let(:bigger_minor) { described_class.new(major, minor + 1)}
    let(:equal) { described_class.new(major, minor)}
    
    it { should be_kind_of Comparable }
    
    it "compares minors" do
      library_version.should < bigger_minor
      bigger_minor.should > library_version
    end
    it "compares majors" do
      library_version.should < bigger_major
      bigger_major.should > library_version
    end
    it "compares equally" do
      library_version.should == equal
      equal.should == library_version
    end
  end
end
