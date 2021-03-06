A rubygem to enable efficient/fast bulk data loading of nested data models, 
with the same ActiveRecord code you already have.

### README Overview

* [Benefits: Why use it](#benefits) _(And example code timing comparison)_
* [Setup Instructions - How to use it](#setup-and-usage)
* [Data Loading Code Example](#data-loading-code-example)
* [The Magic - algorithm explanation and breakdown](#the-magic-aka-the-algorithm)

# Benefits

Two core reasons.

* Bulk Data Loading Speed
* Same code / _No code change required_

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

#### Execution Time Comparison 
From Code Eample shown below.

Executed from a server against a remove Postgres database. 
Timing varies per execution. Records loaded are minimal shells, no data parsing/computed values.
The timing difference is primarily network/query call overhead being removed.

| Total Records | Normal Timing | DeepImport Timing |
| ------------- | ------------- | ----------------- |
|   ~1,500      |   10 seconds  |   1 second        |
|   ~28,000     |  214 seconds  |   32 seconds      |

### Benefit 2: Same Code
The same standard ActiveRecord code can be used between DeepImport data loading, and normal execution.
This is as important as the speed boost provided to bulk data loading.

What this means is:
* 0 code change required to adopt (or remove) DeepImport
  * No lock in, no need to re-write code (add gem, get "Benefit 1")
* Any coder can intuitively, immediately, understand the code
  * Future maintainer or new hire out of college
* Debugging can be done, on a single instance, with or without DeepImport
  * No need to re-write code to confirm functionality or parity

See the data loading code example below for proof of this, along with the rspec examples.

## Setup and Usage

**Warning:** Only works currently with postgres (mysql pending).

#### With Rails

##### Add gem to bundle

`gem deep_import`

##### Add include/extend directives to "importables"

Within the class file of each model involved in the bulk import process, add directives for making it importable, and what associations to track for import (belongs_to, has_one, has_many).

```
# in each of your models:
# app/models/your_model.rb

class YourModel
  # Enable import tracking
  include DeepImport::Importable

  # belongs_to 
  belongs_to :parent
  DeepImport.belongs_to(self, :parent) # added setup command

  # has_many
  has_many :children, extend: DeepImport::HasMany # added extension module

  # polymorphic associations
  # - for belongs to side
  DeepImport.belongs_to(self, :relation, polymorphic: true)
  # - for has_* side
  has_many :in_laws, as: :relation, extend: DeepImport::HasMany
```
 
##### Generate/execute database migration 

To make deep import run your code faster, more temporary disk space is required for a local index. 
Database tables are required. 
The tables are designed so that they can be setup and torndown independently the reset of the application, at any time. 

`rake deep_import:setup`

##### Run Imports

```
DeepImport.logger.level = "INFO" # to see a printout of results (did it work)
DeepImport.import do
  { your logic }
end
```

#### Without Rails

_TODO: requires more testing/fleshing out_

* Add gem to bundle and require it in application
  * `gem deep_import`
  * `require deep_import` 
* Add association directives to "importable models"
  * see config notes in rails setup
* Generate and execute database migration: `rake deep_import:setup`
  * Define `ENV["DEEP_IMPORT_DB_DIR"]`
    * expects to have:
      * `schema.rb`
      * `/migrate` directory for migration
* Start running imports

#### Logging
Logging is verbose by default. With easy overrides.

* Location: STDOUT
  * override with: `ENV["DEEP_IMPORT_LOG_FILE"]` or `DeepImport.logger = Rails.logger`
* Level: INFO (verbose)
  * override with: `ENV["DEEP_IMPORT_LOG_LEVEL"]`

## Data Loading Code Example

Full code example: [spec/deep_import/timing_spec.rb](spec/deep_import/timing_spec.rb)

To execute it (while developing gem)

```
rspec --tag timing
```

Breakdown of example code shown below.

#### 4 Nested Model Classes
See [spec/support/models.rb](spec/support/models.rb).

```
Parent: has Children + InLaws(polymorphic)

Child: belongs to Parent, has many GrandChildren and InLaws

GrandChild: belongs to Child, has many InLaws

InLaws: belongs to relation
```

#### 1 block of code: w/ and w/out DeepImport

Two example tasks to build the same data, via the same code block.

```
  # Normal
  make_random_nested_data

  # Deep Import
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
    children = parents.last.children.build 
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

## To Develop Gem
Clone Repo.

Specify database connection details in `./database.yml` (root of project).

```
adapter: postgresql
database: deep_import_test
username: username
password: password
host: "hostname.com"
port: 5432
```

Run db create:

```
rake deep_import_development:db:create
rake deep_import_development:db:migrate
```

Use RSPEC tests.
