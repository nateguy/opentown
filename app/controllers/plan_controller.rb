class PlanController < ApplicationController
  protect_from_forgery with: :null_session,  :except => [:comment, :newuserzone]

  def index

    plan_id = params[:id]
    @plans = Plan.find(plan_id)
    @vertices = Vertex.all
    @users = User.all
    @zones = Zone.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @plans,
        :include => {:polygons => {
          :include => {:vertices => { :only => [:id, :lat, :lng]}},
            :except => [:created_at, :updated_at, :plan_id]}},
            :except => [:created_at, :updated_at]}
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

      polygonid = params[:polygonid]
      zoneid = params[:zoneid]
      puts "test polygonid"
      puts polygonid
      @pp = polygonid
      @zz = zoneid


      @user_polygons = UserPolygon.all
      if @user_polygons.exists?(polygon_id: polygonid)
        i = @user_polygons.find_by(polygon_id: polygonid)
        i.user_id = User.current.id
        i.custom_zone = zoneid
        i.save
      else
        i = UserPolygon.new
        i.polygon_id = polygonid
        i.user_id = User.current.id
        i.custom_zone = zoneid
        i.save
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
        format.html # index.html.erb
        format.json { render json: @user_polygons }
      end
    end

  end

  def comment
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
end
