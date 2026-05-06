# frozen_string_literal: true

Rails.application.routes.draw do
  mount EffectiveCommittees::Engine => '/', as: 'effective_committees'
end

EffectiveCommittees::Engine.routes.draw do
  # Public routes
  scope module: 'effective' do
    resources :committees, only: [:index, :show] do
      get 'activity', on: :collection

      resources :committee_folders, only: [:show], path: 'folders' do
        member { get :agenda }
        resources :committee_agenda_items, only: [:show]
      end
    end

    get 'volunteers-and-committees', to: 'committees#volunteers_and_committees', as: 'volunteers_and_committees'
    get 'volunteers_and_committees', to: 'committees#volunteers_and_committees'

    resources :committee_members, except: [:show]
  end

  namespace :admin do
    resources :committees, except: [:show]
    resources :committee_members, except: [:show]
    resources :committee_folders, except: [:show]
    resources :committee_files, except: [:show] do
      post :bulk_move, on: :collection
    end
    resources :committee_agenda_items, except: [:show, :index]
  end

end

