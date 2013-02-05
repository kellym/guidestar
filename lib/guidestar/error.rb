module Guidestar
  # Custom error class for rescuing from all Guidestar errors
  class Error < StandardError; end

  # Raised when Guidestar returns a 303 HTTP status code
  class SeeOther < Error; end

  # Raised when Guidestar returns a 400 HTTP status code
  class BadRequest < Error; end

  # Raised when Guidestar returns a 401 HTTP status code
  class Unauthorized < Error; end

  # Raised when Guidestar returns a 403 HTTP status code
  class Forbidden < Error; end

  # Raised when Guidestar returns a 404 HTTP status code
  class NotFound < Error; end

  # Raised when Guidestar returns a 406 HTTP status code
  class NotAcceptable < Error; end

  # Raised when Guidestar returns a 422 HTTP status code
  class UnprocessableEntity < Error; end

  # Raised when Guidestar returns a 500 HTTP status code
  class InternalServerError < Error; end

  # Raised when Guidestar returns a 501 HTTP status code
  class NotImplemented < Error; end

  # Raised when Guidestar returns a 502 HTTP status code
  class BadGateway < Error; end

  # Raised when Guidestar returns a 503 HTTP status code
  class ServiceUnavailable < Error; end

  # Raised when missing information is detected in the wrapper
  class MissingInformation < Error; end
end

