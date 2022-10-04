class ReactionCategoryDefaultWorker
  include Sidekiq::Job

  DEFAULTS = %i[like readinglist unicorn hands_up fire laughing shocked thumbsup thumbsdown vomit].freeze
  PLACEHOLDER_ICONS = {
    like: "<svg xmlns='http://www.w3.org/2000/svg'/></svg>",
    readinglist: "<svg xmlns='http://www.w3.org/2000/svg'/></svg>",
    unicorn: "<svg xmlns='http://www.w3.org/2000/svg'/></svg>",
    hands_up: "<svg xmlns='http://www.w3.org/2000/svg'/></svg>",
    fire: "<svg xmlns='http://www.w3.org/2000/svg'/></svg>",
    laughing: "<svg xmlns='http://www.w3.org/2000/svg'/></svg>",
    shocked: "<svg xmlns='http://www.w3.org/2000/svg'/></svg>",
    thumbsup: "<svg xmlns='http://www.w3.org/2000/svg'/></svg>",
    thumbsdown: "<svg xmlns='http://www.w3.org/2000/svg'/></svg>",
    vomit: "<svg xmlns='http://www.w3.org/2000/svg'/></svg>"
  }.freeze
  SCORE = {
    vomit: -50.0,
    thumbsup: 5.0,
    thumbsdown: -10.0
  }.freeze
  PRIVILEGED = %i[thumbsup thumbsdown vomit].freeze
  UNCONFIGURABLE = %i[like readinglist].freeze

  def perform
    positions_available = ((1..99).to_a - ReactionCategory.positions_taken).to_enum
    DEFAULTS.each do |slug|
      ReactionCategory.where(slug: slug).first_or_create! do |category|
        category.name       = slug.to_s.titleize
        category.position   = positions_available.next
        category.icon       = PLACEHOLDER_ICONS[slug]
        category.score      = SCORE.fetch(slug, 1.0)
        category.editable   = (PRIVILEGED + UNCONFIGURABLE).exclude?(slug)
        category.privileged = PRIVILEGED.include?(slug)
        category.published  = PRIVILEGED.exclude?(slug)
      end
    end
  end
end
