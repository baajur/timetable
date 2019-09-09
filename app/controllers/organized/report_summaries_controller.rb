# frozen_string_literal: true

module Organized
  class ReportSummariesController < BaseController
    before_action :set_week_range, except: :index

    def index
      week_id = Date.today.strftime TimeEntry::WEEK_ID_FORMAT
      redirect_to clients_organization_report_summary_path(id: week_id)
    end

    def clients
      @rows = ReportSummaries::ClientRow.build_from_scope time_entries_one_week
      #@time_entries_by_project = policy_scope(TimeEntry.in_organization(current_organization))
      render 'show'
    end

    def projects
      @rows = ReportSummaries::ProjectRow.build_from_scope time_entries_one_week
      #@time_entries_by_project = policy_scope(TimeEntry.in_organization(current_organization))
      render 'show'
    end

    def tasks
      @rows = ReportSummaries::TaskRow.build_from_scope time_entries_one_week
      #@time_entries_by_project = policy_scope(TimeEntry.in_organization(current_organization))
      render 'show'
    end

    def team
      @rows = ReportSummaries::UserRow.build_from_scope time_entries_one_week
      #@time_entries_by_project =  policy_scope(TimeEntry.in_organization(current_organization))
      render 'show'
    end

    private

    def time_entries_one_week
      @time_entries_one_week ||= policy_scope(
        TimeEntry.in_organization(current_organization)
                 .executed_since(@beginning_of_week)
                 .executed_until(@end_of_week)
      )
    end

    #def time_entries_by_project
    #  @time_entries_by_project = TimeEntry.in_organization(current_organization)
    #end

    def set_week_range
      year, week = params[:id].split('-').map &:to_i
      @beginning_of_week = Date.commercial(year, week, 1)
      @end_of_week = @beginning_of_week.end_of_week
    rescue ArgumentError
      raise ActiveRecord::RecordNotFound, 'dates are not valid'
    end
  end
end
