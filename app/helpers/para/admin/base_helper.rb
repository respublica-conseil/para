module Para
  module Admin
    module BaseHelper
      include Para::ApplicationHelper

      def find_partial_for(relation, partial, partial_dir: 'admin/resources')
        relation_class = if model?(relation.class)
                           relation = relation.class
                         elsif model?(relation)
                           relation
                         end

        relation_name = find_relation_name_for(
          plural_file_path_for(relation), partial,
          relation_class: relation_class,
          overrides_root: 'admin'
        )

        if relation_name
          "admin/#{relation_name}/#{partial}"
        else
          "para/#{partial_dir}/#{partial}"
        end
      end

      def find_relation_name_for(relation, partial, **options)
        return relation if partial_exists?(relation, partial, **options)
        return nil unless options[:relation_class]

        relation = options[:relation_class].ancestors.find do |ancestor|
          next unless model?(ancestor)
          break if ancestor == ActiveRecord::Base

          ancestor_name = plural_file_path_for(ancestor.name)
          partial_exists?(ancestor_name, partial, **options)
        end

        plural_file_path_for(relation) if relation
      end

      def template_path_lookup(*paths)
        path = paths.find { |path| lookup_context.find_all(path).any? }
        path&.gsub(%r{/_([^/]+)\z}, '/\1')
      end

      def resource_title_for(resource)
        if resource.new_record?
          t('para.form.shared.new.title', model: resource.class.model_name.human)
        else
          resource.try(:title).presence ||
            resource.try(:name).presence ||
            t('para.form.shared.edit.title', model: resource.class.model_name.human)
        end
      end

      def registered_components_options
        Para::Component.registered_components.keys.map do |identifier|
          [
            t("para.component.#{identifier}.name", default: identifier.to_s.humanize),
            identifier
          ]
        end
      end

      def flash_message(type, resource = nil, now: false)
        flash_shared_key = 'para.flash.shared'
        key_suffix = "#{params[:action]}.#{type}"

        shared_key = "#{flash_shared_key}.#{key_suffix}"

        shared_translation =
          if resource
            ::I18n.t(shared_key, model: resource.class.model_name.human)
          else
            ::I18n.t(shared_key)
          end

        translation =
          if resource
            ::I18n.t(
              "para.flash.#{resource.class.base_class.model_name.i18n_key}.#{key_suffix}",
              default: shared_translation
            )
          else
            shared_translation
          end

        flash_receiver = now ? flash.now : flash
        flash_receiver[type] = translation
      end

      private

      def plural_file_path_for(class_name)
        class_name.to_s.underscore.pluralize
      end

      def model?(object)
        object.respond_to?(:model_name)
      end

      def partial_exists?(relation, partial, overrides_root: 'admin', **_options)
        partial_path = partial.to_s.split('/')
        partial_path[-1] = "_#{partial_path.last}"
        lookup_context.find_all("#{overrides_root}/#{relation}/#{partial_path.join('/')}").any?
      end
    end
  end
end
