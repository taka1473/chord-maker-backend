require "net/http"

class FirebaseTokenVerifier
  GOOGLE_CERTS_URL = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
  ISSUER_PREFIX = "https://securetoken.google.com/"

  class VerificationError < StandardError; end

  def initialize(project_id = nil)
    @project_id = project_id || Rails.application.credentials.dig(:firebase, :project_id)
  end

  def verify(token)
    header = JWT.decode(token, nil, false).last

    if emulator_mode?
      return verify_emulator_token(token, header)
    end

    kid = header["kid"]
    raise VerificationError, "No kid in token header" unless kid

    public_key = fetch_public_key(kid)

    payload, = JWT.decode(
      token,
      public_key,
      true,
      {
        algorithm: "RS256",
        verify_iss: true,
        iss: "#{ISSUER_PREFIX}#{@project_id}",
        verify_aud: true,
        aud: @project_id,
        verify_iat: true,
        verify_expiration: true
      }
    )

    raise VerificationError, "sub is empty" if payload["sub"].blank?

    payload
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIssuerError,
         JWT::InvalidAudError, JWT::InvalidIatError => e
    raise VerificationError, e.message
  end

  private

  def fetch_public_key(kid)
    certs = cached_certs
    cert_pem = certs[kid]
    raise VerificationError, "Public key not found for kid: #{kid}" unless cert_pem

    OpenSSL::X509::Certificate.new(cert_pem).public_key
  end

  def cached_certs
    Rails.cache.fetch("firebase_google_certs", expires_in: 1.hour) do
      response = Net::HTTP.get(URI(GOOGLE_CERTS_URL))
      JSON.parse(response)
    end
  end

  def emulator_mode?
    ENV["FIREBASE_AUTH_EMULATOR_HOST"].present?
  end

  def verify_emulator_token(token, header)
    raise VerificationError, "Emulator mode only allowed in development/test" unless Rails.env.development? || Rails.env.test?

    payload, = JWT.decode(token, nil, false, { algorithms: [ header["alg"] || "none" ] })

    raise VerificationError, "sub is empty" if payload["sub"].blank?

    payload
  end
end
