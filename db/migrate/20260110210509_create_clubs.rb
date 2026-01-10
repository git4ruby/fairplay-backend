class CreateClubs < ActiveRecord::Migration[8.0]
  def change
    create_table :clubs do |t|
      t.string :name, null: false
      t.text :address, null: false
      t.integer :no_of_courts, null: false, default: 1
      t.string :email
      t.string :phone_number

      t.timestamps
    end

    add_index :clubs, :name
  end
end
