# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :organization_memberships, class_name: 'OrganizationMember', inverse_of: :user
  has_many :organizations, through: :organization_memberships
  has_many :project_memberships, class_name: 'ProjectMember', inverse_of: :user
  has_many :projects, through: :project_memberships
  has_many :time_entries, inverse_of: :user

  alias_attribute :name, :email
end
