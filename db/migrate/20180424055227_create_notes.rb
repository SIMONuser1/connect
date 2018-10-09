class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.references :owner, foreign_key: {to_table: :businesses}
      t.references :noted, foreign_key: {to_table: :businesses}
      t.text :content

      t.timestamps
    end
  end
end
