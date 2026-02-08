require 'rails_helper'

RSpec.describe FirebaseTokenVerifier do
  let(:project_id) { "test-project-id" }
  let(:verifier) { described_class.new(project_id) }

  describe "#verify" do
    before do
      # テストではエミュレータモードを無効にして本番パスをテストする
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("FIREBASE_AUTH_EMULATOR_HOST").and_return(nil)
    end

    context "with malformed token" do
      it "raises VerificationError" do
        expect { verifier.verify("not-a-jwt") }
          .to raise_error(FirebaseTokenVerifier::VerificationError)
      end
    end

    context "with empty string" do
      it "raises VerificationError" do
        expect { verifier.verify("") }
          .to raise_error(FirebaseTokenVerifier::VerificationError)
      end
    end

    context "with token missing kid header" do
      it "raises VerificationError" do
        # JWT without kid in header
        token = JWT.encode({ sub: "test" }, nil, "none")
        expect { verifier.verify(token) }
          .to raise_error(FirebaseTokenVerifier::VerificationError, /No kid in token header/)
      end
    end
  end

  describe "#verify in emulator mode" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("FIREBASE_AUTH_EMULATOR_HOST").and_return("localhost:9099")
    end

    context "with valid emulator token" do
      it "returns the payload" do
        token = JWT.encode({ sub: "emulator-user-123" }, nil, "none")
        payload = verifier.verify(token)
        expect(payload["sub"]).to eq("emulator-user-123")
      end
    end

    context "with emulator token missing sub" do
      it "raises VerificationError" do
        token = JWT.encode({ email: "test@example.com" }, nil, "none")
        expect { verifier.verify(token) }
          .to raise_error(FirebaseTokenVerifier::VerificationError, /sub is empty/)
      end
    end
  end
end
