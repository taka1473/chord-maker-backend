require "swagger_helper"

RSpec.describe "api/admin/users", type: :request do
  path "/api/admin/users" do
    get("list users") do
      tags "Admin"
      produces "application/json"
      security [ BearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: "Firebase ID Token"
      parameter name: :page, in: :query, type: :integer, required: false

      response(200, "successful") do
        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before do
          create_list(:user, 3)
          stub_firebase_verification(admin)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["users"].length).to eq(4) # 3 + admin
          expect(data["total_count"]).to eq(4)
          expect(data["page"]).to eq(1)
          expect(data["per_page"]).to eq(20)
          expect(data["users"].first).to include("scores_count")
        end
      end

      response(401, "unauthorized") do
        let(:Authorization) { nil }

        run_test!
      end

      response(403, "forbidden (non-admin)") do
        let(:non_admin) { create(:user) }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before { stub_firebase_verification(non_admin) }

        run_test!
      end
    end
  end

  path "/api/admin/users/{id}" do
    delete("delete user") do
      tags "Admin"
      security [ BearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :id, in: :path, type: :integer, required: true

      response(204, "no content") do
        let(:admin) { create(:user, :admin) }
        let(:target_user) { create(:user) }
        let(:id) { target_user.id }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before { stub_firebase_verification(admin) }

        run_test! do
          expect(User.exists?(target_user.id)).to be false
        end
      end

      response(403, "forbidden (non-admin)") do
        let(:non_admin) { create(:user) }
        let(:target_user) { create(:user) }
        let(:id) { target_user.id }
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
