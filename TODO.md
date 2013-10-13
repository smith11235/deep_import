How to Restart
==============

Config Reformat
===============
* use config/deep_import.yml
* parse it from yaml to ruby
* reformat it so that:
	- each Model entry was a class name constant
	- each Model mapped to a Hash:
	  - each Hash has a :belongs_to Array
			- each entry is a ClassName constant

* requires updates to lib/deep_import/config.rb
* requires updates to specs/deep_import_config/config_spec.rb
* find all references to config
	* parse the config in Railtie
		* startup validation and alerting of config issues

### Top Level Format:
* Identifies models of interest to DeepImport
* Hash of model names in CamelCase format
	* must match .singularize.camelcase

### Model Def Format
* Identifies associations this model has with regards to import logic
* Hash of has_many, has_one, belongs_to entries
	* model name, or array of model names

### Testing:
* no config file: 
	* railtie does nothing
* junk config file
	* railtie raises error
* Hash of:
	* key: string, camelcase, singular
	* value: hash of:
		* if nil/empty, just enable for deep import tracking
		* key: string, allowed: belongs_to
		* value: array or single string of:
			* camelcase, singular name

API Change
==========
### General
* disabled by default
* railtie executes
	* loads initial config if present
	* sets deep_import status
		* ready_for_import
		* error

### Invoking an Import block
* DeepImport environment modifications are only active inside these blocks
* This api is meant to flag to a user that the following code is special
* Options are supported for tuning the import logic as you wish
	* enable/disable: validations, save/create method handling
* Commits of the models are made after the block is executed
	 
    DeepImport.import( { 
												:on_save => :noop, # :raise_error is default
												:on_create => :build # :raise_error is default
											}
				) {
						parent = Parent.new	
					}


RC1:
===

## Presentation in impress.js

## ARCHITECTURE.md
  * show how the algorithm works

View
-----
* view: 
	* family/benchmarks
		* upgrade to data tables
		* chart


---
- remove dfs logic when api fully supported
- develop support for has_many
	- follow progress in API.md
- save: raise error, or print warning silently depending on setting
	- nested construction:
	- child = parent.children.build
	- hook into has_many/one association helpers
	- call belongs_to logic

- child = parent.children.create 
- call build
					- override method definition on model

			- http://errtheblog.com/posts/18-accessor-missing
			- metaprogramming: http://yehudakatz.com/2009/11/15/metaprogramming-in-ruby-its-all-about-the-self/

---
Teardown:
	- add specs for it

---
batch id as part of deep_import_id field:
- get a process id
- set deep_import_id = "#{process_id}.#{id}"
- commit: scope all queries to this process_id prefix

---
Model Flags:
_polymorphic:

---
Config File:
	- spec: 
		- test for invalid config files
		- test for missing config file
