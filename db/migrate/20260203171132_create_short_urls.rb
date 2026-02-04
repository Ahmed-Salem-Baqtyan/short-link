class CreateShortUrls < ActiveRecord::Migration[8.0]
  def change
    create_table(:short_urls) do |t|
      t.references(:user, null: false, foreign_key: true)

      t.text(:url)
      t.string(:code)

      t.timestamps

      t.index(:code, unique: true)
    end
  end
end
