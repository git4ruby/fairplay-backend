class CreateMatchPlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :match_players do |t|
      t.references :match, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :team_number, null: false

      t.timestamps
    end

    add_index :match_players, [ :match_id, :user_id ], unique: true
  end
end
