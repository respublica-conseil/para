module Para
  module Admin::ComponentsHelper
    # Return the sections / components structure, with components properly
    # decorated
    #
    def admin_component_sections
      @admin_component_sections ||= begin
        sections = Para::ComponentSection.ordered.includes(:components, :parent_component)

        sections.tap do |loaded_sections|
          loaded_sections.flat_map(&:components).each(&method(:decorate))
        end
      end
    end

    def ordered_components
      admin_component_sections.each_with_object([]) do |section, components|
        section.components.each do |component|
          components << component if can?(:read, component)
        end
      end.sort_by(&:name)
    end

    def show_component?(component)
      config = Para.components.component_configuration_for(component.identifier)
      !config.shown_if || instance_exec(&config.shown_if)
    end

    def current_component_or_parent?(component)
      return false unless @component

      @component == component || @component.parent_component == component
    end
  end
end
