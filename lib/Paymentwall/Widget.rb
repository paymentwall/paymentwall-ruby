module Paymentwall
  class Widget < Paymentwall::Base

    BASE_URL = 'https://api.paymentwall.com/api'

    def initialize(userId, widgetCode, products = [], extraParams = {})
      @user_id      = userId
      @widget_code  = widgetCode
      @extra_params = extraParams
      @products    = products
    end

    def getUrl()
      params = {
          'key'    => self.class.getAppKey(),
          'uid'    => @user_id,
          'widget' => @widget_code
      }

      products_number = @products.count()

      if self.class::getApiType() == API_GOODS

        if @products.kind_of?(Array)

          if products_number == 1
            product = @products[0]
            if product.kind_of?(Paymentwall::Product)

              post_trial_product = nil
              if product.getTrialProduct().kind_of?(Paymentwall::Product)
                post_trial_product = product
                product          = product.getTrialProduct()
              end

              params['amount']         = product.getAmount()
              params['currencyCode']   = product.getCurrencyCode()
              params['ag_name']        = product.getName()
              params['ag_external_id'] = product.getId()
              params['ag_type']        = product.getType()

              if product.getType() == Paymentwall::Product::TYPE_SUBSCRIPTION
                params['ag_period_length'] = product.getPeriodLength()
                params['ag_period_type']   = product.getPeriodType()
                if product.isRecurring()

                  params['ag_recurring'] = product.isRecurring() ? 1 : 0

                  if post_trial_product
                    params['ag_trial'] = 1;
                    params['ag_post_trial_external_id']   = post_trial_product.getId()
                    params['ag_post_trial_period_length'] = post_trial_product.getPeriodLength()
                    params['ag_post_trial_period_type']   = post_trial_product.getPeriodType()
                    params['ag_post_trial_name']          = post_trial_product.getName()
                    params['post_trial_amount']           = post_trial_product.getAmount()
                    params['post_trial_currencyCode']     = post_trial_product.getCurrencyCode()
                  end
                end
              end
            else
              #TODO: self.appendToErrors('Not an instance of Paymentwall::Product')
            end
          else
            #TODO: self.appendToErrors('Only 1 product is allowed in flexible widget call')
          end

        end

      elsif self.class.getApiType() == API_CART
        index = 0
        @products.each do |product|
          params['external_ids[' + index.to_s + ']'] = product.getId()

          if product.getAmount() > 0
            params['prices[' + index.to_s + ']'] = product.getAmount()
          end
          if product.getCurrencyCode() != '' && product.getCurrencyCode() != nil
            params['currencies[' + index.to_s + ']'] = product.getCurrencyCode()
          end
          index += 1
        end
      end

      params['sign_version'] = signature_version = self.class.getDefaultSignatureVersion()

      if @extra_params.include?('sign_version')
        signature_version = params['sign_version'] = @extra_params['sign_version']
      end

      params = params.merge(@extra_params)

      params['sign'] = self.class.calculateSignature(params, self.class.getSecretKey(), signature_version)

      "#{BASE_URL}/#{buildController(@widget_code)}?#{http_build_query(params)}"
    end

    def getHtmlCode(attributes = {})
      default_attributes = {
          'frameborder' => '0',
          'width'       => '750',
          'height'      => '800'
      }

      attributes = default_attributes.merge(attributes)

      attributes_query = attributes.map{|attr, value| "#{attr.to_s}=\"#{value.to_s}\"" }.join(' ')

      '<iframe src="' + getUrl() + '" ' + attributes_query + '></iframe>'
    end

    protected

    def buildController(widget, flexibleCall = false)
      if self.class.getApiType() == API_VC
        unless /^w|s|mw/.match(widget)
          return CONTROLLER_PAYMENT_VIRTUAL_CURRENCY
        end
      elsif self.class.getApiType() == API_GOODS
        unless flexibleCall && /^w|s|mw/.match(widget)
            return CONTROLLER_PAYMENT_DIGITAL_GOODS
        else
          return CONTROLLER_PAYMENT_DIGITAL_GOODS
        end
      else
        return CONTROLLER_PAYMENT_CART
      end

      ''
    end

    def http_build_query(params)
      params.map{|key,value| "#{key}=#{url_encode(value)}" }.join('&')
    end

    def url_encode(value)
      URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end
  end
end
