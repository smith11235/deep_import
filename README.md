A rubygem to enable efficient/fast bulk data loading of nested data models, 
with the same ActiveRecord code you already have.

An execution timing example, and explanation of the algorithm can be found further down.

### Benefit 1: Bulk Data Loading Speed Boost

ActiveRecord provides great ease of use to a developer 
(simple, readable code, no raw SQL). 
At a cost in terms of efficiency, 
exacerbated when performing bulk data loading operations. 

In general ORM's are great for small transactions touching a few records at a time.
Typically as a result of a users action (ex: a form submission).

When performing data loading (bulk inserts: feed ingestion, web scraping, ETL), 
ActiveRecord slows down as each model is loaded individually, 
with a network database transaction per record to be loaded.
             
DeepImport solves this data loading efficiency problem by enabling bulk inserts.
And more specifically, solves for multiple associated models seamlessly.

> EX: belongs_to, has_many, has_one, polymorphic relationships

This is done via a small algorithm, portable to any language.

### Benefit 2: Same Code
The same standard ActiveRecord code can be used between DeepImport data loading, and normal execution.
This is as important as the speed boost provided to bulk data loading.

What this means is:
* 0 code change required to adopt (or remove) DeepImport
  * No lock in, no need to re-write code (add gem, get benefit 1)
* Any coder can intuitively, immediately, understand the code
  * Future maintainer or new hire out of college
* Debugging can be done, on a single instance, with or without DeepImport
  * No need to re-write code to confirm functionality or parity

## Setup / Usage

* Add gem: 
  * `gem deep_import`
* Add config file defining importable models and relationships:
  * Example config: [config/deep_import.yml](config/deep_import.yml)
* Generate and execute database migration (from config file)
  * `rake deep_import:setup`
* If not Rails, add initialization call to startup:
  * `DeepImport.initialize! on_save: :noop`
    * conditionally include it only within worker processes
    * not needed from within rails server process
* Start running imports

## Data Loading Code Example

Full code example: [lib/tasks/example.rake](lib/tasks/example.rake)

Breakdown of code example shown below.

#### 3 Nested Model Classes

```
Parent 
  has_many :children

Child
  belongs_to :parent
  has_many :grand_children

GrandChild
  belongs_to :child
```

#### 1 block of code: w/ and w/out DeepImport

Two rake tasks, to build the same data, via the same code block.

* `rake example:normal` 
* `rake example:deep_import`

```
  task :normal do
    make_random_nested_data

  task :deep_import
    DeepImport.import do 
      make_random_nested_data
```

The `make_random_nested_code` method takes a LIMIT parameter, 
to change the size of the sample import.

For any value of {LIMIT}, the code builds:
* {LIMIT} instances of Parents
* {LIMIT}^2 instances of Children 
  * aka: for each Parent, it builds {LIMIT} Children
* {LIMIT}^3 instances of Grand Children 
  * aka: for each Child, it builds {LIMIT} GrandChildren

```
  limit = ENV["LIMIT"]
  (0..limit).each do
    parent = Parent.create!
    (0..limit).each do
      child = parent.children.create! 
      (0..limit).each do
        child.grand_children.create! 
```

#### Execution Time Comparison

Executed from a server against a remove Postgres database.

| LIMIT | Total Records | Normal Timing | DeepImport Timing |
| ----- | ------------- | ------------- | ----------------- |
|  10   |   ~1,500      |   10 seconds  |   1 second        |
|  29   |   ~28,000     |  214 seconds  |   32 seconds      |

## The Magic (AKA: The Algorithm)

**TLDR: A classic tradeoff between Speed vs Space.**

To achieve faster data loading times, extra server side space is used along with temporary extra records in the db.

### The Culprit: Network Transaction Overhead
In a standard ORM process, for X model instances to be loaded, there are X insert db queries/network calls. In a web controller, inserting 1 or 2 records due to a users activity, this is trivial, and fast enough.

When loading a large number of models, the network calls add up to significant overhead.

```
(0..10).each do
  Parent.new.save # 10 insert calls executed
end
```

### The Solution: Bulk Inserts

Rather than committing individual models, new instances are held in memory, server side, until all instances are ready for one bulk insert. 1 query, 1 network transaction.

#### Prior Work: ActiveRecord-Import

A gem called ["ActiveRecord-Import"](https://github.com/zdennis/activerecord-import)
provides a simple solution to this problem.

```
parents = []
(0..10).each do
  parents << Parent.new # build all models in memory, limited by server memory
end
Parent.import parents # 1 bulk insert call executed
```

The above code provides a massive boost to speed of execution.

#### Prior Work: The Limits

ActiveRecord-Import does not handle the creation of nested data relations.
This is due to the fact that relationships (primary/foreign key fields) cannot be tracked, if the associated instance has not yet been created (given an primary key ID). 

```
# Faulty code (what Deep Import handles)
parents = []
children = []
(0..10).each do
  parents << Parent.new # build all models in memory, limited by server memory
  (0..10).each do
    children = parent.children.build 
  end
end
Parent.import parents # 1 bulk insert call executed
Children.import children # 1 bulk insert call executed, children all have "parent: null"
```

The above code would "work", but, all of the children would be orphans, as their "parent_id" value would be missing, as none of the parents were tracked.

To get around this, and still have some speed benefits, all Parents could be created and uploaded, and then all Children could be created and uploaded.

```
# Impractical Code - But works
parents = []
(0..10).each do
  parents << Parent.new # build all models in memory, limited by server memory
end
Parent.import parents # 1 bulk insert call executed

children = []
parents.each do |parent|
  (0..10).each do
    children << parent.children.build
  end
end
Children.import children # 1 bulk insert call executed
```

While the above works, it is not practical in many data loading scenarios.

**Effectively, for "Bulk Data Loads" of nested data relations, a Depth First Traversal of the source data is desired, rather than a "Breadth First Traversal".** The "Breadth First" load pattern would create a lot of churn in your system, resulting in a lot of redundant processing overhead.

##### Real World Examples

**Financial Data Set - On Companies**
With a data feed of top level entities (say, a Company), where each top level entity can be parsed to obtain its Products, and Metrics, you would want to parse the feed 1 Company at a time, building up all its data, and then move on to the next one. You would not want to parse all "top nodes" (feed files), load them, then all "secondary nodes", load them, and so on. 

**Web Scraping - Aggregating an index**
If a scraper was running, you would want to parse 1 website, and its associated data, then move onto the next website. You would not want to load each website record, then go back and reprocess each website.

### Bulk Data Loading: Nested Data (with DeepImport)

DeepImport solves for this real world, complex structures, problem.

To do so, a "shadow" index using "batch process relative" primary/foriegn keys is created.

This is the temporary extra space required to allow bulk inserts at the end of data processing.

Effectively, for each ModelClass to be loaded, there is a secondary table associated to that class. For each ModelClass instance to be loaded, there is a secondary index record to be loaded.

While the ModelClass instance may contain a set of data points/columns, the index table contains only an ID field, and a foreign key field for each "belongs to" relation on that model.

#### Schema/Data Architecture

Each "Importable" ModelClass:

* Will have a "deep_import_id" field on its "model_class" table
* There will be a corresponding index table: "deep_import_{model_class}"
  * With matching "deep_import_id" field

* For each "belongs to" {OtherClass} association (foreign key relation) on ModelClass
  * The "deep_import_model_class" table will have a "deep_import_{other_class}_id" field
##### Schema Example
For sample data load code models: Parent, each having many Children.

```
parents
  id PKEY
  ...data fields...
  deep_import_id # relative id to batch import

children
  id PKEY
  parent_id FKEY # unavailable at time of initial import
  ...data fields...
  deep_import_id # relative id to batch import

deep_import_parents
  deep_import_id 

deep_import_children
  deep_import_id
  deep_import_parent_id # for joining to parents
```

When the "children" are bulk inserted, they all have null parent.
Each child record has an index record, that has recorded the parent relation via a relative deep import id. Post import, the foreign key relations ("children.parent_id" field) are set via an update/joins query through the deep import index tables.

#### Batch Relative IDs

The "deep_import_id" values, and association tracking, is handled automatically for the developer, by DeepImport.

These ids are generated dynamically, specific to the set of to-be-imported data. They do not represent globally unique database uuids.

EX: For a batch of 10 models, their relative id's will be "1" through "10". Running a second batch of 10, would again have relative id's "1" through "10".

For multi-machine safety:

> deep_import_id = {process_id}_#{count of models in memory}

> deep_import_id = 2384239482341_15
 

#### DeepImport Bulk Upload Process

* First, all models are built in memory
  * Via developer code block
  * Standard ORM calls, modified behind the scenes by DeepImport
* Then DeepImport Commit:
  * Each model class is uploaded with a bulk insert
    * 1 class at a time (plus its index records)
    * For X core model classes, there are 2X bulk insert queries
  * Each "belongs_to" association is set
    * 1x UPDATE/JOINS query per association 
  * DeepImport index data is deleted
    * Both deep_import_ids and index records

#### The Cost

_Write out the math - for time + space_
