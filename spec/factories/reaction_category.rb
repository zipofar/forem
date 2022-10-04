FactoryBot.define do
  factory :reaction_category do
    name { "#{Faker::Book.title} #{rand(1000)}" }
    slug { name.downcase.underscore }
    icon { "<svg xmlns='http://www.w3.org/2000/svg'/></svg>" }
    sequence :position
    published { true }
  end
end
