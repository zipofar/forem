require "rails_helper"

RSpec.describe Metrics::RecordBackgroundQueueStatsWorker, type: :worker do
  include_examples "#enqueues_on_correct_queue", "low_priority", 1

  subject(:worker) { described_class.new(queues: queues, workers: workers, stats: stats) }
  let(:queues) { [double("Queue", name: "default", size: 1, latency: 2)] }
  let(:workers) { double("Workers", size: 12) }
  let(:stats) { double("Stats") }

  describe "#perform" do
    it "logs estimated counts in Datadog" do
      allow(stats).to receive(:gauge)

      worker.perform

      expect_stats "sidekiq.queues.total_size", 1, tags: []
      expect_stats "sidekiq.queues.total_workers", 12, tags: []
      expect_stats "sidekiq.queues.latency", 2, tags: %w[sidekiq_queue:default]
      expect_stats "sidekiq.queues.size", 1, tags: %w[sidekiq_queue:default]
    end

    private def expect_stats(name, value, tags:)
      expect(stats)
        .to have_received(:gauge)
        .with(name, value, tags: tags)
    end
  end
end
