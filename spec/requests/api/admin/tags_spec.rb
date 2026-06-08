require "swagger_helper"

RSpec.describe "api/admin/tags", type: :request do
  path "/api/admin/tags" do
    get("list tags") do
      tags "Admin"
      produces "application/json"
      security [ BearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer, required: false

      response(200, "successful") do
        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before do
          create_list(:tag, 3)
          stub_firebase_verification(admin)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["tags"].length).to eq(3)
          expect(data["total_count"]).to eq(3)
          expect(data["tags"].first).to include("scores_count")
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

  path "/api/admin/tags/{id}" do
    delete("delete tag") do
      tags "Admin"
      security [ BearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :id, in: :path, type: :integer, required: true

      response(204, "no content") do
        let(:admin) { create(:user, :admin) }
        let(:tag) { create(:tag) }
        let(:id) { tag.id }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before { stub_firebase_verification(admin) }

        run_test! do
          expect(Tag.exists?(tag.id)).to be false
        end
      end

      response(403, "forbidden (non-admin)") do
        let(:non_admin) { create(:user) }
        let(:tag) { create(:tag) }
        let(:id) { tag.id }
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
