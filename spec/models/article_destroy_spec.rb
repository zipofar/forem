require "rails_helper"

# TestProf::FactoryAllStub.init
# TestProf::FactoryAllStub.enable!

RSpec.describe Article, type: :model do
  context "when no organization" do
    # Setting published explicitly to true to pass guard clause in the async_score_calc method on
    # the Article model that returns early if the article is unpublished
    it "doesn't create ScoreCalcWorker on destroy" do
      article = create(:article, published: true)
      create(:reaction, reactable: article)

      sidekiq_assert_no_enqueued_jobs(only: Articles::ScoreCalcWorker) do
        article.destroy
      end
    end
  end

  context "with organization" do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }
    let!(:article) { create(:article, organization: organization, user: user) }
    let!(:org_article) { create(:article, organization: organization) }
    let!(:user_article) { create(:article, user: user) }
    let!(:org_user_article) { create(:article, user: user, organization: organization) }

    it "queues BustCacheJob with user and organization article_ids" do
      sidekiq_assert_enqueued_with(job: Articles::BustMultipleCachesWorker,
                                   args: [[user_article.id, org_user_article.id, org_article.id].sort]) do
        article.destroy
      end
    end
  end
end
