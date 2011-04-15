
class Credits::ManageUserController < ModuleController
  include ActiveTable::Controller

  permit 'credits_manage'

  component_info 'Credits'

  def self.members_view_handler_info
    {
      :name => 'Credits',
      :controller => '/credits/manage_user',
      :action => 'view'
    }
   end

  # need to include
  active_table :transactions_table,
                CreditTransaction,
                [ hdr(:static, 'Type'),
                  :amount,
                  :note,
                  :purchased,
                  hdr(:static, 'Achievement'),
                  :created_at,
                  :updated_at
                ]

  public

  def display_transactions_table(display=true)
    @user ||= EndUser.find params[:path][0]
    @tab ||= params[:tab]

    active_table_action 'transaction' do |act,ids|
    end

    @active_table_output = transactions_table_generate params, :conditions => ['credit_transactions.end_user_id = ?', @user.id], :include => :credit_user_credit, :order => 'created_at DESC'

    render :partial => 'transactions_table' if display
  end

  def view
    @user = EndUser.find params[:path][0]
    @tab = params[:tab]
    display_transactions_table(false)
    render :partial => 'view'
  end

  def transaction
    @user = EndUser.find params[:path][0]
    @tab = params[:tab]
    @transaction = CreditTransaction.new

    if request.post? && params[:transaction]
      credit_type = CreditType.find_by_id params[:transaction].delete(:credit_type_id)
      if credit_type
        credit_user = credit_type.push_user @user
        @transaction = credit_user.credit_transactions.new params[:transaction]
        @transaction.admin_user_id = myself.id
        @transaction.note = "[Administrative]" if @transaction.note.to_s.strip.blank?

        if params[:commit] && @transaction.valid?
          if @transaction.amount > 0
            credit_user.add_credits @transaction.amount, :note => @transaction.note, :admin_user_id => myself.id
          elsif @transaction.amount < 0
            credit_user.use_credits @transaction.amount, :note => @transaction.note, :admin_user_id => myself.id
          end

          render :update do |page|
            page << 'CreditsData.viewTransactions();'
          end
          return
        end
      end
    end

    render :partial => 'transaction'
  end
end
