Gem::Specification.new do |s|
	s.name        = "deep_import"
	s.version     = "0.0.1" 
	s.authors     = ["Mike Smith"]
	s.email       = ["smith11235@gmail.com"]
	s.homepage    = "http://github.com/smith11235"
	s.summary     = "Batch import logic for nested models"
	s.description = "Build up many models, load them in a minimal number of transactions."

	s.add_development_dependency "rspec"
	s.add_dependency "colorize"
	s.add_dependency "activerecord-import"

	s.files        = Dir.glob("lib/deep_import/*") + %w(lib/deep_import.gemspec)
	s.require_path = 'deep_import'

end
