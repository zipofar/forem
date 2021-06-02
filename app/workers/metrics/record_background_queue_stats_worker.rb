module Metrics
  class RecordBackgroundQueueStatsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :low_priority, retry: 10

    attr_reader :queues, :workers

    def initialize(queues: Sidekiq::Queue.all, workers: Sidekiq::Workers.new, stats: ForemStatsClient)
      @queues = queues
      @workers = workers
      @stats = stats
    end

    def perform
      log_to_datadog("sidekiq.queues.total_size", queues.sum(&:size))
      log_to_datadog("sidekiq.queues.total_workers", workers.size)

      queues.each do |queue|
        tags = ["sidekiq_queue:#{queue.name}"]

        log_to_datadog("sidekiq.queues.latency", queue.latency, tags)
        log_to_datadog("sidekiq.queues.size", queue.size, tags)
      end
    end

    private

    def log_to_datadog(metric_name, value, tags = [])
      @stats.gauge(metric_name, value, tags: tags)
    end
  end
end
