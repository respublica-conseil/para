module Para
  module Ext
    module CustomTurboStreamActions
      def display_flash(id = 'para_admin_flash_messages')
        replace(id, partial: 'para/admin/shared/flash')
      end
    end
  end
end

ActiveSupport::Reloader.to_prepare do
  Turbo::Streams::TagBuilder.prepend(Para::Ext::CustomTurboStreamActions)
end
