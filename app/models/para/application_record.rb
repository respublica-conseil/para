module Para
  # Base class for all para-specific models.
  #
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    # Adds the `optional: true` option to the belongs_to calls inside the provided block,
    # but only for Rails 5.1+
    #
    def self.with_belongs_to_optional_option_if_needed(&block)
      belongs_to_accepts_optional = ActiveRecord::Associations::Builder::BelongsTo
                                    .send(:valid_options, {})
                                    .include?(:optional)

      if belongs_to_accepts_optional
        with_options(optional: true, &block)
      else
        block.call
      end
    end
  end
end
