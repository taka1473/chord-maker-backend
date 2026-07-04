module Api
  class TagsController < ApplicationController
    def index
      tags = Tag.suggest(params[:q].to_s)
      render json: { tags: tags }
    end
  end
end
