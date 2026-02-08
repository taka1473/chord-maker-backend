class ApplicationController < ActionController::API
  private

  def authenticate!
    token = extract_token_from_header
    if token.nil?
      Rails.logger.warn "[Auth] No Authorization header found"
      render json: { error: "Authorization header is required" }, status: :unauthorized
      return
    end

    Rails.logger.info "[Auth] Token received (length=#{token.length})"
    payload = verify_firebase_token(token)
    return unless payload

    Rails.logger.info "[Auth] Token verified, sub=#{payload['sub']}"
    @current_user = find_or_create_user(payload)
  end

  def current_user
    @current_user
  end

  def extract_token_from_header
    auth_header = request.headers["Authorization"]
    return nil unless auth_header&.start_with?("Bearer ")

    auth_header.split(" ").last
  end

  def verify_firebase_token(token)
    FirebaseTokenVerifier.new.verify(token)
  rescue FirebaseTokenVerifier::VerificationError => e
    Rails.logger.warn "[Auth] Token verification failed: #{e.message}"
    render json: { error: "Invalid token: #{e.message}" }, status: :unauthorized
    nil
  end

  def find_or_create_user(payload)
    uid = payload["sub"]

    User.find_or_create_by!(account_id: uid) do |user|
      user.name = "user_#{SecureRandom.hex(4)}"
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "User creation failed: #{e.message}" }, status: :unprocessable_entity
    nil
  end
end
