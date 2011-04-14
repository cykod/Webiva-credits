class InitalSetup < ActiveRecord::Migration
  def self.up
    create_table :credit_types, :force => true do |t|
      t.string :name
      t.decimal :price, :precision=> 14, :scale => 2
      t.timestamps
    end
    
    create_table :credit_user_credits, :force => true do |t|
      t.integer :end_user_id
      t.integer :credit_type_id
      t.integer :total_credits
      t.integer :used_credits
      t.timestamps
    end
    
    create_table :credit_transactions, :force => true do |t|
      t.integer :credit_user_credit_id
      t.integer :end_user_id
      t.integer :amount
      t.boolean :purchased, :default => false
      t.text :note
      t.integer :admin_user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :credit_types
    drop_table :credit_user_credits
    drop_table :credit_transactions
  end
end
