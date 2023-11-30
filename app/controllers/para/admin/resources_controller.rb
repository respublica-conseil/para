require_dependency 'para/application_controller'

module Para
  module Admin
    class ResourcesController < Para::Admin::BaseController
      include Para::ModelHelper
      include Para::Helpers::AttributesMappings

      class_attribute :resource_name, :resource_class
      load_and_authorize_component
      helper_method :resource

      def new
        render 'para/admin/resources/new'
      end

      def create
        # Assign component the resource belongs to it
        resource.component = @component if resource.respond_to?(:component=)

        # We overriden Cancan so it does not try to assign our params during the
        # create action, allowing our attribute fields to parse them with an
        # actual resource.
        resource.assign_attributes(resource_params)

        if resource.save
          flash_message(:success, resource)
          redirect_to after_form_submit_path, status: 303
        else
          flash_message(:error, resource)
          render 'new', status: 422
        end
      end

      def edit
        render 'para/admin/resources/edit'
      end

      def update
        if resource.update(resource_params)
          flash_message(:success, resource)
          redirect_to after_form_submit_path, status: 303
        else
          flash_message(:error, resource)
          render 'edit', status: 422
        end
      end

      def destroy
        resource.destroy
        flash_message(:success, resource)
        redirect_to after_form_submit_path, status: 303
      end

      def order
        ActiveRecord::Base.transaction do
          resources_data.each do |resource_params|
            resource = resources_hash[resource_params[:id]]
            resource.position = resource_params[:position].to_i
            resource.save(validate: false)
          end
        end

        head 200
      end

      def tree
        ActiveRecord::Base.transaction do
          resources_data.each do |resource_params|
            resource = resources_hash[resource_params[:id]]
            resource.assign_attributes(
              position: resource_params[:position].to_i,
              parent_id: resource_params[:parent_id]
            )
            resource.save(validate: false)
          end
        end

        head 200
      end

      private

      def after_form_submit_path
        if params[:_save_and_edit]
          host_redirect_params.merge(
            action: 'edit',
            id: resource.id,
            # The `anchor` doesn't work with javascript's `fetch` async requests so we
            # can't redirect an XHR request to an anchor, we need to pass it as an
            # explicit param.
            # See : https://github.com/hotwired/turbo/issues/211
            _current_anchor: params[:_current_anchor].presence,
            return_to: params[:return_to].presence
          )
        elsif params[:_save_and_add_another]
          host_redirect_params.merge(
            action: 'new',
            type: resource.try(:type)
          )
        else
          params.delete(:return_to).presence || @component.path
        end
      end

      def host_redirect_params
        { subdomain: request.subdomain, domain: request.domain }
      end

      def resource_model
        @resource_model ||= self.class.resource_model
      end

      def resource
        @resource ||= begin
          self.class.ensure_resource_name_defined!
          instance_variable_get(:"@#{self.class.resource_name}")
        end
      end

      # We check for the existance of `params[:resource]` to avoid rails'
      # params sanitizer to raise if no `:resource` key is found. We prefer
      # to let the model handle validations instead of asking the controller
      # to validate some params presence
      #
      # Note : This also created a bug with cancan which tried to build the
      #        params on a `new` action, that did not contain the `:resource`
      #        key in the params, which made the `#new` action form raise
      #
      def resource_params
        @resource_params ||= parse_resource_params(
          (params[:resource] && params.require(:resource).permit!) || {}
        )
      end

      def parse_resource_params(hash)
        model_field_mappings(resource_model, mappings: attributes_mappings_for(hash)).fields.each do |field|
          field.parse_input(hash, resource)
        end

        hash
      end

      def self.resource(name, options = {})
        default_options = {
          class: name.to_s.camelize,
          parent: false
        }

        default_options.each do |key, value|
          options[key] = value unless options.key?(key)
        end

        self.resource_name = name
        self.resource_class = options[:class]

        load_and_authorize_resource(name, options)
      end

      def self.resource_model
        @resource_model ||= begin
          ensure_resource_name_defined!
          Para.const_get(resource_class)
        end
      end

      def self.ensure_resource_name_defined!
        return if resource_name.presence

        raise 'Resource not defined in your controller. ' \
              'You can define the resource of your controller with the ' \
              '`resource :resource_name` macro when subclassing ' \
              'Para::Admin::ResourcesController'
      end

      def resources_data
        @resources_data ||= params[:resources].values
      end

      def resources_hash
        @resources_hash ||= begin
          ids = resources_data.map { |resource| resource[:id] }

          resources = resource_model.where(id: ids)
          resources.each_with_object({}) do |resource, hash|
            hash[resource.id.to_s] = resource
          end
        end
      end
    end
  end
end
