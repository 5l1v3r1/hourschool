HourschoolV2::Application.routes.draw do

  scope :path => '/admin', :module => 'admin', :as => 'admin' do
    resources :charts
  end

  resources :ecourses, :path => 'classes'

  resources :suggestions# , :path => 'requests'
  resources :esuggestions, :path => 'suggestions'

  resources :courses

  devise_for :members
  resources :members, :only => [:index, :show]


   resources :enterprises, :only => [:index, :show]  do
    resources :subdomains, :shallow => true
  end

  devise_for :users, :controllers => { :omniauth_callbacks  => "users/omniauth_callbacks", 
                                       :registrations       => "registrations",
                                       :sessions            => 'sessions' }
  devise_scope :user do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  end
  match 'user_root' => 'home#index'
  resources :users do
  end

  resources :payments
  match 'confirm_payment' => 'payments#confirm'


  match   'oh-no/404'     => 'pages#show',        :id => 'errors/404'
  match   'oh-no/500'     => 'pages#show',        :id => 'errors/404'

  get "sites/show"
  match '/learn' => 'home#learn'
  match '/teach' => 'home#teach'
  match '/suggest' => 'suggestions#suggest'
  match '/csvote' => 'suggestions#vote'
  match '/register' => 'courses#register'
  match '/register_with_amazon' => 'courses#register_with_amazon'
  match '/drop' => 'courses#drop'
  match '/preview' => 'courses#preview'
  match '/confirm' => 'courses#confirm'
  match '/heart' => 'courses#heart'
  match '/proposal' => 'courses#show_proposal'
  match '/payment_preview' => 'courses#register_preview'
  match '/course_confirm' => 'courses#course_confirm'

  match '/enterprise-learn' => 'enterprises#learn'
  match '/enterprise-teach' => 'enterprise#teach'
  match '/esvote' => 'esuggestions#vote'
  match '/eregister' => 'ecourses#register'

  match '/approve' => 'courses#approve'
  match '/courses-all' => 'courses#all'

  match '/community' => 'home#community'
  match '/community_faq' => 'home#community_faq'
  
  match '/profile' => 'users#show', :id => 'current'
  match '/profile_past_taught' => 'users#profile_past_taught'
  match '/profile_past_attended' => 'users#profile_past_attended'
  match '/profile-suggest' => 'users#profile_suggest'
  match '/profile-pending' => 'users#profile_pending'
  match '/profile-approved' => 'users#profile_approved'

  match '/my_classes' => 'users#my_classes'
  match '/classes_taken' => 'users#classes_taken'
  match '/classes_taught' => 'users#classes_taught'

  match '/contact' => 'home#contactus'
  match '/search' => 'home#search'

  match '/search_by_tg' => 'home#search_by_tg', :as => "tags"
  match '/search_by_city' => 'home#search_by_city', :as => "cities"
  match '/organization' => 'home#organization'
  match '/about_save' => 'home#about_save'
  match '/nominate' => 'home#nominate'
  match '/nominate_send' => 'home#nominate_send'
  match '/nominate_confirm' => 'home#nominate_confirm'
  match '/nominate_reject' => 'home#nominate_reject'
  match '/nominate_reject_send' => 'home#nominate_reject_send'
  match '/contact_teacher' => 'courses#contact_teacher'
  match '/contact_teacher_send' => 'courses#contact_teacher_send'
  match '/contact_all_students' => 'courses#contact_all_students'
  match '/contact_all_students_send' => 'courses#contact_all_students_send'

  match '/business' => 'home#business'
  match '/about' => 'home#about'
  root :to => "home#index"

  resources :test
  match ":bad_route", :to => "pages#show", :id => "errors/404"
end
