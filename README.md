Deep Import
===========

#### Problem
When importing:
* many models
* with many associations between them
* using standard Rails syntax

##### transaction costs become prohibitive

ORM's in general suffer from prohibitive wrapper costs when applied to large data sets.
* some avoid them for this reason alone
Rails/ActiveRecord are efficient developer tools.
* abandoning them has other costs

#### Idea
* Provide an enhancement to Rails to support efficient mass data loading.
* Keep it familiar so any developer can pick it up and understand it.
* Deep Import in no way solves every problem, but it solves a problem.

#### Pior Work
A commonly found solution is [activerecord-import](https://github.com/zdennis/activerecord-import)<br />
* DeepImport is built using this.  
Much Thanks.

#### Self
* Deep Import is a gem for mass importing of multiple models with associations.
* Deep Import is built within the Associations API providing a seamless developer experience
* Deep Import reduces the transaction costs of communicating with a database
  * by temporarily increasing the space used for representing your models
* [TUTORIAL](https://github.com/smith11235/deep_import/blob/master/TUTORIAL.md)
* [Association API](https://github.com/smith11235/deep_import/blob/master/API.md)
* [Current Planned Features](https://github.com/smith11235/deep_import/blob/master/TODO.md)
* Preliminary Benchmark data below, more to follow

Transaction Analysis
====================

Each model created with Model.new.save causes 1 transaction with the database.
When creating many models, transaction costs become significant.

Standard Rails Model Instance Creation: 

      - 1 instance per transation
      - Product.new.save, @product.reviews.create

[activeRecord-import](https://github.com/zdennis/activerecord-import/wiki):

      - X instances per transaction for 1 model class
			- supports flat record formats
			- doesnt support nested data well

DeepImport:

      - Load X instances of M model classes
      - in M + B transactions
      - Where B is the number of belongs to relationships between the M model classes
      - M and B must be neglible compared to X for benefit
  		- using 2M records of space on the database
  			- association index created by DeepImport* models
  			- space is cheap, time is not

Benchmark
=========
* Models are Parent, Child, Grandchild
  * defined in config/deep_import.yml (provided by application developer, not gem)
* X Parents have X Children each and each Child has X GrandChildren
  *  1,110 objects for 10 x 10 x 10 
  * 27,930 objects for 30 x 30 x 30
* Rake Task: deep_import:benchmark
  * defined in lib/deep_import/deep_import.rake[https://github.com/smith11235/deep_import/blob/master/lib/deep_import/deep_import.rake]

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
Usage
=====
- Gemfile:  "gem: 'deep_import', :git => 'git://github.com/smith11235/deep_import'"
- create a config[https://github.com/smith11235/deep_import/blob/master/config/deep_import.yml] with your model architecture
- rake deep_import:setup # to load the config and generate model enhancements
- rake db:migrate # to load the model enhancements to your database
- rake deep_import:benchmark:deep_import[https://github.com/smith11235/deep_import/blob/master/lib/deep_import/deep_import.rake] # for sample batch load code
  - review code, use .new, .build, dont use .save, .create
  - add a DeepImport.commit call at the end of your loader
