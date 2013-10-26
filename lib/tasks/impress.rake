desc "Generate public/impress/index.html from public/impress.md"
task :impress => :environment do

	Dir.chdir "public" do

		system("mdpress impress.md" )

	end

end