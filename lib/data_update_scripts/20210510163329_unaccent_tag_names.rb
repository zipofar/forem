module DataUpdateScripts
  class UnaccentTagNames
    def run
      Tag.transaction do
        Tag.connection.execute <<~SQL
          UPDATE tags
          SET name = unaccent(name)
        SQL

        Article.connection.execute <<~SQL
          UPDATE articles
          SET cached_tag_list = unaccent(cached_tag_list)
        SQL
      end
    end
  end
end
