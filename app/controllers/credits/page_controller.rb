class Credits::PageController < ParagraphController

  editor_header 'Credits Paragraphs'
  
  editor_for :buy, :name => "Buy", :feature => :credits_page_buy

  class BuyOptions < HashModel
    attributes :success_page_id => nil, :credit_type_id => nil

    page_options :success_page_id

    validates_presence_of :credit_type_id

    options_form(
                 fld(:success_page_id, :page_selector),
                 fld(:credit_type_id, :select, :options => :credit_type_options)
                 )
    
    def credit_type
      @credit_type ||= CreditType.where(:id => self.credit_type_id).first
    end

    def credit_type_options
      CreditType.select_options_with_nil
    end
  end
end
