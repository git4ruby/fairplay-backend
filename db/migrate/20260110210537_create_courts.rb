class CreateCourts < ActiveRecord::Migration[8.0]
  def change
    create_table :courts do |t|
      t.string :name, null: false
      t.references :club, null: false, foreign_key: true

      t.timestamps
    end

    add_index :courts, [:club_id, :name], unique: true
  end
end
