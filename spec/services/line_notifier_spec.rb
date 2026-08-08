require 'rails_helper'

RSpec.describe LineNotifier do
  describe ".notify" do
    context "when line credentials are not configured" do
      it "skips without calling the API and returns false" do
        expect_any_instance_of(Net::HTTP).not_to receive(:request)
        expect(described_class.notify("hello")).to be false
      end
    end

    context "when line credentials are configured" do
      before do
        allow(Rails.application.credentials).to receive(:dig).and_call_original
        allow(Rails.application.credentials).to receive(:dig)
          .with(:line, :channel_access_token).and_return("test-token")
        allow(Rails.application.credentials).to receive(:dig)
          .with(:line, :admin_user_id).and_return("U1234567890")
      end

      it "returns true when the push succeeds" do
        response = Net::HTTPOK.new("1.1", "200", "OK")
        allow_any_instance_of(Net::HTTP).to receive(:request).and_return(response)

        expect(described_class.notify("hello")).to be true
      end

      it "returns false when the request raises instead of propagating the error" do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(Timeout::Error)

        expect(described_class.notify("hello")).to be false
      end
    end
  end
end
