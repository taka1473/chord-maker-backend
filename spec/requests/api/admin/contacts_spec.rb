require "swagger_helper"

RSpec.describe "api/admin/contacts", type: :request do
  path "/api/admin/contacts" do
    get("list contacts") do
      tags "Admin"
      produces "application/json"
      security [ BearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :status, in: :query, type: :string, required: false,
        description: "Filter by status (open / resolved)"
      parameter name: :category, in: :query, type: :string, required: false,
        description: "Filter by category (rights_violation / bug / other)"

      response(200, "successful") do
        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer mock-firebase-token" }

        before do
          create_list(:contact, 2)
          create(:contact, category: "bug", status: "resolved")
          stub_firebase_verification(admin)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["contacts"].length).to eq(3)
          expect(data["total_count"]).to eq(3)
          expect(data["contacts"].first).to include("category", "body", "status", "created_at")
        end
      end

      response(200, "filtered by status") do
        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer mock-firebase-token" }
        let(:status) { "open" }

        before do
          create(:contact, status: "open")
          create(:contact, status: "resolved")
          stub_firebase_verification(admin)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["contacts"].length).to eq(1)
          expect(data["contacts"].first["status"]).to eq("open")
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

  path "/api/admin/contacts/{id}" do
    patch("update contact status") do
      tags "Admin"
      consumes "application/json"
      produces "application/json"
      security [ BearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :contact, in: :body, schema: {
        type: :object,
        properties: {
          contact: {
            type: :object,
            properties: {
              status: { type: :string, enum: [ "open", "resolved" ] }
            },
            required: [ "status" ]
          }
        }
      }

      response(200, "status updated") do
        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer mock-firebase-token" }
        let(:id) { create(:contact, status: "open").id }
        let(:contact) { { contact: { status: "resolved" } } }

        before { stub_firebase_verification(admin) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["status"]).to eq("resolved")
          expect(Contact.find(id).status).to eq("resolved")
        end
      end

      response(404, "contact not found") do
        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer mock-firebase-token" }
        let(:id) { 999_999 }
        let(:contact) { { contact: { status: "resolved" } } }

        before { stub_firebase_verification(admin) }

        run_test!
      end

      response(403, "forbidden (non-admin)") do
        let(:non_admin) { create(:user) }
        let(:Authorization) { "Bearer mock-firebase-token" }
        let(:id) { create(:contact).id }
        let(:contact) { { contact: { status: "resolved" } } }

        before { stub_firebase_verification(non_admin) }

        run_test!
      end
    end
  end
end
