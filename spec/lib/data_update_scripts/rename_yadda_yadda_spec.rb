require "rails_helper"
require Rails.root.join("lib/data_update_scripts/rename_yadda_yadda.rb")

describe DataUpdateScripts::RenameYaddaYadda do
  let(:tag) { create(:tag) }
  let!(:listing) { create(:listing, tag_list: tag.name) }

  it "leaves correct records alone" do
    expect { described_class.new.run }.not_to change { listing.taggings.count }
  end

  it "does not change listing taggings" do
    described_class.new.run

    expect(listing.taggings.first.taggable_type).to eq("Listing")
  end

  context "with a ClassifiedListing taggable_type" do
    before do
      # update column to bypass validation on type name
      listing.taggings.first.update_column(:taggable_type, "ClassifiedListing")
    end

    it "renames the taggable type from ClassifiedListing to Listing" do
      expect(tag.taggings.first.taggable_type).to eq("ClassifiedListing")

      described_class.new.run

      expect(tag.taggings.first.taggable_type).to eq("Listing")
    end
  end
end
