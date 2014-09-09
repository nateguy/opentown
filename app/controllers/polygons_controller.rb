class PolygonsController < ApplicationController
  protect_from_forgery with: :null_session,  :except => [:create_update, :delete]
  #before_action :set_polygon, only: [:show, :edit, :update, :destroy]

  def delete
    Polygon.find(params[:id]).vertices.destroy_all

    Polygon.find(params[:id]).destroy
    redirect_to :back
  end

  def create_update

    if params[:id].blank?
      polygon = Polygon.new(plan_id: params[:planId], polygontype: params[:polygontype], zone_id: params[:zoneid], description: params[:description])
    else
      polygon = Polygon.find(params[:id])
      oldpolygons = Array.new(polygon.vertices)

      allPlanMapPolygons = Polygon.where(polygontype: "planmap", plan_id: params[:planId])

      if (allPlanMapPolygons.count < 1)
        polygon.polygontype = "planmap"
      elsif (allPlanMapPolygons.count == 1) && allPlanMapPolygons.exists?(params[:id])
        polygon.polygontype = "planmap"
      else
        polygon.polygontype = params[:polygontype]
      end

      polygon.zone_id = params[:zoneid]
      polygon.description = params[:description]

    end
    if polygon.polygontype.eql? "planmap"
      polygon.zone_id = 0
    end
    polygon.save

    @paths = JSON(params[:paths])
    @paths.each do |vertex|

      new_vertex = polygon.vertices.new(lat: vertex["lat"], lng: vertex["lng"], todelete: false)
      new_vertex.save
    end

    unless oldpolygons.blank?
      oldpolygons.each do |old_vertex|
        polygon.vertices.find(old_vertex.id).destroy
      end
    end

    redirect_to :back
  end

  private



    def set_polygon
      @polygon = Polygon.find(params[:id])

    end

    def polygon_params
      params.require(:plan).permit(:plan_id, :polygontype, :zone_id, :description, :vertices)
    end
end
