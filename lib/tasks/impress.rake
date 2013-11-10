desc "Generate public/impress/index.html from public/impress.md"
task :impress => :environment do
	
	slides = get_slides

	# generate app/views/impress.html.erb
	output_file = "app/views/impress/index.html.erb"
	File.open( output_file, "w" ) do |f|

		f.puts header_content

		position = Positioner.new
		slides.each do |slide|
			f.puts step_header( position.next_position )
			
			markdown = Redcarpet.new( slide )
			f.puts markdown.to_html

			f.puts "</div>"
		end

		f.puts footer_content
	end

end

task :math do
	positioner = Positioner.new
	(0..10).each do 
		puts positioner.next_position.to_yaml
	end
end

class Positioner 
	def initialize
		@x = 0
		@y = 0
		@z = 0
		@rotate_y = 0
		@coordinates_scale = 1500
		@increment_amount = 0.5
	end

	def cscale( value )
		@coordinates_scale * value
	end

	def next_position
		increment_position

		{ :x => cscale( @x ), :y => cscale( @y ), :z => cscale( @z ), :scale => 1, :rotate_x => 0, :rotate_y => @rotate_y, :rotate_z => 0 }
	end

	def increment_position
		@y -= @increment_amount
		@x = Math.sin( @y )
		@z = Math.cos( @y )

		# now find the rotate_y value using 
		# - the distance formula
		# - the law of cosines
		# C = rotate y (see wikipedia)

		c_point = [0,0]
		b_point = [@x,@z]
		a_point = [1,0]

		c_dist = distance( *a_point, *b_point)
		b_dist = distance( *a_point, *c_point)
		a_dist = distance( *c_point, *b_point)

		@rotate_y = law_of_cosines( c_dist, b_dist, a_dist )
	end

	def law_of_cosines( c, b, a )
		# returns the angle C opposite side c
		to_degrees Math.acos( ( square( a ) + square( b ) - square( c ) ) / (2*a*b) )
	end

	def to_degrees( radians )
		( radians * 180 ) / Math::PI
	end

	def distance( x1, y1, x2, y2 )
		Math.sqrt( square( x2 - x1 ) + square( y2 - y1 ) )
	end

	def square( x )
		x * x
	end
end

def step_header( position )
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