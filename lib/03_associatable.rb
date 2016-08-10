require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.to_s.constantize
  end

  def table_name
    @class_name.downcase + "s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    unless options.keys.empty?
      options.keys.each do |key|
        instance_variable_set("@#{key}", options[key])
      end
    end
    @foreign_key ||= "#{name.to_s}_id".to_sym
    @primary_key ||= :id
    @class_name ||= name.capitalize.to_s
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    unless options.keys.empty?
      options.keys.each do |key|
        instance_variable_set("@#{key}", options[key])
      end
    end
    @foreign_key ||= "#{self_class_name.downcase}_id".to_sym
    @primary_key ||= :id
    @class_name ||= name.to_s.capitalize.singularize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      foreign_key = self.send(self.class.assoc_options[name].foreign_key)
      class_name = self.class.assoc_options[name].model_class
      class_name.where(id: foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      primary_key = self.send(options.primary_key)
      class_name = options.class_name.to_s.camelcase.constantize
      class_name.where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
