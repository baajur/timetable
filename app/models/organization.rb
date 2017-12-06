# frozen_string_literal: true

class Organization < ApplicationRecord
  extend FriendlyId

  has_many :members, class_name: 'OrganizationMember', inverse_of: :organization
  has_many :users, through: :organization_members
  has_many :projects

  friendly_id :name, use: :slugged

  validates :name,
            presence: true,
            uniqueness: true
end
