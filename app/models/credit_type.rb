class CreditType < DomainModel
  has_many :credit_user_credits, :dependent => :destroy
  
  validates_presence_of :name
  
  def push_user(user)
    self.credit_user_credits.where(:end_user_id => user.id).first || self.credit_user_credits.create(:end_user_id => user.id)
  end
end
