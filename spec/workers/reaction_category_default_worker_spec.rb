require "rails_helper"

RSpec.describe ReactionCategoryDefaultWorker, type: :worker do
  before do
    create :reaction_category, name: "Like", slug: "like", position: 1
    create :reaction_category, name: "Hug", slug: "hug", position: 3
  end

  it "creates default reaction categories as needed" do
    described_class.new.perform
    expect(ReactionCategory.count).to eq(11)
    expect(ReactionCategory.pluck(:position)).to contain_exactly(*(1..11).to_a)
    expect(ReactionCategory.pluck(:slug)).to contain_exactly(*%w[like hug readinglist unicorn hands_up fire laughing
                                                                 shocked thumbsup thumbsdown vomit])
  end
end
