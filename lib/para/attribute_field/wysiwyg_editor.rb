module Para
  module AttributeField
    class WysiwygEditor < AttributeField::Base
      include ActionView::Helpers::SanitizeHelper
      include ActionView::Helpers::TextHelper

      register :wysiwyg_editor, self

      def initialize(model, options = {})
        options.reverse_merge!(type: 'text', field_type: 'wysiwyg_editor')
        super(model, options)
      end

      def value_for(instance)
        (value = instance.send(name)) && truncate(
          sanitize(value, tags: []),
          length: 50
        )
      end
    end
  end
end
