module Para
  module FormBuilder
    module Containers
      def fieldset(options = {}, &block)
        template.content_tag(:div, class: 'form-inputs') do
          buffer = if (title = options[:title])
                     template.content_tag(:legend, title)
                   else
                     ''.html_safe
                   end

          buffer + template.capture(&block)
        end
      end

      def actions(options = {}, &block)
        template.content_tag(:div, class: 'form-actions') do
          next template.capture(&block) if block

          if options.empty?
            options[:only] =
              template.instance_variable_get(:@component).default_form_actions
          end

          actions_buttons_for(options).join("\n").html_safe
        end
      end

      def actions_buttons_for(options)
        names = %i[submit submit_and_edit]
        names << :submit_and_add_another if template.can?(:create, object.class)
        names << :cancel

        names.select! { |name| Array.wrap(options[:only]).include?(name) } if options[:only]
        names.reject! { |name| Array.wrap(options[:except]).include?(name) } if options[:except]
        buttons = names.map { |name| send(:"para_#{name}_button") }
        buttons.unshift(return_to_hidden_field)

        buttons
      end

      def return_to_hidden_field
        template.hidden_field_tag(:return_to, return_to_path)
      end

      def para_submit_button(_options = {})
        button(
          :submit,
          ::I18n.t('para.shared.save'),
          name: '_save',
          class: 'btn-success btn-shadow',
          data: { 'turbo-submits-with': ::I18n.t('para.form.shared.saving') }
        )
      end

      def para_submit_and_edit_button
        # Create a hidden field that will hold the last tab used by the user,
        # allowing redirection and re-rendering to display it directly
        current_anchor_tag = template.hidden_field_tag(
          :_current_anchor,
          template.params[:_current_anchor],
          data: { 'current-anchor': true }
        )

        button_tag = button(
          :submit,
          ::I18n.t('para.shared.save_and_edit'),
          name: '_save_and_edit',
          class: 'btn-primary btn-shadow',
          data: { 'turbo-submits-with': ::I18n.t('para.form.shared.saving') }
        )

        current_anchor_tag + button_tag
      end

      def para_submit_and_add_another_button
        button(
          :submit,
          ::I18n.t('para.shared.save_and_add_another_button'),
          name: '_save_and_add_another',
          class: 'btn-primary btn-shadow',
          data: { 'turbo-submits-with': ::I18n.t('para.form.shared.saving') }
        )
      end

      def para_cancel_button
        template.link_to(
          ::I18n.t('para.shared.cancel'),
          return_to_path,
          class: 'btn btn-danger btn-shadow'
        )
      end

      def return_to_path
        template.params[:return_to].presence || component_path
      end

      def component_path
        return unless (component = template.instance_variable_get(:@component))

        component.path
      end
    end
  end
end
