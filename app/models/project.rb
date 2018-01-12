# frozen_string_literal: true

class Project < ApplicationRecord
  extend FriendlyId

  belongs_to :organization, inverse_of: :projects
  belongs_to :client, inverse_of: :projects
  has_many :members, class_name: 'ProjectMember', inverse_of: :project
  has_many :users, through: :members
  has_many :time_entries, inverse_of: :project
  has_and_belongs_to_many :tasks, inverse_of: :projects

  accepts_nested_attributes_for :members, reject_if: :all_blank, allow_destroy: true
  friendly_id :name, use: :scoped, scope: :organization

  scope :by_name, -> { order :name }
  scope :in_organization, ->(organization) { where organization_id: organization.id }

  validates :name,
            presence: true,
            uniqueness: { scope: :organization_id }
  validate :validate_organization_references, on: :create

  delegate :name, to: :client, prefix: true

  def self.policy_class
    Organized::ProjectPolicy
  end

  def as_json opts = {}
    super opts.reverse_merge(
      only: %i[id organization_id name],
      include: { tasks: { only: %i[id name] } }
    )
  end

  def total_amount
    time_entries.sum(:amount)
  end

  private

  def validate_organization_references
    return if client.nil? || organization.nil? || client.organization == organization
    errors.add :client, :forbidden
  end
end
