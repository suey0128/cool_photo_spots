class UsersController < ApplicationController
  before_action :set_user, only: [:update, :destroy]
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response


  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    # render jsoan: @user
    #when the user signup, the id is stored in session(cookie), find the user using cookie
    user = User.find_by(id: session[:user_id])
    # byebug #=> session[:user_id] nil 
    if user
        render json: user
    else
        render json: { error: "Not authorized"}, status: :unauthorized
    end
  end

  # POST /users
  def create
    if params[:business] 
      business = Business.create!(business_params)
      @user = User.new(user_params)
      @user.update!(platform_user_id: business.id, platform_user_type: "Business")
    elsif params[:content_creator]
      content_creator = ContentCreator.create!(content_creator_params)
      @user = User.new(user_params)
      @user.update!(platform_user_id: content_creator.id, platform_user_type: "ContentCreator")
    end
    session[:user_id] = @user.id
    render json: @user, status: :created, location: @user
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params[:user].permit(:username, :email, :password , :password_confirmation, :business)
    end

    def business_params
      params[:business].permit(:name,:business_type, :logo, :description, :address, :city, :state, :zip, :country, :website)
    end

    def content_creator_params
      params.require(:content_creator).permit(:first_name, :last_name, :gender, :instagram_username, :instagram_url, :instagram_follower, :instagram_feamle_follower_ratio, :instagram_top1_follow_location, :instagram_connection_permission, :ave_rate_per_campaign, :paypal_account)
    end

    def render_not_found_response
      render json: {error: "User not found"}, status: :not_found
    end

    def render_unprocessable_entity_response(invalid)
      render json: { errors: invalid.record.errors.full_messages}, status: :unprocessable_entity
    end
end
