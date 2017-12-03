# frozen_string_literal: true

class OrganizationsController < ApplicationController
  def index
    @organizations = Organization.order(:name).load
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new params.require(:organization).permit(:name)
    if @organization.save
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def show
    @organization = Organization.friendly.find params[:id]
    @memberships = @organization.organization_memberships.includes(:user).load
  end

  def edit
    @organization = Organization.friendly.find params[:id]
  end

  def update
    @organization = Organization.friendly.find params[:id]
    if @organization.update params.require(:organization).permit(:name)
      redirect_to action: :index
    else
      render 'edit'
    end
  end
end
