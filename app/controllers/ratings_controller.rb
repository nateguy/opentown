class RatingsController < ApplicationController

  def create
    @rating = Rating.new(rating_params)
    @existing_rating = Rating.find_by(plan_id: @rating.plan_id, user_id: @rating.user_id)
    if @existing_rating
      @existing_rating.update(rating_params)
    else
      @rating.save
    end
    redirect_to :back, notice: 'Rated'
  end

  private

  def rating_params
    params.require(:rating).permit(:plan_id, :rating, :user_id)
  end
end