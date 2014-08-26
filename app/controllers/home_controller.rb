class HomeController < ApplicationController
  def index

    @plans = Plan.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @plans }
    end
  end
end
