---
# Deep Import

Making **bulk data** with ActiveRecord **EASY**

---
= data-z="-800"
= data-scale=".1"
# Simplicity
```
	DeepImport.import do 
		(1..25).each do
			parent = Parent.new
			(1..25).each do 
				child = Child.new
				child.parent = parent
			end
		end
```

