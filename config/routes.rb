# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    root to: 'dashboard#index'
    resources :organizations, except: :delete do
      resources :organization_members, path: :members, only: :create do
        patch :toggle_admin, on: :member
      end
    end
  end

  scope module: 'organized' do
    resources :organizations, only: :show, path: 'orgs', controller: 'home' do
      resources :projects do
        resources :project_memberships, path: :members, only: :create
      end

      resources :organization_members, path: :members, only: :index do
        patch :toggle_admin, on: :member
      end
    end
  end

  get 'no_organization' => 'home#no_organization'
  root to: 'home#index'
end
