module FirebaseAuthHelper
  def stub_firebase_verification(user)
    payload = {
      "sub" => user.account_id,
      "name" => user.name,
      "email" => "#{user.account_id}@example.com",
      "iss" => "https://securetoken.google.com/test-project-id",
      "aud" => "test-project-id",
      "iat" => Time.current.to_i,
      "exp" => 1.hour.from_now.to_i
    }

    verifier = instance_double(FirebaseTokenVerifier)
    allow(FirebaseTokenVerifier).to receive(:new).and_return(verifier)
    allow(verifier).to receive(:verify).and_return(payload)
  end

  def stub_firebase_verification_failure(message = "Invalid token")
    verifier = instance_double(FirebaseTokenVerifier)
    allow(FirebaseTokenVerifier).to receive(:new).and_return(verifier)
    allow(verifier).to receive(:verify)
      .and_raise(FirebaseTokenVerifier::VerificationError, message)
  end
end
