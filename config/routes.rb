Rails.application.routes.draw do

  devise_scope :user do
    unauthenticated do
      root to: "devise/sessions#new"
    end
    authenticated :user do
      root to: "dashboard#show", as: :authenticated_root
    end
  end

  namespace :account do
    get 'create-new-account', to: 'account#new'
    get 'account-created', to: 'account#account_created'
  end

  namespace :user do
    get 'details', to: 'details#show'
    put 'details', to: 'details#update'

  end

  scope '/:type/:id/address' do
    get '/postcode', to: 'address#postcode_lookup'
    post '/address-results',
         to: 'address#display_address_search_results'
    put '/address-details',
        to: 'address#assign_address_attributes'
    get '/address',
        to: 'address#show'
    put '/address',
        to: 'address#update'
    # This route ensures that attempting to navigate back to the list of address results
    # redirects the user back to the search page
    get '/address-results',
        to: 'address#postcode_lookup'
    # This route ensures that users can navigate back to the address details page
    get '/address-details',
        to: 'address#show'
  end

  namespace :organisation do
    scope '/:organisation_id' do
      get '/type', to: 'type#show'
      put '/type', to: 'type#update'
      get '/numbers', to: 'numbers#show'
      put '/numbers', to: 'numbers#update'

      get '/mission', to: 'mission#show'
      put '/mission', to: 'mission#update'
      get '/signatories', to: 'signatories#show'
      put '/signatories', to: 'signatories#update'
      get '/summary', to: 'summary#show'
    end
  end

  scope "/3-10k", as: :three_to_ten_k do
    namespace :project do

      get 'create-new-project', to: 'new_project#create_new_project', as: :create

      get ':project_id/title', to: 'title#show', as: :title_get
      put ':project_id/title', to: 'title#update', as: :title_put

      get ':project_id/key-dates', to: 'dates#show', as: :dates_get
      put ':project_id/key-dates', to: 'dates#update', as: :dates_put

      get ':project_id/location', to: 'location#show', as: :location_get
      put ':project_id/location', to: 'location#update', as: :location_put

      get ':project_id/description', to: 'description#show', as: :description_get
      put ':project_id/description', to: 'description#update', as: :description_put

      get ':project_id/capital-works',
          to: 'capital_works#show',
          as: :capital_works_get
      put ':project_id/capital-works',
          to: 'capital_works#update',
          as: :capital_works_put

      get ':project_id/do-you-need-permission',
          to: 'permission#show',
          as: :permission_get
      put ':project_id/do-you-need-permission',
          to: 'permission#update',
          as: :permission_put

      get ':project_id/difference', to: 'difference#show', as: :difference_get
      put ':project_id/difference', to: 'difference#update', as: :difference_put

      get ':project_id/how-does-your-project-matter', to: 'matter#show', as: :matter_get
      put ':project_id/how-does-your-project-matter', to: 'matter#update', as: :matter_put

      get ':project_id/your-project-heritage', to: 'heritage#show', as: :heritage_get
      put ':project_id/your-project-heritage', to: 'heritage#update', as: :heritage_put

      get ':project_id/why-is-your-organisation-best-placed',
          to: 'best_placed#show', as: :best_placed_get
      put ':project_id/why-is-your-organisation-best-placed',
          to: 'best_placed#update', as: :best_placed_put

      get ':project_id/how-will-your-project-involve-people',
          to: 'involvement#show', as: :involvement_get
      put ':project_id/how-will-your-project-involve-people',
          to: 'involvement#update', as: :involvement_put

      get ':project_id/our-other-outcomes',
          to: 'outcomes#show',
          as: :other_outcomes_get
      put ':project_id/our-other-outcomes',
          to: 'outcomes#update',
          as: :other_outcomes_put

      get ':project_id/costs', to: 'costs#show', as: :project_costs
      put ':project_id/costs', to: 'costs#update'
      delete ':project_id/costs/:project_cost_id',
             to: 'costs#delete',
             as: :cost_delete

      put ':project_id/confirm-costs',
          to: 'costs#validate_and_redirect',
          as: :project_costs_validate_and_redirect

      get ':project_id/are-you-getting-cash-contributions',
          to: 'cash_contributions#question',
          as: :cash_contributions_question_get
      put ':project_id/are-you-getting-cash-contributions',
          to: 'cash_contributions#question_update',
          as: :cash_contributions_question_put

      get ':project_id/cash-contributions',
          to: 'cash_contributions#show',
          as: :project_cash_contribution
      put ':project_id/cash-contributions',
          to: 'cash_contributions#update'
      delete ':project_id/cash-contributions/:cash_contribution_id',
             to: 'cash_contributions#delete',
             as: :cash_contribution_delete

      get ':project_id/your-grant-request',
          to: 'grant_request#show',
          as: :grant_request_get

      get ':project_id/are-you-getting-non-cash-contributions',
          to: 'non_cash_contributions#question',
          as: :non_cash_contributions_question_get
      put ':project_id/are-you-getting-non-cash-contributions',
          to: 'non_cash_contributions#question_update',
          as: :non_cash_contributions_question_put

      get ':project_id/non-cash-contributions',
          to: 'non_cash_contributions#show',
          as: :non_cash_contributions_get
      put ':project_id/non-cash-contributions',
          to: 'non_cash_contributions#update',
          as: :non_cash_contributions_put
      delete ':project_id/non-cash-contributions/:non_cash_contribution_id',
             to: 'non_cash_contributions#delete',
             as: :non_cash_contribution_delete

      get ':project_id/volunteers', to: 'volunteers#show', as: :volunteers
      put ':project_id/volunteers', to: 'volunteers#update'
      delete ':project_id/volunteers/:volunteer_id',
             to: 'volunteers#delete',
             as: :volunteer_delete

      get ':project_id/evidence-of-support',
          to: 'evidence_of_support#show',
          as: :project_support_evidence
      put ':project_id/evidence-of-support',
          to: 'evidence_of_support#update'
      delete ':project_id/evidence-of-support/:supporting_evidence_id',
             to: 'evidence_of_support#delete',
             as: :supporting_evidence_delete

      get ':project_id/check-your-answers',
          to: 'check_answers#show', as: :check_answers_get
      put ':project_id/check-your-answers',
          to: 'check_answers#update', as: :check_answers_update

      get ':project_id/declaration', to: 'declaration#show_declaration', as: :declaration_get
      put ':project_id/declaration', to: 'declaration#update_declaration', as: :declaration_put

      get ':project_id/confirm-declaration',
          to: 'declaration#show_confirm_declaration',
          as: :confirm_declaration_get
      put ':project_id/confirm-declaration',
          to: 'declaration#update_confirm_declaration',
          as: :confirm_declaration_put

      get ':project_id/application-submitted',
          to: 'application_submitted#show',
          as: :application_submitted_get

      get 'location' => 'project_location#project_location'
      get ':project_id/governing-documents',
          to: 'governing_documents#show',
          as: :governing_docs_get
      put ':project_id/governing-documents',
          to: 'governing_documents#update',
          as: :governing_docs_put

      get ':project_id/accounts', to: 'accounts#show', as: :accounts_get
      put ':project_id/accounts', to: 'accounts#update', as: :accounts_put

    end

  end

  get '/accessibility-statement',
      to: 'static_pages#show_accessibility_statement',
      as: :accessibility_statement

  get 'health' => 'health#get_status'

  get 'support', to: 'support#show'
  post 'support', to: 'support#update'
  get 'support/report-a-problem', to: 'support#report_a_problem'
  post 'support/report-a-problem', to: 'support#process_problem'
  get 'support/question-or-feedback', to: 'support#question_or_feedback'
  post 'support/question-or-feedback', to: 'support#process_question'

  # TODO: Remove bau flipper
  constraints lambda { !Flipper.enabled?(:bau) } do
    devise_scope :user do
      get "/users/sign_up",  :to => "devise/sessions#new"
    end
  end

  # Override the Devise registration controller
  devise_for :users,
             :controllers  => {
                 :registrations => 'user/registrations'
             }

  # TODO: Remove bau flipper
  get 'start-a-project', to: 'home#show', constraints: lambda { Flipper.enabled?(:bau) }
  get 'start-a-project', to: 'dashboard#show', constraints: lambda { !Flipper.enabled?(:bau) }

  post 'consumer' => 'released_form#receive' do
    header "Content-Type", "application/json"
  end
  resources :organisation do
    get 'show'
  end
  # TODO Put this behind auth on PAAS
  match "/delayed_job" => DelayedJobWeb, :anchor => false, :via => [:get, :post]
end
