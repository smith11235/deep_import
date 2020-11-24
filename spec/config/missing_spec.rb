require 'spec_helper'

describe 'DeepImport::Config - Missing API' do

	before( :all ) do
		DeepImport.logger ||= DeepImport.default_logger # TODO: this needed here?
    DeepImport.initialize! reset: true
	end
  after(:all) do
    $deep_import_config = nil
  end

  it "missing file" do
    ENV["DEEP_IMPORT_CONFIG"] = "fake_file.yml"
	  c = DeepImport::Config.new
		expect(c.valid?).to be false
		expect(c.models.empty?).to be true
  end

  it "bad config classes" do
    $deep_import_config = [ Parent, Child, GrandChild ]
	  c = DeepImport::Config.new
		expect(c.valid?).to be false
		expect(c.models.empty?).to be true
  end

  it "allows execution - no special logic" do 
    expect(Parent.create.id).to be_present
  end

  it "does not allow access to deep import" do
    pending # TODO: improved ModelLogic
    Child.new.deep_import_child = DeepImportChild.new
    # expect error to be raised - no belongs to defined
  end

end
