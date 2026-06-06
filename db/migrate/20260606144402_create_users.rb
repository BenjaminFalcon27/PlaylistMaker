class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :spotify_uid
      t.string :spotify_token
      t.string :spotify_refresh_token
      t.datetime :token_expires_at
      t.string :display_name
      t.string :email
      t.string :avatar_url

      t.timestamps
    end
  end
end
