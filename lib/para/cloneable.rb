module Para
  module Cloneable
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    included do
      class_attribute :cloneable_options
    end

    eager_autoload do
      autoload :IncludeTreeBuilder
      autoload :AttachmentsCloner
    end

    # Wraps the deep_cloneable gem #deep_clone method to allow using the
    # predefined associations and options from our Cloneable.acts_as_cloneable
    # macro.
    #
    def deep_clone!(options = {})
      processed_options = Para::Cloneable::IncludeTreeBuilder.new(self, cloneable_options).build
      options = options.reverse_merge(processed_options)
      callback = build_clone_callback(options.delete(:prepare))

      deep_clone(options) do |original, clone|
        Para::Cloneable::AttachmentsCloner.new(original, clone).clone!
        callback&.call(original, clone)
      end
    end

    private

    # We ensure that the passed callback is actually callable on the object
    # we're cloning. This is needed for associations because deep_cloneable
    # calls the callback for every associated object.
    #
    def build_clone_callback(callback)
      case callback
      when Proc
        callback
      when Symbol
        ->(original, clone) {
          original.send(callback, clone) if original.respond_to?(callback, true)
        }
      end
    end

    module ClassMethods
      # Allow configuring cloneable options for the model, and making the
      # model cloneable in the admin
      #
      # The provided arguments are the cloneable associations for the model,
      # and keyword arguments are passed to the #deep_clone method.
      #
      # An optional :prepare keyword argument can be passed and will be called
      # by #deep_clone to allow altering the cloned resource before saving it.
      #
      def acts_as_cloneable(*args)
        @cloneable = true

        options = args.extract_options!

        # Allow nested STI resources to define their own relations to clone even
        # if other sibling models don't define those relations
        options[:skip_missing_associations] = true

        # If `acts_as_cloneable` is called multiple times, for example by a parent class
        # and the by its subclass, ensure that we don't lose the previously defined
        # cloneable options, to avoid having to repeat the same include options in each
        # subclass, if it has to define subclass specific cloneable options.
        previous_cloneable_options = cloneable_options || {}

        # Prepare the new cloneable options hash with the provided arguments
        new_cloneable_options = options.reverse_merge({
          include: args
        })

        # Merges previous and new cloneable options into the cloneable_options class
        # attribute, also merging the `:include` array
        self.cloneable_options =
          previous_cloneable_options.merge(new_cloneable_options) do |key, a, b|
            a.is_a?(Array) && b.is_a?(Array) ? (a + b).uniq : b
          end
      end

      def cloneable?
        @cloneable ||= false
      end
    end
  end
end
