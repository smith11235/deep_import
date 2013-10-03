class FamilyController < ApplicationController
	
	
	# for easily viewing markdown files in development
	def markdown
		@file = params[:file]
	end

  def index
		@fields = { :mode => "Import Mode", :parents => "# of Parents", :children => "# of Children", :grand_children => "# of GrandChildren", :total_time => "Total Time", :elapsed_time => "Elapsed Time" }
		
		lines = File.open( "public/benchmarks_30.dat", "r" ).readlines
		@benchmarks = lines.collect do |line|
			fields = Hash.new
			mode_regex = /^(Deep Import|Standard Rails)/
			fields[:mode] = line[ mode_regex ]
			
			line.gsub!( /^.*\[/,'' )

			parent_regex = /^\d+/
			fields[:parents] = line[parent_regex].to_i
			line.gsub!(/^\d+\|\|/,'')
			child_regex = /^\d+/
			fields[:children] = line[child_regex].to_i
			line.gsub!(/^\d+\|\|/,'')
			grand_child_regex = /^\d+/
			fields[:grand_children] = line[grand_child_regex].to_i
			line.gsub!(/^\d+\]/,'')

			fields[:total_count] = fields[:parents] + fields[:children] + fields[:grand_children]

			times = line[/\d+\.\d+\s\(\s*\d+\.\d+\)$/]
			fields[:total_time] = times[/^\d+\.\d+/].to_f
			fields[:elapsed_time] = times[/\d+\.\d+\)$/].gsub(/\)/,'').to_f

			fields
		end

		@elapsed_times = Hash.new # model-count => times-hash
		@benchmarks.each do |benchmark|
			@elapsed_times[ benchmark[:total_count] ] ||= Hash.new

			if benchmark[:mode] =~ /Deep\sImport/
				@elapsed_times[ benchmark[:total_count] ][ :deep_import ] = benchmark[:elapsed_time]
			else
				@elapsed_times[ benchmark[:total_count] ][ :standard_rails ] = benchmark[:elapsed_time]
			end
		end
		
  end
end
