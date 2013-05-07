module DeepImport

	def self.commit
		puts "Commiting".red
		Commit.new
	end

	class Commit
		def initialize
			DeepImport::ModelsCache.show_stats
			@cache = DeepImport::ModelsCache.get_cache
		end

	end

end
