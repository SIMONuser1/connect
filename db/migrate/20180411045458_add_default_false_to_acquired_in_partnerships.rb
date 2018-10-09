class AddDefaultFalseToAcquiredInPartnerships < ActiveRecord::Migration[5.1]
  def change
    change_column :partnerships, :acquired, :boolean, default: false, null: false
  end
end
