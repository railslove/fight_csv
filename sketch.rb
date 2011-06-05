{ 'Name' => 'Ruby', 'Creator' => 'Matz', 'Year' => '1994'}
['Name', 'Ruby']
['Creator', 'Matz']
                                                                                          # ||
fields.map(&:matcher)
# => ['Name', 'Creator', /Y(ae)?rg]
module Parser                                                                             # ||
  # parses csv and puts it into a hash from with data_source and body                     # ||
end                                                                                       # ||
                                                                                          # ||
class DataSource                                                                          # ||
  # provides data about the header of the csv and the file/string where it was defined    # ||
end                                                                                       # ||
                                                                                          # ||
class Schema                                                                              # ||
  # is composed of several fields defining the structure of the csv doc                   # ||
end                                                                                       # ||
                                                                                          # ||
class Field                                                                               # ||
  # maps a defintion of a field                                                           # || Priority
end                                                                                       # ||
                                                                                          # ||
module Record                                                                             # ||
  # maps Schema#fields to attributes                                                      # ||
  # can validate itsefl                                                                   # ||
end                                                                                       # ||
                                                                                          # ||
                                                                                          # ||
                                                                                          # \/
