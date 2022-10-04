require "rails_helper"
require Rails.root.join(
  "lib/data_update_scripts/20221004130932_create_reaction_category_defaults.rb",
)

describe DataUpdateScripts::CreateReactionCategoryDefaults do
  it "enques the background job" do
    allow(ReactionCategoryDefaultWorker).to receive(:perform_async)
    described_class.new.run
    expect(ReactionCategoryDefaultWorker).to have_received(:perform_async)
  end
end
