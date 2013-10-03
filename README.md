Deep Import
===========

#### Problem
In Rails, when importing:
* lots of data (many model instances)
* of multiple distinct Models
* with Associations
* using standard Rails/ActiveRecord syntax
* <b>database transaction costs become prohibitive</b>

#### Pior Solution: activerecord-import
[activerecord-import](https://github.com/zdennis/activerecord-import) is a fantastic tool, but it does not by default support the loading of multiple model types, or associations.
* It is the basis for Deep Import though, so Much Thanks

#### Deep Import
* Deep Import is a gem for mass importing of multiple models with associations.
* Deep Import reduces the transaction costs of communicating with a database
  * by temporarily increasing the space used for representing your models
* Deep Import is built within Rails to prevent developers from learning a new API
* [Tutorial](https://github.com/smith11235/deep_import/blob/master/TUTORIAL.md)
* [Association API](https://github.com/smith11235/deep_import/blob/master/API.md)
* [TODO](https://github.com/smith11235/deep_import/blob/master/TODO.md)
* [Benchmarks View](http://twostepsleftofnormal.com:31234/)

Transaction Analysis
====================

Each model created with:
* Model.new.save 

Causes 1 transaction with the database.

<b>Standard Rails Model Instance Creation:</b>

      - 1 instance per transation
      - Product.new.save, @product.reviews.create

<b>[activeRecord-import](https://github.com/zdennis/activerecord-import/wiki):</b>

      - X instances per transaction for 1 model class
			- supports flat record formats
			- doesnt support nested data well

<b>DeepImport:</b>

      - Load X instances of M model classes
      - in M + B transactions
      - Where B is the number of belongs to relationships between the M model classes
      - M and B must be neglible compared to X for benefit
  		- using 2M records of space on the database
  			- association index created by DeepImport* models
  			- space is cheap, time is not

Benchmark Testing
=================
* Models are Parent, Child, Grandchild
	* app/models/*.rb
* Benchmark Data:
	* sh script/benchmark.sh RANGE=30
		* Generates Import Models: 
			* RANGE = number of Parents
			* RANGE^2 = number of Children (each Parent has RANGE Children)
			* RANGE^3 = number of GrandChildren (each Child has RANGE GrandChildren)
	* raw data: [public/benchmarks_30.dat](https://github.com/smith11235/deep_import/blob/master/public/benchmarks_30.dat)

Results: (the 'real' column reflects the database transaction overhead)

    mysql running on remote server, time is in seconds
                   user     system      total        real
    10 x 10 x 10
    deep_import:  4.650000   0.070000   4.720000 (  7.043655)
        classic:  4.370000   0.260000   4.630000 (209.035913)
    30 x 30 x 30
    deep_import:  80.770000   0.980000  81.750000 ( 97.582577)
        classic:  120.160000   7.850000 128.010000 (5264.665823) 

#####Thats 50 TIMES FASTER for a 27,000 object load

#### How Fast Is Fast
Rails will never be as fast as the perfect c++ data importer<br />
But how often do you have time to configure perfect c++?<br />
Deep Import attempts to make average bulk data loading fast enough for Rails developers<br />


Usage
=====
- Read [TUTORIAL.md](https://github.com/smith11235/deep_import/blob/master/TUTORIAL.md) for explanations and examples
- Gemfile:  "gem: 'deep_import', :git => 'git://github.com/smith11235/deep_import'"
- create a [config/deep_import.yml](https://github.com/smith11235/deep_import/blob/master/config/deep_import.yml) with your model architecture
- rake deep_import:setup # to load the config and generate model enhancements
- rake db:migrate # to load the model enhancements to your database
- rake [deep_import:benchmark:deep_import](https://github.com/smith11235/deep_import/blob/master/lib/deep_import/deep_import.rake) # for sample batch load code
  - review code, use .new, .build, dont use .save, .create
  - add a DeepImport.commit call at the end of your loader

#### Code Robustness/RSpec
- RSpec/BDD is the development process being used.
- There are currently 170 specifications, with many more planned.

    Finished in 32.74 seconds
    170 examples, 0 failures, 29 pending
