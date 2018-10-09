class AddFrequencyToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :frequency, :string, default: "daily"
  end
end
