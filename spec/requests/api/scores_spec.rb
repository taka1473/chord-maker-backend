require 'swagger_helper'

RSpec.describe 'api/scores', type: :request do

  path '/api/scores' do

    get('list scores') do
      produces 'application/json'

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Score' }

        before { create_list(:score, 3) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.length).to eq(3)
        end
      end
    end
  end

  path '/api/scores/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    
    get('show score') do
      produces 'application/json'

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Score'

        let(:score) { create(:score, title: 'test', key: 0, key_name: 'A', tempo: 120, time_signature: '4/4') }
        let(:id) { score.id }

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
