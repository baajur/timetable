# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :organization_memberships, class_name: 'OrganizationMember', inverse_of: :user
  has_many :organizations, through: :organization_memberships
  has_many :project_memberships, class_name: 'ProjectMember', inverse_of: :user
  has_many :projects, through: :project_memberships
  has_many :time_entries, inverse_of: :user
  has_and_belongs_to_many :roles, inverse_of: :users

  scope :by_name, -> { order :first_name, :last_name }
  scope :confirmed, -> { where.not confirmed_at: nil }

  validates :first_name,
            :last_name,
            presence: true

  def name
    "#{first_name} #{last_name}"
  end

  def admin_in? organization
    return true if admin?
    membership = organization_memberships.find_by(organization_id: organization.id)
    membership&.admin?
  end
end
