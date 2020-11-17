ActiveRecord and other ORM's are great for ease of code writing and reading.
But typically slow for bulk data loading.

Deep Import lets you use standard code, 
to upload bulk data, with nested relations,
in a fraction of the time.

### Simple Code Example

Full code example: [lib/tasks/example.rake](lib/tasks/example.rake)

* 1 block of code: can be run normally, or with DeepImport
  * `rake example:normal`
  * `rake example:deep_import`
* loads ~1500 models (in 3 nested classes: Parent/Child/Grandchild)
  * **"Normal" execution takes ~10 seconds**
  * **"Deep Import" execution takes ~1 second**
  * larger data set timing is even more pronounced

```
  DeepImport.import do # engages magic
    (0..30).each do |p|
      parent = Parent.new name: SecureRandom.hex
      (0..30).each do |c|
        child = parent.children.build name: SecureRandom.hex
        (0..30).each do |gc|
          child.grand_children.build name: SecureRandom.hex
```

## The Magic
**A classic tradeoff between Speed and Disk Space.**

To achieve faster data loading times, extra server side space is used along with temporary extra records in the db.

### The Culprit
In a standard ORM process, for X model instances to be loaded, there are X insert db queries/network calls. In a web controller, inserting 1 or 2 records due to a users activity, this is trivial, and fast enough.

When loading a large number of models, the network calls add up to significant overhead.

```
(0..10).each do |p|
  Parent.new.save # 10 insert calls executed
end
```

### Bulk Inserts

Rather than committing individual models, new instances are held in memory, server side, until all instances are ready for one bulk insert.

#### Prior Work: ActiveRecord-Import

A gem called ["ActiveRecord-Import"](https://github.com/zdennis/activerecord-import)
provides a simple solution to this problem.

```
parents = []
(0..10).each do |p|
  parents << Parent.new # build all models in memory, limited by server memory
end
Parent.import parents # 1 bulk insert call executed
```

The above code provides a massive boost to speed of execution.

#### Prior Work: The Limits

ActiveRecord-Import does not handle the creation of nested data relations.
This is due to the fact that relationships (primary/foreign key fields) cannot be tracked appropriately on, if the associated instance has not yet been created. 

```
# Faulty code (what Deep Import handles)
parents = []
children = []
(0..10).each do |p|
  parents << Parent.new # build all models in memory, limited by server memory
  (0..10).each do |c|
    children = Child.new parent: parents.last
  end
end
Parent.import parents # 1 bulk insert call executed
Children.import children # 1 bulk insert call executed
```

The above code would "work", but, all of the children would be orphans, as their "parent_id" value would be missing, as none of the parents were tracked.

To get around this, and still have some benefits, all Parents could be created and uploaded, and then all Children could be created and uploaded.

```
# Impractical Code - But works
parents = []
(0..10).each do |p|
  parents << Parent.new # build all models in memory, limited by server memory
end
Parent.import parents # 1 bulk insert call executed

children = []
parents.each do |parent|
  (0..10).each do |c|
    children = Child.new parent: parent
  end
end
Children.import children # 1 bulk insert call executed
```

While the above works, it is not practical in many data loading scenarios.

**Effectively, for "Bulk Data Loads" of nested data relations, a Depth First Traversal of the data is desired, rather than a "Breadth First Traversal".** The "Breadth First" load pattern would create a lot of churn in your system, resulting in a lot of redundant processing overhead.

##### Real Examples

**Financial Data Set - On Companies**
With a data feed of top level entities (say, a Company), where each top level entity can be parsed to obtain its Products, and Metrics, you would want to parse the feed 1 Company at a time, building up all its data, and then move on to the next one. You would not want to parse all "top nodes" (feed files), load them, then all "secondary nodes", load them, and so on. 

**Web Scraping - Aggregating an index**
If a scraper was running, you would want to parse 1 website, and its associated data, then move onto the next website. You would not want to load each website record, then go back and reprocess each website.

### Bulk Data Loading: Nested Data (Deep Import)

Deep Import solves for this real world, complex structures, problem.

To do so, a "shadow" index using "batch process relative" primary/foriegn keys is created.

This is the temporary extra space required to allow bulk inserts at the end of data processing.

Effectively, for each ModelClass to be loaded, there is a secondary table associated to that class. For each ModelClass instance to be loaded, there is a secondary index record to be loaded.

While the ModelClass instance may contain a set of data points/columns, the index table contains only an ID field, and a foreign key field for each "belongs to" relation on that model.

#### Schema/Data Architecture

Each "Importable" ModelClass:

* will have a "deep_import_id" field on its "model_class" table
* there will be a corresponding index table: "deep_import_{model_class}"
  * with matching "deep_import_id" field

* for each "belongs to" {OtherClass} association (foreign key relation) on ModelClass
  * the "deep_import_model_class" table will have a "deep_import_{other_class}_id" field

The "deep_import_id" values, and association tracking, is handled automatically for the developer, by DeepImport.

#### DeepImport Bulk Upload Process

* all models are built in memory
* each model class (and its index records) are uploaded in batch, 1 class at a time
  * for 3x model classes, there are 6x bulk inserts
* each belongs to association (foreign key) is set
  * 1x UPDATE/JOINS query per association
* deep import ids, and deep import index records, are deleted

#### Schema Example

```
parents
  id PKEY
  ...data fields...
  deep_import_id # relative id to batch import

deep_import_parents
  deep_import_id 

children
  id PKEY
  parent_id FKEY
  ...data fields...
  deep_import_id # relative id to batch import

deep_import_children
  deep_import_id
  deep_import_parent_id # for joining to parents
```

When the "children" are bulk inserted, they all have null parent.
Each child record has an index record, that has recorded the parent relation via a relative deep import id. Post import, the foreign key relations ("children.parent_id" field) are set via an update/joins query through the deep import index tables.
  
#### The Cost

_Write out the math_

### Setup:

* Intall gem
  * `gem deep_import`
* Add config file defining importable models:
  * [config/deep_import.yml](config/deep_import.yml)
* Setup code files, and database migration (index tables required)
  * `rake deep_import:setup`
* Start writing code and running imports

# Outdated Notes Below - Rewrite/Update
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
