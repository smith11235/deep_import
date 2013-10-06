class ConfigHelper

	def valid_config
		config = { 
			'Parent' => nil,
			'Child' => { 'belongs_to' => 'Parent' },
			'GrandChild' => { 'belongs_to' => [ 'Child' ] }
		}
		File.open( 'config/deep_import.yml', 'w' ) {|f| f.puts config.to_yaml }
	end

	def missing_config
		FileUtils.rm( 'config/deep_import.yml' )
	end

end
