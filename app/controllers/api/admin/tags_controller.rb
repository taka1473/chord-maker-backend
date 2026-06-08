class Api::Admin::TagsController < Api::Admin::BaseController
  PER_PAGE = 20

  def index
    tags = Tag.left_joins(:scores)
               .select("tags.*, COUNT(scores.id) AS scores_count")
               .group("tags.id")
               .order(created_at: :desc)

    total_count = Tag.count
    page = [ params[:page].to_i, 1 ].max
    tags = tags.limit(PER_PAGE).offset((page - 1) * PER_PAGE)

    render json: {
      tags: tags.map { |t| t.as_json(only: [ :id, :name, :created_at ]).merge("scores_count" => t.scores_count.to_i) },
      total_count: total_count,
      page: page,
      per_page: PER_PAGE
    }
  end

  def destroy
    tag = Tag.find(params[:id])
    tag.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Tag not found" }, status: :not_found
  end
end
