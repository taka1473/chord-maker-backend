class Api::ContactsController < ApplicationController
  CATEGORY_LABELS = {
    "rights_violation" => "権利侵害の申し立て",
    "bug" => "不具合報告",
    "other" => "その他"
  }.freeze

  def create
    # ハニーポット: 画面上は不可視のフィールドが埋まっていたら bot とみなし、
    # 保存せずに成功レスポンスを返す
    if params[:website].present?
      head :created
      return
    end

    contact = Contact.new(contact_params)
    if contact.save
      notify_admin(contact)
      head :created
    else
      render_validation_errors(contact)
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:category, :body, :email, :score_url)
  end

  def notify_admin(contact)
    text = <<~TEXT.strip
      【Chordlet】新しい問い合わせ
      種別: #{CATEGORY_LABELS.fetch(contact.category, contact.category)}
      #{contact.score_url.present? ? "対象スコア: #{contact.score_url}\n" : ""}#{contact.email.present? ? "返信先: #{contact.email}\n" : ""}---
      #{contact.body.truncate(500)}
    TEXT
    LineNotifier.notify(text)
  end
end
