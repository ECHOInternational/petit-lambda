require 'petit'
require 'spec_helper'
require 'rack/test'
require 'rack/parser'

describe 'Petit App' do
  include Rack::Test::Methods

  def app
    Petit::App
  end

  before(:example) do
    Petit.reset
    # Set configuration values using these environment variables.
    Petit.configure do |config|
      config.db_table_name = ENV['DB_TABLE_NAME']
      config.api_base_url = ENV['API_BASE_URL']
      config.service_base_url = ENV['SERVICE_BASE_URL']
      config.cross_origin_domain = ENV['CROSS_ORIGIN_DOMAIN']
    end
  end

  describe "options '/suggestion" do
    it "returns CORS headers" do
      options '/suggestion', {}, 'HTTPS' => 'on'
      expect(last_response.header).to include "Access-Control-Allow-Origin"
      expect(last_response.header).to include "Access-Control-Allow-Methods"
      expect(last_response.header).to include "Access-Control-Allow-Headers"
    end
    it "returns success code 200" do
      options '/suggestion', {}, 'HTTPS' => 'on'
      expect(last_response.status).to eq 200
    end
    it "allows only specified domain" do
      options '/suggestion', {}, 'HTTPS' => 'on'
      expect(last_response.header["Access-Control-Allow-Origin"]).to eq Petit.configuration.cross_origin_domain
    end
    it "allows required headers" do
      options '/suggestion', {}, 'HTTPS' => 'on'
      expect(last_response.header["Access-Control-Allow-Headers"]).to eq 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
    end
    it "only allows get and options methods" do
      options '/suggestion', {}, 'HTTPS' => 'on'
      expect(last_response.header["Access-Control-Allow-Methods"]).to eq 'GET,OPTIONS'
    end
  end

  describe "get '/suggestion" do
    it "returns a CORS header" do
      header 'Accept', 'application/json'
      get '/suggestion', {}, 'HTTPS' => 'on'
      expect(last_response.header).to include "Access-Control-Allow-Origin"
      expect(last_response.header["Access-Control-Allow-Origin"]).to eq Petit.configuration.cross_origin_domain
    end
    context 'when json is requested' do
      it "returns Content-Type of 'application/vnd.api+json'" do
        header 'Accept', 'application/json'
        get '/suggestion', {}, 'HTTPS' => 'on'
        expect(last_response.header['Content-Type']).to include 'application/vnd.api+json'
      end
      it 'returns a json object' do
        header 'Accept', 'application/json'
        get '/suggestion', {}, 'HTTPS' => 'on'
        expect do
          JSON.parse(last_response.body)
        end.to_not raise_error
      end
      it 'returns a properly formatted vnd.api+json object' do
        header 'Accept', 'application/json'
        get '/suggestion', {}, 'HTTPS' => 'on'
        json_response = JSON.parse(last_response.body)
        expect(json_response).to include 'data'
        expect(json_response['data']).to be_a Hash
        expect(json_response['data']).to include 'type'
        expect(json_response['data']['type']).to eq 'suggestion'
        expect(json_response['data']['id']).to be_a String
        expect(json_response['data']).to include 'attributes'
        expect(json_response['data']['attributes']).to include 'name'
        expect(json_response['data']['attributes']['name'].length).to be > 0
        expect(json_response['data']['attributes']['name']).to be_a String
      end
    end
    context 'when vnd.api+json is requested' do
      it "returns Content-Type of 'application/vnd.api+json'" do
        header 'Accept', 'application/vnd.api+json'
        get '/suggestion', {}, 'HTTPS' => 'on'
        expect(last_response.header['Content-Type']).to include 'application/vnd.api+json'
      end
      it 'returns a json object' do
        header 'Accept', 'application/vnd.api+json'
        get '/suggestion', {}, 'HTTPS' => 'on'
        expect do
          JSON.parse(last_response.body)
        end.to_not raise_error
      end
      it 'returns a properly formatted vnd.api+json object' do
        header 'Accept', 'application/vnd.api+json'
        get '/suggestion', {}, 'HTTPS' => 'on'
        json_response = JSON.parse(last_response.body)
        expect(json_response).to include 'data'
        expect(json_response['data']).to be_a Hash
        expect(json_response['data']).to include 'type'
        expect(json_response['data']['type']).to eq 'suggestion'
        expect(json_response['data']['id']).to be_a String
        expect(json_response['data']).to include 'attributes'
        expect(json_response['data']['attributes']).to include 'name'
        expect(json_response['data']['attributes']['name'].length).to be > 0
        expect(json_response['data']['attributes']['name']).to be_a String
      end
    end
    context 'when plaintext is requested' do
      it 'returns a string' do
        header 'Accept', 'text/html'
        get '/suggestion', {}, 'HTTPS' => 'on'
        expect(last_response.header['Content-Type']).to include 'text/html'
        expect(last_response.body).to be_a String
      end
    end
    context 'when leading path segments are present' do
      it "ignores extra leading path segments" do
        header 'Accept', 'application/vnd.api+json'
        get '/dumpthis/garbage/suggestion', {}, 'HTTPS' => 'on'
        json_response = JSON.parse(last_response.body)
        expect(json_response).to include 'data'
        expect(json_response['data']).to be_a Hash
        expect(json_response['data']).to include 'type'
        expect(json_response['data']['type']).to eq 'suggestion'
        expect(json_response['data']['id']).to be_a String
        expect(json_response['data']).to include 'attributes'
        expect(json_response['data']['attributes']).to include 'name'
        expect(json_response['data']['attributes']['name'].length).to be > 0
        expect(json_response['data']['attributes']['name']).to be_a String
      end
    end
  end

  describe "options '/shortcodes" do
    it "returns CORS headers" do
      options '/shortcodes', {}, 'HTTPS' => 'on'
      expect(last_response.header).to include "Access-Control-Allow-Origin"
      expect(last_response.header).to include "Access-Control-Allow-Methods"
      expect(last_response.header).to include "Access-Control-Allow-Headers"
    end
    it "returns success code 200" do
      options '/shortcodes', {}, 'HTTPS' => 'on'
      expect(last_response.status).to eq 200
    end
    it "allows only specified domain" do
      options '/shortcodes', {}, 'HTTPS' => 'on'
      expect(last_response.header["Access-Control-Allow-Origin"]).to eq Petit.configuration.cross_origin_domain
    end
    it "allows required headers" do
      options '/shortcodes', {}, 'HTTPS' => 'on'
      expect(last_response.header["Access-Control-Allow-Headers"]).to eq 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
    end
    it "only allows get and options methods" do
      options '/shortcodes', {}, 'HTTPS' => 'on'
      expect(last_response.header["Access-Control-Allow-Methods"]).to eq 'GET,OPTIONS'
    end
  end

  describe "get '/shortcodes'" do
    it "returns a CORS header" do
      header 'Accept', 'application/json'
      get '/shortcodes', {}, 'HTTPS' => 'on'
      expect(last_response.header).to include "Access-Control-Allow-Origin"
      expect(last_response.header["Access-Control-Allow-Origin"]).to eq Petit.configuration.cross_origin_domain
    end
    context 'when json is requested' do
      it "returns Content-Type of 'application/vnd.api+json'" do
        header 'Accept', 'application/json'
        get '/shortcodes', { 'destination' => 'www.gobbledygoodadfadf.id' }, 'HTTPS' => 'on'
        expect(last_response.header['Content-Type']).to include 'application/vnd.api+json'
      end
      it 'returns a json object' do
        header 'Accept', 'application/json'
        get(
          '/shortcodes',
          {
            'destination' => 'www.gobbledygoodadfadf.id'
          },
          'HTTPS' => 'on'
        )
        expect do
          JSON.parse(last_response.body)
        end.to_not raise_error
      end
    end
    context 'when destination argument is not supplied' do
      it 'returns an error code 400' do
        get '/shortcodes', {}, 'HTTPS' => 'on'
        expect(last_response.status).to eq 400
      end
      context 'when json is requested' do
        it 'returns a json api conformant object' do
          header 'Accept', 'application/json'
          get '/shortcodes', {}, 'HTTPS' => 'on'
          json_response = JSON.parse(last_response.body)
          expect(json_response).to include 'errors'
          expect(json_response['errors']).to be_a Array
          expect(json_response['errors'].length).to be >= 1
          expect(json_response['errors'][0]).to include 'message'
        end
      end
    end
    context 'when destination argument is supplied' do
      context 'when json is requested' do
        it 'returns a jsonapi conformant object' do
          header 'Accept', 'application/json'
          get(
            '/shortcodes',
            {
              'destination' => 'www.gobbledygoodadfadf.id'
            },
            'HTTPS' => 'on'
          )
          json_response = JSON.parse(last_response.body)
          expect(json_response).to include 'data'
        end
        context 'when no records exist' do
          it 'returns and empty array' do
            header 'Accept', 'application/json'
            get(
              '/shortcodes',
              {
                'destination' => 'www.gobbledygoodadfadf.id'
              },
              'HTTPS' => 'on'
            )
            json_response = JSON.parse(last_response.body)
            expect(json_response['data']).to eq []
          end
        end
        context 'when records exist' do
          it 'returns and array of hashes' do
            header 'Accept', 'application/json'
            get(
              '/shortcodes',
              { 'destination' => 'www.yahoo.com' },
              'HTTPS' => 'on'
            )
            json_response = JSON.parse(last_response.body)
            expect(json_response['data']).to be_kind_of Array
            expect(json_response['data'].length).to be > 0
          end
          it 'returns child objects with destination and interpreted short code as json' do
            header 'Accept', 'application/json'
            get(
              '/shortcodes',
              { 'destination' => 'www.yahoo.com' },
              'HTTPS' => 'on'
            )
            json_response = JSON.parse(last_response.body)
            expect(json_response['data'][0]['attributes']).to include 'name'
            expect(json_response['data'][0]['attributes']).to include 'destination'
          end
          it 'returns child objects with a url to the generated shortcode' do
            header 'Accept', 'application/json'
            get(
              '/shortcodes',
              { 'destination' => 'www.yahoo.com' },
              'HTTPS' => 'on'
            )
            json_response = JSON.parse(last_response.body)
            expect(json_response['data'][0]['meta']).to include 'generated_link'
            expect(json_response['data'][0]['meta']['generated_link']).to be_kind_of String
          end
          it 'returns child objects with a qr-code attribute' do
            header 'Accept', 'application/json'
            get(
              '/shortcodes',
              { 'destination' => 'www.yahoo.com' },
              'HTTPS' => 'on'
            )
            json_response = JSON.parse(last_response.body)
            expect(json_response['data'][0]['attributes']).to include 'qr-code'
            expect(json_response['data'][0]['attributes']['qr-code']).to be_kind_of String
          end
          context 'when leading path segments are present' do
            it "ignores extra leading path segments" do
              header 'Accept', 'application/json'
              get(
                '/leading/garbage/shortcodes',
                { 'destination' => 'www.yahoo.com' },
                'HTTPS' => 'on'
              )
              json_response = JSON.parse(last_response.body)
              expect(json_response['data'][0]['attributes']).to include 'name'
              expect(json_response['data'][0]['attributes']).to include 'destination'
            end
          end
          context 'when sparse fieldsets are requested' do
            it 'only returns requested attributes' do
              header 'Accept', 'application/json'
              get(

                '/shortcodes?fields[shortcodes]=name',
                { 'destination' => 'www.yahoo.com' },
                'HTTPS' => 'on'
              )
              json_response = JSON.parse(last_response.body)
              expect(json_response['data'][0]['attributes']).to include 'name'
              expect(json_response['data'][0]['attributes']).to_not include 'qr-code'
            end
          end
        end
      end
    end
  end

  describe "head '/shortcodes/:shortcode" do
    context 'when the shortcode is not present' do
      it 'returns 404' do
        head '/shortcodes/342jklh23', {}, 'HTTPS' => 'on'
        expect(last_response.status).to eq 404
      end
      it 'has no body' do
        head '/shortcodes/342jklh23', {}, 'HTTPS' => 'on'
        expect(last_response.body).to be_empty
      end
    end
    context 'when the shortcode is present' do
      it 'returns 200' do
        head '/shortcodes/abc123', {}, 'HTTPS' => 'on'
        expect(last_response.status).to eq 200
      end
      it 'has no body' do
        head '/shortcodes/abc123', {}, 'HTTPS' => 'on'
        expect(last_response.body).to be_empty
      end
      it "returns a CORS header" do
        head '/shortcodes/abc123', {}, 'HTTPS' => 'on'
        expect(last_response.header).to include "Access-Control-Allow-Origin"
        expect(last_response.header["Access-Control-Allow-Origin"]).to eq Petit.configuration.cross_origin_domain
      end
      context 'when leading path segments are present' do
        it "ignores extra leading path segments" do
          head '/extra/garbage/shortcodes/abc123', {}, 'HTTPS' => 'on'
          expect(last_response.status).to eq 200
        end
      end
    end
  end

  describe "options '/shortcodes/:shortcode" do
    it "returns CORS headers" do
      options '/shortcodes/abc123', {}, 'HTTPS' => 'on'
      expect(last_response.header).to include "Access-Control-Allow-Origin"
      expect(last_response.header).to include "Access-Control-Allow-Methods"
      expect(last_response.header).to include "Access-Control-Allow-Headers"
    end
    it "returns success code 200" do
      options '/shortcodes/abc123', {}, 'HTTPS' => 'on'
      expect(last_response.status).to eq 200
    end
    it "allows only specified domain" do
      options '/shortcodes/abc123', {}, 'HTTPS' => 'on'
      expect(last_response.header["Access-Control-Allow-Origin"]).to eq Petit.configuration.cross_origin_domain
    end
    it "allows required headers" do
      options '/shortcodes/abc123', {}, 'HTTPS' => 'on'
      expect(last_response.header["Access-Control-Allow-Headers"]).to eq 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
    end
    it "only allows head and options methods" do
      options '/shortcodes/abc123', {}, 'HTTPS' => 'on'
      expect(last_response.header["Access-Control-Allow-Methods"]).to eq 'HEAD,OPTIONS'
    end
  end

  describe "get '/shortcodes/:shortcode'" do
    it "does not return a CORS header" do
      header 'Accept', 'application/json'
      get '/shortcodes/abc123', {}, 'HTTPS' => 'on'
      expect(last_response.header).to_not include "Access-Control-Allow-Origin"
    end
    context 'when json is requested' do
      context 'when the shortcode is present' do
        it "returns Content-Type of 'application/vnd.api+json'" do
          get '/shortcodes/abc123', 'HTTPS' => 'on'
          expect(last_response.header['Content-Type']).to include 'application/vnd.api+json'
        end
        it 'returns a json object' do
          get '/shortcodes/abc123', 'HTTPS' => 'on'
          expect do
            JSON.parse(last_response.body)
          end.to_not raise_error
        end
        it 'returns a jsonapi conformant object' do
          header 'Accept', 'application/json'
          get '/shortcodes/abc123', {}, 'HTTPS' => 'on'
          json_response = JSON.parse(last_response.body)
          expect(json_response).to include 'data'
          expect(json_response['data']).to include 'attributes'
        end
        it 'returns the destination and interpreted short code as json' do
          get '/shortcodes/abc123', {}, 'HTTPS' => 'on'
          json_response = JSON.parse(last_response.body)
          expect(json_response['data']['attributes']).to include 'name'
          expect(json_response['data']['attributes']).to include 'destination'
        end
        context 'when leading path segments are present' do
          it "ignores extra leading path segments" do
            get '/leading/garbage/shortcodes/abc123', {}, 'HTTPS' => 'on'
            json_response = JSON.parse(last_response.body)
            expect(json_response['data']['attributes']).to include 'name'
            expect(json_response['data']['attributes']).to include 'destination'
          end
        end
        it 'returns a url to the generated shortcode' do
          get '/shortcodes/abc123', {}, 'HTTPS' => 'on'
          json_response = JSON.parse(last_response.body)
          expect(json_response['data']['meta']).to include 'generated_link'
          expect(json_response['data']['meta']['generated_link'])
            .to eq Petit.configuration.service_base_url + '/abc123'
        end
        it 'returns a QR code to the generated shortcode' do
          get '/shortcodes/abc123', {}, 'HTTPS' => 'on'
          json_response = JSON.parse(last_response.body)
          expect(json_response['data']['attributes']).to include 'qr-code'
          expect(json_response['data']['attributes']['qr-code']).to be_kind_of String
        end
        it 'downcases the shortcode' do
          get '/shortcodes/ABC123', {}, 'HTTPS' => 'on'
          json_response = JSON.parse(last_response.body)
          expect(json_response['data']['attributes']['name']).to eq('abc123')
        end
        it 'does not increment the access_count' do
          shortcode_pre = Petit::Shortcode.find('abc123')
          get '/shortcodes/abc123', {}, 'HTTPS' => 'on'
          shortcode_post = Petit::Shortcode.find('abc123')
          expect(shortcode_post.access_count).to eq(shortcode_pre.access_count)
        end
        context 'when sparse fieldsets are requested' do
          it 'only returns requested attributes' do
            get '/shortcodes/abc123?fields[shortcodes]=name', {}, 'HTTPS' => 'on'
            json_response = JSON.parse(last_response.body)
            expect(json_response['data']['attributes']).to include 'name'
            expect(json_response['data']['attributes']).to_not include 'qr-code'
          end
        end
      end
      context 'when the shortcode is not present' do
        it 'returns an 404 (not found) error' do
          get '/shortcodes/thisisnotfoundever.json', {}, 'HTTPS' => 'on'
          expect(last_response).to be_not_found
        end
        it 'returns a JSON object' do
          get '/shortcodes/thisisnotfoundever.json', {}, 'HTTPS' => 'on'
          expect do
            JSON.parse(last_response.body)
          end.to_not raise_error
        end
        it 'returns a JSON error message' do
          get '/shortcodes/thisisnotfoundever.json', {}, 'HTTPS' => 'on'
          json_response = JSON.parse(last_response.body)
          expect(json_response).to include 'errors'
          expect(json_response['errors']).to be_a Array
          expect(json_response['errors'].length).to be >= 1
          expect(json_response['errors'][0]).to include 'message'
        end
      end
    end
  end

  describe "post '/shortcodes'" do
    context 'when arguments are supplied as json' do
      before(:context) do
        shortcode = Petit::Shortcode.find('testcodejson')
        shortcode.destroy if shortcode
      end
      it 'parses the json and creates the record' do
        json_body = {
          data: {
            type: 'shortcodes',
            attributes: {
              name: 'testcodejson',
              destination: 'www.testcodejson.io',
              ssl: true
            }
          }
        }
        header 'Content-Type', 'application/vnd.api+json'
        header 'Accept', 'application/vnd.api+json'
        post '/shortcodes', json_body.to_json, 'HTTPS' => 'on'
        expect(last_response.status).to eq 201
        found = Petit::Shortcode.find('testcodejson')
        expect(found).to_not be_nil
        expect(found.name).to eq 'testcodejson'
        expect(found.destination).to eq 'www.testcodejson.io'
        expect(found.ssl?).to be true
        expect(last_response.header).to_not include "Access-Control-Allow-Origin"
      end
    end
    context 'when shortcode does not already exist' do
      before(:context) do
        shortcode = Petit::Shortcode.find('testcode')
        shortcode.destroy if shortcode
      end
      context 'when parameters are correct' do
        it 'returns 201 (created)' do
          post(
            '/shortcodes',
            {
              'name' => 'testcode',
              'destination' => 'www.testcode.io',
              'ssl' => true
            },
            'HTTPS' => 'on'
          )
          expect(last_response.status).to eq 201
        end
        it 'creates a shortcode' do
          found = Petit::Shortcode.find('testcode')
          expect(found).to_not be_nil
        end
        it 'has correct values' do
          found = Petit::Shortcode.find('testcode')
          expect(found.name).to eq 'testcode'
          expect(found.destination).to eq 'www.testcode.io'
          expect(found.ssl?).to be true
        end
        it 'returns a Location header with a link to the new address' do
          shortcode = Petit::Shortcode.find('testcode')
          shortcode.destroy if shortcode
          post(
            '/shortcodes',
            {
              'name' => 'testcode',
              'destination' => 'www.testcode.io',
              'ssl' => true
            },
            'HTTPS' => 'on'
          )
          expect(last_response.headers).to include 'Location'
          expect(last_response.headers['Location'])
            .to eq Petit.configuration.api_base_url + '/shortcodes/testcode'
        end
      end
      context 'when parameters are not correct' do
        it 'returns 400 (Bad Request)' do
          post(
            '/shortcodes',
            { 'name' => 'testcode' },
            'HTTPS' => 'on'
          )
          expect(last_response.status).to eq 400
        end
      end
    end
    context 'when shortcode already exists' do
      it 'throws a 409 (conflict) error' do
        post(
          '/shortcodes',
          {
            'name' => 'duptestcode',
            'destination' => 'www.test.me',
            'ssl' => true
          },
          'HTTPS' => 'on'
        )
        post(
          '/shortcodes',
          {
            'name' => 'duptestcode',
            'destination' => 'www.test.me',
            'ssl' => true
          },
          'HTTPS' => 'on'
        )
        expect(last_response.status).to eq 409
      end
    end
  end

  describe "put '/shortcodes/:shortcode'" do
    context 'if the shortcode is not found' do
      it 'throws a 404 (not found) error' do
        put(
          '/shortcodes/notthere23480238',
          {
            'name' => 'nocreate',
            'destination' => 'www.shouldntwork.com',
            'ssl' => false
          },
          'HTTPS' => 'on'
        )
        expect(last_response).to be_not_found
      end
      context 'when json is requested' do
        it 'returns a json api conformant object' do
          put(
            '/shortcodes/notthere23480238.json',
            {
              'name' => 'nocreate',
              'destination' => 'www.shouldntwork.com',
              'ssl' => false
            },
            'HTTPS' => 'on'
          )
          json_response = JSON.parse(last_response.body)
          expect(json_response).to include 'errors'
          expect(json_response['errors']).to be_a Array
          expect(json_response['errors'].length).to be >= 1
          expect(json_response['errors'][0]).to include 'message'
        end
      end
    end
    context 'if the shortcode is found' do
      context 'if the updated data is valid' do
        before(:example) do
          shortcode = Petit::Shortcode.new(name: 'abc124', destination: 'www.yahoo.com', ssl: true)
          shortcode.destroy
          shortcode.save
        end

        it 'returns 200' do
          put(
            '/shortcodes/abc124',
            { 'destination' => 'www.google.com' },
            'HTTPS' => 'on'
          )
          expect(last_response).to be_ok
        end
        it "does not return a CORS header" do
          put(
            '/shortcodes/abc124',
            { 'destination' => 'www.google.com' },
            'HTTPS' => 'on'
          )
          expect(last_response.header).to_not include "Access-Control-Allow-Origin"
        end
        it 'updates the destination' do
          put(
            '/shortcodes/abc124',
            { 'destination' => 'www.foogle.com' },
            'HTTPS' => 'on'
          )
          expect(last_response).to be_ok
          result = Petit::Shortcode.find_by_name('abc124')
          expect(result.destination).to eq 'www.foogle.com'
        end
        it 'does not override parameters that are not passed' do
          result = Petit::Shortcode.find_by_name('abc124')
          expect(result.ssl?).to be true
        end
        it 'updates the ssl flag' do
          put(
            '/shortcodes/abc124',
            { 'ssl' => false },
            'HTTPS' => 'on'
          )
          expect(last_response).to be_ok
          result = Petit::Shortcode.find_by_name('abc124')
          expect(result.ssl?).to be false
        end
        it 'ignores an attempt to update the name' do
          put(
            '/shortcodes/abc124',
            { 'name' => 'newnamethatdoesntexist' },
            'HTTPS' => 'on'
          )
          expect(last_response).to be_ok
          result = Petit::Shortcode.find_by_name('newnamethatdoesntexist')
          expect(result).to be_nil
          result = Petit::Shortcode.find_by_name('abc124')
          expect(result.name).to eq 'abc124'
        end
        context 'when arguments are supplied as json' do
          it 'parses the json and updates the record' do
            json_body = {
              data: {
                type: 'shortcodes',
                attributes: {
                  name: 'abc125',
                  destination: 'www.moogle.com',
                  ssl: true
                }
              }
            }
            header 'Content-type', 'application/vnd.api+json'
            header 'Accept', 'application/vnd.api+json'
            put '/shortcodes/abc124', json_body.to_json, 'HTTPS' => 'on'
            expect(last_response.status).to eq 200
            found = Petit::Shortcode.find('abc124')
            expect(found).to_not be_nil
            expect(found.name).to eq 'abc124' # It shouldn't be able to change the name
            expect(found.destination).to eq 'www.moogle.com'
            expect(found.ssl?).to be true
          end
        end
      end
      context 'if the updated data is invalid' do
        before(:example) do
          shortcode = Petit::Shortcode.new(name: 'abc124', destination: 'www.yahoo.com', ssl: true)
          shortcode.destroy
          shortcode.save
        end

        it 'throws a 400 (Bad Request) error' do
          put '/shortcodes/abc124', { 'destination' => '' }, 'HTTPS' => 'on'
          expect(last_response.status).to eq 400
        end
      end
    end
  end

  describe "delete '/shortcodes/:shortcode'" do
    context 'if the shortcode is not found' do
      it 'throws a 404 (not found) error' do
        delete '/shortcodes/notthere23480238', {}, 'HTTPS' => 'on'
        expect(last_response).to be_not_found
      end
    end
    context 'if the shortcode is found' do
      it 'deletes the record' do
        shortcode = Petit::Shortcode.new(name: 'abc124', destination: 'www.yahoo.com', ssl: true)
        shortcode.destroy
        shortcode.save

        expect(Petit::Shortcode.find_by_name('abc124')).to be_a Petit::Shortcode

        delete '/shortcodes/abc124', {}, 'HTTPS' => 'on'

        expect(Petit::Shortcode.find_by_name('abc124')).to be_nil
      end
      it 'returns 200' do
        shortcode = Petit::Shortcode.new(name: 'abc124', destination: 'www.yahoo.com', ssl: true)
        shortcode.destroy
        shortcode.save

        delete '/shortcodes/abc124', {}, 'HTTPS' => 'on'
        expect(last_response).to be_ok
      end
    end
  end
end
