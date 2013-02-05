require 'faraday'

# @api private
module Faraday
  class Response::RaiseGuidestarError < Response::Middleware
    def on_complete(response)
      case response[:status].to_i
      when 303
        raise Guidestar::SeeOther, error_message(response)
      when 400
        raise Guidestar::BadRequest, error_message(response)
      when 401
        raise Guidestar::Unauthorized, error_message(response)
      when 403
        raise Guidestar::Forbidden, error_message(response)
      when 404
        raise Guidestar::NotFound, error_message(response)
      when 406
        raise Guidestar::NotAcceptable, error_message(response)
      when 422
        raise Guidestar::UnprocessableEntity, error_message(response)
      when 500
        raise Guidestar::InternalServerError, error_message(response)
      when 501
        raise Guidestar::NotImplemented, error_message(response)
      when 502
        raise Guidestar::BadGateway, error_message(response)
      when 503
        raise Guidestar::ServiceUnavailable, error_message(response)
      end
    end

    def error_message(response)
      "#{response[:description]}\n#{response[:body]}"
    end
  end
end

