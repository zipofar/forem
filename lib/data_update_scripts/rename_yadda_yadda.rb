module DataUpdateScripts
  class RenameYaddaYadda
    SQL = <<ENDOFQUERY.freeze
 UPDATE taggings
 SET taggable_type = 'Listing'
 WHERE taggable_type = 'ClassifiedListing'
ENDOFQUERY

    def run
      Tag.connection.execute(SQL)
    end
  end
end
