module Sessions
  class CleanupExpiredJob < ApplicationJob
    queue_as :default

    def perform
      SessionRepository.new.delete_expired
    end
  end
end
