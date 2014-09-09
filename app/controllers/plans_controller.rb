class PlansController < ApplicationController




  protect_from_forgery with: :null_session,  :except => [:modifypolygon]
  before_action :set_plan, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:update_bounds]

  def index

  end

  def new
    @plan = Plan.new

  end

  def create
    @plan = Plan.new(plan_params)
  end


  def stats
    @plan = Plan.find(params[:id])
    @user_polygons = UserPolygon.all
    @zones = Zone.all
  end

  # def user_polygons
  #   @user_polygons = UserPolygon.all
  # end

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


  def update_bounds

    @plan = Plan.find(params[:id])

    @plan.sw_lng = params[:sw_lng]
    @plan.sw_lat = params[:sw_lat]
    @plan.ne_lng = params[:ne_lng]
    @plan.ne_lat = params[:ne_lat]
    @plan.save
    redirect_to :back
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
