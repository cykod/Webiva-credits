class CreditUserCredit < DomainModel
  belongs_to :credit_type
  has_end_user :end_user_id
  
  has_many :credit_transactions, :dependent => :delete_all
  
  validates_presence_of :credit_type_id
  validates_presence_of :end_user_id
  
  def add_credits(credits)
    credits = credits.to_i
    self.connection.update "UPDATE credit_user_credits SET total_credits = total_credits + #{credits} WHERE id = #{self.id}"
    self.total_credits += credits
    self.credit_transactions.create :credits => credits    
    true
  end
  
  def use_credits(credits)
    credits = credits.to_i
    affected_rows = self.connection.update "UPDATE credit_user_credits SET total_credits = total_credits - #{credits}, used_credits = used_credits + #{credits} WHERE id = #{self.id} AND (total_credits - #{credits}) >= 0"
    return false unless affected_rows == 1
    self.total_credits -= credits
    self.used_credits += credits
    self.credit_transactions.create :credits => -credits
    true
  end
end
