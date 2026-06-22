module Pagination
  class ResolveLimitService < BaseService
    ALLOWED_LIMITS = [ 10, 30, 50 ].freeze

    def initialize(limit:)
      @limit = limit
    end

    def call
      resolved = ALLOWED_LIMITS.include?(@limit.to_i) ? @limit.to_i : Pagy::OPTIONS[:limit]
      ServiceResult.success({ limit: resolved })
    end
  end
end
