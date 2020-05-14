class PostsController < ApplicationController
  before_action :check_login_user?,except: :index
  def index
    @user = current_user
    @other_user = 
    @posts = @user.feed if user_login?
    @like = Like.new
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post =Post.new
  end

  def create
    @post = Post.create(params_post)
    if @post.save
      flash[:success] = "投稿が完了しました"
      redirect_to root_path
    else
      flash.now[:alert] = "内容を確認してください"
      render :new
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to root_path
  end

  private
    def params_post
      params.require(:post).permit(:genre,:content, :url).merge(user_id: current_user.id)
    end
end
