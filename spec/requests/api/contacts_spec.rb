require "swagger_helper"

RSpec.describe "api/contacts", type: :request do
  before do
    allow(LineNotifier).to receive(:notify).and_return(true)
  end

  path "/api/contacts" do
    post("create contact") do
      tags "Contacts"
      consumes "application/json"
      produces "application/json"
      parameter name: :contact, in: :body, schema: {
        type: :object,
        properties: {
          contact: {
            type: :object,
            properties: {
              category: { type: :string, enum: [ "rights_violation", "bug", "other" ] },
              body: { type: :string },
              email: { type: :string },
              score_url: { type: :string }
            },
            required: [ "category", "body" ]
          },
          website: { type: :string, description: "Honeypot field. Must be empty." }
        }
      }

      response(201, "contact created") do
        let(:contact) do
          {
            contact: {
              category: "rights_violation",
              body: "権利侵害の報告です",
              email: "reporter@example.com",
              score_url: "https://chord-let.com/scores/abc123"
            }
          }
        end

        run_test! do
          expect(Contact.count).to eq(1)
          created = Contact.last
          expect(created.category).to eq("rights_violation")
          expect(created.status).to eq("open")
          expect(LineNotifier).to have_received(:notify).with(a_string_including("権利侵害の申し立て"))
        end
      end

      response(201, "honeypot filled (bot): pretends success without saving") do
        let(:contact) do
          {
            contact: { category: "other", body: "spam" },
            website: "http://spam.example.com"
          }
        end

        run_test! do
          expect(Contact.count).to eq(0)
          expect(LineNotifier).not_to have_received(:notify)
        end
      end

      response(422, "validation error") do
        let(:contact) do
          { contact: { category: "invalid_category", body: "" } }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["errors"]["category"]).to be_present
          expect(data["errors"]["body"]).to be_present
          expect(LineNotifier).not_to have_received(:notify)
        end
      end
    end
  end
end
