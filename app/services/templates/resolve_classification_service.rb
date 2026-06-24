module Templates
  # Validates and resolves the themes/tier classification supplied in a template payload.
  # Returns the resolved records plus flags indicating which keys were present, so callers
  # can apply PATCH semantics (only touch what was sent).
  class ResolveClassificationService < BaseService
    def initialize(params:)
      @params = params
    end

    def call
      themes = resolve_themes
      return themes if themes.is_a?(ServiceResult)

      tier = resolve_tier
      return tier if tier.is_a?(ServiceResult)

      ServiceResult.success(
        themes:      themes,
        tier:        tier,
        sync_themes: @params.key?(:theme_ids),
        sync_tier:   @params.key?(:tier_id)
      )
    end

    private

    def resolve_themes
      return [] unless @params.key?(:theme_ids)

      requested = Array(@params[:theme_ids]).map(&:to_i).uniq.reject(&:zero?)
      themes    = ThemeRepository.new.active_by_ids(requested).to_a
      return themes if themes.size == requested.size

      ServiceResult.failure(theme_ids: [ I18n.t("messages.errors.invalid_themes") ])
    end

    def resolve_tier
      return nil unless @params.key?(:tier_id) && @params[:tier_id].present?

      tier = TierRepository.new.find_active(@params[:tier_id])
      return tier if tier

      ServiceResult.failure(tier_id: [ I18n.t("messages.errors.invalid_tier") ])
    end
  end
end
