class Api::Admin::UsersController < Api::Admin::BaseController
  PER_PAGE = 20

  def index
    users = User.includes(:scores).order(created_at: :desc)

    total_count = users.count
    page = [ params[:page].to_i, 1 ].max
    users = users.limit(PER_PAGE).offset((page - 1) * PER_PAGE)

    render json: {
      users: users.map { |u|
        u.as_json(only: [ :id, :name, :account_id, :role, :created_at ])
         .merge("scores_count" => u.scores.size)
      },
      total_count: total_count,
      page: page,
      per_page: PER_PAGE
    }
  end

  def destroy
    user = User.find(params[:id])
    if user.id == current_user.id
      render json: { error: "Cannot delete your own account" }, status: :forbidden
      return
    end
    user.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end
end
