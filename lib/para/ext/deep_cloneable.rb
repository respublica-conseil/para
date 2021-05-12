require "deep_cloneable/deep_clone"

module Para
  module Ext
    module DeepCloneExtension
      # Override the default deep_cloneable method to avoid nested :except rules that target
      # polymorphic relations to try to assign default values to unexisting attributes on
      # models that don't define the excluded attribute
      #
      # For example, we can have :
      #
      #   { except: { comments: { author: [:confirmation_token] } } }
      #
      # Because some comments have a an author that's a user, and the user `acts_as_cloneable`
      # macro defines `{ except: [:confirmation_token] }`, but if one of the comments has
      # an anonymous user in its author relation, this method would faild with a
      # ActiveModel::MissingAttributeError.
      #
      def dup_default_attribute_value_to(kopy, attribute, origin)
        return unless kopy.attributes.keys.include?(attribute.to_s)

        kopy[attribute] = origin.class.column_defaults.dup[attribute.to_s]
      end
    end
  end
end
