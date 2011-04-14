class Credits::ManageController < ModuleController
  include ActiveTable::Controller

  permit 'credits_manage'

  component_info 'Credits'

  cms_admin_paths 'content',
                  'Content'   => {:controller => '/content'},
                  'Types' => {:controller => 'admin', :action => 'types'},
                  'Users Credits' => {:action => 'user_credits'}

  active_table :user_credits_table,
                CreditUserCredit,
                [ hdr(:string, 'end_users.full_name'),
                  hdr(:options, :credit_type_id, :options => :credit_type_options),
                  :total_credits,
                  :used_credits,
                  :created_at,
                  :updated_at
                ]
  
  def display_user_credits_table(display=true)
    active_table_action 'credit' do |act,ids|
    end

    @active_table_output = user_credits_table_generate params, :order => 'credit_user_credits.created_at DESC', :joins => [:end_user, :credit_type]

    render :partial => 'user_credits_table' if display
  end
  
  def user_credits
    cms_page_path ['Content'], 'Users Credits'
    display_user_credits_table false
  end
  
  active_table :transactions_table,
                CreditTransaction,
                [ :credits,
                  :occurred_at
                ]
  
  def display_transactions_table(display=true)
    @user_credit ||= CreditUserCredit.find params[:path][0]

    active_table_action 'transaction' do |act,ids|
    end

    @active_table_output = transactions_table_generate params,
    :conditions => ['credit_transactions.credit_user_credit_id = ?', @user_credit.id],
    :order => 'credit_transactions.occurred_at DESC'

    render :partial => 'transactions_table' if display
  end
  
  def transactions
    @user_credit = CreditUserCredit.find params[:path][0]
    cms_page_path ['Content', 'Users Credits'], 'Transactions'
    display_transactions_table false
  end
  
  protected
  
  def credit_type_options
    CreditType.select_options
  end
end
