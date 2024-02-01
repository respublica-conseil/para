module Para
  module Markup
    class ResourcesButtons < Para::Markup::Component
      attr_reader :component

      def initialize(component, view)
        @component = component
        super(view)
      end

      def clone_button(resource)
        return unless resource.class.cloneable? && view.can?(:clone, resource)

        path = component.relation_path(
          resource, action: :clone, return_to: view.request.fullpath
        )

        options = {
          class: 'btn btn-sm btn-icon-info btn-shadow hint--left',
          data: { 'turbo-method': :post, 'turbo-frame': '_top' },
          aria: { label: ::I18n.t('para.shared.copy') }
        }

        view.link_to(path, **options) do
          content_tag(:i, '', class: 'fa fa-copy')
        end
      end

      def edit_button(resource)
        return unless view.can?(:edit, resource)

        path = component.relation_path(
          resource, action: :edit, return_to: view.request.fullpath
        )

        options = {
          class: 'btn btn-sm btn-icon-primary btn-shadow hint--left',
          data: { 'turbo-frame': '_top' },
          aria: { label: ::I18n.t('para.shared.edit') }
        }

        view.link_to(path, **options) do
          content_tag(:i, '', class: 'fa fa-pencil')
        end
      end

      def delete_button(resource)
        return unless view.can?(:delete, resource)

        path = component.relation_path(resource, return_to: view.request.fullpath)

        options = {
          class: 'btn btn-sm btn-icon-danger btn-shadow hint--left',
          data: {
            'turbo-method': :delete,
            'turbo-confirm': ::I18n.t('para.list.delete_confirmation')
          },
          aria: {
            label: ::I18n.t('para.shared.destroy')
          }
        }

        view.link_to(path, **options) do
          content_tag(:i, '', class: 'fa fa-times')
        end
      end
    end
  end
end
