require "swagger_helper"

RSpec.describe "api/admin/scores", type: :request do
  path "/api/admin/scores" do
    get("list all scores") do
      tags "Admin"
      produces "application/json"
      security [ BearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer, required: false

      response(200, "successful") do
        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before do
          create_list(:score, 2, :published)
          create_list(:score, 1) # unpublished
          stub_firebase_verification(admin)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["scores"].length).to eq(3)
          expect(data["total_count"]).to eq(3)
          expect(data["scores"].first).to include("user")
        end
      end

      response(403, "forbidden (non-admin)") do
        let(:non_admin) { create(:user) }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before { stub_firebase_verification(non_admin) }

        run_test!
      end
    end
  end

  path "/api/admin/scores/{id}/unpublish" do
    patch("unpublish score") do
      tags "Admin"
      security [ BearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :id, in: :path, type: :integer, required: true

      response(204, "no content") do
        let(:admin) { create(:user, :admin) }
        let(:score) { create(:score, :published) }
        let(:id) { score.id }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before { stub_firebase_verification(admin) }

        run_test! do
          expect(score.reload.published).to be false
        end
      end

      response(403, "forbidden (non-admin)") do
        let(:non_admin) { create(:user) }
        let(:score) { create(:score, :published) }
        let(:id) { score.id }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before { stub_firebase_verification(non_admin) }

        run_test!
      end

      response(404, "not found") do
        let(:admin) { create(:user, :admin) }
        let(:id) { 0 }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before { stub_firebase_verification(admin) }

        run_test!
      end
    end
  end

  path "/api/admin/scores/{id}" do
    delete("delete score") do
      tags "Admin"
      security [ BearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :id, in: :path, type: :integer, required: true

      response(204, "no content") do
        let(:admin) { create(:user, :admin) }
        let(:score) { create(:score) }
        let(:id) { score.id }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before { stub_firebase_verification(admin) }

        run_test! do
          expect(Score.exists?(score.id)).to be false
        end
      end

      response(403, "forbidden (non-admin)") do
        let(:non_admin) { create(:user) }
        let(:score) { create(:score) }
        let(:id) { score.id }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before { stub_firebase_verification(non_admin) }

        run_test!
      end

      response(404, "not found") do
        let(:admin) { create(:user, :admin) }
        let(:id) { 0 }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before { stub_firebase_verification(admin) }

        run_test!
      end
    end
  end
end
