class PlansController < ApplicationController
  protect_from_forgery with: :null_session,  :except => [:comment, :newuserzone]
  before_action :set_plan, only: [:show, :edit, :update, :destroy]

  def index

  end

  def new
    @plan = Plan.new

  end


  def stats
    @plan = Plan.find(params[:id])
    @user_polygons = UserPolygon.all
    @zones = Zone.all
  end

  def user_polygons
    @user_polygons = UserPolygon.all
  end

  def show
    response.headers["Vary"]= "Accept"
    @users = User.all

  end

  def update
    respond_to do |format|
      if @plan.update(plan_params)
        format.html { redirect_to plans_url, notice: 'Plan was successfully updated.' }
        format.json { render :show, status: :ok, location: @plan }
      else
        format.html { render :edit }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_bounds
    @plan = Plan.find(params[:id])
    @plan.sw_lng = params[:sw_lng]
    @plan.sw_lat = params[:sw_lat]
    @plan.ne_lng = params[:ne_lng]
    @plan.ne_lat = params[:ne_lat]
    @plan.save
    redirect_to :back
  end

  def destroy
    @plan.destroy
    respond_to do |format|
      format.html { redirect_to plans_all_path, notice: 'Plan removed.' }
      format.json { head :no_content }
    end
  end

  def showall
    @plans = Plan.all
  end

  def newcomment
    if user_signed_in?
      @comment = Comment.new
    end
  end

  def create
    @plan = Plan.new(plan_params)

    respond_to do |format|
      if @plan.save
        format.html { redirect_to plans_all_path, notice: 'Plan was successfully created.' }
        format.json { render :show, status: :created, location: @plan }
      else
        format.html { render :new }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def comments
    @plan_id = params[:plan_id]
    # @comments = Plan.find(plan_id).comments
    # @users = User.all
  end

  def deletepolygon
    id = params[:id]
    Polygon.find(id).destroy
    redirect_to :back
  end

  def modifypolygon
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


  def newuserzone
    if user_signed_in?
      @user_polygons = UserPolygon.all
      user_polygon = nil
      polygonid = params[:polygonid]
      zoneid = params[:zoneid]
      description = params[:description]

      if @user_polygons.exists?(polygon_id: polygonid)
        user_polygon = @user_polygons.find_by(polygon_id: polygonid)
        user_polygon.user_id = User.current.id
        user_polygon.custom_zone = zoneid
        user_polygon.custom_description = description
      else
        user_polygon = UserPolygon.new(polygon_id: polygonid, user_id: User.current.id, custom_description: description, custom_zone: zoneid)
      end

      if user_polygon.save
        redirect_to :back, notice: 'Plan was successfully created.'
      else
        render :userplan
      end


    end

  end

  def userplan
    if user_signed_in?
      plan_id = params[:id]
      @plans = Plan.find(plan_id)
      @zones = Zone.all

      @user_polygons = UserPolygon.where(user_id: User.current.id)

      respond_to do |format|
        format.html { render :userplan }
        format.json { render json: @user_polygons }
      end
    end

  end


  def comment_new
    if user_signed_in?
      @plans_comment = Comment.new
    end
  end


  def comment_create
    if user_signed_in?
      user_id = User.current.id
      comments = Comment.new
      comments.content = params[:content]
      comments.plan_id = params[:plan_id]
      comments.user_id = user_id
      if comments.save == false
        alert "error"
        render :comments
      else
        redirect_to :back
      end
    end
  end

  private
    def set_plan
      @plan = Plan.find(params[:id])
      @zones = Zone.all
    end

    def plan_params
      params.require(:plan).permit(:name, :district, :content, :overlay, :sw_lat, :sw_lng, :ne_lat, :ne_lng)
    end

end
