require 'spec_helper'

describe 'valid_config' do
	before( :all ) { ConfigHelper.new.valid_config }

	[Parent,Child,GrandChild].each {|model| it "should have #{model} included" }

	belongs_to_associations = { Child => [ Parent ], GrandChild => [ Child ] }
	belongs_to_associations.each do |child,parent|
		it "#{child} should belong to #{parent}" 
	end

end
