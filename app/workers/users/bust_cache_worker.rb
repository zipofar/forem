module Users
  class BustCacheWorker < BustCacheBaseWorker
    include Sidekiq::Job

    sidekiq_options queue: :high_priority, retry: 5

    def perform(user_id)
      user = User.find_by(id: user_id)
      return unless user

      EdgeCache::BustUser.call(user)
    end
  end
end
