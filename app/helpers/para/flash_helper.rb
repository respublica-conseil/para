module Para
  module FlashHelper
    def flash_partial_path
      template_path_lookup('admin/shared/_flash', 'para/admin/shared/_flash')
    end

    # Converts flash types to :success or :error to conform to what
    # twitter bootstrap can handle
    #
    def homogenize_flash_type(type)
      case type.to_sym
      when :notice then :success
      when :alert then :warning
      when :error then :danger
      else type
      end
    end

    def icon_class_for(type)
      case type
      when :success then 'fa-check'
      when :error then 'fa-warning'
      else 'fa-exclamation-triangle'
      end
    end
  end
end
