class Api::Admin::ContactsController < Api::Admin::BaseController
  PER_PAGE = 20

  def index
    contacts = Contact.order(created_at: :desc)
    contacts = contacts.where(status: params[:status]) if params[:status].present?
    contacts = contacts.where(category: params[:category]) if params[:category].present?

    total_count = contacts.count
    page = [ params[:page].to_i, 1 ].max
    contacts = contacts.limit(PER_PAGE).offset((page - 1) * PER_PAGE)

    render json: {
      contacts: contacts.as_json(only: [ :id, :category, :body, :email, :score_url, :status, :created_at ]),
      total_count: total_count,
      page: page,
      per_page: PER_PAGE
    }
  end

  def update
    contact = Contact.find(params[:id])
    if contact.update(params.require(:contact).permit(:status))
      render json: contact.as_json(only: [ :id, :category, :body, :email, :score_url, :status, :created_at ])
    else
      render_validation_errors(contact)
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Contact not found" }, status: :not_found
  end
end
