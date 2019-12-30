Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  config.active_support.deprecation = :log
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end
end
