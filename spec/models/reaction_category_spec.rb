require "rails_helper"

RSpec.describe ReactionCategory, type: :model do
  it "is valid" do
    category = build :reaction_category, name: "Laugh", slug: "lol", position: 1
    expect(category).to be_valid
  end
end
