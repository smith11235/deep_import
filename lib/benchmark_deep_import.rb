require 'benchmark'

class BenchmarkDeepImport

	def deep_import_disabled?
		@deep_import_disabled if @checked
		@deep_import_disabled = DeepImport.railtie_disabled?
		@checked = true
		@deep_import_disabled
	end

	def import_method
		deep_import_disabled? ? 'Standard Rails' : 'Deep Import'
	end

	def benchmark( range )
		puts "Running benchmark(#{range})".green

		delete_models # so the database is empty each run

		benchmark_output = "#{import_method}[#{range}||#{range*range}||#{range*range*range}] #{Benchmark.measure { import(range) } }"

		File.open( "tmp/benchmarks.dat", "a" ){|f| f.puts benchmark_output}
	end

	private
	# for clearing out the tables between each benchmarking measurement
	def delete_models 
		GrandChild.delete_all
		Child.delete_all
		Parent.delete_all
		DeepImportGrandChild.delete_all
		DeepImportChild.delete_all
		DeepImportParent.delete_all
	end

	def import( range )
		puts "Running #{import_method} Benchmark Of #{range*range*range} Models"
		# disabled:
		# - for each live with 'disabled'
		#   - if disabled: we're in standard rails mode, deep import is disabled
		#   - unless disabled: we're in deep import mode
		# This example is meant to show the interchangability of DeepImport/Normal code
		(0..range).each do |parent_name|
			parent = Parent.new( :name => parent_name.to_s ) # new, or build, not create
			parent.save! if deep_import_disabled?
			(0..range).each do |child_name|
				child = Child.new( :name => child_name.to_s )
				child.parent = parent
				child.save! if deep_import_disabled?
				(0..range).each do |grand_child_name|
					grand_child = GrandChild.new( :name => grand_child_name.to_s )
					grand_child.child = child
					grand_child.save! if deep_import_disabled?
				end
			end
		end
		# then save all models from the cache unless Deep Import was deep_import_disabled
		DeepImport.commit unless deep_import_disabled? # save all models to database
	end
end
