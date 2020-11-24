require 'spec_helper'

describe 'DeepImport::Config - General API' do
  # before :all
  #   ConfigHelper.new.valid_config 

  it "is valid when loaded" do
		DeepImport::Config.new.should be_valid
	end

  let!(:config) do
    DeepImport::Config.new
    DeepImport::Config
  end

	it "importable class list" do
		config.importable.should =~ [Parent, Child, GrandChild]
	end

	it "belongs_to relations" do
    config.belongs_to(Child).should =~ [:parent]
    config.belongs_to(GrandChild).should =~ [:child]
    config.belongs_to(Parent).should =~ []
	end

  it "has_many relations" do
    config.has_many(Parent).should =~ [:children]
    config.has_many(Child).should =~ [:grand_children]
    expect(config.has_many(GrandChild)).to be_nil # TODO: []
  end

end
