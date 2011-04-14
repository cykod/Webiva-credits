
class Credits::AdminController < ModuleController
  include ActiveTable::Controller

  component_info 'Credits', :description => 'Credits support', :access => :public
                              
  # Register a handler feature
  register_permission_category :credits, "Credits", "Permissions related to Credits"
  
  register_permissions :credits, [[:manage, 'Manage Credits', 'Manage Credits'],
                                  [:config, 'Configure Credits', 'Configure Credits']
                                 ]
  cms_admin_paths "options",
     "Credits Types" => { :action => 'types' },
     "Options" => { :controller => '/options' },
     "Modules" => { :controller => '/modules' }

  permit 'credits_config'

  content_model :credits
  
  public
  def self.get_credits_info
    [ { :name => 'Credits', :url => { :controller => '/credits/manage', :action => 'user_credits' }, :permission => :credits_manage }
    ]
  end

  active_table :types_table,
                CreditType,
                [ :name,
                  :created_at
                ]

  def display_types_table(display=true)
    active_table_action 'type' do |act,ids|
    end

    @active_table_output = types_table_generate params, :order => :name

    render :partial => 'types_table' if display
  end

  def types
    cms_page_path ['Options', 'Modules'], 'Credits Types'
    display_types_table false
  end
  
  def type
    cms_page_path ['Options', 'Modules', 'Credits Types'], 'Credit Type'
    @credit_type = CreditType.find(params[:path][0]) if params[:path][0]
    @credit_type ||= CreditType.new
    if request.post? && params[:credit_type] && @credit_type.update_attributes(params[:credit_type])
      flash[:noice] = "#{@credit_type.name} was updated"
      redirect_to :action => 'types'
    end
  end
end
