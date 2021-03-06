class CreditTransaction < DomainModel
  belongs_to :credit_user_credit
  has_end_user :end_user_id
  belongs_to :achievement, :polymorphic => true
  
  validates_presence_of :credit_user_credit_id
  validates_presence_of :amount
  
  before_create :set_defaults
  after_save :add_credits_to_user

  def self.by_user(user)
    self.where(:end_user_id => user.id)
  end

  def self.by_achievement(achievement)
    self.where(:achievement_id => achievement.id, :achievement_type => achievement.class.to_s)
  end
  
  def set_defaults
    self.end_user_id = self.credit_user_credit.end_user_id if self.credit_user_credit
  end

  def add_credits_to_user
    if self.purchased && self.purchased_changed?
      # Don't create another transaction
      self.credit_user_credit.add_credits self.amount, :skip => true
    end
  end

  def price
    self.credit_user_credit.price
  end

  def type_name
    self.credit_type.name
  end

  def credit_type
    self.credit_user_credit.credit_type
  end

  def credit_type_id
    self.credit_user_credit.credit_type.id if self.credit_user_credit
  end

  # cart functions

  def name
    self.credit_type.name
  end

  def coupon?
    false
  end

  def cart_details(options, cart)
    ''
  end

  def cart_shippable?
    false
  end
  
  def cart_sku
    "#{self.name.gsub(' ', '-').upcase}-CREDITS"
  end

  def cart_price(options, cart)
    1.0 / self.price
  end

  def cart_limit(options, cart)
    1000
  end

  def cart_post_processing(user, order_item, session)
    return if self.purchased?

    self.amount = order_item.quantity
    self.purchased = true
    self.save
  end     
end
