require 'benchmark_deep_import.rb'
def construct_and_return_tasks 
	# collect the list of tasks if benchmark_deep_import is called
	task_list = if ENV["RANGE"] # everything depends on if this is set 
								benchmark_range = ENV["RANGE"]
								raise "Invalid BENCHMARK_RANGE, expecting an integer, not '#{benchmark_range}'" unless benchmark_range =~ /^\d+$/
								benchmark_range = benchmark_range.to_i # convert it to an integer
								puts "Benchmark Range: #{benchmark_range}"
								[ :environment ] + generate_benchmark_tasks( benchmark_range )
							else
								[:usage] 
							end
	task_list
end

def generate_benchmark_tasks( range )
	# collect the statistics from 1 - benchmark_range
	(1..range).collect { |range| generate_task_for_range( range ) }
end

def generate_task_for_range( range )
	task_name = "benchmark_deep_import_#{range}".to_sym

	task task_name do
		puts "Running: #{task_name}"
		BenchmarkDeepImport.new.benchmark( range )
	end

	task_name
end


# construct and return the list of tasks to be run if benchmarking is executed
task_list = construct_and_return_tasks

desc "Run Benchmark testing for deep import"
task :benchmark => task_list do
	puts "Check Out: tmp/benchmarks.yml"
end

task :usage do
	puts 
	puts "Usage:"
	puts
	puts "rake benchmark RANGE=INTEGER"
	puts "- RANGE = profile from 1..RANGE"
	puts "  Parents x Children x Grandchildren = RANGE + RANGE^2 + RANGE^3 models loaded"
	puts
end

task :enable_benchmarking do
	ENV["ENABLE_DEEP_IMPORT_BENCHMARK"] = "1"
end
