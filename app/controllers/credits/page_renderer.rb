class Credits::PageRenderer < ParagraphRenderer
  features '/credits/page_feature'

  paragraph :buy
  paragraph :reward_source_user

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

      if @options.testing?
        credits_to_give = @options.test_credits - @user.total_credits
        @user.add_credits(credits_to_give, :note => "[Testing (#{site_node.node_path})]") if credits_to_give > 0
        redirect_paragraph @options.test_success_page_url
        return
      end

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

  def reward_source_user
    @options = paragraph_options :reward_source_user
    return render_paragraph :nothing => true unless myself.id && @options.credit_type
    
    if editor?
      @source_user = EndUser.first
      render_paragraph :feature => :credits_page_reward_source_user
      return
    end

    @source_user = myself.source_user
    if @source_user
      unless CreditTransaction.by_achievement(myself).where(:end_user_id => @source_user.id).first
        credit_user = @options.credit_type.push_user(@source_user)
        credit_user.add_credits @options.credits, :note => '[Source user credits]', :achievement => myself
      end
    end
    
    render_paragraph :feature => :credits_page_reward_source_user
  end

  protected

  include Shop::CartUtility # Get Cart Functionality

end
