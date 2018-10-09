class CreateSuggestions < ActiveRecord::Migration[5.1]
  def change
    create_table :suggestions do |t|
      t.references :business, foreign_key: true
      t.references :suggested_business, foreign_key: { to_table: :businesses}
      t.integer :rating, default: 0

      t.timestamps
    end
  end
end
