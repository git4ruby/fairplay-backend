class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.references :court, null: false, foreign_key: true
      t.integer :match_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end

    add_index :matches, :status
    add_index :matches, :start_time
  end
end
