class CreateCompetitions < ActiveRecord::Migration[5.1]
  def change
    create_table :competitions do |t|
      t.references :business, foreign_key: true
      t.references :competitor, foreign_key: { to_table: :businesses}

      t.timestamps
    end
  end
end
