require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject

  def self.columns
    col_names = (<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      LIMIT 1
    SQL
    DBConnection.execute2(col_names).first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |col_name|
      define_method(col_name) { attributes[col_name] }
      col_name_with_equal = "#{col_name}=".to_sym
      define_method(col_name_with_equal) { |val| attributes[col_name] = val }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    entire_table = (<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    object_params = DBConnection.execute(entire_table)
    parse_all(object_params)
  end

  def self.parse_all(results)
    results.map { |params| self.new(params) }
  end

  def self.find(id)
    find_query = (<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = #{id}
    SQL
    output = DBConnection.execute(find_query)
    return nil if output.empty?
    self.new(output.first)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_to_symbol = attr_name.to_sym
      if !self.class.columns.include?(attr_to_symbol)
        raise "unknown attribute \'#{attr_name}\'"
      end
      attr_setter = "#{attr_name}=".to_sym
      send(attr_setter, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col_name| attributes[col_name] }
  end

  def insert
    col_names_string = self.class.columns.map(&:to_s).join(', ')
    question_marks = Array.new(self.class.columns.count) {"?"}
    question_marks_string = question_marks.join(', ')
    query = (<<-SQL)
      INSERT INTO
        #{self.class.table_name} (#{col_names_string})
      VALUES
        (#{question_marks_string})
    SQL
    DBConnection.execute(query, *attribute_values)
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_cols = self.class.columns.map { |col_name| "#{col_name} = ?" }
    set_string = set_cols.join(', ')
    query = (<<-SQL)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_string}
      WHERE
        id = #{id}
    SQL
    DBConnection.execute(query, *attribute_values)
  end

  def save
    id.nil? ? insert : update
  end

  def destroy
    query = (<<-SQL)
      DELETE FROM
        #{self.class.table_name}
      WHERE
        id = #{id}
    SQL
    DBConnection.execute(query)
  end
end
