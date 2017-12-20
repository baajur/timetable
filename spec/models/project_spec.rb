# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'validations' do
    it 'require an organization' do
      expect(subject).to have(1).error_on :organization
      subject.organization = build :organization
      expect(subject).to have(0).errors_on :organization
    end

    it 'require a client' do
      expect(subject).to have(1).error_on :client
      subject.client = build :client
      expect(subject).to have(0).errors_on :client
    end

    it 'require a name' do
      expect(subject).to have(1).error_on :name
      subject.name = 'asd'
      expect(subject).to have(0).errors_on :name
    end

    it 'require a unique name against the belonging organization' do
      existing = create :project
      subject.organization = existing.organization
      subject.name = existing.name
      expect(subject).to have(1).error_on :name
      subject.name = 'asd'
      expect(subject).to have(0).errors_on :name
    end

    it 'require the client to be in the same organization of the project' do
      subject.organization = create :organization
      subject.client = create :client
      expect(subject).to have(1).error_on :client
    end

    it 'pass when all constraints are met' do
      subject.organization = create :organization
      subject.client = create :client, organization: subject.organization
      subject.name = 'asd'
      expect(subject).to be_valid
    end

    it 'does not require organization integrity on update' do
      subject = create :project
      subject.client = create :client
      expect(subject).to be_valid
    end
  end
end
