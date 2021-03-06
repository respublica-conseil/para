module Para
  module FormBuilder
    module AttributesMappingsTracker
      def initialize(*) #:nodoc:
        @attributes_mappings = {}

        super
      end

      def input(attribute_name, options = {}, &block)
        store_attribute_mapping_for(attribute_name, options, &block)

        super(attribute_name, options, &block)
      end

      def input_field(attribute_name, options = {})
        store_attribute_mapping_for(attribute_name, options)

        super(attribute_name, options)
      end

      def fields_for(*args, &block)
        fields_options = args.extract_options!

        track_attribute_mappings = (
          fields_options[:track_attribute_mappings] != false &&
          options[:track_attribute_mappings]
        )

        fields_options.reverse_merge!(
          track_attribute_mappings: track_attribute_mappings
        )

        super(*args, fields_options) do |fields|
          fields_html = @template.capture { block.call(fields) }

          fields_html + fields.attributes_mappings_field_for(fields)
        end
      end

      def attributes_mappings_field_for(fields)
        return unless options[:track_attribute_mappings]

        hidden_field :_attributes_mappings, value: @attributes_mappings.to_json,
                     data: { :'attributes-mappings' => fields.options[:child_index] }
      end

      private

      def store_attribute_mapping_for(attribute_name, input_options, &block)
        return unless options[:track_attribute_mappings]

        type = if input_options[:as]
          input_options[:as]
        else
          input = find_input(attribute_name, input_options, &block)
          input.class.name.demodulize.underscore.gsub(/_input\z/, '')
        end

        @attributes_mappings[attribute_name] = type
      end
    end
  end
end
