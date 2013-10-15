Method Overriding
=================
- how to override instance.other=
- alias_method_chain


Config Reformat
===============
* flesh out specs

DeepImport.import
=================
* add specs
* correct model_cache and other specs

* Options are supported for tuning the import logic as you wish
	* enable/disable: validations, save/create method handling
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
