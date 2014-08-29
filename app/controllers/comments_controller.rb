class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  def index
    @comments = Comment.all
  end

  def new
    @comment = Comment.new
  end

  def show

  end

  def create
    @comment = Comment.new(comment_params)

    if @comment.save
      redirect_to :back, notice: 'Comment was successfully created.'
    else
      render :new
    end


  end

  def update_content
    content = params[:content]
    id = params[:id]
    @comment = Comment.find(params[:id])
    @comment.content = params[:content]
    @comment.save

  end

  def update

      if @comment.update(comment_params)
        redirect_to comments_url, notice: 'Zone was successfully updated.'
       else
        render :edit
      end

  end


  def destroy
    @comment.destroy
  end


  private
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:content, :plan_id, :user_id)
    end


end
