class Api::UsersController < ApplicationController
  before_action :authenticate!

  def me
    render json: current_user, only: [ :id, :name, :account_id, :role, :created_at ], methods: [ :handle_name_set? ]
  end

  def update_me
    if current_user.update(user_params)
      render json: current_user, only: [ :id, :name, :account_id, :role, :created_at ], methods: [ :handle_name_set? ]
    else
      render_validation_errors(current_user)
    end
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end
