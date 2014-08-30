class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session,  :except => [:update_comment]

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

  def update_comment

    @comment = Comment.find(params[:id])
    @comment.content = params[:content]
    if @comment.save
      redirect_to :back
    else
      render :new
    end

  end

  def update

      if @comment.update(comment_params)
        redirect_to comments_url, notice: 'Comment was successfully updated.'
       else
        render :edit
      end

  end


  def destroy
    @comment.destroy
    redirect_to :back
  end


  private
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:content, :plan_id, :user_id)
    end


end
