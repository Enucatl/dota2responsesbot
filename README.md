# README

* Ruby version
2.3.0

* System dependencies
see [recipe.pp](https://github.com/Enucatl/dota2responsesbot/blob/master/lib/puppet/recipe.pp)

* Configuration
```
cap staging puppet
```

* Database creation and initialization
```
cap production db:setup
```

* How to run the test suite
```
rake test
```

* Deployment instructions
```
cap production deploy
```
