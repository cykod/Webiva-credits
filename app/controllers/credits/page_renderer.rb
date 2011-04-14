class Credits::PageRenderer < ParagraphRenderer
  features '/credits/page_feature'

  paragraph :buy

  def buy
    @options = paragraph_options :buy

    return render_paragraph :text => 'Configure Buy Paragraph' unless @options.credit_type
    
    @user = @options.credit_type.push_user(myself) if myself.id

    cart = nil
    product = nil
    if @user
      cart = get_cart
      product = cart.products.detect { |p| p.cart_item_type == 'CreditTransaction' }

      @credits = product ? @user.credit_transactions.find_by_id(product.cart_item_id) : @user.credit_transactions.build(:amount => 0, :note => '[User purchased]')
      @credits.amount = product.quantity if product
    end

    if request.post? && ! editor? && @credits && params[:credits]
      amount = (params[:credits][:amount] || 0).to_i

      # remove the credits
      if product && amount == 0
        cart.edit_product @credits, 0
        @credits.destroy
        if @options.success_page_url
          redirect_paragraph @options.success_page_url
          return
        end
        @removed = true
      else
        @credits.amount = amount

        if @credits.save
          product ? cart.edit_product(@credits, amount) : cart.add_product(@credits, amount)
          if @options.success_page_url
            redirect_paragraph @options.success_page_url
            return
          end
          @updated = true
        end
      end
    end
    
    render_paragraph :feature => :credits_page_buy
  end

  protected

  include Shop::CartUtility # Get Cart Functionality

end
