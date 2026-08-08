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

  # 退会。スコアは削除せず匿名化する(所有者を外し、ゲスト編集リンクも無効化)。
  # 公開スコアは作者なしで公開され続け、非公開スコアは誰からも見えなくなる。
  def destroy_me
    ActiveRecord::Base.transaction do
      current_user.scores.update_all(user_id: nil, guest_token: nil, guest_expires_at: nil)
      current_user.destroy!
    end
    head :no_content
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end
