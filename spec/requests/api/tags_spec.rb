require "swagger_helper"

RSpec.describe "api/tags", type: :request do
  path "/api/tags" do
    get("suggest tags") do
      tags "Tags"
      produces "application/json"
      parameter name: :q, in: :query, type: :string, required: false,
        description: "Search query (min 2 chars). Supports partial match."

      response(200, "returns matching tags from published scores") do
        let(:published_score) { create(:score, :published) }
        let(:unpublished_score) { create(:score) }

        before do
          rock = create(:tag, name: "rock")
          ロック = create(:tag, name: "ロック")
          pop = create(:tag, name: "pop")

          published_score.tags = [ rock, ロック ]
          unpublished_score.tags = [ pop ]
        end

        let(:q) { "ro" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["tags"]).to include("rock")
          expect(data["tags"]).not_to include("pop")
        end
      end

      response(200, "returns empty array for query shorter than 2 chars") do
        let(:q) { "r" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["tags"]).to eq([])
        end
      end

      response(200, "prefix matches are ranked first") do
        let!(:score) { create(:score, :published) }

        before do
          score.tags = [
            create(:tag, name: "jazz"),
            create(:tag, name: "jazz-rock"),
            create(:tag, name: "acid-jazz"),
          ]
        end

        let(:q) { "jazz" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["tags"].first(2)).to eq([ "jazz", "jazz-rock" ])
          expect(data["tags"]).to include("acid-jazz")
        end
      end

      response(200, "excludes tags only on unpublished scores") do
        let(:q) { "secret" }

        before do
          unpublished = create(:score)
          unpublished.tags = [ create(:tag, name: "secret-tag") ]
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["tags"]).to eq([])
        end
      end
    end
  end
end
