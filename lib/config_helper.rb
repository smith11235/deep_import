class ConfigHelper

	@@config_file = 'config/deep_import.yml'

	def valid_config
		config = { 
			'Parent' => nil,
			'Child' => { 'belongs_to' => 'Parent' },
			'GrandChild' => { 'belongs_to' => [ 'Child' ] }
		}
		File.open( @@config_file, 'w' ) {|f| f.puts config.to_yaml }
	end

	def remove_config
		FileUtils.rm( @@config_file ) if File.file? @@config_file
	end

end
