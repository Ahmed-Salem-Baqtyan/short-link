HASHIDS = Hashids.new(
  Rails.application.secret_key_base,
  6
)