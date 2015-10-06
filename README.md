# myActiveRecord
ORM inspired by the functionality of Active Record

## SQLObject class
- usage: have your desired Model class inherit from SQLObject, then call
self.finalize!
- represents the traditional Model of the Rails MVC framework
- inflector gem handles pluralization and constantization
- makes use of SQL statements to execute CRUD actions
  - create, read, update, delete actions all supported

### Searchable
- extends SQLobject class to accept `where` style filtering

### Associatable
- extends SQLobject class to support ORM associations
- supports belongs_to and has_many associations
- makes us of `where` method to perform an abstracted SQL query
- has_one_through + has_many_through
  - compose join query using previously written methods
  - uses assoc_options hash to determin correct join attributes

## Todos
- [x] SQLObject#destroy
- [x] Associatable#has_many_through
