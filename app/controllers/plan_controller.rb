class PlanController < ApplicationController
  protect_from_forgery with: :null_session,  :except => [:comment]

  def index

    plan_id = params[:id]
    @plans = Plan.find(plan_id)
    @comments = Plan.find(plan_id).comments
    @users = User.all

  end

  def modifypolygon
    id = params[:id]
    paths = params[:paths]

    paths = paths.split("),(")
    @paths = paths[1..(paths.length-2)]

    oldpolygons = Polygon.where("plan_id == #{id}")

    oldpolygons.each do |oldpolygon|
      oldpolygon.todelete = true
      oldpolygon.save
    end

    @paths.each do |cord|
      cord = cord.split(", ")

      Polygon.create(plan_id: id, lat: cord[0], lng: cord[1], todelete: false)

    end

    oldpolygons = Polygon.where(todelete: true)
    oldpolygons.delete_all
    #oldpolygons.delete_all
    # @paths = path.split("),(")
    # @paths = path.gsub!("(","\n")
    # @paths = path.gsub!(")","\n")



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
      end
      redirect_to :back
    end
  end
end
