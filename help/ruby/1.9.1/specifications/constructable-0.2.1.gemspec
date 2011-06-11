# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{constructable}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Manuel Korfmann"]
  s.date = %q{2011-06-10}
  s.description = %q{
Adds the class macro Class#constructable to easily define what attributes a Class accepts provided as a hash to Class#new.
Attributes can be configured in their behaviour in case they are not provided or are in the wrong format.
Their default value can also be defined and you have granular control on how accessible your attribute is.
See the documentation for Constructable::Constructable#constructable or the README for more information.
  }
  s.email = %q{manu@korfmann.info}
  s.homepage = %q{http://github.com/mkorfmann/constructable}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Makes constructing objects through an attributes hash easier}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end
