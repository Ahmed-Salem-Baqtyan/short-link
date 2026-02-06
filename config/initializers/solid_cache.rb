Rails.application.config.cache_store = :solid_cache_store,
  { expires_in: 1.hour, marshalled: true }