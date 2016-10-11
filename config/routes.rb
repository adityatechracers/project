Corkcrm::Application.routes.draw do

  root :to => 'pages#show', :id => 'home/index'
  post 'stripe_callbacks' => 'stripe_callbacks#create'

  get '/dashboard' => 'dashboard#index', :as => :dashboard
  get '/user_created' => 'users#created', :as => :user_created
  get '/blog' => 'posts#index', :as => :blog
  get '/pages/*id' => 'pages#show', :as => :page, :format => false

  devise_for :users, controllers: { registrations: "registrations", omniauth_callbacks: "omniauth_callbacks" }
  resources :users
  resources :quotes
  resources :inquiries
  resources :proposal_item_responses
  resources :proposal_section_responses

  namespace :web_hooks,  defaults: {format: 'json'} do
    resources :quick_books, :only => [] do
      collection do
        post '/', action: :index
      end
    end
  end

  namespace :uploads do
    resources :froala, only: [:create, :destroy] do

    end

  end
  resources :config, controller: :app_config, defaults: {format: 'json'}, only: [] do
    collection do
      get 'froala'
    end
  end

  resources :quick_books, only:[] do
    collection do
      get :authenticate
      get :oauth_callback
      get :bluedot
      get :success
      delete :disconnect
    end
  end

  resources :google_calendars, only:[] do
    collection do
      get :list
      post :choose
    end
  end

  resources :posts, :path => 'blog' do
    collection do
      get ':post_slug', :action => 'show', :as => :show
    end
  end

  get "/contract_portal/:id" => "proposals#contract_portal", :as => "contract_portal"
  get "/proposal_portal/:id" => "proposals#proposal_portal", :as => "proposal_portal"
  post '/header_table_preview' => 'proposals#header_table_preview', :as => :proposal_header_table_preview
  put '/header_table_preview' => 'proposals#header_table_preview', :as => :proposal_header_table_preview

  resources :proposals do
    resources :change_orders
    get 'new/:ptid' => 'proposals#new', :on => :collection, :as => :new_proposal
    member do
      get 'get_contact_rating'
      get 'print', :as => :print
      get 'contract', :as => :contract
      get 'void_contract', :as => :void_contract
      get 'print_contract', :as => :print_contract
      put 'issue', :as => :issue
      post 'store_signatures', :as => :store_signatures
      post 'email_proposal', :as => :email
      post 'upload_files'
    end
    collection do
      post 'table'
    end
  end

  resources :contacts do
    collection do
      get 'new_lead'
      get 'export'
      get 'zestimate'
      get 'edit_lead/:id' => 'contacts#edit_lead'
      post 'table'
      post 'contact_rating'
      post 'create_from_embedded_form'
    end
  end

  resources :jobs do
    collection do
      post 'table'
      post 'fetch'
      post 'contact_rating'
      get 'modal'
      get 'schedule'
      get 'crew_calendar'
      get 'crew_calendar_row'
      get 'find_by_address'
      resources :expenses
      resources :expense_categories
      resources :vendor_categories
      resources :payments
      resources :timecards do
        collection do
          get "modal_form"
          post "update_state"
        end
        member do
          get "modal_form"
          get "approve"
          get "unapprove"
          get "mark_paid"
          get "unmark_paid"
        end
      end
    end
    member do
      get 'modal'
      get 'mark_dead'
      get 'mark_undead'
      get 'complete'
      get 'uncomplete'
      post 'request_client_feedback'
      get 'new_invoice_modal'
      post 'send_invoice'
    end
    resources :expenses
    resources :payments
    resources :timecards
  end
  get "expenses/expense_edit_jobs"

  get "/feedback_portal/:id" => "job_feedback#new", :as => "feedback_portal"
  post "/feedback_portal/:id" => "job_feedback#create"
  resources :job_feedback

  resources :job_schedule_entries do
    collection do
      get 'modal'
    end
    member do
      get 'modal'
    end
  end

  resources :appointments do
    collection do
      get 'fetch_open'
      post 'fetch'
      get 'modal'
      get 'feed'
      get 'google_disconnect'
      get 'get_contact_rating'
    end
    get 'modal', :on => :member
  end

  get 'availabilities' => 'availabilities#index', :as => :availabilities
  get 'availabilities/:date' => 'availabilities#move_days', :as => :availabilities_move_days
  get 'availabilities/:date/available_employees' => 'availabilities#available_employees', :as => :availabilities_available_employees
  get 'availabilities/:date/appointment_modal' => 'availabilities#appointment_modal', :as => :availabilities_appointment_modal

  # resources :communications do
  #   collection do
  #     get 'schedule', :as => :schedule
  #     get ':job_id/start_new_form', :action => "start_new_form"
  #     get ':job_id/plan_form', :action => "plan_form"
  #     get 'modal'
  #   end
  #   member do
  #     get 'start', :as => :start_communication
  #     get 'start_planned_form', :as => :communication_start_form
  #     get 'modal'
  #   end
  # end

  resources :communications, only: [:create]

  resources :planned_communications
  resources :communication_records

  resources :parsers, only: [] do
    collection do
      post :fetch_parse_data
    end
  end


  resources :mail_parsers, only: [] do
    collection do
      get :fetch_parse_data
    end
  end

  resources :leads do
    collection do
      get 'import'
      post 'import'
      get 'export'
      get 'print'
      post 'table'
      get 'embed' => "leads#embed_schedule"
      get 'embed/ask_questions' => 'leads#embed_ask_questions'
      get 'new/:contact' => 'leads#new', :as => :new_with_contact
      resources :sources, :controller => :lead_sources, :as => :lead_sources
    end
  end

  get "/get_regions/:country" => "dashboard#get_regions"
  get "get_leads_stats" => "dashboard#get_leads_stats"
  get "get_proposals_stats" => "dashboard#get_proposals_stats"
  get "get_jobs_stats" => "dashboard#get_jobs_stats"
  get "get_sales_stats" => "dashboard#get_sales_stats"
  get "get_footer" => "dashboard#get_footer"
  
  namespace :manage do
    root :to => 'base#index'
    resources :users do
      get 'become', :on => :member
      get 'switch_back', :on => :member
    end
    resources :crews
    resources :managed_organizations do
      get 'become', :on => :member
    end
    resources :email_templates do
      member do
        put 'restore/:version_id', :action => 'restore', :as => :restore
        post 'toggle', :action => 'toggle', :as => :toggle
        post 'test', :action => 'test', :as => :test
      end
    end
    resources :proposal_templates do
      put 'restore/:version_id', :action => 'restore', :on => :member, :as => :restore
      get 'edit_contract', :on => :member, :as => :edit_contract
      get 'contract', :on => :member, :as => :contract
      post 'reorder_sections', :on => :member
      get "load_versions"
      resources :sections, :controller => :proposal_template_sections do
        put 'restore/:version_id', :action => 'restore', :on => :member, :as => :restore
        resources :items, :controller => :proposal_template_items do
          put 'restore/:version_id', :action => 'restore', :on => :member, :as => :restore
        end
      end
    end
    resources :subscriptions, :except => [:show]
    get 'organization/edit' => 'organizations#edit', :as => :edit_organization
    put 'organization' => 'organizations#update', :as => :update_organization
    post 'organization/change_signature' => 'organizations#change_signature', :as => :change_signature
    get 'organization/get_signature' => 'organizations#get_signature', :as => :get_signature
    get 'website_embed' => 'base#website_embed'
    put 'website_embed' => 'base#website_embed'
    get 'subscription' => 'subscriptions#edit', :as => :subscription
    put 'subscription' => 'subscriptions#update', :as => :update_subscription
    delete 'subscription' => 'subscriptions#destroy', :as => :delete_subscription
    get 'edit_card' => 'subscriptions#edit_card', :as => :edit_card
    put 'edit_card' => 'subscriptions#update_card', :as => :update_card
    get 'calendar_options' => 'calendar_options#index', :as => :calendar_options
    post 'calendar_options' => 'calendar_options#set_calendar_options', :as => :set_calendar_options

    resources :reports do
      collection do
        get 'leads'
        get 'timesheets'
        get 'appointments'
        get 'proposals'
        get 'jobs'
        get 'job_cost'
        get 'payroll'
        get 'expenses'
        get 'profit'
        get 'profit_totals'
        get 'deposit_payment_tracking'
        get 'deposit_payment_tracking_totals'
        get 'clients'
        get 'estimates'
        get 'sales_performance'
        get 'communications'
        get 'managed_organizations'
        get 'accounts_receivable'
        get 'weekly_booking'
      end
    end
  end

  namespace :admin do
    root :to => 'base#index'
    get 'failing_cards' => 'base#failing_cards'
    get 'activity' => 'base#activity'
    resources :invoices, :only => [:index, :show]
    resources :inquiries, :only => [:index, :show, :destroy]
    resources :posts
    resources :organizations do
      put 'apply_credit', :on => :member
      put 'disable', :on => :member
      put 'enable', :on => :member
      post 'table', :on => :collection
    end
    resources :users do
      get 'export', :on => :collection
      get 'become', :on => :member
      post 'table', :on => :collection
    end
    resources :email_templates do
      member do
        put 'restore/:version_id', :action => 'restore', :as => :restore
        post 'toggle', :action => 'toggle', :as => :toggle
        post 'test', :action => 'test', :as => :test
      end
      collection do
        post 'sort_email_templates'
      end
    end
    post 'cms/update' => "base#update_cms"
    resources :proposal_templates do
      put 'restore/:version_id', :action => 'restore', :on => :member, :as => :restore
      get 'edit_contract', :on => :member, :as => :edit_contract
      get 'contract', :on => :member, :as => :contract
      post 'reorder_sections', :on => :member
      resources :sections, :controller => :proposal_template_sections do
        resources :items, :controller => :proposal_template_items
      end
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
#== Route Map
# Generated on 30 Jan 2015 12:00
#
#                           stripe_callbacks POST   /stripe_callbacks(.:format)                                                                    stripe_callbacks#create
#                                  dashboard GET    /dashboard(.:format)                                                                           dashboard#index
#                                       blog GET    /blog(.:format)                                                                                posts#index
#                                       page GET    /pages/*id                                                                                     pages#show
#                           new_user_session GET    /users/sign_in(.:format)                                                                       devise/sessions#new
#                               user_session POST   /users/sign_in(.:format)                                                                       devise/sessions#create
#                       destroy_user_session DELETE /users/sign_out(.:format)                                                                      devise/sessions#destroy
#                              user_password POST   /users/password(.:format)                                                                      devise/passwords#create
#                          new_user_password GET    /users/password/new(.:format)                                                                  devise/passwords#new
#                         edit_user_password GET    /users/password/edit(.:format)                                                                 devise/passwords#edit
#                                            PUT    /users/password(.:format)                                                                      devise/passwords#update
#                   cancel_user_registration GET    /users/cancel(.:format)                                                                        devise/registrations#cancel
#                          user_registration POST   /users(.:format)                                                                               devise/registrations#create
#                      new_user_registration GET    /users/sign_up(.:format)                                                                       devise/registrations#new
#                     edit_user_registration GET    /users/edit(.:format)                                                                          devise/registrations#edit
#                                            PUT    /users(.:format)                                                                               devise/registrations#update
#                                            DELETE /users(.:format)                                                                               devise/registrations#destroy
#                                      users GET    /users(.:format)                                                                               users#index
#                                            POST   /users(.:format)                                                                               users#create
#                                   new_user GET    /users/new(.:format)                                                                           users#new
#                                  edit_user GET    /users/:id/edit(.:format)                                                                      users#edit
#                                       user GET    /users/:id(.:format)                                                                           users#show
#                                            PUT    /users/:id(.:format)                                                                           users#update
#                                            DELETE /users/:id(.:format)                                                                           users#destroy
#                                     quotes GET    /quotes(.:format)                                                                              quotes#index
#                                            POST   /quotes(.:format)                                                                              quotes#create
#                                  new_quote GET    /quotes/new(.:format)                                                                          quotes#new
#                                 edit_quote GET    /quotes/:id/edit(.:format)                                                                     quotes#edit
#                                      quote GET    /quotes/:id(.:format)                                                                          quotes#show
#                                            PUT    /quotes/:id(.:format)                                                                          quotes#update
#                                            DELETE /quotes/:id(.:format)                                                                          quotes#destroy
#                                  inquiries GET    /inquiries(.:format)                                                                           inquiries#index
#                                            POST   /inquiries(.:format)                                                                           inquiries#create
#                                new_inquiry GET    /inquiries/new(.:format)                                                                       inquiries#new
#                               edit_inquiry GET    /inquiries/:id/edit(.:format)                                                                  inquiries#edit
#                                    inquiry GET    /inquiries/:id(.:format)                                                                       inquiries#show
#                                            PUT    /inquiries/:id(.:format)                                                                       inquiries#update
#                                            DELETE /inquiries/:id(.:format)                                                                       inquiries#destroy
#                    proposal_item_responses GET    /proposal_item_responses(.:format)                                                             proposal_item_responses#index
#                                            POST   /proposal_item_responses(.:format)                                                             proposal_item_responses#create
#                 new_proposal_item_response GET    /proposal_item_responses/new(.:format)                                                         proposal_item_responses#new
#                edit_proposal_item_response GET    /proposal_item_responses/:id/edit(.:format)                                                    proposal_item_responses#edit
#                     proposal_item_response GET    /proposal_item_responses/:id(.:format)                                                         proposal_item_responses#show
#                                            PUT    /proposal_item_responses/:id(.:format)                                                         proposal_item_responses#update
#                                            DELETE /proposal_item_responses/:id(.:format)                                                         proposal_item_responses#destroy
#                 proposal_section_responses GET    /proposal_section_responses(.:format)                                                          proposal_section_responses#index
#                                            POST   /proposal_section_responses(.:format)                                                          proposal_section_responses#create
#              new_proposal_section_response GET    /proposal_section_responses/new(.:format)                                                      proposal_section_responses#new
#             edit_proposal_section_response GET    /proposal_section_responses/:id/edit(.:format)                                                 proposal_section_responses#edit
#                  proposal_section_response GET    /proposal_section_responses/:id(.:format)                                                      proposal_section_responses#show
#                                            PUT    /proposal_section_responses/:id(.:format)                                                      proposal_section_responses#update
#                                            DELETE /proposal_section_responses/:id(.:format)                                                      proposal_section_responses#destroy
#                                 show_posts GET    /blog/:post_slug(.:format)                                                                     posts#show
#                                      posts GET    /blog(.:format)                                                                                posts#index
#                                            POST   /blog(.:format)                                                                                posts#create
#                                   new_post GET    /blog/new(.:format)                                                                            posts#new
#                                  edit_post GET    /blog/:id/edit(.:format)                                                                       posts#edit
#                                       post GET    /blog/:id(.:format)                                                                            posts#show
#                                            PUT    /blog/:id(.:format)                                                                            posts#update
#                                            DELETE /blog/:id(.:format)                                                                            posts#destroy
#                            contract_portal GET    /contract_portal/:id(.:format)                                                                 proposals#contract_portal
#                     new_proposal_proposals GET    /proposals/new/:ptid(.:format)                                                                 proposals#new
#                             print_proposal GET    /proposals/:id/print(.:format)                                                                 proposals#print
#                          contract_proposal GET    /proposals/:id/contract(.:format)                                                              proposals#contract
#                     void_contract_proposal GET    /proposals/:id/void_contract(.:format)                                                         proposals#void_contract
#                    print_contract_proposal GET    /proposals/:id/print_contract(.:format)                                                        proposals#print_contract
#                             issue_proposal PUT    /proposals/:id/issue(.:format)                                                                 proposals#issue
#                  store_signatures_proposal POST   /proposals/:id/store_signatures(.:format)                                                      proposals#store_signatures
#                             email_proposal POST   /proposals/:id/email_proposal(.:format)                                                        proposals#email_proposal
#                                  proposals GET    /proposals(.:format)                                                                           proposals#index
#                                            POST   /proposals(.:format)                                                                           proposals#create
#                               new_proposal GET    /proposals/new(.:format)                                                                       proposals#new
#                              edit_proposal GET    /proposals/:id/edit(.:format)                                                                  proposals#edit
#                                   proposal GET    /proposals/:id(.:format)                                                                       proposals#show
#                                            PUT    /proposals/:id(.:format)                                                                       proposals#update
#                                            DELETE /proposals/:id(.:format)                                                                       proposals#destroy
#                          new_lead_contacts GET    /contacts/new_lead(.:format)                                                                   contacts#new_lead
#                             table_contacts POST   /contacts/table(.:format)                                                                      contacts#table
#         create_from_embedded_form_contacts POST   /contacts/create_from_embedded_form(.:format)                                                  contacts#create_from_embedded_form
#                                   contacts GET    /contacts(.:format)                                                                            contacts#index
#                                            POST   /contacts(.:format)                                                                            contacts#create
#                                new_contact GET    /contacts/new(.:format)                                                                        contacts#new
#                               edit_contact GET    /contacts/:id/edit(.:format)                                                                   contacts#edit
#                                    contact GET    /contacts/:id(.:format)                                                                        contacts#show
#                                            PUT    /contacts/:id(.:format)                                                                        contacts#update
#                                            DELETE /contacts/:id(.:format)                                                                        contacts#destroy
#                                 fetch_jobs POST   /jobs/fetch(.:format)                                                                          jobs#fetch
#                                 modal_jobs GET    /jobs/modal(.:format)                                                                          jobs#modal
#                              schedule_jobs GET    /jobs/schedule(.:format)                                                                       jobs#schedule
#                         crew_calendar_jobs GET    /jobs/crew_calendar(.:format)                                                                  jobs#crew_calendar
#                       find_by_address_jobs GET    /jobs/find_by_address(.:format)                                                                jobs#find_by_address
#                                   expenses GET    /jobs/expenses(.:format)                                                                       expenses#index
#                                            POST   /jobs/expenses(.:format)                                                                       expenses#create
#                                new_expense GET    /jobs/expenses/new(.:format)                                                                   expenses#new
#                               edit_expense GET    /jobs/expenses/:id/edit(.:format)                                                              expenses#edit
#                                    expense GET    /jobs/expenses/:id(.:format)                                                                   expenses#show
#                                            PUT    /jobs/expenses/:id(.:format)                                                                   expenses#update
#                                            DELETE /jobs/expenses/:id(.:format)                                                                   expenses#destroy
#                         expense_categories GET    /jobs/expense_categories(.:format)                                                             expense_categories#index
#                                            POST   /jobs/expense_categories(.:format)                                                             expense_categories#create
#                       new_expense_category GET    /jobs/expense_categories/new(.:format)                                                         expense_categories#new
#                      edit_expense_category GET    /jobs/expense_categories/:id/edit(.:format)                                                    expense_categories#edit
#                           expense_category GET    /jobs/expense_categories/:id(.:format)                                                         expense_categories#show
#                                            PUT    /jobs/expense_categories/:id(.:format)                                                         expense_categories#update
#                                            DELETE /jobs/expense_categories/:id(.:format)                                                         expense_categories#destroy
#                                   payments GET    /jobs/payments(.:format)                                                                       payments#index
#                                            POST   /jobs/payments(.:format)                                                                       payments#create
#                                new_payment GET    /jobs/payments/new(.:format)                                                                   payments#new
#                               edit_payment GET    /jobs/payments/:id/edit(.:format)                                                              payments#edit
#                                    payment GET    /jobs/payments/:id(.:format)                                                                   payments#show
#                                            PUT    /jobs/payments/:id(.:format)                                                                   payments#update
#                                            DELETE /jobs/payments/:id(.:format)                                                                   payments#destroy
#                       modal_form_timecards GET    /jobs/timecards/modal_form(.:format)                                                           timecards#modal_form
#                     update_state_timecards POST   /jobs/timecards/update_state(.:format)                                                         timecards#update_state
#                        modal_form_timecard GET    /jobs/timecards/:id/modal_form(.:format)                                                       timecards#modal_form
#                           approve_timecard GET    /jobs/timecards/:id/approve(.:format)                                                          timecards#approve
#                         unapprove_timecard GET    /jobs/timecards/:id/unapprove(.:format)                                                        timecards#unapprove
#                         mark_paid_timecard GET    /jobs/timecards/:id/mark_paid(.:format)                                                        timecards#mark_paid
#                       unmark_paid_timecard GET    /jobs/timecards/:id/unmark_paid(.:format)                                                      timecards#unmark_paid
#                                  timecards GET    /jobs/timecards(.:format)                                                                      timecards#index
#                                            POST   /jobs/timecards(.:format)                                                                      timecards#create
#                               new_timecard GET    /jobs/timecards/new(.:format)                                                                  timecards#new
#                              edit_timecard GET    /jobs/timecards/:id/edit(.:format)                                                             timecards#edit
#                                   timecard GET    /jobs/timecards/:id(.:format)                                                                  timecards#show
#                                            PUT    /jobs/timecards/:id(.:format)                                                                  timecards#update
#                                            DELETE /jobs/timecards/:id(.:format)                                                                  timecards#destroy
#                                  modal_job GET    /jobs/:id/modal(.:format)                                                                      jobs#modal
#                              mark_dead_job GET    /jobs/:id/mark_dead(.:format)                                                                  jobs#mark_dead
#                            mark_undead_job GET    /jobs/:id/mark_undead(.:format)                                                                jobs#mark_undead
#                               complete_job GET    /jobs/:id/complete(.:format)                                                                   jobs#complete
#                             uncomplete_job GET    /jobs/:id/uncomplete(.:format)                                                                 jobs#uncomplete
#                request_client_feedback_job POST   /jobs/:id/request_client_feedback(.:format)                                                    jobs#request_client_feedback
#                               job_expenses GET    /jobs/:job_id/expenses(.:format)                                                               expenses#index
#                                            POST   /jobs/:job_id/expenses(.:format)                                                               expenses#create
#                            new_job_expense GET    /jobs/:job_id/expenses/new(.:format)                                                           expenses#new
#                           edit_job_expense GET    /jobs/:job_id/expenses/:id/edit(.:format)                                                      expenses#edit
#                                job_expense GET    /jobs/:job_id/expenses/:id(.:format)                                                           expenses#show
#                                            PUT    /jobs/:job_id/expenses/:id(.:format)                                                           expenses#update
#                                            DELETE /jobs/:job_id/expenses/:id(.:format)                                                           expenses#destroy
#                               job_payments GET    /jobs/:job_id/payments(.:format)                                                               payments#index
#                                            POST   /jobs/:job_id/payments(.:format)                                                               payments#create
#                            new_job_payment GET    /jobs/:job_id/payments/new(.:format)                                                           payments#new
#                           edit_job_payment GET    /jobs/:job_id/payments/:id/edit(.:format)                                                      payments#edit
#                                job_payment GET    /jobs/:job_id/payments/:id(.:format)                                                           payments#show
#                                            PUT    /jobs/:job_id/payments/:id(.:format)                                                           payments#update
#                                            DELETE /jobs/:job_id/payments/:id(.:format)                                                           payments#destroy
#                              job_timecards GET    /jobs/:job_id/timecards(.:format)                                                              timecards#index
#                                            POST   /jobs/:job_id/timecards(.:format)                                                              timecards#create
#                           new_job_timecard GET    /jobs/:job_id/timecards/new(.:format)                                                          timecards#new
#                          edit_job_timecard GET    /jobs/:job_id/timecards/:id/edit(.:format)                                                     timecards#edit
#                               job_timecard GET    /jobs/:job_id/timecards/:id(.:format)                                                          timecards#show
#                                            PUT    /jobs/:job_id/timecards/:id(.:format)                                                          timecards#update
#                                            DELETE /jobs/:job_id/timecards/:id(.:format)                                                          timecards#destroy
#                                       jobs GET    /jobs(.:format)                                                                                jobs#index
#                                            POST   /jobs(.:format)                                                                                jobs#create
#                                    new_job GET    /jobs/new(.:format)                                                                            jobs#new
#                                   edit_job GET    /jobs/:id/edit(.:format)                                                                       jobs#edit
#                                        job GET    /jobs/:id(.:format)                                                                            jobs#show
#                                            PUT    /jobs/:id(.:format)                                                                            jobs#update
#                                            DELETE /jobs/:id(.:format)                                                                            jobs#destroy
#                            feedback_portal GET    /feedback_portal/:id(.:format)                                                                 job_feedback#new
#                                            POST   /feedback_portal/:id(.:format)                                                                 job_feedback#create
#                         job_feedback_index GET    /job_feedback(.:format)                                                                        job_feedback#index
#                                            POST   /job_feedback(.:format)                                                                        job_feedback#create
#                           new_job_feedback GET    /job_feedback/new(.:format)                                                                    job_feedback#new
#                          edit_job_feedback GET    /job_feedback/:id/edit(.:format)                                                               job_feedback#edit
#                               job_feedback GET    /job_feedback/:id(.:format)                                                                    job_feedback#show
#                                            PUT    /job_feedback/:id(.:format)                                                                    job_feedback#update
#                                            DELETE /job_feedback/:id(.:format)                                                                    job_feedback#destroy
#                 modal_job_schedule_entries GET    /job_schedule_entries/modal(.:format)                                                          job_schedule_entries#modal
#                   modal_job_schedule_entry GET    /job_schedule_entries/:id/modal(.:format)                                                      job_schedule_entries#modal
#                       job_schedule_entries GET    /job_schedule_entries(.:format)                                                                job_schedule_entries#index
#                                            POST   /job_schedule_entries(.:format)                                                                job_schedule_entries#create
#                     new_job_schedule_entry GET    /job_schedule_entries/new(.:format)                                                            job_schedule_entries#new
#                    edit_job_schedule_entry GET    /job_schedule_entries/:id/edit(.:format)                                                       job_schedule_entries#edit
#                         job_schedule_entry GET    /job_schedule_entries/:id(.:format)                                                            job_schedule_entries#show
#                                            PUT    /job_schedule_entries/:id(.:format)                                                            job_schedule_entries#update
#                                            DELETE /job_schedule_entries/:id(.:format)                                                            job_schedule_entries#destroy
#                    fetch_open_appointments GET    /appointments/fetch_open(.:format)                                                             appointments#fetch_open
#                         fetch_appointments POST   /appointments/fetch(.:format)                                                                  appointments#fetch
#                         modal_appointments GET    /appointments/modal(.:format)                                                                  appointments#modal
#                          feed_appointments GET    /appointments/feed(.:format)                                                                   appointments#feed
#                          modal_appointment GET    /appointments/:id/modal(.:format)                                                              appointments#modal
#                               appointments GET    /appointments(.:format)                                                                        appointments#index
#                                            POST   /appointments(.:format)                                                                        appointments#create
#                            new_appointment GET    /appointments/new(.:format)                                                                    appointments#new
#                           edit_appointment GET    /appointments/:id/edit(.:format)                                                               appointments#edit
#                                appointment GET    /appointments/:id(.:format)                                                                    appointments#show
#                                            PUT    /appointments/:id(.:format)                                                                    appointments#update
#                                            DELETE /appointments/:id(.:format)                                                                    appointments#destroy
#                    schedule_communications GET    /communications/schedule(.:format)                                                             communications#schedule
#                                            GET    /communications/:job_id/start_new_form(.:format)                                               communications#start_new_form
#                                            GET    /communications/:job_id/plan_form(.:format)                                                    communications#plan_form
#                       modal_communications GET    /communications/modal(.:format)                                                                communications#modal
#          start_communication_communication GET    /communications/:id/start(.:format)                                                            communications#start
#     communication_start_form_communication GET    /communications/:id/start_planned_form(.:format)                                               communications#start_planned_form
#                        modal_communication GET    /communications/:id/modal(.:format)                                                            communications#modal
#                             communications GET    /communications(.:format)                                                                      communications#index
#                                            POST   /communications(.:format)                                                                      communications#create
#                          new_communication GET    /communications/new(.:format)                                                                  communications#new
#                         edit_communication GET    /communications/:id/edit(.:format)                                                             communications#edit
#                              communication GET    /communications/:id(.:format)                                                                  communications#show
#                                            PUT    /communications/:id(.:format)                                                                  communications#update
#                                            DELETE /communications/:id(.:format)                                                                  communications#destroy
#                     planned_communications GET    /planned_communications(.:format)                                                              planned_communications#index
#                                            POST   /planned_communications(.:format)                                                              planned_communications#create
#                  new_planned_communication GET    /planned_communications/new(.:format)                                                          planned_communications#new
#                 edit_planned_communication GET    /planned_communications/:id/edit(.:format)                                                     planned_communications#edit
#                      planned_communication GET    /planned_communications/:id(.:format)                                                          planned_communications#show
#                                            PUT    /planned_communications/:id(.:format)                                                          planned_communications#update
#                                            DELETE /planned_communications/:id(.:format)                                                          planned_communications#destroy
#                      communication_records GET    /communication_records(.:format)                                                               communication_records#index
#                                            POST   /communication_records(.:format)                                                               communication_records#create
#                   new_communication_record GET    /communication_records/new(.:format)                                                           communication_records#new
#                  edit_communication_record GET    /communication_records/:id/edit(.:format)                                                      communication_records#edit
#                       communication_record GET    /communication_records/:id(.:format)                                                           communication_records#show
#                                            PUT    /communication_records/:id(.:format)                                                           communication_records#update
#                                            DELETE /communication_records/:id(.:format)                                                           communication_records#destroy
#                               import_leads GET    /leads/import(.:format)                                                                        leads#import
#                                            POST   /leads/import(.:format)                                                                        leads#import
#                               export_leads GET    /leads/export(.:format)                                                                        leads#export
#                                print_leads GET    /leads/print(.:format)                                                                         leads#print
#                                embed_leads GET    /leads/embed(.:format)                                                                         leads#embed_schedule
#                  embed_ask_questions_leads GET    /leads/embed/ask_questions(.:format)                                                           leads#embed_ask_questions
#                     new_with_contact_leads GET    /leads/new/:contact(.:format)                                                                  leads#new
#                               lead_sources GET    /leads/sources(.:format)                                                                       lead_sources#index
#                                            POST   /leads/sources(.:format)                                                                       lead_sources#create
#                            new_lead_source GET    /leads/sources/new(.:format)                                                                   lead_sources#new
#                           edit_lead_source GET    /leads/sources/:id/edit(.:format)                                                              lead_sources#edit
#                                lead_source GET    /leads/sources/:id(.:format)                                                                   lead_sources#show
#                                            PUT    /leads/sources/:id(.:format)                                                                   lead_sources#update
#                                            DELETE /leads/sources/:id(.:format)                                                                   lead_sources#destroy
#                                      leads GET    /leads(.:format)                                                                               leads#index
#                                            POST   /leads(.:format)                                                                               leads#create
#                                   new_lead GET    /leads/new(.:format)                                                                           leads#new
#                                  edit_lead GET    /leads/:id/edit(.:format)                                                                      leads#edit
#                                       lead GET    /leads/:id(.:format)                                                                           leads#show
#                                            PUT    /leads/:id(.:format)                                                                           leads#update
#                                            DELETE /leads/:id(.:format)                                                                           leads#destroy
#                                            GET    /get_regions/:country(.:format)                                                                dashboard#get_regions
#                                manage_root        /manage(.:format)                                                                              manage/base#index
#                         become_manage_user GET    /manage/users/:id/become(.:format)                                                             manage/users#become
#                    switch_back_manage_user GET    /manage/users/:id/switch_back(.:format)                                                        manage/users#switch_back
#                               manage_users GET    /manage/users(.:format)                                                                        manage/users#index
#                                            POST   /manage/users(.:format)                                                                        manage/users#create
#                            new_manage_user GET    /manage/users/new(.:format)                                                                    manage/users#new
#                           edit_manage_user GET    /manage/users/:id/edit(.:format)                                                               manage/users#edit
#                                manage_user GET    /manage/users/:id(.:format)                                                                    manage/users#show
#                                            PUT    /manage/users/:id(.:format)                                                                    manage/users#update
#                                            DELETE /manage/users/:id(.:format)                                                                    manage/users#destroy
#                               manage_crews GET    /manage/crews(.:format)                                                                        manage/crews#index
#                                            POST   /manage/crews(.:format)                                                                        manage/crews#create
#                            new_manage_crew GET    /manage/crews/new(.:format)                                                                    manage/crews#new
#                           edit_manage_crew GET    /manage/crews/:id/edit(.:format)                                                               manage/crews#edit
#                                manage_crew GET    /manage/crews/:id(.:format)                                                                    manage/crews#show
#                                            PUT    /manage/crews/:id(.:format)                                                                    manage/crews#update
#                                            DELETE /manage/crews/:id(.:format)                                                                    manage/crews#destroy
#         become_manage_managed_organization GET    /manage/managed_organizations/:id/become(.:format)                                             manage/managed_organizations#become
#               manage_managed_organizations GET    /manage/managed_organizations(.:format)                                                        manage/managed_organizations#index
#                                            POST   /manage/managed_organizations(.:format)                                                        manage/managed_organizations#create
#            new_manage_managed_organization GET    /manage/managed_organizations/new(.:format)                                                    manage/managed_organizations#new
#           edit_manage_managed_organization GET    /manage/managed_organizations/:id/edit(.:format)                                               manage/managed_organizations#edit
#                manage_managed_organization GET    /manage/managed_organizations/:id(.:format)                                                    manage/managed_organizations#show
#                                            PUT    /manage/managed_organizations/:id(.:format)                                                    manage/managed_organizations#update
#                                            DELETE /manage/managed_organizations/:id(.:format)                                                    manage/managed_organizations#destroy
#              restore_manage_email_template PUT    /manage/email_templates/:id/restore/:version_id(.:format)                                      manage/email_templates#restore
#               toggle_manage_email_template POST   /manage/email_templates/:id/toggle(.:format)                                                   manage/email_templates#toggle
#                 test_manage_email_template POST   /manage/email_templates/:id/test(.:format)                                                     manage/email_templates#test
#                     manage_email_templates GET    /manage/email_templates(.:format)                                                              manage/email_templates#index
#                                            POST   /manage/email_templates(.:format)                                                              manage/email_templates#create
#                  new_manage_email_template GET    /manage/email_templates/new(.:format)                                                          manage/email_templates#new
#                 edit_manage_email_template GET    /manage/email_templates/:id/edit(.:format)                                                     manage/email_templates#edit
#                      manage_email_template GET    /manage/email_templates/:id(.:format)                                                          manage/email_templates#show
#                                            PUT    /manage/email_templates/:id(.:format)                                                          manage/email_templates#update
#                                            DELETE /manage/email_templates/:id(.:format)                                                          manage/email_templates#destroy
#           restore_manage_proposal_template PUT    /manage/proposal_templates/:id/restore/:version_id(.:format)                                   manage/proposal_templates#restore
#     edit_contract_manage_proposal_template GET    /manage/proposal_templates/:id/edit_contract(.:format)                                         manage/proposal_templates#edit_contract
#          contract_manage_proposal_template GET    /manage/proposal_templates/:id/contract(.:format)                                              manage/proposal_templates#contract
#  reorder_sections_manage_proposal_template POST   /manage/proposal_templates/:id/reorder_sections(.:format)                                      manage/proposal_templates#reorder_sections
#     manage_proposal_template_section_items GET    /manage/proposal_templates/:proposal_template_id/sections/:section_id/items(.:format)          manage/proposal_template_items#index
#                                            POST   /manage/proposal_templates/:proposal_template_id/sections/:section_id/items(.:format)          manage/proposal_template_items#create
#  new_manage_proposal_template_section_item GET    /manage/proposal_templates/:proposal_template_id/sections/:section_id/items/new(.:format)      manage/proposal_template_items#new
# edit_manage_proposal_template_section_item GET    /manage/proposal_templates/:proposal_template_id/sections/:section_id/items/:id/edit(.:format) manage/proposal_template_items#edit
#      manage_proposal_template_section_item GET    /manage/proposal_templates/:proposal_template_id/sections/:section_id/items/:id(.:format)      manage/proposal_template_items#show
#                                            PUT    /manage/proposal_templates/:proposal_template_id/sections/:section_id/items/:id(.:format)      manage/proposal_template_items#update
#                                            DELETE /manage/proposal_templates/:proposal_template_id/sections/:section_id/items/:id(.:format)      manage/proposal_template_items#destroy
#          manage_proposal_template_sections GET    /manage/proposal_templates/:proposal_template_id/sections(.:format)                            manage/proposal_template_sections#index
#                                            POST   /manage/proposal_templates/:proposal_template_id/sections(.:format)                            manage/proposal_template_sections#create
#       new_manage_proposal_template_section GET    /manage/proposal_templates/:proposal_template_id/sections/new(.:format)                        manage/proposal_template_sections#new
#      edit_manage_proposal_template_section GET    /manage/proposal_templates/:proposal_template_id/sections/:id/edit(.:format)                   manage/proposal_template_sections#edit
#           manage_proposal_template_section GET    /manage/proposal_templates/:proposal_template_id/sections/:id(.:format)                        manage/proposal_template_sections#show
#                                            PUT    /manage/proposal_templates/:proposal_template_id/sections/:id(.:format)                        manage/proposal_template_sections#update
#                                            DELETE /manage/proposal_templates/:proposal_template_id/sections/:id(.:format)                        manage/proposal_template_sections#destroy
#                  manage_proposal_templates GET    /manage/proposal_templates(.:format)                                                           manage/proposal_templates#index
#                                            POST   /manage/proposal_templates(.:format)                                                           manage/proposal_templates#create
#               new_manage_proposal_template GET    /manage/proposal_templates/new(.:format)                                                       manage/proposal_templates#new
#              edit_manage_proposal_template GET    /manage/proposal_templates/:id/edit(.:format)                                                  manage/proposal_templates#edit
#                   manage_proposal_template GET    /manage/proposal_templates/:id(.:format)                                                       manage/proposal_templates#show
#                                            PUT    /manage/proposal_templates/:id(.:format)                                                       manage/proposal_templates#update
#                                            DELETE /manage/proposal_templates/:id(.:format)                                                       manage/proposal_templates#destroy
#                       manage_subscriptions GET    /manage/subscriptions(.:format)                                                                manage/subscriptions#index
#                                            POST   /manage/subscriptions(.:format)                                                                manage/subscriptions#create
#                    new_manage_subscription GET    /manage/subscriptions/new(.:format)                                                            manage/subscriptions#new
#                   edit_manage_subscription GET    /manage/subscriptions/:id/edit(.:format)                                                       manage/subscriptions#edit
#                        manage_subscription PUT    /manage/subscriptions/:id(.:format)                                                            manage/subscriptions#update
#                                            DELETE /manage/subscriptions/:id(.:format)                                                            manage/subscriptions#destroy
#                   manage_edit_organization GET    /manage/organization/edit(.:format)                                                            manage/organizations#edit
#                 manage_update_organization PUT    /manage/organization(.:format)                                                                 manage/organizations#update
#                       manage_website_embed GET    /manage/website_embed(.:format)                                                                manage/base#website_embed
#                                            PUT    /manage/website_embed(.:format)                                                                manage/base#website_embed
#                        manage_subscription GET    /manage/subscription(.:format)                                                                 manage/subscriptions#edit
#                 manage_update_subscription PUT    /manage/subscription(.:format)                                                                 manage/subscriptions#update
#                 manage_delete_subscription DELETE /manage/subscription(.:format)                                                                 manage/subscriptions#destroy
#                       leads_manage_reports GET    /manage/reports/leads(.:format)                                                                manage/reports#leads
#                  timesheets_manage_reports GET    /manage/reports/timesheets(.:format)                                                           manage/reports#timesheets
#                appointments_manage_reports GET    /manage/reports/appointments(.:format)                                                         manage/reports#appointments
#                   proposals_manage_reports GET    /manage/reports/proposals(.:format)                                                            manage/reports#proposals
#                        jobs_manage_reports GET    /manage/reports/jobs(.:format)                                                                 manage/reports#jobs
#                    job_cost_manage_reports GET    /manage/reports/job_cost(.:format)                                                             manage/reports#job_cost
#                     payroll_manage_reports GET    /manage/reports/payroll(.:format)                                                              manage/reports#payroll
#                    expenses_manage_reports GET    /manage/reports/expenses(.:format)                                                             manage/reports#expenses
#                      profit_manage_reports GET    /manage/reports/profit(.:format)                                                               manage/reports#profit
#    deposit_payment_tracking_manage_reports GET    /manage/reports/deposit_payment_tracking(.:format)                                             manage/reports#deposit_payment_tracking
#                     clients_manage_reports GET    /manage/reports/clients(.:format)                                                              manage/reports#clients
#                   estimates_manage_reports GET    /manage/reports/estimates(.:format)                                                            manage/reports#estimates
#           sales_performance_manage_reports GET    /manage/reports/sales_performance(.:format)                                                    manage/reports#sales_performance
#              communications_manage_reports GET    /manage/reports/communications(.:format)                                                       manage/reports#communications
#       managed_organizations_manage_reports GET    /manage/reports/managed_organizations(.:format)                                                manage/reports#managed_organizations
#                             manage_reports GET    /manage/reports(.:format)                                                                      manage/reports#index
#                                            POST   /manage/reports(.:format)                                                                      manage/reports#create
#                          new_manage_report GET    /manage/reports/new(.:format)                                                                  manage/reports#new
#                         edit_manage_report GET    /manage/reports/:id/edit(.:format)                                                             manage/reports#edit
#                              manage_report GET    /manage/reports/:id(.:format)                                                                  manage/reports#show
#                                            PUT    /manage/reports/:id(.:format)                                                                  manage/reports#update
#                                            DELETE /manage/reports/:id(.:format)                                                                  manage/reports#destroy
#                                 admin_root        /admin(.:format)                                                                               admin/base#index
#                        admin_failing_cards GET    /admin/failing_cards(.:format)                                                                 admin/base#failing_cards
#                             admin_activity GET    /admin/activity(.:format)                                                                      admin/base#activity
#                             admin_invoices GET    /admin/invoices(.:format)                                                                      admin/invoices#index
#                              admin_invoice GET    /admin/invoices/:id(.:format)                                                                  admin/invoices#show
#                            admin_inquiries GET    /admin/inquiries(.:format)                                                                     admin/inquiries#index
#                              admin_inquiry GET    /admin/inquiries/:id(.:format)                                                                 admin/inquiries#show
#                                            DELETE /admin/inquiries/:id(.:format)                                                                 admin/inquiries#destroy
#                                admin_posts GET    /admin/posts(.:format)                                                                         admin/posts#index
#                                            POST   /admin/posts(.:format)                                                                         admin/posts#create
#                             new_admin_post GET    /admin/posts/new(.:format)                                                                     admin/posts#new
#                            edit_admin_post GET    /admin/posts/:id/edit(.:format)                                                                admin/posts#edit
#                                 admin_post GET    /admin/posts/:id(.:format)                                                                     admin/posts#show
#                                            PUT    /admin/posts/:id(.:format)                                                                     admin/posts#update
#                                            DELETE /admin/posts/:id(.:format)                                                                     admin/posts#destroy
#            apply_credit_admin_organization PUT    /admin/organizations/:id/apply_credit(.:format)                                                admin/organizations#apply_credit
#                 disable_admin_organization PUT    /admin/organizations/:id/disable(.:format)                                                     admin/organizations#disable
#                  enable_admin_organization PUT    /admin/organizations/:id/enable(.:format)                                                      admin/organizations#enable
#                  table_admin_organizations POST   /admin/organizations/table(.:format)                                                           admin/organizations#table
#                        admin_organizations GET    /admin/organizations(.:format)                                                                 admin/organizations#index
#                                            POST   /admin/organizations(.:format)                                                                 admin/organizations#create
#                     new_admin_organization GET    /admin/organizations/new(.:format)                                                             admin/organizations#new
#                    edit_admin_organization GET    /admin/organizations/:id/edit(.:format)                                                        admin/organizations#edit
#                         admin_organization GET    /admin/organizations/:id(.:format)                                                             admin/organizations#show
#                                            PUT    /admin/organizations/:id(.:format)                                                             admin/organizations#update
#                                            DELETE /admin/organizations/:id(.:format)                                                             admin/organizations#destroy
#                          become_admin_user GET    /admin/users/:id/become(.:format)                                                              admin/users#become
#                          table_admin_users POST   /admin/users/table(.:format)                                                                   admin/users#table
#                                admin_users GET    /admin/users(.:format)                                                                         admin/users#index
#                                            POST   /admin/users(.:format)                                                                         admin/users#create
#                             new_admin_user GET    /admin/users/new(.:format)                                                                     admin/users#new
#                            edit_admin_user GET    /admin/users/:id/edit(.:format)                                                                admin/users#edit
#                                 admin_user GET    /admin/users/:id(.:format)                                                                     admin/users#show
#                                            PUT    /admin/users/:id(.:format)                                                                     admin/users#update
#                                            DELETE /admin/users/:id(.:format)                                                                     admin/users#destroy
#               restore_admin_email_template PUT    /admin/email_templates/:id/restore/:version_id(.:format)                                       admin/email_templates#restore
#                toggle_admin_email_template POST   /admin/email_templates/:id/toggle(.:format)                                                    admin/email_templates#toggle
#                  test_admin_email_template POST   /admin/email_templates/:id/test(.:format)                                                      admin/email_templates#test
#                      admin_email_templates GET    /admin/email_templates(.:format)                                                               admin/email_templates#index
#                                            POST   /admin/email_templates(.:format)                                                               admin/email_templates#create
#                   new_admin_email_template GET    /admin/email_templates/new(.:format)                                                           admin/email_templates#new
#                  edit_admin_email_template GET    /admin/email_templates/:id/edit(.:format)                                                      admin/email_templates#edit
#                       admin_email_template GET    /admin/email_templates/:id(.:format)                                                           admin/email_templates#show
#                                            PUT    /admin/email_templates/:id(.:format)                                                           admin/email_templates#update
#                                            DELETE /admin/email_templates/:id(.:format)                                                           admin/email_templates#destroy
#                           admin_cms_update POST   /admin/cms/update(.:format)                                                                    admin/base#update_cms
#            restore_admin_proposal_template PUT    /admin/proposal_templates/:id/restore/:version_id(.:format)                                    admin/proposal_templates#restore
#      edit_contract_admin_proposal_template GET    /admin/proposal_templates/:id/edit_contract(.:format)                                          admin/proposal_templates#edit_contract
#           contract_admin_proposal_template GET    /admin/proposal_templates/:id/contract(.:format)                                               admin/proposal_templates#contract
#   reorder_sections_admin_proposal_template POST   /admin/proposal_templates/:id/reorder_sections(.:format)                                       admin/proposal_templates#reorder_sections
#      admin_proposal_template_section_items GET    /admin/proposal_templates/:proposal_template_id/sections/:section_id/items(.:format)           admin/proposal_template_items#index
#                                            POST   /admin/proposal_templates/:proposal_template_id/sections/:section_id/items(.:format)           admin/proposal_template_items#create
#   new_admin_proposal_template_section_item GET    /admin/proposal_templates/:proposal_template_id/sections/:section_id/items/new(.:format)       admin/proposal_template_items#new
#  edit_admin_proposal_template_section_item GET    /admin/proposal_templates/:proposal_template_id/sections/:section_id/items/:id/edit(.:format)  admin/proposal_template_items#edit
#       admin_proposal_template_section_item GET    /admin/proposal_templates/:proposal_template_id/sections/:section_id/items/:id(.:format)       admin/proposal_template_items#show
#                                            PUT    /admin/proposal_templates/:proposal_template_id/sections/:section_id/items/:id(.:format)       admin/proposal_template_items#update
#                                            DELETE /admin/proposal_templates/:proposal_template_id/sections/:section_id/items/:id(.:format)       admin/proposal_template_items#destroy
#           admin_proposal_template_sections GET    /admin/proposal_templates/:proposal_template_id/sections(.:format)                             admin/proposal_template_sections#index
#                                            POST   /admin/proposal_templates/:proposal_template_id/sections(.:format)                             admin/proposal_template_sections#create
#        new_admin_proposal_template_section GET    /admin/proposal_templates/:proposal_template_id/sections/new(.:format)                         admin/proposal_template_sections#new
#       edit_admin_proposal_template_section GET    /admin/proposal_templates/:proposal_template_id/sections/:id/edit(.:format)                    admin/proposal_template_sections#edit
#            admin_proposal_template_section GET    /admin/proposal_templates/:proposal_template_id/sections/:id(.:format)                         admin/proposal_template_sections#show
#                                            PUT    /admin/proposal_templates/:proposal_template_id/sections/:id(.:format)                         admin/proposal_template_sections#update
#                                            DELETE /admin/proposal_templates/:proposal_template_id/sections/:id(.:format)                         admin/proposal_template_sections#destroy
#                   admin_proposal_templates GET    /admin/proposal_templates(.:format)                                                            admin/proposal_templates#index
#                                            POST   /admin/proposal_templates(.:format)                                                            admin/proposal_templates#create
#                new_admin_proposal_template GET    /admin/proposal_templates/new(.:format)                                                        admin/proposal_templates#new
#               edit_admin_proposal_template GET    /admin/proposal_templates/:id/edit(.:format)                                                   admin/proposal_templates#edit
#                    admin_proposal_template GET    /admin/proposal_templates/:id(.:format)                                                        admin/proposal_templates#show
#                                            PUT    /admin/proposal_templates/:id(.:format)                                                        admin/proposal_templates#update
#                                            DELETE /admin/proposal_templates/:id(.:format)                                                        admin/proposal_templates#destroy
#                                   ckeditor        /ckeditor                                                                                      Ckeditor::Engine
#                                       page GET    /pages/*id                                                                                     high_voltage/pages#show
#
# Routes for Ckeditor::Engine:
#         pictures GET    /pictures(.:format)             ckeditor/pictures#index
#                  POST   /pictures(.:format)             ckeditor/pictures#create
#          picture DELETE /pictures/:id(.:format)         ckeditor/pictures#destroy
# attachment_files GET    /attachment_files(.:format)     ckeditor/attachment_files#index
#                  POST   /attachment_files(.:format)     ckeditor/attachment_files#create
#  attachment_file DELETE /attachment_files/:id(.:format) ckeditor/attachment_files#destroy
