Deep Import Readme
==================

[Presentation](http://smith11235.github.io/deep_import)

#### WIKI
* [WIKI](http://www.github.com/smith11235/deep_import/wiki/README)
* To Develop: ```git clone https://github.com/smith11235/deep_import.wiki.git wiki```
	* add to .gitignore ```/wiki/``` 

#### Impress Presentation

[Impress.js](https://github.com/bartaz/impress.js)

###### Impress/Gh-Pages Setup

* add ```/gh-pages/``` to .gitignore
* from root: ```git clone https://github.com/smith11235/deep_import.git gh-pages```
* ```cd gh-pages && git checkout gh-pages```
	* first time setup: empty orphan branch
		* ```git checkout --orphan gh-pages```
		* ```git rm -rf .```
	* edit files
	* ```git push -u origin gh-pages```

* adding impress:
	* ```wget https://raw.github.com/bartaz/impress.js/master/js/impress.js```
	* need to learn css to set classes

