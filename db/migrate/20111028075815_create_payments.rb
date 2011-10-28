class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.float :amount
      t.string :transaction_id
      t.references :user
      t.references :course

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
