require 'json'
require 'ostruct'
require 'net/http'
require 'net/https'

module Paymentwall
  # Wrapper class for the Utility Cancellation API
  class Ticket < Paymentwall::Base

    BASE_URL = 'https://api.paymentwall.com/developers/api/ticket'

    TYPE_REFUND = 1
    TYPE_CANCELLATION = 2
    TYPE_OTHER = 3

    # Request a cancellation ticket
    # @param type [Integer] Accepts one of the TYPE_XXX constant values
    # @param user_id [Integer|String] User ID
    # @param reference [String] Transaction reference ID
    # @param extra_params [Hash<String,String>] Additional parameters for the call
    def self.create(type, user_id, reference, extra_params = {})
      raise ArgumentError.new 'Either user_id or reference is required.' unless user_id || reference
      params = {
          'key' => self.getAppKey(),
          'type' => type
      }
      params.update('uid' => user_id) if user_id
      params.update('ref' => reference) if reference

      params['sign_version'] = signatureVersion = self.getDefaultSignatureVersion()

      if extra_params.include?('sign_version')
        signatureVersion = params['sign_version'] = extra_params['sign_version']
      end

      params = params.merge(extra_params)

      params['sign'] = self.calculateSignature(params, self.getSecretKey(), signatureVersion)

      uri = URI.parse(BASE_URL)
      response = Net::HTTP::post_form(uri, params)

      return OpenStruct.new(JSON.parse(response.body)) if response.code.to_i == 200
      nil
    end
  end
end