module Para
  class ComponentsConfiguration
    class UndefinedComponentTypeError < StandardError; end
    class ComponentTooDeepError < StandardError; end

    def draw(&block)
      return unless components_installed?

      Para::LogConfig.with_log_level(:fatal) do
        log_level = Rails.logger.level
        Rails.logger.level = :fatal

        eager_load_components!
        instance_eval(&block)
        build
      end
    end

    def section(*args, &block)
      sections << Section.new(*args, &block)
    end

    def sections
      @sections ||= []
    end

    def method_missing(method, *args, &block)
      if (component = component_for(method))
        component.tap(&ActiveDecorator::Decorator.instance.method(:decorate))
      else
        super
      end
    end

    def section_for(identifier)
      if (section = sections_cache[identifier])
        section
      else
        sections_cache[identifier] = if (section_id = sections_ids_hash[identifier])
                                       Para::ComponentSection.find(section_id)
                                     else
                                       Para::ComponentSection.find_by(identifier: identifier)
                                     end
      end
    end

    def component_for(identifier)
      if (component = components_cache[identifier])
        component
      else
        components_cache[identifier] = if (component_id = components_ids_hash[identifier])
                                         Para::Component::Base.find(component_id)
                                       else
                                         Para::Component::Base.find_by(identifier: identifier)
                                       end
      end
    end

    def component_configuration_for(identifier)
      sections.each do |section|
        section.components.each do |component|
          # If one of the section component has the searched identifier return it
          if component.identifier.to_s == identifier.to_s
            return component
          else
            component.child_components.each do |child_component|
              # If one of the component children has the searched identifier return it
              return child_component if child_component.identifier.to_s == identifier.to_s
            end
          end
        end
      end

      # Return nil if the identifier was not found
      nil
    end

    def sections_ids_hash
      @sections_ids_hash ||= {}.with_indifferent_access
    end

    def components_ids_hash
      @components_ids_hash ||= {}.with_indifferent_access
    end

    private

    def build
      sections.each_with_index do |section, index|
        section.refresh(position: index)
        sections_ids_hash[section.identifier] = section.model.id

        section.components.each do |component|
          components_ids_hash[component.identifier] = component.model.id

          component.child_components.each do |child_component|
            components_ids_hash[child_component.identifier] = child_component.model.id
          end
        end
      end
    end

    # Only store sections cache for the request duration to avoid expired
    # references to AR objects between requests
    #
    def sections_cache
      RequestStore.store[:sections_cache] ||= {}.with_indifferent_access
    end

    # Only store components cache for the request duration to avoid expired
    # references to AR objects between requests
    #
    def components_cache
      RequestStore.store[:components_cache] ||= {}.with_indifferent_access
    end

    def components_installed?
      tables_exist = %w[component/base component_section].all? do |name|
        Para.const_get(name.camelize).table_exists?
      end

      unless tables_exist
        Rails.logger.warn(
          "Para migrations are not installed.\n" \
          'Skipping components definition until next app reload.'
        )
      end

      tables_exist
    rescue ActiveRecord::NoDatabaseError
      false # Do not load components when the database is not installed
    end

    # Eager loads every file ending with _component.rb that's included in a
    # $LOAD_PATH directory which ends in "/components"
    #
    # Note : This allows not to process too many folders, but makes it harder to
    # plug gems into the components system
    #
    def eager_load_components!
      $LOAD_PATH.each do |path|
        next unless path.match(%r{/(para_)?components$})

        glob = File.join(path, '**', '*_component.rb')

        Dir[glob].each do |file|
          load(file)
        end
      end
    end

    class Section
      attr_accessor :identifier, :model

      def initialize(identifier, &block)
        self.identifier = identifier.to_s
        instance_eval(&block)
      end

      def component(*args, **options, &block)
        components << Component.new(*args, **options, &block)
      end

      def components
        @components ||= []
      end

      def refresh(attributes = {})
        self.model = ComponentSection.where(identifier: identifier).first_or_initialize
        model.assign_attributes(attributes)
        model.save!

        components.each_with_index do |component, index|
          component.refresh(component_section: model, position: index)
        end
      end
    end

    class Component
      attr_accessor :identifier, :type, :shown_if, :options, :model, :parent

      def initialize(identifier, type_identifier, shown_if: nil, **options, &block)
        @identifier = identifier.to_s
        @type = Para::Component.registered_components[type_identifier]
        @options = options
        @shown_if = shown_if
        @parent = options.delete(:parent)

        # Build child components if a block is provided
        instance_eval(&block) if block

        unless type
          raise UndefinedComponentTypeError, "Undefined Para component : #{type_identifier}. " +
                                             'Please ensure that your app or gems define this component type.'
        end
      end

      def component(*args, **child_options, &block)
        # Do not allow nesting components more than one level as the display of illimited
        # child nesting deepness is not implemented
        raise ComponentTooDeepError, 'Cannot nest components more than one level' if parent

        child_component_options = child_options.merge(parent: self)
        child_components << Component.new(*args, **child_component_options, &block)
      end

      def child_components
        @child_components ||= []
      end

      def refresh(attributes = {})
        @model = type.where(identifier: identifier).first_or_initialize
        model.update_with(attributes.merge(options_with_defaults))
        model.save!

        child_components.each_with_index do |child_component, child_index|
          child_component.refresh(component_section: nil, position: child_index)
        end
      end

      # Ensures unset :configuration store options are set to nil to allow
      # removing a configuration option from the components.rb file
      #
      def options_with_defaults
        configurable_keys = type.local_stored_attributes.try(:[], :configuration) || []
        configurable_keys += options.keys
        configurable_keys.uniq!

        options_with_defaults = {}

        # Assign parent component resource to the final attribute options, assigning nil
        # if the `:parent` option is empty, to allow extracting a component from its
        # parent by just moving the component call outside of its parent block.
        options_with_defaults[:parent_component] = parent&.model

        configurable_keys.each_with_object(options_with_defaults) do |key, hash|
          hash[key] = options[key]
        end
      end
    end
  end
end
