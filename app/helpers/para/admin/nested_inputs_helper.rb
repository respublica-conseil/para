module Para
  module Admin
    module NestedInputsHelper
      # Helper that allows filling a parent association for a given resource, based on the
      # inverse_of option of the parent resource association.
      #
      def with_inverse_association_for(resource, attribute_name, parent_resource)
        resource.tap do
          association_name = parent_resource.association(attribute_name).options[:inverse_of]
          return resource unless association_name

          resource.association(association_name).send(:replace, parent_resource)
        end
      end
    end
  end
end
