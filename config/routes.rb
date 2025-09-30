# frozen_string_literal: true

Rails.application.routes.draw do
  mount EffectiveCommittees::Engine => '/', as: 'effective_committees'
end

EffectiveCommittees::Engine.routes.draw do
  # Public routes
  scope module: 'effective' do
    resources :committees, only: [:index, :show] do
      get 'activity', on: :collection

      resources :committee_folders, only: [:show]
    end

    resources :committee_members, except: [:show]
  end

  namespace :admin do
    resources :committees, except: [:show]
    resources :committee_members, except: [:show]
    resources :committee_folders, except: [:show]
    resources :committee_files, except: [:show]
  end

end
