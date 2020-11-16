ActiveRecord and other ORM's are great for ease of code writing and reading.
But typically slow for bulk data loading.

Deep Import lets you use standard code, 
to upload bulk data, with nested relations,
in a fraction of the time.

The tradeoff is some extra in memory, and db space, temporarily used.

### Usage Example

Code Example: [lib/tasks/example.rake](lib/tasks/example.rake)

For the above example 
* with ~1500 instances loaded
  * Parent has many Children has many Grand Children
* "normal" code takes ~10 seconds
* "Deep Import" takes ~1 second

#### Example Code

Create a set of nested data models. Finance models, or web scraping, etc.

```
    limit = (ENV["limit"] || "10").to_i
    (0..limit).each do |parent_number|
      parent = Parent.new name: SecureRandom.hex
      (0..limit).each do |child_number|
        child = Child.new name: SecureRandom.hex, parent: parent
        (0..limit).each do |grandchild_number|
          grandchild = GrandChild.new name: SecureRandom.hex, child: child
        end
      end
    end
```


### Setup:

* Intall gem
  * `gem deep_import`
* Add config file defining importable models:
  * [config/deep_import.yml](config/deep_import.yml)
* Setup code files, and database migration (index tables required)
  * `rake deep_import:setup`

# Outdated Below - Rewrite/Update
### Outdated Setup Example 
Refactor/rewrite.

[Usage Example](https://gist.github.com/smith11235/7281601)

### To Develop 
Note: need to break gem out from rails example app.
#### Gem

```
deep_import.gemspec
lib/deep_import
```

#### WIKI
* [WIKI-Home](http://www.github.com/smith11235/deep_import/wiki/Home)
	* full readme
	* api
	* architecture
	* tutorial

#### Presentation
_TODO: outdated - replace_
[Deep Import Presentation](http://twostepsleftofnormal.com:31234) 
built with: 
[Impress.js](https://github.com/bartaz/impress.js)

* to develop presentation
	* edit IMPRESS.md within wiki/
	* execute ```rake impress```
		* to regenerate **app/views/impress/index.html.erb**
  * ```git clone https://github.com/smith11235/deep_import.wiki.git wiki```
