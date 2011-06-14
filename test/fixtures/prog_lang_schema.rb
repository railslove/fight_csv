field 'Name', {
  identifier: :name,
}

field 'Paradigms', {
  identifier: :paradigms,
  validator: /([^,]*,)*[^,]*/,
  converter: ->(string) { string.split(',') },
}

field 'Creator' , {
  identifier: :creator,
}
