require "rails_helper"
require Rails.root.join("lib/data_update_scripts/rename_yadda_yadda.rb")

describe DataUpdateScripts::RenameYaddaYadda do
  let(:tag) { create(:tag) }
  let!(:listing) { create(:listing, tag_list: tag.name) }

  it "leaves correct records alone" do
    expect { described_class.new.run }.not_to change { listing.taggings.count }
  end

  context "with a ClassifiedListing taggable_type" do
    before do
      listing.taggings.first.update_column(:taggable_type, "ClassifiedListing")
    end

    it "renames the taggable type from ClassifiedListing to Listing" do
      expect { described_class.new.run }.to change { listing.taggings.count }.by 1
    end
  end
end
