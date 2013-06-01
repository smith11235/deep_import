require 'spec_helper'

describe "DeepImport::Commit" do
=begin
		- commit
			- load models like in cache
			- run commit:
				- cache should be size=0
				- deep_import_id is null
				- no deep_import models

				- there should be X models in the db instead
				- with correct number of linkages
				- use names to ensure everyone is properly associated
=end
end
