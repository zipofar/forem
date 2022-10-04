class ReactionCategory < ApplicationRecord
  validates :position, uniqueness: true, if: lambda { |category|
    category.visible_to_public?
  }

  def self.positions_taken
    where(published: true).pluck(:position)
  end

  def visible_to_public?
    !privileged? && published?
  end
end
