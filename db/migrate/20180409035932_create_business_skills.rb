class CreateBusinessSkills < ActiveRecord::Migration[5.1]
  def change
    create_table :business_skills do |t|
      t.references :business, foreign_key: true
      t.references :skill, foreign_key: true
      t.boolean :acquired, null: false

      t.timestamps
    end
  end
end
