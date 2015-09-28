# myActiveRecord
ORM inspired by the functionality of Active Record

## SQLObject class
- represents the traditional Model of the Rails MVC framework
- inflector gem handles pluralization and constantization
- makes use of SQL statements to execute CRUD actions
- create, read, update actions all supported (delete to be implemented)

### Searchable
- extends SQLobject class to accept `where` style filtering

### Associatable
- extends SQLobject class to support ORM associations
- supports belongs_to and has_many associations
- makes us of `where` method to perform an abstracted SQL query
- has_one_through:
  - toughest method to write!
  - compose join query using previously written methods

## Todos
- SQLObject#destroy
- Associatable#has_many_through
