RC1 DeepImport.import
=====================

### WIKI
move *.md to wiki

### Specs Rewrite
* SPECS.md
	* provide filelisting and purpose in lib/deep_import*
	* add written specs for each
* create actual spec/*

### option enhancement
import_options: :on_belongs_to_create_other => :build # :raise_error is default
	* override belongs_to.build_other
	* option defaults should be through first:



Other
=====

### Impress.js
* impress.js in gh-pages
purpose
example
benefits
cons

### View
* family/benchmarks
	* upgrade to data tables
	* chart
		* http://errtheblog.com/posts/18-accessor-missing
		* metaprogramming: http://yehudakatz.com/2009/11/15/metaprogramming-in-ruby-its-all-about-the-self/

### Teardown specs

### batch id as part of deep_import_id field:
* get a process id
* set deep_import_id = "#{process_id}.#{id}"
* commit: scope all queries to this process_id prefix


### _polymorphic:

