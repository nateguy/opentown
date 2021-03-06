class UserPolygonsController < ApplicationController
  protect_from_forgery with: :null_session,  :except => [:create]
  before_action :set_user_polygons, only: [:show, :edit, :update, :destroy]
  before_action :set_user_polygons_all, only: [:index]

  def index

  end

  def create
    if user_signed_in?
      @user_polygons = UserPolygon.all
      polygonid = params[:polygonid]
      zoneid = params[:zoneid]
      description = params[:description]

      if @user_polygons.exists?(polygon_id: polygonid, user_id: User.current.id)
        user_polygon = @user_polygons.find_by(polygon_id: polygonid, user_id: User.current.id)
        user_polygon.user_id = User.current.id
        user_polygon.custom_zone = zoneid
        user_polygon.custom_description = description
      else
        user_polygon = UserPolygon.new(polygon_id: polygonid, user_id: User.current.id, custom_description: description, custom_zone: zoneid)
      end

      if user_polygon.save
        redirect_to :back, notice: 'Custom zone created.'
      else
        redirect_to :back, notice: 'Could not create custom zone.'
      end


    end
  end

  def show

    if user_signed_in?

      @plan = Plan.find(params[:id])
      @plan.polygons.each do |polygon|
        unless UserPolygon.exists?(user_id: User.current.id, polygon_id: polygon.id)
          UserPolygon.create(user_id: User.current.id, polygon_id: polygon.id, custom_zone: polygon.zone_id, custom_description: polygon.description)
        end
      end
      @zones = Zone.all


    end


  end

  private


  def set_user_polygons_all
    @user_polygons = UserPolygon.all
  end

  def set_user_polygons
    @users = User.all
    @user_polygons = UserPolygon.where(user_id: User.current.id)
  end

end
