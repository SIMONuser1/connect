class CreateClicks < ActiveRecord::Migration[5.1]
  def change
    create_table :clicks do |t|
      t.references :clicker, foreign_key: {to_table: :businesses}
      t.references :clicked, foreign_key: {to_table: :businesses}
      t.integer :count, default: 1

      t.timestamps
    end
  end
end
