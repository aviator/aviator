require 'test_helper'
require 'mocha/setup'


class Aviator::Test

  describe 'aviator/core/response' do

    describe '#to_hash' do

      it 'returns a Hashish instance representing the response' do
        mock_http_response = mock('Faraday::Response')
        mock_request = mock('Aviator::Request')

        hashed_response = {
          :status => 200,
          :headers => {
            :header1 => 'value1',
            :header2 => 'value2'
          },
          :body => {
            :body1 => 'bodyvalue1',
            :body2 => 'bodyvalue2'
          }
        }

        mock_http_response.expects(:status).returns(hashed_response[:status])
        mock_http_response.expects(:headers).returns(hashed_response[:headers])
        mock_http_response.expects(:body).returns(hashed_response[:body].to_json)

        response = Aviator::Response.new(mock_http_response, mock_request)

        response.to_hash.must_equal Hashish.new(hashed_response)
      end

    end


  end

end
