rails generate model SoftProduct soft_id:integer soft_user:references
rails generate model SoftUser soft_id:integer
rails generate model SoftReview soft_id:integer soft_product:references
rails generate model SoftFeature soft_id:integer soft_product:references
rails generate model SoftAttribute soft_id:integer soft_feature:references
rails generate model SoftAccount soft_id:integer soft_user:references
