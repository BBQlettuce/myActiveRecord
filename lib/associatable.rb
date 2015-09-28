require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key]
    @foreign_key ||= "#{name}_id".to_sym
    @primary_key = options[:primary_key]
    @primary_key ||= :id
    @class_name = options[:class_name]
    @class_name ||= name.to_s.singularize.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key]
    @foreign_key ||= "#{self_class_name.underscore}_id".to_sym
    @primary_key = options[:primary_key]
    @primary_key ||= :id
    @class_name = options[:class_name]
    @class_name ||= name.to_s.singularize.camelcase
  end
end

module Associatable
  def belongs_to(name, options = {})
    belongs_to_options = BelongsToOptions.new(name, options)
    assoc_options[name] = belongs_to_options
    define_method(name) do
      # the class you intend to look in
      mc = belongs_to_options.model_class
      # the value of the foreign key that you are holding
      owner_key = self.send(belongs_to_options.foreign_key)
      # match the value you just found with the owner that has it
      mc.where({ belongs_to_options.primary_key => owner_key }).first
    end
  end

  def has_many(name, options = {})
    has_many_options = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      mc = has_many_options.model_class
      owner_key = self.send(has_many_options.primary_key)
      mc.where({ has_many_options.foreign_key => owner_key })
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
