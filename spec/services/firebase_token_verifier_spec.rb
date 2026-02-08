require 'rails_helper'

RSpec.describe FirebaseTokenVerifier do
  let(:project_id) { "test-project-id" }
  let(:verifier) { described_class.new(project_id) }

  describe "#verify" do
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
end
