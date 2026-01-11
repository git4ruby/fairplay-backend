class CreateClubOwnerships < ActiveRecord::Migration[8.0]
  def change
    create_table :club_ownerships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true

      t.timestamps
    end

    add_index :club_ownerships, [ :user_id, :club_id ], unique: true
  end
end
