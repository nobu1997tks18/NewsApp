class UsersController < ApplicationController
  attr_accessor :name, :email
  before_action :check_login_user?, only:[:show, :edit, :update,:destroy, :followings, :followers]
  before_action :check_current_user?, only:[:edit, :update, :destroy]
  
  def index
    @user = current_user
    @users = User.all.page(params[:page]).per(15)
  end
  
  def show
    @user = User.find(params[:id])
    @posts = @user.posts.page(params[:page]).per(10).includes(:posts_genres_relationships, :genres)
    @like = Like.new
    @likes = @user.likes.order(created_at: "desc" ).page(params[:page]).includes(post: :user, post: :genres).per(10)
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.create(params_user)
    if @user.save
      login @user
      flash[:succsess] = "ご登録完了いたしました"
      redirect_to root_path
    else
      flash.now[:alert] = "入力項目を確認してください"
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(params_user)
      flash[:succsess] = "変更内容を登録いたしました"
      redirect_to @user
    else
      flash.now[:alert] = "入力項目を確認してください"
      render :edit
    end
  end

  def destroy
    check_admin_or_current_user?
    if @user = User.find(params[:id]).destroy
      flash[:succsess] = "ユーザを削除しました"
      redirect_to root_path
    else
      flash[:alert] = "アクセス権限がありません"
      render :edit
    end
  end

  def followings
    @user = User.find(params[:id])
    @followings = @user.followings.page(params[:page]).per(15)
  end

  def followers
    @user = User.find(params[:id])
    @followers = @user.followers.page(params[:page]).per(15)
  end

  private
  def params_user
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :profile, :picture )
  end

  def check_current_user?
    @user = User.find(params[:id])
    unless current_user?(@user)
      flash[:alert] ="アクセス権限がありません"
      redirect_to root_path
    end
  end

  def check_admin_or_current_user?
    unless current_user.id = params[:id] || current_user.admin?
      flash[:alert] = "権限がありません"
      redirect_to root_path
    end
  end
end
