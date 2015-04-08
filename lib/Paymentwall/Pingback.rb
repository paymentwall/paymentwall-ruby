module Paymentwall
  class Pingback < Paymentwall::Base

    PINGBACK_TYPE_REGULAR  = 0
    PINGBACK_TYPE_GOODWILL = 1
    PINGBACK_TYPE_NEGATIVE = 2

    def initialize(parameters = {}, ipAddress = '')
      @parameters = parameters
      @ip_address  = ipAddress
    end

    def validate(skipIpWhitelistCheck = false)
      validated = false

      if isParametersValid()
        if isIpAddressValid() || skipIpWhitelistCheck
          if isSignatureValid()
            validated = true
          else
            appendToErrors('Wrong signature')
          end
        else
          appendToErrors('IP address is not whitelisted')
        end
      else
        appendToErrors('Missing parameters')
      end

      validated
    end

    def isSignatureValid()
      signature_params_to_sign = {}

      if self.class.getApiType() == API_VC
        signature_params = %w(uid currency type ref)
      elsif self.class.getApiType() == API_GOODS
        signature_params = %w(uid goodsid slength speriod type ref)
      else
        signature_params = %w(uid goodsid type ref)
        @parameters['sign_version'] = SIGNATURE_VERSION_2
      end

      if !@parameters.include?('sign_version') || @parameters['sign_version'].to_i == SIGNATURE_VERSION_1
        signature_params.each do |field|
          signature_params_to_sign[field] = @parameters.include?(field) ? @parameters[field] : nil
        end
        @parameters['sign_version'] = SIGNATURE_VERSION_1
      else
        signature_params_to_sign = @parameters
      end

      signature_calculated = self.class.calculateSignature(signature_params_to_sign, self.class.getSecretKey(), @parameters['sign_version'])

      signature = @parameters.include?('sig') ? @parameters['sig'] : nil

      signature == signature_calculated
    end

    def isIpAddressValid()
      ip_whitelist = %w(174.36.92.186 174.36.96.66 174.36.92.187 174.36.92.192 174.37.14.28)

      ip_whitelist.include? @ip_address
    end

    def isParametersValid()
      errors_number   = 0
      required_params = []

      if self.class::getApiType() == self.class::API_VC
        required_params = %w(uid currency type ref sig)
      elsif self.class::getApiType() == self.class::API_GOODS
        required_params = %w(uid goodsid type ref sig)
      else
        required_params = %w(uid goodsid type ref sig)
      end

      required_params.each do |field|
        if !@parameters.include?(field) # || $parameters[field] === ''
          self.appendToErrors("Parameter #{field} is missing")
          errors_number += 1
        end
      end

      errors_number == 0
    end

    def getParameter(param)
      return @parameters[param] if @parameters.include?(param)
      nil
    end

    def getType()
      pingback_types = [
          PINGBACK_TYPE_REGULAR,
          PINGBACK_TYPE_GOODWILL,
          PINGBACK_TYPE_NEGATIVE
      ]

      return @parameters['type'].to_i if @parameters.include?('type') && pingback_types.include?(@parameters['type'].to_i)
      nil
    end

    def getUserId
      getParameter('uid').to_s
    end

    def getVirtualCurrencyAmount()
      getParameter('currency').to_i
    end

    def getProductId()
      getParameter('goodsid').to_s
    end

    def getProductPeriodLength()
      getParameter('slength').to_i
    end

    def getProductPeriodType()
      getParameter('speriod').to_s
    end

    def getProduct()
      Paymentwall::Product.new(
          self.getProductId(),
          0,
          nil,
          nil,
          self.getProductPeriodLength() > 0 ? Paymentwall::Product::TYPE_SUBSCRIPTION : Paymentwall::Product::TYPE_FIXED,
          self.getProductPeriodLength(),
          self.getProductPeriodType()
      )
    end

    def getProducts()
      product_ids = self.getParameter('goodsid')

      if product_ids.kind_of?(Array) && product_ids.length > 0
        product_ids.map{|id| Paymentwall::Product.new(id) }
      else
        []
      end
    end

    def getReferenceId()
      getParameter('ref').to_s
    end

    def getPingbackUniqueId()
      getReferenceId().to_s + '_' + getType().to_s
    end

    def isDeliverable()
      getType() == PINGBACK_TYPE_REGULAR || getType() == PINGBACK_TYPE_GOODWILL
    end

    def isCancelable()
      getType() == PINGBACK_TYPE_NEGATIVE
    end

    protected

    def self.calculateSignature(params, secret, version)

      params = params.clone
      params.delete('sig')

      sort_keys = (version.to_i == SIGNATURE_VERSION_2 or version.to_i == SIGNATURE_VERSION_3)
      keys = sort_keys ? params.keys.sort : params.keys

      base_string = ''

      keys.each do |name|
        p = params[name]

        # converting array to hash
        if p.kind_of?(Array)
          p = Hash[p.map.with_index { |key, value| [value, key] }]
        end

        if p.kind_of?(Hash)
          sub_keys = sort_keys ? p.keys.sort : p.keys;
          sub_keys.each do |key|
            value = p[key]
            base_string += "#{name}[#{key}]=#{value}"
          end
        else
          base_string += "#{name}=#{p}"
        end
      end

      base_string += secret

      require 'digest'
      if version.to_i == SIGNATURE_VERSION_3
        return Digest::SHA256.hexdigest(base_string)
      else
        return Digest::MD5.hexdigest(base_string)
      end
    end

  end
end
