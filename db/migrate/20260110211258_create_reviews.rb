class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :match, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :video_url, null: false
      t.string :landing_frame_url
      t.integer :decision
      t.decimal :confidence, precision: 5, scale: 2
      t.decimal :landing_x, precision: 10, scale: 6
      t.decimal :landing_y, precision: 10, scale: 6
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :reviews, :status
    add_index :reviews, :created_at
  end
end
