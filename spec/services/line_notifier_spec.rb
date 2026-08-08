require 'rails_helper'

RSpec.describe LineNotifier do
  describe ".notify" do
    context "when LINE env vars are not configured" do
      it "skips without calling the API and returns false" do
        expect_any_instance_of(Net::HTTP).not_to receive(:request)
        expect(described_class.notify("hello")).to be false
      end
    end

    context "when LINE env vars are configured" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("LINE_CHANNEL_ACCESS_TOKEN").and_return("test-token")
        allow(ENV).to receive(:[]).with("LINE_ADMIN_USER_ID").and_return("U1234567890")
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
