# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      components: {
        schemas: {
          Score: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              key: { 
                type: :integer, 
                description: 'Key as integer (0: A, 1: A#, etc.)' 
              },
              key_name: { 
                type: :string, 
                description: 'Key name distinguishing A# from Bb' 
              },
              tempo: { 
                type: :integer, 
                nullable: true, 
                description: 'Beats per minute' 
              },
              time_signature: { 
                type: :string, 
                nullable: true, 
                description: 'Time signature (e.g., 4/4)' 
              },
              lyrics: { 
                type: :string, 
                nullable: true, 
                description: 'Song lyrics' 
              },
              measures: {
                type: :array,
                items: { '$ref': '#/components/schemas/Measure' },
                description: 'Array of measures containing chords'
              }
            },
            required: [:id, :title, :key, :key_name, :tempo, :time_signature, :lyrics]
          },
          
          Measure: {
            type: :object,
            properties: {
              id: { 
                type: :integer, 
                description: 'Unique identifier for the measure' 
              },
              position: { 
                type: :integer, 
                description: 'Position of the measure in the score' 
              },
              chords: {
                type: :array,
                items: { '$ref': '#/components/schemas/Chord' },
                description: 'Array of chords in this measure'
              }
            },
            required: [:id, :position, :chords]
          },
          
          Chord: {
            type: :object,
            properties: {
              id: { 
                type: :integer, 
                description: 'Unique identifier for the chord' 
              },
              position: { 
                type: :integer, 
                description: 'Position of the chord within the measure' 
              },
              root_offset: { 
                type: :integer, 
                description: 'Root note offset (0-11, where 0=A, 1=A#, etc.)' 
              },
              bass_offset: { 
                type: :integer, 
                description: 'Bass note offset (0-11, where 0=A, 1=A#, etc.)' 
              },
              chord_type: { 
                type: :string, 
                description: 'Type of chord (e.g., major, minor, dominant7)' 
              }
            },
            required: [:id, :position, :root_offset, :bass_offset, :chord_type]
          },

          ChordType: {
            type: :string,
            enum: Chord::CHORD_TYPES
          }
        }
      },
      servers: [
        {
          url: 'http://localhost:3000',
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
