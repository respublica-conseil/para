module Para
  module ModelFieldParsers
    class WysiwygEditor < Para::ModelFieldParsers::Base
      register :wysiwyg_editor, self

      def parse!
        %w[content description].each do |field_name|
          field = fields_hash[field_name]

          next unless field && field.type == :text

          fields_hash[field_name] = Para::AttributeField::WysiwygEditor.new(
            field.model, name: field_name
          )
        end
      end
    end
  end
end
