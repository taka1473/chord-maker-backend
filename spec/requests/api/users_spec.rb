require "swagger_helper"

RSpec.describe "api/users", type: :request do
  path "/api/users/me" do
    delete("delete own account") do
      tags "Users"
      produces "application/json"
      security [ BearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true

      response(204, "account deleted and scores anonymized") do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer mock-firebase-token" }
        let!(:published_score) { create(:score, :published, user: user) }
        let!(:unpublished_score) do
          create(:score, user: user, guest_token: "guest-token-123", guest_expires_at: 1.day.from_now)
        end

        before { stub_firebase_verification(user) }

        run_test! do
          expect(User.exists?(user.id)).to be false

          # スコアは削除されず匿名化される
          expect(Score.exists?(published_score.id)).to be true
          published_score.reload
          unpublished_score.reload
          expect(published_score.user_id).to be_nil
          expect(published_score.published).to be true
          expect(unpublished_score.user_id).to be_nil
          expect(unpublished_score.guest_token).to be_nil
          expect(unpublished_score.guest_expires_at).to be_nil
        end
      end

      response(401, "unauthorized") do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
