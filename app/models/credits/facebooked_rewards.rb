class Credits::FacebookedRewards < HashModel
  def self.facebooked_rewards_handler_info
    {
      :name => 'Credit Facebook Friends'
    }
  end
  
  attributes :credits => 1, :credit_type_id => nil

  integer_options :credits

  validates_presence_of :credits, :credit_type_id

  options_form(
               fld(:credits, :text_field, :description => 'credits to assign friends'),
               fld(:credit_type_id, :select, :options => :credit_type_options)
               )
  
  def credit_type
    @credit_type ||= CreditType.where(:id => self.credit_type_id).first if self.credit_type_id
  end

  def reward(oauth_user, friends)
    return unless self.credit_type
    
    friends.each do |user|
      user = user.end_user if user.respond_to?(:end_user)
      next if CreditTransaction.by_achievement(oauth_user).where(:end_user_id => user.id).first
      credit_user = self.credit_type.push_user(user)
      credit_user.add_credits self.credits, :note => '[Facebook friend credits]', :achievement => oauth_user
    end
  end
  
  def credit_type_options
    CreditType.select_options_with_nil
  end
  
  def features(c, data, base='reward')
    c.value_tag("#{base}:credits") { |t| self.credits }
    c.h_tag("#{base}:name") { |t| self.credit_type.name if self.credit_type }
  end
end
