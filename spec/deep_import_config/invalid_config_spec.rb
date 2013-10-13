require 'spec_helper'
describe "Invalid/Corrupt config/deep_import.rb Provided" do

	describe "Bad Models Hash definition" do
		it "should fail if root not a Hash"
		it "should fail if keys arent Strings"
		it "should fail if keys arent in SingularClassName format"
		it "should fail if value isnt nil or Hash"
	end
	
	describe "Bad Model Hash definition" do
		it "should fail if keys have anything other than 'belongs_to'"
		it "should fail if values are anything other than String or Array"
		it "should fail if value entries are anything but String SingularClassNames"
	end

end
