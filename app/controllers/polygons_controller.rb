class PolygonsController < ApplicationController
  protect_from_forgery with: :null_session,  :except => [:create, :update, :delete]
  #before_action :set_polygon, only: [:show, :edit, :update, :destroy]

  def delete
    Polygon.find(params[:id]).vertices.destroy_all

    Polygon.find(params[:id]).destroy
    redirect_to :back
  end





  def create
    polygon = Polygon.new(plan_id: params[:planId], description: params[:description])
    planMapPolygons = Polygon.where(polygontype: "planmap", plan_id: params[:planId])


    if (params[:zoneid].to_i == return_planmap_id) || (planMapPolygons.count < 1)
      puts "planmmapping"
      polygon.polygontype = "planmap"
      polygon.zone_id = return_planmap_id
    else
      puts "zonninging"
      polygon.polygontype = "zone"
      polygon.zone_id = params[:zoneid]
    end

    polygon.save
    paths = JSON(params[:paths])
    generate_vertices(polygon, paths)
    redirect_to :back
  end

  def update

    polygon = Polygon.find(params[:id])

    planMapPolygons = Polygon.where(polygontype: "planmap", plan_id: params[:planId])

    if (params[:zoneid].to_i == return_planmap_id) || (planMapPolygons.count < 1) || ((planMapPolygons.count == 1)&&(polygon.polygontype == "planmap"))
      polygontype = "planmap"
      zone_id = return_planmap_id
    else
      polygontype = "zone"
      zone_id = params[:zoneid]
    end


    polygon.update(polygontype: polygontype, description: params[:description], zone_id: zone_id)


    paths = JSON(params[:paths])

    destroy_old_vertices(polygon, Array.new(polygon.vertices))
    generate_vertices(polygon, paths)

    redirect_to :back
  end


  private

    def return_planmap_id
      @zone = Zone.find_by(code: "planmap")
      if @zone.nil?
        @zone = Zone.create(code: "planmap", color_code: "#888888")
      end
      return @zone.id
    end

    def generate_vertices(polygon, paths)

      paths.each do |vertex|

        new_vertex = polygon.vertices.new(lat: vertex["lat"], lng: vertex["lng"], todelete: false)
        new_vertex.save
      end
    end

    def destroy_old_vertices(polygon, paths)
      unless paths.blank?
        paths.each do |vertex|
          polygon.vertices.find(vertex.id).destroy
        end
      end
    end

    def set_polygon
      @polygon = Polygon.find(params[:id])

    end

    def polygon_params
      params.require(:polygon).permit(:plan_id, :polygontype, :zone_id, :description, :vertices)
    end
end
