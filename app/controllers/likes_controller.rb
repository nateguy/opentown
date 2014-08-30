class LikesController < ApplicationController
  def create
    @like = Like.create(like_params)
    @comment = @like.comment
    render :toggle
  end

  def destroy
    like = Like.find(params[:id]).destroy
    @comment = like.comment
    render :toggle
  end


  private

  def like_params
    params.require(:like).permit(:comment_id, :user_id)
  end
end