class CreditUserCredit < DomainModel
  belongs_to :credit_type
  has_end_user :end_user_id
  
  has_many :credit_transactions, :dependent => :delete_all
  
  validates_presence_of :credit_type_id
  validates_presence_of :end_user_id

  before_create :set_defaults
  after_create :initial_transaction

  def name
    self.end_user.name
  end

  def add_credits(credits, opts={})
    credits = credits.to_i
    self.connection.update "UPDATE credit_user_credits SET total_credits = total_credits + #{credits} WHERE id = #{self.id}"
    self.total_credits += credits

    # when credits are being purchased, we've already created a transaction
    self.credit_transactions.create(:amount => credits, :note => '[Earned credits]') unless opts[:skip]

    true
  end
  
  def use_credits(credits, opts={})
    credits = credits.to_i
    affected_rows = self.connection.update "UPDATE credit_user_credits SET total_credits = total_credits - #{credits}, used_credits = used_credits + #{credits} WHERE id = #{self.id} AND (total_credits - #{credits}) >= 0"
    return false unless affected_rows == 1
    self.total_credits -= credits
    self.used_credits += credits
    self.credit_transactions.create :amount => -credits, :note => '[Used credits]'
    true
  end
  
  def set_defaults
    self.total_credits ||= 0
    self.used_credits ||= 0
  end

  def initial_transaction
    self.credit_transactions.create(:amount => self.total_credits, :note => '[Initail credits]') if self.total_credits > 0
  end

  def price
    self.credit_type.price
  end
end
