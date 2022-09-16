#  @note When we destroy the related user, it's using dependent:
#        :delete for the relationship.  That means no before/after
#        destroy callbacks will be called on this object.
class DisplayAdEvent < ApplicationRecord
  belongs_to :display_ad
  belongs_to :user, optional: true

  CATEGORY_IMPRESSION = "impression".freeze
  CATEGORY_CLICK = "click".freeze
  VALID_CATEGORIES = [CATEGORY_CLICK, CATEGORY_IMPRESSION].freeze

  CONTEXT_TYPE_HOME = "home".freeze
  VALID_CONTEXT_TYPES = [CONTEXT_TYPE_HOME].freeze

  validates :category, inclusion: { in: VALID_CATEGORIES }
  validates :context_type, inclusion: { in: VALID_CONTEXT_TYPES }

  scope :impressions, -> { where(category: CATEGORY_IMPRESSION) }
  scope :clicks, -> { where(category: CATEGORY_CLICK) }

  ROLL_UP_QUERY = <<-SQL.freeze
    select count(id) as counts_for,
           category,
           context_type,
      	   display_ad_id,
           user_id,
      	   DATE(created_at) as created_on
    from display_ad_events
    where (counts_for = 1 AND (created_at > '%<earliest>s') AND (created_at < '%<latest>s'))
    group by category,
             context_type,
             display_ad_id,
             user_id,
             created_on
    having (COUNT(id) > 9);
  SQL

  def self.for_roll_up(between)
    connection.execute format(ROLL_UP_QUERY, earliest: between.first, latest: between.last)
  end
end
