module DataUpdateScripts
  class CreateReactionCategoryDefaults
    def run
      ReactionCategoryDefaultWorker.perform_async
    end
  end
end
