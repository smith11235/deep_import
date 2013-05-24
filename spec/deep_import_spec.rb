require 'spec_helper'

describe "Example" do

	it "should say hello" do 
		"Hello".should == "hello"
	end

end

describe Config do

	it "should say hello" do
		"Hello".should =~ /hello/i
	end

end
