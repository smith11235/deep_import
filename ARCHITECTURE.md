# ARCHITECTURE
## Support For Associations
* only simple associations so far
* polymorphism, and other tricks are as of yet untested
* belongs_to
	* through belongs_to you can hopefully code anything you need to
		* GIST make one of lib/tasks/example.rake
* has_one, has_many are next

## DeepImport.import { ... load logic ... }
* signals magic
* DeepImport logic only executes within these blocks
	* this ensures that on any error, deep_import will be a part of relevant stack traces
* **[GIST](https://gist.github.com/smith11235/7001147)**
	* focus on creating all the models and associations
	* everything created in the block will be commited to the database 
	* forget calling save, and create_* methods

## config/deep_import.yml
* A Hash of 'ModelName' => Hash of Associations
* **[GIST](https://gist.github.com/smith11235/7001180)**
	* Association:
		* only 'belongs_to' currently supported
		* an Array of 'ModelName' this model belongs to

## Active Record Associations:
* [ActiveRecord API](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html)
* has_one
	* planned, unsupported
* has_many
	* planned, unsupported
* belongs_to
	* API for Child belongs_to Parent
	* child.parent=
	* child.build_parent
	* child.create_parent
	* child.create_parent!

## deep import models
* models and associations are only established once id values are saved to the database
* DeepImport tracks these relationships in ActiveRecord like index models
* for each **Model** in config file
	* there is a generated **DeepImportModel**
	* for each belongs_to association
		* there is a **deep_import_models.deep_import_belongs_to_id** field
* these DeepImport models are responsible for tracking association links
	* before and after serialization or commit to the database

## commit algorithm
* for each model class in the import cache
	* DeepImport runs the activerecord-import method
	* for each belongs_to relation
		* DeepImport joins the ModelClass
			* to DeepImportModelClass on a deep_import_id
			* and links to the BelongsToClass using:
				* DeepImportModelClass.deep_import_belongs_to_class_id = BelongsToClass.deep_import_id
* then all DeepImport models are deleted
	* ensuring that no additional space is consumed once initial import is completed
