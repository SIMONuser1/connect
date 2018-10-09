class ChangeDefaultCountInClicksTo0 < ActiveRecord::Migration[5.1]
  def change
    change_column :clicks, :count, :integer, default: 0
  end
end
