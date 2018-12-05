# frozen_string_literal: true

module Organized
  class TimeOffEntriesController < BaseController
    before_action :set_time_off_period, only: [:new, :create]

    def index
      redirect_to new_organization_time_off_entry_path
    end

    def new
      @time_off_entry = TimeOffEntry.new user: impersonating_or_current_user
      authorize @time_off_entry
      respond_with current_organization, @time_off_entry, @time_off_period
    end

    def create
      @time_off_entry = TimeOffEntry.new create_params
      authorize @time_off_entry
      @time_off_entry.save
      respond_with current_organization, @time_off_entry,
                   location: -> { after_create_or_update_path @time_off_entry }
    end

    private

    def set_time_off_period
      @time_off_period = TimeOffPeriod.new user: impersonating_or_current_user
    end

    def after_create_or_update_path time_off_entry
      options = {
        as: time_off_entry.user != current_user ? time_off_entry.user.id : nil
      }
      organization_time_view_path current_organization, time_off_entry.time_view, options
    end

    def create_params
      params.require(:time_off_entry).permit(:user_id, :notes, :amount, :executed_on, :typology)
            .reverse_merge(user_id: current_user.id, organization_id: current_organization.id)
    end

    def impersonating_user
      return nil unless params[:as]
      @impersonating_user ||= current_organization.users.find params[:as]
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def impersonating_or_current_user
      impersonating_user || current_user
    end
  end
end
