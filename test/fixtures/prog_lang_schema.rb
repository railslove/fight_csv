field 'Name', {
  identifier: :name,
  required: true
}

field 'Paradigms', {
  identifier: :paradigms,
  validator: /([^,]*,)*[^,]*/,
  converter: ->(string) { string.split(',') },
  required: false
}

field 'Creator' , {
  identifier: :creator,
  required: true
}
