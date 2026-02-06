class CreateSolidCacheEntries < ActiveRecord::Migration[8.0]
  def change
    create_table(:solid_cache_entries) do |t|
      t.binary(:key, limit: 1024, null: false)
      t.bigint(:key_hash, null: false)
      t.binary(:value, null: false)
      t.text(:value_hash)
      t.integer(:byte_size, null: false, default: 0)
      t.datetime(:expires_at)
      t.timestamps
    end

    add_index(:solid_cache_entries, :key_hash, unique: true)
    add_index(:solid_cache_entries, :expires_at)
  end
end

