schema do
  field 'Name', {
    identifier: :name,
    required: true
  }

  field 'Paradigms', {
    identifier: :paradigms,
    validator: /([^,]*,)*[^,]*/,
    converter: ->(string) { string.split(',') }
  }

  field 'Creator' , {
    identifier: :creator,
    required: true
  }
end
