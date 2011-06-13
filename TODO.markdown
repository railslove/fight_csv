* method_missing of record needs to be aware of not having a schema
  defined

* make csv documents without header work  like:
 schema do
  header ['Surname', 'Name', 'Tel', 'Email']
end
