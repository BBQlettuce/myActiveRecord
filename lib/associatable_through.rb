require_relative 'associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]
    define_method(name) do
      # owner = self.send(through_name)
      # house = owner.send(source_name)
      # house
      # foreign key i'm holding now; used at end
      owner_key = "#{through_options.table_name}.#{through_options.primary_key}"
      owner_key_value = self.send(through_options.foreign_key)

      # model class i'm going through first
      # will need its table name in query
      thru_table = through_options.table_name

      # now i'm inside thru_mc, looking at its assoc options
      source_options = through_options.model_class.assoc_options[source_name]

      # second model class, and also need its name as .table_name
      source_table = source_options.table_name

      # through object fk = source obj pk; join condition
      thru_dot_fk = "#{thru_table}.#{source_options.foreign_key}"
      source_dot_pk = "#{source_table}.#{source_options.primary_key}"

      query = (<<-SQL)
        SELECT
          #{source_table}.*
        FROM
          #{source_table}
        JOIN
          #{thru_table}
        ON
          #{thru_dot_fk} = #{source_dot_pk}
        WHERE
          #{owner_key} = #{owner_key_value}
      SQL
      source_options.model_class.parse_all(DBConnection.execute(query)).first
    end
  end

end
