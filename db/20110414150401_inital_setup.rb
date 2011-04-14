class InitalSetup < ActiveRecord::Migration
  def self.up
    create_table :credit_types, :force => true do |t|
      t.string :name
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
      t.integer :credits
      t.datetime :occurred_at
    end
  end

  def self.down
    drop_table :credit_types
    drop_table :credit_user_credits
    drop_table :credit_transactions
  end
end
