class CreateCustomerInterests < ActiveRecord::Migration[5.1]
  def change
    create_table :customer_interests do |t|
      t.string :name

      t.timestamps
    end
  end
end
