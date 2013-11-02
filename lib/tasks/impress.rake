desc "Generate public/impress/index.html from public/impress.md"
task :impress => :environment do
	
	slides = get_slides

	# generate app/views/impress.html.erb
	output_file = "app/views/impress/index.html.erb"
	File.open( output_file, "w" ) do |f|

		f.puts header_content

		slides.each do |slide|
			f.puts step_header
			
			markdown = Redcarpet.new( slide )
			f.puts markdown.to_html

			f.puts "</div>"
		end

		f.puts footer_content
	end

end

def default_position
	$x ||= 0 
	defaults = { :x => $x, :y => 0, :z => 0, :scale => 1, :rotate_x => 0, :rotate_y => 0, :rotate_z => 0 }
	$x += 1000
	defaults
end

def step_header( position = {} )
	position.reverse_merge! default_position 

	header = "<div class='step' "
	position.each do |key,value|
		header << "data-#{key.to_s.gsub(/_/,"-")}='#{value}' "
	end
	header << ">"
	
	return header
end

def get_slides
	source_file = "wiki/IMPRESS.md"
	raise "Missing #{source_file}" unless File.file? source_file
	
	lines = File.open( source_file, "r" ).readlines

	slides = Array.new

	current_slide = nil 
	lines.each do |line|
		line.chomp!
		# each H1 started with # is a new slide 
		if line =~ /^#\s\S+/
			slides << current_slide unless current_slide.nil? 
			current_slide = ""
		end
		current_slide << line + "\n"
	end
	
	slides
end

def header_content
	'
<p><b>Left(back)</b> and <b>Right(forward)</b> arrow keys move the slideshow</p>
<script type="text/javascript" src="../impress.js" ></script>
<div id="impress" >
	'	
end

def footer_content
	'</div>'
end