require_relative '03_associatable'
require 'byebug'
require 'active_support/inflector'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options
  def has_one_through(name, through_name, source_name)
    define_method(name) do
      first_options = self.class.assoc_options[through_name]
      second_options = first_options.model_class.assoc_options[source_name]
      through_object = self.send(through_name)
      through_object.send(source_name)
    end


  end
end
