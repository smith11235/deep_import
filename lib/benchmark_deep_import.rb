require 'benchmark'
require 'yaml'

class BenchmarkDeepImport

	def benchmark( range )

		[ :deep_import, :standard ].each do |import_method|
			delete_models # so the database is empty each run

			puts "Running benchmark for #{import_method} - #{range}^3 models..." 
			benchmark_data = {
				:import_method => import_method,
				:number_of_parents => range,
				:number_of_children => range * range,
				:number_of_grand_children => range * range * range,
				:total_models_imported => range + range * range + range * range * range,
				:benchmark => "#{Benchmark.measure { import(range,import_method) }}"
			}

			File.open( "tmp/benchmarks.dat", "a" ){|f| f.puts benchmark_data.to_yaml }
		end
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

	def import( range, import_method )
		case import_method
		when :standard
			load_batch_models( range )
		when :deep_import
			DeepImport.import( :on_save => :noop ) { load_batch_models( range ) }
		end
	end

	def load_batch_models( range )
		(0..range).each do |parent_name|
			parent = Parent.new( :name => parent_name.to_s ) # new, or build, not create
			parent.save!
			(0..range).each do |child_name|
				child = Child.new( :name => child_name.to_s )
				child.parent = parent
				child.save!
				(0..range).each do |grand_child_name|
					grand_child = GrandChild.new( :name => grand_child_name.to_s )
					grand_child.child = child
					grand_child.save!
				end
			end
		end
	end
end
