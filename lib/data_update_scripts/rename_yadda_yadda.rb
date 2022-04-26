module DataUpdateScripts
  class RenameYaddaYadda
    UPDATE_SQL = <<ENDOFQUERY.freeze
 UPDATE taggings
 SET taggable_type = 'Listing'
 WHERE taggable_type = 'ClassifiedListing'
ENDOFQUERY

    def run
      Tag.connection.execute(UPDATE_SQL)
    end
  end
end
