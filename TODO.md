---
RC1:
* view: 
	* family/benchmarks
		* upgrade to data tables
		* chart

	* ARCHITECTURE.md
	  * show how the algorithm works

	* Deep Import Control:

	  * disabled by default
		* if railtie enabled:
		  * modify models
	    * deep_import model caching is still disabled

		* when DeepImport.import { } called:
			* enable caching
			* call block
			* load cache when block returns

	* instead of config file:
	  * extend activerecord::base using a module
		  * add deep_import_belongs_to :parent ?
				- extend the class
				- adding a new method to activerecord::base

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
