require 'spec_helper'

describe 'DeepImport::Config - General API' do
  before(:each) do
    DeepImport::Config.new
  end

  it "is valid when loaded" do
		DeepImport::Config.new.should be_valid
	end

	it "importable class list" do
		DeepImport::Config.importable.should =~ [Parent, Child, GrandChild]
	end

	it "belongs_to relations" do
    DeepImport::Config.belongs_to(Child).should =~ [:parent]
    DeepImport::Config.belongs_to(GrandChild).should =~ [:child]
    DeepImport::Config.belongs_to(Parent).should =~ []
	end

  it "has_many relations" do
    DeepImport::Config.has_many(Parent).should =~ [:children]
    DeepImport::Config.has_many(Child).should =~ [:grand_children]
    expect(DeepImport::Config.has_many(GrandChild)).to be_nil # TODO: []
  end

end
