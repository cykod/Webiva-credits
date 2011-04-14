class CreditTransaction < DomainModel
  belongs_to :credit_user_credit
  
  validates_presence_of :credits
  
  before_create :set_defaults
  
  def set_defaults
    self.occurred_at = Time.now
  end
end
