rails destroy model SoftProduct soft_id:integer soft_user:references
rails destroy model SoftUser soft_id:integer
rails destroy model SoftReview soft_id:integer soft_product:references
rails destroy model SoftFeature soft_id:integer soft_product:references
rails destroy model SoftAttribute soft_id:integer soft_feature:references
rails destroy model SoftAccount soft_id:integer soft_user:references
