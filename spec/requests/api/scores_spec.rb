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
          create(:score, title: 'test', key_name: 'A', tempo: 120, time_signature: '4/4')
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

  path '/api/scores/{id}/upsert_whole_score' do
    parameter name: 'id', in: :path, type: :string, description: 'id of existing score'
    
    patch('upsert whole score') do
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
              user_id: { type: :integer },
              published: { type: :boolean },
              measures_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    position: { type: :integer },
                    _destroy: { type: :boolean },
                    chords_attributes: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          id: { type: :integer },
                          position: { type: :integer },
                          root_offset: { type: :integer },
                          bass_offset: { type: :integer },
                          chord_type: { type: :string },
                          _destroy: { type: :boolean }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'whole score updated successfully') do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 key: { type: :integer },
                 key_name: { type: :string },
                 tempo: { type: :integer, nullable: true },
                 time_signature: { type: :string, nullable: true },
                 measures: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       position: { type: :integer },
                       chords: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             id: { type: :integer },
                             position: { type: :integer },
                             root_offset: { type: :integer },
                             bass_offset: { type: :integer },
                             chord_type: { type: :string }
                           }
                         }
                       }
                     }
                   }
                 }
               }

        let(:user) { create(:user) }
        let(:existing_score) { create(:score, title: 'Original Song', key_name: 'C', user: user) }
        let(:id) { existing_score.id }
        let(:score) do
          {
            score: {
              title: 'Updated Complete Song',
              key_name: 'G',
              tempo: 100,
              time_signature: '4/4',
              user_id: user.id,
              published: true,
              measures_attributes: [
                {
                  position: 1,
                  chords_attributes: [
                    { position: 1, root_offset: 0, bass_offset: 0, chord_type: 'major' },
                    { position: 2, root_offset: 5, bass_offset: 5, chord_type: 'minor' }
                  ]
                },
                {
                  position: 2,
                  chords_attributes: [
                    { position: 1, root_offset: 7, bass_offset: 7, chord_type: 'major' },
                    { position: 2, root_offset: 2, bass_offset: 2, chord_type: 'dim' }
                  ]
                }
              ]
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          
          # Test score attributes were updated
          expect(data['title']).to eq('Updated Complete Song')
          expect(data['key']).to eq(10) # G maps to 10
          expect(data['key_name']).to eq('G')
          expect(data['tempo']).to eq(100)
          expect(data['time_signature']).to eq('4/4')
          expect(data['id']).to eq(existing_score.id)
          
          # Test measures structure
          expect(data['measures']).to be_present
          expect(data['measures'].length).to eq(2)
          
          measures = data['measures'].sort_by { |m| m['position'] }
          
          # Test measure 1
          measure1 = measures[0]
          expect(measure1['position']).to eq(1)
          expect(measure1['chords'].length).to eq(2)
          
          chords_m1 = measure1['chords'].sort_by { |c| c['position'] }
          expect(chords_m1[0]['position']).to eq(1)
          expect(chords_m1[0]['root_offset']).to eq(0)
          expect(chords_m1[0]['chord_type']).to eq('major')
          
          expect(chords_m1[1]['position']).to eq(2)
          expect(chords_m1[1]['root_offset']).to eq(5)
          expect(chords_m1[1]['chord_type']).to eq('minor')
          
          # Test measure 2
          measure2 = measures[1]
          expect(measure2['position']).to eq(2)
          expect(measure2['chords'].length).to eq(2)
          
          chords_m2 = measure2['chords'].sort_by { |c| c['position'] }
          expect(chords_m2[0]['chord_type']).to eq('major')
          expect(chords_m2[1]['chord_type']).to eq('dim')
          
          # Verify database records were updated
          updated_score = Score.find(data['id'])
          expect(updated_score.title).to eq('Updated Complete Song')
          expect(updated_score.measures.count).to eq(2)
          expect(updated_score.chords.count).to eq(4)
        end
      end

      response(200, 'upsert score with updating existing measures') do
        let(:user) { create(:user) }
        let(:existing_score) { create(:score, title: 'Test Song', key_name: 'C', user: user) }
        let!(:measure1) { create(:measure, score: existing_score, position: 1) }
        let!(:chord1) { create(:chord, measure: measure1, position: 1, root_offset: 0, chord_type: 'major') }
        let(:id) { existing_score.id }
        let(:score) do
          {
            score: {
              title: 'Updated Song',
              key_name: 'D',
              user_id: user.id,
              measures_attributes: [
                {
                  id: measure1.id,
                  position: 1,
                  chords_attributes: [
                    {
                      id: chord1.id,
                      position: 1,
                      root_offset: 2, # Updated from 0 to 2
                      bass_offset: 2,
                      chord_type: 'minor' # Updated from major to minor
                    },
                    {
                      # New chord
                      position: 2,
                      root_offset: 5,
                      bass_offset: 5,
                      chord_type: 'aug'
                    }
                  ]
                }
              ]
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          
          expect(data['title']).to eq('Updated Song')
          expect(data['key']).to eq(5) # D maps to 5
          expect(data['measures'].length).to eq(1)
          
          measure = data['measures'][0]
          expect(measure['id']).to eq(measure1.id) # Same measure ID
          expect(measure['chords'].length).to eq(2)
          
          chords = measure['chords'].sort_by { |c| c['position'] }
          
          # Updated chord
          expect(chords[0]['id']).to eq(chord1.id) # Same chord ID
          expect(chords[0]['root_offset']).to eq(2) # Updated value
          expect(chords[0]['chord_type']).to eq('minor') # Updated value
          
          # New chord
          expect(chords[1]['id']).to be_present
          expect(chords[1]['id']).not_to eq(chord1.id) # Different ID
          expect(chords[1]['root_offset']).to eq(5)
          expect(chords[1]['chord_type']).to eq('aug')
        end
      end

      response(200, 'upsert score with deleting measures and chords') do
        let(:user) { create(:user) }
        let(:existing_score) { create(:score, title: 'Test Song', key_name: 'C', user: user) }
        let!(:measure1) { create(:measure, score: existing_score, position: 1) }
        let!(:measure2) { create(:measure, score: existing_score, position: 2) }
        let!(:chord1) { create(:chord, measure: measure1, position: 1, root_offset: 0, chord_type: 'major') }
        let!(:chord2) { create(:chord, measure: measure1, position: 2, root_offset: 5, chord_type: 'minor') }
        let!(:chord3) { create(:chord, measure: measure2, position: 1, root_offset: 7, chord_type: 'dim') }
        let(:id) { existing_score.id }
        let(:score) do
          {
            score: {
              title: 'Simplified Song',
              key_name: 'C',
              user_id: user.id,
              measures_attributes: [
                {
                  id: measure1.id,
                  position: 1,
                  chords_attributes: [
                    {
                      id: chord1.id,
                      position: 1,
                      root_offset: 0,
                      bass_offset: 0,
                      chord_type: 'major'
                    },
                    {
                      id: chord2.id,
                      _destroy: true # Delete this chord
                    }
                  ]
                },
                {
                  id: measure2.id,
                  _destroy: true # Delete this entire measure (and its chords)
                }
              ]
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          
          expect(data['title']).to eq('Simplified Song')
          expect(data['measures'].length).to eq(1) # measure2 deleted
          
          measure = data['measures'][0]
          expect(measure['id']).to eq(measure1.id)
          expect(measure['chords'].length).to eq(1) # chord2 deleted
          
          expect(measure['chords'][0]['id']).to eq(chord1.id)
          
          # Verify in database
          updated_score = Score.find(existing_score.id)
          expect(updated_score.measures.count).to eq(1)
          expect(updated_score.chords.count).to eq(1)
          expect { Measure.find(measure2.id) }.to raise_error(ActiveRecord::RecordNotFound)
          expect { Chord.find(chord2.id) }.to raise_error(ActiveRecord::RecordNotFound)
          expect { Chord.find(chord3.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      response(404, 'score not found') do
        let(:id) { 99999 }
        let(:score) do
          {
            score: {
              title: 'Test Song',
              key_name: 'C',
              user_id: 1,
              measures_attributes: []
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Score not found')
        end
      end

      response(422, 'validation errors') do
        context 'when updating with invalid score data' do
          let(:user) { create(:user) }
          let(:existing_score) { create(:score, title: 'Test Song', key_name: 'C', user: user) }
          let(:id) { existing_score.id }
          let(:score) do
            {
              score: {
                title: '', # Invalid - blank title
                key_name: 'C',
                user_id: user.id,
                measures_attributes: [
                  {
                    position: 1,
                    chords_attributes: [
                      { position: 1, root_offset: 0, bass_offset: 0, chord_type: 'major' }
                    ]
                  }
                ]
              }
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors']).to include("Title can't be blank")
          end
        end

        context 'when updating with invalid chord data' do
          let(:user) { create(:user) }
          let(:existing_score) { create(:score, title: 'Test Song', key_name: 'C', user: user) }
          let(:id) { existing_score.id }
          let(:score) do
            {
              score: {
                title: 'Test Song',
                key_name: 'C',
                user_id: user.id,
                measures_attributes: [
                  {
                    position: 1,
                    chords_attributes: [
                      { position: 1, root_offset: 15, bass_offset: 0, chord_type: 'major' } # Invalid root_offset
                    ]
                  }
                ]
              }
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors']).to include("Measures chords root offset must be less than or equal to 11")
          end
        end

        context 'when updating with invalid key_name' do
          let(:user) { create(:user) }
          let(:existing_score) { create(:score, title: 'Test Song', key_name: 'C', user: user) }
          let(:id) { existing_score.id }
          let(:score) do
            {
              score: {
                title: 'Test Song',
                key_name: 'InvalidKey',
                user_id: user.id,
                measures_attributes: []
              }
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors']).to include("Key name is not included in the list")
          end
        end

        context 'when updating with invalid tempo' do
          let(:user) { create(:user) }
          let(:existing_score) { create(:score, title: 'Test Song', key_name: 'C', user: user) }
          let(:id) { existing_score.id }
          let(:score) do
            {
              score: {
                title: 'Test Song',
                key_name: 'C',
                tempo: 600, # Invalid tempo
                user_id: user.id,
                measures_attributes: []
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
end
