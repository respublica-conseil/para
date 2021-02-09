module Para
  module Admin
    class NestedFormsController < ComponentController
      def show
        @model = params[:model_name].constantize
        @object = params[:id] ? @model.find(params[:id]) : @model.new
        @object_name = params[:object_name]
        @builder_options = params[:builder_options]&.permit! || {}

        render layout: false
      end
    end
  end
end
