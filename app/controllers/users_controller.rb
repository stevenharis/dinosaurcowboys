class UsersController < ApplicationController

  # GET /users
  # As admin, provides all the users.
  # As non-admin, redirects with access error.
  #
  def index
    @users = policy_scope(User)
    authorize @users
  end

  # GET /users/new
  # Builds a User and a Character for the user to create an account.
  #
  def new
    @user = User.new
    @character = @user.characters.build
    authorize @user
  end

  # POST /users
  # Creates a new User with the passed in parameters, this includes nested
  # character parameters. Redisplays the new page when there are errors.
  #
  def create
    @user = User.new(user_params)
    @character = @user.characters.first
    authorize @user

    if @user.save
      sign_in(@user)
      redirect_to(@user)
    else
      render :new
    end
  end

  # GET /users/:id
  # Provides the user, and it's posts.
  #
  def show
    @user = User.find(params[:id])
    authorize @user
  end

  # GET /users/:id/edit
  # Provides the user.
  #
  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  # PATCH or PUT /users/:id
  # Allows for users to update their attributes.
  #
  def update
    @user = User.find(params[:id])
    authorize @user

    # Assume user is not trying to update password if the password is blank.
    if params[:user][:password].blank?
       params[:user].delete(:password)
       params[:user].delete(:password_confirmation)
    end

    # Append an error for the admin field if you are trying to make yourself
    # not an admin.
    if params[:user][:admin] == "0" && current_user.admin? && current_user == @user
      @user.errors.add(:admin?, "can't be disabled by the same user")
      render :edit
      return
    end

    if @user.update_attributes(user_params)
      sign_in @user, bypass: true if @user == current_user
      redirect_to @user
    else
      render :edit
    end
  end

  # DELETE /users/:id
  # Destroy the user, and everything it did.
  #
  def destroy
    @user = User.find(params[:id])
    authorize @user

    @user.destroy
    sign_out if @user == current_user
    redirect_to root_path, notice: "#{@user.email} deleted"
  end

  private

  # user_params: -> Hash
  # Permits the user fields for assignment.
  #
  def user_params
    params.require(:user).permit(*policy(@user || User).permitted_attributes)
  end

end
