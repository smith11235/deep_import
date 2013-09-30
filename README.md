===
Deep Import
* A gem for loading big data in Rails
* Improved database transaction efficiency for large dataset loads
* Allows standard active record syntax for developer familiarity
* [TUTORIAL](https://github.com/smith11235/deep_import/blob/master/TUTORIAL.md)

===
Transaction Analysis
* when creating many models, database transaction costs are significant
    Standard Rails Model Instanct Creation: 
      - 1 instance per transation
      - Product.new.save, @product.reviews.create
    activeRecord-import[https://github.com/zdennis/activerecord-import/wiki]:
      - X instances per transaction for 1 model class
    gem:DeepImport:
      - Load X instances of M model classes
      - in M + B transactions
      - Where B is the number of belongs to relationships between the M model classes
      - M and B must be neglible compared to X for benefit

===
Benchmark
* Models are Parent, Child, Grandchild
  * defined in config/deep_import.yml (provided by application developer, not gem)
* X Parents have X Children each and each Child has X GrandChildren
  *  1,110 objects for 10 x 10 x 10 
  * 27,930 objects for 30 x 30 x 30
* Rake Task: deep_import:benchmark
  * defined in lib/deep_import/deep_import.rake[https://github.com/smith11235/deep_import/blob/master/lib/deep_import/deep_import.rake]
* Results: (the 'real' column reflects the database transaction overhead)
    mysql running on remote server, time is in seconds
                    user     system      total        real
    10 x 10 x 10
     deep_import:  4.650000   0.070000   4.720000 (  7.043655)
         classic:  4.370000   0.260000   4.630000 (209.035913)
    30 x 30 x 30
     deep_import:  80.770000   0.980000  81.750000 ( 97.582577)
         classic:  120.160000   7.850000 128.010000 (5264.665823) 

===
Usage
- Gemfile:  "gem: 'deep_import', :git => 'git://github.com/smith11235/deep_import'"
- create a config[https://github.com/smith11235/deep_import/blob/master/config/deep_import.yml] with your model architecture
- rake deep_import:setup # to load the config and generate model enhancements
- rake db:migrate # to load the model enhancements to your database
- rake deep_import:benchmark:deep_import[https://github.com/smith11235/deep_import/blob/master/lib/deep_import/deep_import.rake] # for sample batch load code
  - review code, use .new, .build, dont use .save, .create
  - add a DeepImport.commit call at the end of your loader
