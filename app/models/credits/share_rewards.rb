class Credits::ShareRewards < HashModel
  def self.share_rewards_handler_info
    {
      :name => 'Credits for Sources'
    }
  end
  
  attributes :credits => 1, :credit_type_id => nil

  integer_options :credits

  validates_presence_of :credits, :credit_type_id

  options_form(
               fld(:credits, :text_field, :description => 'credits to earn for sources'),
               fld(:credit_type_id, :select, :options => :credit_type_options)
               )
  
  def credit_type
    @credit_type ||= CreditType.where(:id => self.credit_type_id).first if self.credit_type_id
  end

  def reward(user, sources)
    return unless self.credit_type
    
    credit_user = self.credit_type.push_user(user)
    
    sources.each do |source|
      source = source.end_user if source.respond_to?(:end_user)
      next if CreditTransaction.by_achievement(source).where(:end_user_id => user.id).first
      credit_user.add_credits self.credits, :note => '[Share credits for source]', :achievement => source
    end
  end
  
  def credit_type_options
    CreditType.select_options_with_nil
  end
end
