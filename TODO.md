---
RC1:
- API.md: done, just review

- correct enabling/disabling logic
	- correct specs
	- make it disabled by default

- TUTORIAL.md
	- all using Parent, Child, GrandChild
	- build with code in rails app
	- formats:
		- belongs_to: solid
		- dfs: unsafe but cool
			- will be deprecated when api fully supported

- better README linking to things
	- meant as quick description and show off
	- provide reference to TUTORIAL and API

- benchmark profiling of many inputs, record outputs
- view: display and explain benchmarks
- view: family???


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
