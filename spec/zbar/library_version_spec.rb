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
    it { is_expected.to be_kind_of String }
    it "is formatted as major.minor" do
      is_expected.to eq("#{major}.#{minor}")
    end
  end
  
  describe "comparisons" do
    let(:bigger_major) { described_class.new(major + 1, minor)}
    let(:bigger_minor) { described_class.new(major, minor + 1)}
    let(:equal) { described_class.new(major, minor)}
    
    it { is_expected.to be_kind_of Comparable }
    
    it "compares minors" do
      expect(library_version).to be < bigger_minor
      expect(bigger_minor).to be > library_version
    end
    it "compares majors" do
      expect(library_version).to be < bigger_major
      expect(bigger_major).to be > library_version
    end
    it "compares equally" do
      expect(library_version).to eq(equal)
      expect(equal).to eq(library_version)
    end
  end
end
