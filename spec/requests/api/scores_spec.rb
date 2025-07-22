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

  path '/api/scores/{id}/whole_score' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    
    get('show score') do
      produces 'application/json'

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Score'

        let(:score) do
          create(:score, title: 'test', key: 0, key_name: 'A', tempo: 120, time_signature: '4/4', lyrics: 'Test lyrics')
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
