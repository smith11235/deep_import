desc "Example Deep Import"
task :example => :environment do

	DeepImport.import do
		(0..29).each do |parent_number|
      parent = Parent.new name: SecureRandom.hex
			(0..29).each do |child_number|
				child = Child.new name: SecureRandom.hex
				child.parent = parent
				(0..29).each do |grandchild_number|
					grandchild = GrandChild.new name: SecureRandom.hex
					grandchild.child = child
				end
			end
		end
	end
end
