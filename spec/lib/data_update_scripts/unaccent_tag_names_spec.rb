require "rails_helper"
require Rails.root.join(
  "lib/data_update_scripts/20210510163329_unaccent_tag_names.rb",
)

RSpec.describe DataUpdateScripts::UnaccentTagNames do
  subject(:update) { described_class.new }

  context "with tag names in Latin charsets with accents" do
    {
      "exámenes" => "examenes",
      "componentização" => "componentizacao",
      "uzaktançalışmak" => "uzaktancalismak",
      "cáđộbóngđá" => "cadobongda"
    }.each do |original, expected|
      it "converts #{original} to #{expected}" do
        tag = create_tag(original)

        update.run

        expect(tag.reload.name).to eq expected
      end
    end
  end

  context "with names in non-Latin character sets" do
    %w[
      ساختلانجربرایپایچ
      ไทย
    ].each do |name|
      it "does not alter #{name}" do
        tag = create_tag(name)

        update.run

        expect(tag.reload.name).to eq name
      end
    end
  end

  describe "sanitization of denormalized cached_tag_list" do
    it do
      article = create_article(tags: %w[exámenes componentização])

      update.run

      expect(article.reload.cached_tag_list).to eq "examenes, componentizacao"
    end
  end

  private

  # [@jgaskins]: I'm not sure if we can create a tag with an invalid name
  #   using FactoryBot, so I'm creating it with an arbitrary name and
  #   changing it without validations to get it into that invalid state.
  #   This also requires that we create articles using the same helper.
  def create_article(tags:, **options)
    tags = tags.map { |name| create_tag(name) }

    article = create(:article, **options)
    article.tags.clear
    article.tags << tags
    article.update_columns cached_tag_list: tags.map(&:name).join(", ")

    article
  end

  def create_tag(name)
    tag = create(:tag, name: SecureRandom.hex[0...30])
    tag.update_columns name: name
    tag
  end
end
