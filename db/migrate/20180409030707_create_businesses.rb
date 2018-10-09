class CreateBusinesses < ActiveRecord::Migration[5.1]
  def change
    create_table :businesses do |t|
      t.string :name
      t.string :industries, array: true, default: []
      t.string :employees
      t.string :other_partners, array: true, default: [] # or "{}"
      t.string :other_competitors, array: true, default: [] # or "{}"

      t.timestamps
    end
  end
end
