class HomeController < ApplicationController
  def index

    @plans = Plan.all
    @polygons = Polygon.where(polygontype: "planmap")


    respond_to do |format|
      format.html # index.html.erb

      format.json { render json: @plans,
        :include => {:polygons => {
          :include => {:vertices => { :only => [:id, :lat, :lng]}},
            :except => [:created_at, :updated_at, :plan_id]}},
            :except => [:created_at, :updated_at]}

      # format.json { render json: @polygons,
      #      :include => {:vertices => { :only => [:id, :lat, :lng]}},
      #        :except => [:created_at, :updated_at]}
    end
  end
end
