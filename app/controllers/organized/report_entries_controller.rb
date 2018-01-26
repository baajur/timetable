# frozen_string_literal: true

module Organized
  class ReportEntriesController < BaseController
    def index
      @q = scoped_subset
      @report_entries_export = current_organization.report_entries_exports.build(
        user: current_user,
        export_query: params[:q]
      )
      @time_entries = @q.result.includes(:project, :client, :task, :user)
                        .page(params[:page])
    end

    private

    def scoped_subset
      scoped = policy_scope(TimeEntry.in_organization(current_organization))
      scoped.ransack(params[:q]).tap do |q|
        q.sorts = 'executed_on asc' if q.sorts.empty?
      end
    end
  end
end
