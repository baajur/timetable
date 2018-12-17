# frozen_string_literal: true

module Organized
  class TimeOffPeriodsController < BaseController
    include BusinessDate
    include HoursAmount

    before_action :find_time_off_period, only: [:approve, :decline]

    def create
      @time_off_period = TimeOffPeriod.new create_params
      if @time_off_period.save
        business_dates = business_dates_between(@time_off_period.start_date, @time_off_period.end_date)
        business_dates.each &create_time_off_entries
        @time_off_entry = @time_off_period.time_off_entries.sort_by(&:executed_on).first
        TimeOffEntryMailer.request_time_off(current_organization, @time_off_period).deliver_later
        respond_with current_organization, @time_off_entry,
                     location: -> { after_create_or_update_path @time_off_entry }
      else
        redirect_to new_time_off_entry_path_with_params
      end
    end

    def approve
      # TODO redirect to confirmation form instead of updating in GET method
      @time_off_period.update_entries({ status: 'approved' })
      @time_off_period.update({ status: 'approved' })
      render template: 'organized/time_off_periods/confirmation', locals: { status: 'approved' }
    end

    def decline
      # TODO redirect to confirmation form instead of updating in GET method
      @time_off_period.update_entries({ status: 'declined' })
      @time_off_period.update({ status: 'declined' })
      render template: 'organized/time_off_periods/confirmation', locals: { status: 'declined' }
    end

    private

    def find_time_off_period
      @time_off_period = current_organization.time_off_periods.find params[:id]
    end

    def after_create_or_update_path time_off_entry
      options = {
        as: time_off_entry.user != current_user ? time_off_entry.user.id : nil
      }
      organization_time_view_path current_organization, time_off_entry.time_view, options
    end

    def new_time_off_entry_path_with_params
      path = { controller: :time_off_entries, action: :new }
      period = @time_off_period.slice(:typology, :start_date, :end_date, :notes)
      errors = { errors: @time_off_period.errors.messages }
      new_params = period.merge(errors)
      path.merge(new_params)
    end

    def create_params
      params.require(:time_off_period).permit(:user_id, :notes, :start_date, :end_date, :typology)
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

    def create_time_off_entries
      lambda do |date|
        entry = TimeOffEntry.new(
          user_id: current_user.id,
          organization_id: current_organization.id,
          executed_on: date,
          amount: parse_hours(8),
          notes: @time_off_period.notes,
          typology: @time_off_period.typology,
          time_off_period_id: @time_off_period.id
        )
        authorize entry
        entry.save
      end
    end
  end
end
