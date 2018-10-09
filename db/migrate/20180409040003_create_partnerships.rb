class CreatePartnerships < ActiveRecord::Migration[5.1]
  def change
    create_table :partnerships do |t|
      t.references :business, foreign_key: true
      t.references :partner, foreign_key: {to_table: :businesses}
      t.boolean :acquired, null: false

      t.timestamps
    end
  end
end
