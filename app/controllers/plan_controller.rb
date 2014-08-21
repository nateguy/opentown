class PlanController < ApplicationController
  protect_from_forgery with: :null_session,  :except => [:comment]

  def index

    plan_id = params[:id]
    @plan = Plan.find(plan_id)
    @comments = Plan.find(plan_id).comments
    @users = User.all

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
