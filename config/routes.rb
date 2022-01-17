# frozen_string_literal: true

Rails.application.routes.draw do
  mount EffectiveCommittees::Engine => '/', as: 'effective_committees'
end

EffectiveCommittees::Engine.routes.draw do
  # Public routes
  scope module: 'effective' do
    resources :committees, except: [:show, :destroy]
    resources :committee_members, except: [:show]
  end

  namespace :admin do
    resources :committees, except: [:show]
    resources :committee_members, except: [:show]
  end

end
