# frozen_string_literal: true

module Organized
  class TimeEntriesController < BaseController
    before_action :set_time_view, only: %i[new create]

    def new
      @time_entry = TimeEntry.new executed_on: @time_view.date, user: impersonating_user
      respond_with current_organization, @time_entry
    end

    def create
      @time_entry = TimeEntry.create create_params
      respond_with current_organization, @time_entry,
                   location: -> { organization_time_view_path(current_organization, @time_entry.time_view, as: @time_entry.user) }
    end

    def edit
      @time_entry = current_organization.time_entries.in_organization(current_organization).find params[:id]
      respond_with current_organization, @time_entry
    end

    def update
      @time_entry = current_organization.time_entries.in_organization(current_organization).find params[:id]
      @time_entry.update_attributes update_params
      respond_with current_organization, @time_entry,
                   location: -> { organization_time_view_path(current_organization, @time_entry.time_view, as: @time_entry.user) }
    end

    private

    def create_params
      params.require(:time_entry).permit(:user_id, :project_id, :task_id, :notes, :minutes_in_distance)
            .merge(executed_on: @time_view.date)
    end

    def update_params
      params.require(:time_entry).permit(:project_id, :task_id, :notes, :minutes_in_distance,
                                         :executed_on)
    end

    def set_time_view
      @time_view = TimeView.find params[:time_view_id], current_organization, current_user
    end

    def available_tasks
      project = @time_entry.project || available_projects.first
      @available_tasks_for_project ||= project.tasks.by_name
    end

    def impersonating_user
      @impersonating_user ||= current_organization.users.find params[:as]
    rescue ActiveRecord::RecordNotFound
      current_user
    end
  end
end
