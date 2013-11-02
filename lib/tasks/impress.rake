desc "Generate public/impress/index.html from public/impress.md"
task :impress => :environment do
	source_file = "wiki/IMPRESS.md"
	raise "Missing #{source_file}" unless File.file? source_file
	
	# parse it, each H1 started with # is a new slide 

	# load slide contenst through redcarpet

	# generate app/views/impress.html.erb

end