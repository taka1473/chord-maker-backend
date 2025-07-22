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

    post('create score') do
      consumes 'application/json'
      produces 'application/json'
      parameter name: :score, in: :body, schema: {
        type: :object,
        properties: {
          score: {
            type: :object,
            properties: {
              title: { type: :string },
              key_name: { type: :string },
              tempo: { type: :integer },
              time_signature: { type: :string },
              lyrics: { type: :string },
              user_id: { type: :integer },
              published: { type: :boolean }
            },
            required: ['title', 'key_name', 'user_id']
          }
        }
      }

      response(201, 'score created') do
        schema '$ref' => '#/components/schemas/Score'

        let(:user) { create(:user) }
        let(:score) do
          {
            score: {
              title: 'New Test Song',
              key_name: 'C',
              tempo: 140,
              time_signature: '3/4',
              lyrics: 'Test lyrics for new song',
              user_id: user.id,
              published: false
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          
          expect(data['title']).to eq('New Test Song')
          expect(data['key']).to eq(3) # C maps to 3, automatically set by set_key callback
          expect(data['key_name']).to eq('C')
          expect(data['tempo']).to eq(140)
          expect(data['time_signature']).to eq('3/4')
          expect(data['lyrics']).to eq('Test lyrics for new song')
          expect(data['id']).to be_present
          expect(data['created_at']).to be_present
          
          # Verify the score was actually created in database
          created_score = Score.find(data['id'])
          expect(created_score.title).to eq('New Test Song')
          expect(created_score.user_id).to eq(user.id)
          expect(created_score.key).to eq(3) # Verify key was automatically set
        end
      end

      response(201, 'score created with minimal data') do
        let(:user) { create(:user) }
        let(:score) do
          {
            score: {
              title: 'Minimal Song',
              key_name: 'C',
              user_id: user.id
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          
          expect(data['title']).to eq('Minimal Song')
          expect(data['key']).to eq(3) # C maps to 3, automatically set by set_key callback
          expect(data['key_name']).to eq('C')
          expect(data['tempo']).to be_nil
          expect(data['time_signature']).to be_nil
          expect(data['lyrics']).to be_nil
          expect(data['id']).to be_present
        end
      end

      response(422, 'validation errors') do
        context 'when title is missing' do
          let(:user) { create(:user) }
          let(:score) do
            {
              score: {
                key_name: 'C',
                user_id: user.id
              }
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors']).to include("Title can't be blank")
          end
        end

        context 'when key_name is missing' do
          let(:user) { create(:user) }
          let(:score) do
            {
              score: {
                title: 'Test Song',
                user_id: user.id
              }
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors']).to include("Key name can't be blank")
          end
        end

        context 'when key_name is invalid' do
          let(:user) { create(:user) }
          let(:score) do
            {
              score: {
                title: 'Test Song',
                key_name: 'InvalidKey',
                user_id: user.id
              }
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors']).to include("Key name is not included in the list")
          end
        end

        context 'when user_id is missing' do
          let(:score) do
            {
              score: {
                title: 'Test Song',
                key_name: 'C'
              }
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors']).to include("User must exist")
          end
        end

        context 'when tempo is invalid' do
          let(:user) { create(:user) }
          let(:score) do
            {
              score: {
                title: 'Test Song',
                key_name: 'C',
                user_id: user.id,
                tempo: 600
              }
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors']).to include("Tempo must be less than 500")
          end
        end
      end
    end
  end

  path '/api/scores/{id}/whole_score' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    
    get('show score') do
      produces 'application/json'

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Score'

        let(:score) do
          create(:score, title: 'test', key_name: 'A', tempo: 120, time_signature: '4/4', lyrics: 'Test lyrics')
        end
        let!(:measure1) { create(:measure, score: score, position: 1) }
        let!(:measure2) { create(:measure, score: score, position: 2) }
        let!(:chord1) { create(:chord, measure: measure1, position: 1, root_offset: 0, bass_offset: 0, chord_type: 'major') }
        let!(:chord2) { create(:chord, measure: measure1, position: 2, root_offset: 5, bass_offset: 5, chord_type: 'minor') }
        let!(:chord3) { create(:chord, measure: measure2, position: 1, root_offset: 7, bass_offset: 7, chord_type: 'major') }
        let(:id) { score.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          
          # Test score attributes
          expect(data['id']).to eq(id)
          expect(data['title']).to eq('test')
          expect(data['key']).to eq(0)
          expect(data['key_name']).to eq('A')
          expect(data['tempo']).to eq(120)
          expect(data['time_signature']).to eq('4/4')
          expect(data['lyrics']).to eq('Test lyrics')
          
          # Test measures are included
          expect(data['measures']).to be_present
          expect(data['measures'].length).to eq(2)
          
          # Test measure attributes and order
          measures = data['measures'].sort_by { |m| m['position'] }
          expect(measures[0]['id']).to eq(measure1.id)
          expect(measures[0]['position']).to eq(1)
          expect(measures[1]['id']).to eq(measure2.id)
          expect(measures[1]['position']).to eq(2)
          
          # Test chords are included in measures
          measure1_data = measures.find { |m| m['id'] == measure1.id }
          measure2_data = measures.find { |m| m['id'] == measure2.id }
          
          expect(measure1_data['chords']).to be_present
          expect(measure1_data['chords'].length).to eq(2)
          expect(measure2_data['chords']).to be_present
          expect(measure2_data['chords'].length).to eq(1)
          
          # Test chord attributes for measure1
          chords_m1 = measure1_data['chords'].sort_by { |c| c['position'] }
          expect(chords_m1[0]['id']).to eq(chord1.id)
          expect(chords_m1[0]['position']).to eq(1)
          expect(chords_m1[0]['root_offset']).to eq(0)
          expect(chords_m1[0]['bass_offset']).to eq(0)
          expect(chords_m1[0]['chord_type']).to eq('major')
          
          expect(chords_m1[1]['id']).to eq(chord2.id)
          expect(chords_m1[1]['position']).to eq(2)
          expect(chords_m1[1]['root_offset']).to eq(5)
          expect(chords_m1[1]['bass_offset']).to eq(5)
          expect(chords_m1[1]['chord_type']).to eq('minor')
          
          # Test chord attributes for measure2
          chords_m2 = measure2_data['chords']
          expect(chords_m2[0]['id']).to eq(chord3.id)
          expect(chords_m2[0]['position']).to eq(1)
          expect(chords_m2[0]['root_offset']).to eq(7)
          expect(chords_m2[0]['bass_offset']).to eq(7)
          expect(chords_m2[0]['chord_type']).to eq('major')
        end
      end

      response(404, 'not found') do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
