module Themes
  class CreateService < BaseService
    def initialize(params:)
      @params = params
    end

    def call
      theme = ThemeRepository.new.create_theme(name: @params[:name])
      ServiceResult.success({ theme: theme })
    end
  end
end
