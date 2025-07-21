require 'swagger_helper'

RSpec.describe 'api/scores', type: :request do

  path '/api/scores' do

    get('list scores') do
      response(200, 'successful') do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :integer },
            title: { type: :string },
            key: { type: :integer },
            key_name: { type: :string },
            tempo: { type: :integer },
            time_signature: { type: :string },
          },
          required: [:id, :title, :key, :key_name, :tempo, :time_signature]
        }
        run_test!
      end
    end
  end

  path '/api/scores/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show score') do
      response(200, 'successful') do
        let(:score) { create(:score, title: 'test', key: 0, key_name: 'A', tempo: 120, time_signature: '4/4') }
        let(:id) { score.id }

        schema type: :object, properties: {
          id: { type: :integer },
          title: { type: :string },
          key: { type: :integer },
          key_name: { type: :string },
          tempo: { type: :integer },
          time_signature: { type: :string },
        }, required: [:id, :title, :key, :key_name, :tempo, :time_signature]
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(id)
          expect(data['title']).to eq('test')
          expect(data['key']).to eq(0)
          expect(data['key_name']).to eq('A')
          expect(data['tempo']).to eq(120)
          expect(data['time_signature']).to eq('4/4')
        end
      end

      response(404, 'not found') do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
