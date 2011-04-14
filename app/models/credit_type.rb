class CreditType < DomainModel
  has_many :credit_user_credits, :dependent => :destroy
  
  validates_presence_of :name
end
