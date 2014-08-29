class PlansController < ApplicationController
  protect_from_forgery with: :null_session,  :except => [:comment, :newuserzone]
  before_action :set_plan, only: [:show, :edit, :update, :destroy]

  def index

  end

  def new
    @plan = Plan.new
  end

  def show
    @users = User.all

  end

  def destroy
    @plan.destroy
    respond_to do |format|
      format.html { redirect_to plans_url, notice: 'Plan removed.' }
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
        format.html { redirect_to plans_url, notice: 'Plan was successfully created.' }
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

  def modifypolygon
    id = params[:id]
    paths = params[:paths]

    paths = paths.strip
    paths = paths[1..paths.length - 2]
    @paths = paths.split("),(")
    # puts @paths
    oldpolygons = Vertex.where(polygon_id: id)

    oldpolygons.each do |oldpolygon|
      oldpolygon.todelete = true
      oldpolygon.save
    end

    @paths.each do |cord|
      cord = cord.split(", ")

      Vertex.create(polygon_id: id, lat: cord[0], lng: cord[1], todelete: false)

    end



  end


  def newuserzone
    if user_signed_in?
      @user_polygons = UserPolygon.all
      user_polygon = nil
      polygonid = params[:polygonid]
      zoneid = params[:zoneid]





      if @user_polygons.exists?(polygon_id: polygonid)
        user_polygon = @user_polygons.find_by(polygon_id: polygonid)
        user_polygon.user_id = User.current.id
        user_polygon.custom_zone = zoneid

      else
        user_polygon = UserPolygon.new(user_id: User.current.id, custom_zone: zoneid)
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
      params.require(:plan).permit(:name, :district, :content)
    end

end
