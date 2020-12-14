module Para
  module Admin
    module PageHelper
      def page_top_bar(options = {})
        top_bar = content_tag(:div, class: 'page-title row') do
          content_tag(:h1, options[:title]) +

          if (actions = actions_for(options[:type]))
            actions.map(&method(:build_action)).join('').html_safe
          end
        end

        # Return both top bar and component navigation to be displayed at the top of the
        # page.
        top_bar + component_navigation
      end

      def build_action(action)
        link_options = action.fetch(:link_options, {})
        link_options[:class] ||= "btn btn-default btn-shadow"

        content_tag(:div, class: 'actions-control pull-right') do
          link_to(action[:url], link_options) do
            (
              (fa_icon(action[:icon], class: 'fa-fw') if action[:icon]) +
              action[:label]
            ).html_safe
          end
        end
      end

      def actions_for(type)
        Para.config.page_actions_for(type).map do |action|
          instance_eval(&action)
        end.compact
      end

      def component_navigation
        parent_component = @component && (
          @component.parent_component ||
          @component.child_components.any? && @component
        )

        return unless parent_component

        # If the component has a `model_type` option, therefore, an associated model,
        # we try to render the partial from the relative path of the model, else we
        # use the component class as the base target path
        partial_target = parent_component.try(:model_type) || parent_component

        render partial: find_partial_for(partial_target, :navigation),
                locals: {
                  parent_component: parent_component,
                  active_component: @component
                }
      end
    end
  end
end
