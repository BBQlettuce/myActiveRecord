require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    conditions = []
    params.each do |col_name, value|
      conditions << "#{col_name} = ?"
    end
    conditions_string = conditions.join(' AND ')
    query = (<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{conditions_string}
    SQL
    output = DBConnection.execute(query, *params.values)
    parse_all(output)
  end
end

class SQLObject
  extend Searchable
end
