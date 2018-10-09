class CreateBusinessCustomerInterests < ActiveRecord::Migration[5.1]
  def change
    create_table :business_customer_interests do |t|
      t.references :business, foreign_key: true
      t.references :customer_interest, foreign_key: true

      t.timestamps
    end
  end
end
