Specs Rewrite
=============
Move logger to '#{Rails.env}_deep_import.log'
DeepImport.import
# move :import_options to DeepImport.settings

RC1 DeepImport.import
=====================
* Options are supported for tuning the import logic as you wish
	* override belongs_to.create_other(!)
		* reroute to build_other 
			:on_belongs_to_create_other => :build # :raise_error is default
	* override belongs_to.build_other
* option defaults should be through first:

* replan specs
* remake specs
* impress.js
* blog post

### View
* view: 
	* family/benchmarks
		* upgrade to data tables
		* chart

other
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
