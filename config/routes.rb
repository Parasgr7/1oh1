Rails.application.routes.draw do

  resources :calendars
  resources :bookings
  resources :events
  resources :projects
  resources :helps
  resources :messages, only:[:create,:index]
  resources :landing
  resources :profiles
  resources :markets
  resources :explores
  resources :guides
  resources :subscribes
  resources :home
  resources :categories
  resources :sessions
  resources :sessions, only: [:index,:create]
  resources :chests
  resources :reviews
  resources :payment
  resources :products
  resources :omniauths
  resources :errors
  resources :reports


  scope '/contact-us' do
    resources :contacts,except: :index
    get '/customer-support', to: 'contacts#customer',as: :customer_support
    get '/security-escalations', to: 'contacts#customer',as: :security
    get '/technical-issues', to: 'contacts#customer',as: :technical
    get '/hr-inquiries', to: 'contacts#customer',as: :hr
    get '/investor-opportunites', to: 'contacts#customer',as: :investor
    get '/pr-communications', to: 'contacts#customer',as: :pr
  end

  scope '/session' do
    get '/subject', to: 'bookings#subject', as: :booking_subject
    post '/submit-subject',to: 'bookings#submit_subject',as: :submit_subject
    get '/schedule', to: 'bookings#schedule', as: :booking_schedule
    post '/confirm-schedule',to: 'bookings#confirm_schedule',as: :confirm_schedule
    get '/confirm', to: 'bookings#confirm', as: :booking_confirm
    post '/submit-booking', to: 'bookings#submit_request', as: :submit_request
    get '/completed', to: 'bookings#completed', as: :booking_completed
  end

  resources :notifications do
    member do
      post :mark_as_read
    end
  end

  get '/terms', to: 'landing#terms'
  get '/user_login', to: 'landing#user_login'
  get '/privacy-policy', to: 'landing#policy'
  get '/reservation_calendar' , to: 'sessions#index', as: :reserve_calendar
  get '/states/:country', to: 'helps#states'
  get '/cities/:state/:country', to: 'helps#cities'
  post '/webhook', to: 'payment#after_payment'
  get '/profile/about-yourself', to: 'profiles#introduction', as: :first_page_introduction
  get '/profile/explores', to: 'profiles#explores',as: :explores_introduction
  get '/profile/guides', to: 'profiles#guides',as: :guides_introduction
  get '/profile/projects', to: 'profiles#projects',as: :projects_introduction
  get '/profile/availabilty', to: 'profiles#availabilty',as: :availabilty_introduction
  post '/profile/availabilty', to: 'profiles#availabilty_booking_create', as: :availabilty_booking
  get '/profile/completed', to: 'profiles#completed'
  get '/edit/project', to: 'projects#open_edit_project_modal', as: :open_edit_project_modal
  post '/send/tip', to: 'bookings#send_tip', as: :send_tip
  get '/search', to: 'landing#search_result', as: :search
  get '/home_filter', to: 'home#filter_result', as: :home_filter_result
  get '/explores_filter', to: 'explores#filter_result', as: :explores_filter_result
  get '/guides_filter', to: 'guides#filter_result', as: :guides_filter_result
  get '/projects_filter', to: 'projects#filter_result', as: :projects_filter_result
  get '/categories_filter', to: 'categories#filter_result', as: :categories_filter_result
  get '/categories_explore_filter', to: 'categories#filter_result_explore', as: :categories_filter_result_explore
  get '/categories_guide_filter', to: 'categories#filter_result_guide', as: :categories_filter_result_guide
  get '/categories_project_filter', to: 'categories#filter_result_project', as: :categories_filter_result_project
  get '/filter_reviews', to: 'reviews#filter_reviews'
  get '/search_result', to: 'categories#search_result',as: :search_result
  get '/contact-us', to: 'contacts#index',as: :contact_us
  post '/change-password', to: 'profiles#change_password',as: :change_password
  get '/fetch-time-slots', to: 'bookings#time_slots'
  get '/canceled', to: 'payment#canceled'
  get '/categories/:id/explores', to: 'categories#explorers', as: :categories_explorers
  get '/categories/:id/guides', to: 'categories#guides', as: :categories_guides
  get '/categories/:id/projects', to: 'categories#projects', as: :categories_projects
  post '/send_message_notification', to: 'notifications#send_message_notif'
  post '/create_review', to: 'reviews#create_reviews', as: :create_reviews
  put '/edit_review/:id', to: 'reviews#edit_reviews', as: :edit_reviews
  post '/update_settings', to: 'helps#update_settings', as: :update_settings
  post '/block_user', to: 'reports#block_user', as: :block
  post '/project/create-comment', to: 'projects#create_comment', as: :create_comment
  get '/projects/new/overview', to: 'projects#overview', as: :projects_overview
  get '/projects/new/collaborators', to: 'projects#collaborators', as: :project_collaborators
  get '/projects/new/details', to: 'projects#details', as: :projects_details
  post '/project/details', to: 'projects#update_details', as: :project_update_details
  post '/project/collaborators', to: 'projects#update_collaborators', as: :project_update_collaborators
  post '/project/overview', to: 'projects#update_overview', as: :project_update_overview
  put '/project/update_details/:id', to: 'projects#edit_details', as: :project_edit_details
  put '/project/update_collaborators/:id', to: 'projects#edit_collaborators', as: :project_edit_collaborators
  put '/project/update_overview/:id', to: 'projects#edit_overview', as: :project_edit_overview
  get '/categories_name', to: 'projects#list_categories_name'
  post '/offer_help', to: 'projects#offer_help', as: :offer_help
  get '/get_approve_modal/:id', to: 'bookings#approve_modal', as: :approve_modal
  get '/get_change_cancel_modal/:id', to: 'bookings#change_cancel_modal', as: :change_cancel_modal
  post '/get_cancel_modal/:id', to: 'bookings#cancel_modal', as: :cancel_modal
  post '/create_project', to: 'projects#create_project_builder', as: :create_project_builder
  get '/edit_project', to: 'projects#edit_project_builder', as: :edit_project_builder
  put '/update_project/:id', to: 'projects#update_project_builder', as: :update_project_builder
  put '/running_late/:id', to: 'bookings#running_late', as: :running_late
  get '/claim_reward/', to: 'profiles#claim_reward', as: :claim_reward
  put '/update_categories/:id', to: 'categories#edit_types', as: :edit_types


  resources :users, only:[:new] do
   resources :chats, only: [:show,:create]
  end

  get '/404', to: "errors#not_found"
  get '/422', to: "errors#unacceptable"
  get '/500', to: "errors#internal_error"


  resources :chats do
    member do
      post :unread_chats
    end
  end
  resources :profiles, only: [:show] do
   resources :bookings, only: [:show,:create]
  end

  # Routes for Google authentication
  get 'auth/:provider/callback', to: 'omniauths#googleAuth'
  # Routes for FB authentication
  # get 'auth/facebook/callback', to: 'omniauths#facebookAuth'
  get 'auth/failure', to: redirect('/')

  authenticated :user, ->(user) {user.admin?} do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
    namespace :admin do
      get "/", to: redirect("/admin/users")
      resources :users, only: %i[index show update]
    end
  end



  # if Rails.env.development?
    devise_for :users, controllers:{
        sessions: "users/sessions",
        registrations: "users/registrations",
        passwords: "users/passwords",
        confirmations: "users/confirmations"
    }
    devise_scope :user do
      unauthenticated do
        root 'landing#index', as: :unauthenticated_root

      end
      authenticated :user do
        root 'home#index', as: :authenticated_root
      end
      post '/resend_verification', to: 'users/registrations#resend_verification', as: :resend_verification
    end

    mount ActionCable.server, at: '/cable'

  #   else
  #     root :to => "subscribes#index"
  # end
end
