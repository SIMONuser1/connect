class ReplaceBusinessSkillsAndSkillsTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :business_skills
    drop_table :skills

    add_column :businesses, :desired_partnership_types, :string, array: true
    add_column :businesses, :offered_partnership_types, :string, array: true
  end
end
