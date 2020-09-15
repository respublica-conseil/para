module Para
  module Inputs
    class NestedManyInput < NestedBaseInput
      attr_reader :resource

      def input(wrapper_options = nil)
        input_html_options[:class] << "nested-many"

        orderable = options.fetch(:orderable, model.orderable?)
        add_button = options.fetch(:add_button, true)
        # Load existing resources
        resources = object.send(attribute_name)
        # Order them if the list should be orderable
        resources = resources.sort_by(&:position) if orderable

        locals = options.fetch(:locals, {})

        with_global_nested_field do
          template.render(
            partial: 'para/inputs/nested_many',
            locals: {
              form: @builder,
              model: model,
              attribute_name: attribute_name,
              orderable: orderable,
              add_button: add_button,
              dom_identifier: dom_identifier,
              resources: resources,
              nested_locals: locals,
              subclass: subclass,
              subclasses: subclasses,
              add_button_label: add_button_label,
              add_button_class: add_button_class,
              inset: inset?,
              uncollapsed: uncollapsed?,
              render_partial: render_partial?,
              remote_partial_params: remote_partial_params
            }
          )
        end
      end

      def parent_model
        @parent_model ||= @builder.object.class
      end

      def model
        @model ||= parent_model.reflect_on_association(attribute_name).klass
      end

      def inset?
        options.fetch(:inset, false)
      end

      def uncollapsed?
        inset? && Para.config.uncollapse_inset_nested_fields
      end

      def render_partial?
        options[:render_partial] || object.errors.any? || (object.persisted? && uncollapsed?)
      end

      def remote_partial_params
        @remote_partial_params ||= options.fetch(:remote_partial_params, {}).merge(
          namespace: :nested_form
        )
      end
    end
  end
end
