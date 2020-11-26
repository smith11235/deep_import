Gem::Specification.new do |s|
	s.name        = "deep_import"
	s.version     = "0.0.1" 
	s.authors     = ["Michael Smith"]
	s.email       = ["smith11235@gmail.com"]
	s.homepage    = "http://github.com/smith11235"
	s.summary     = "Batch import logic for nested models"
  s.description = "Build many nested models in memory. With standard active record code. Load them efficiently with {Model Type Count} transactions instead of {instance count} transactions."

	s.add_development_dependency "rspec"
	s.add_dependency "colorize"

	s.add_dependency "activerecord-import"
  s.add_dependency "rake"
  s.add_dependency "activesupport"

  # for database handling
	s.add_dependency "activerecord"
  # one of mysql2 / pg - currently does not support sqlite

	s.files        = Dir.glob("lib/deep_import/*") + %w(lib/deep_import.rb)
	s.require_path = 'lib'

end
