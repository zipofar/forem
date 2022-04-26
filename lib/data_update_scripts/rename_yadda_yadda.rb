module DataUpdateScripts
  class RenameYaddaYadda
    def run
      ActsAsTaggableOn::Tagging
        .where(taggable_type: "ClassifiedListing")
        .update_all(taggable_type: "Listing")
    end
  end
end
