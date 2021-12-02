# frozen_string_literal: true

module Para
  module Cloneable
    # This object acts as a service to compile a nested cloneable options hash to be
    # provided to the `deep_clone` method from the `deep_cloneable` gem. It iterates over
    # every reflections that must be included for a given model when it's cloned, and
    # creates a nested hash of :include and :except directives based on the tree that
    # is created by nested `acts_as_cloneable` calls on the different models of the
    # application
    #
    # Example :
    #
    #   Given the following model structure :
    #
    #     class Article < ApplicationRecord
    #       acts_as_cloneable :category, :comments, except: [:publication_date]
    #
    #       belongs_to :category
    #       has_many :comments
    #     end
    #
    #     class Category < ApplicationRecord
    #       acts_as_cloneable :category, except: [:articles_count]
    #
    #       has_many :articles
    #     end
    #
    #     class Comment < ApplicationRecord
    #       acts_as_cloneable :author
    #
    #       belongs_to :article
    #       belongs_to :author
    #     end
    #
    #     class Author < ApplicationRecord
    #       acts_as_cloneable except: [:email]
    #
    #       has_many :articles
    #     end
    #
    #   The behavior would be :
    #
    #     Para::Cloneable::IncludeTreeBuilder.new(article).build
    #     # => {
    #            include: [:category, { comments: :author }],
    #            except: [:publication_date, {
    #              category: [:articles_count],
    #              comments: { author: [:email] }
    #            }]
    #          }
    #
    class IncludeTreeBuilder
      attr_reader :resource, :cloneable_options

      def initialize(resource)
        @resource = resource
        @cloneable_options = resource.cloneable_options.deep_dup
      end

      def build
        options_tree = build_cloneable_options_tree(resource)
        exceptions = extract_exceptions_from(options_tree)
        inclusions = clean_options_tree(options_tree)
        cloneable_options.merge(include: inclusions, except: exceptions)
      end

      private

      # The cloneable options tree iterates over the resources' relations that are
      # declared as included in the cloneable_options of the provided resource, and
      # recursively checks included relations for its associated resources.
      #
      # It returns a nested hash with the included relations and their :except array
      # if it exist, which include the attributes that shouldn't be duplicated when
      # the resource is cloned.
      #
      def build_cloneable_options_tree(resource, path = [])
        cloneable_options = resource.cloneable_options

        # Iterate over the resource's cloneable options' :include array and recursively
        # add nested included resources to its own included resources.
        options = cloneable_options[:include].each_with_object({}) do |reflection_name, hash|
          # This avoids cyclic dependencies issues by stopping nested association
          # inclusions before the cycle starts.
          #
          # For example, if a post includes its author, and the author includes its posts,
          # this would make the system fail with a stack level too deep error. Here this
          # guard allows the inclusion to stop at :
          #
          #   { posts: { author: { posts: { author: {}}}}}
          #
          # Which ensures that, using the dictionary strategy of deep_cloneable, all
          # posts' authors' posts will have their author mapped to an already cloned
          # author when it comes to cloning the "author" 4th level of the include tree.
          #
          # This is not the most optimized solution, but works well enough as if the
          # author's posts match previously cloned posts, they won't be cloned as they'll
          # exist in the cloned resources dictionary.
          next if path.length >= 4 &&
                  path[-4] == path[-2] &&
                  path[-2] == reflection_name &&
                  path[-3] == path[-1]

          hash[reflection_name] = {}

          unless (reflection = resource.class.reflections[reflection_name.to_s])
            next
          end

          reflection_options = hash[reflection_name]
          association_target = resource.send(reflection_name)

          if reflection.collection?
            association_target.each do |nested_resource|
              add_reflection_options(
                reflection_options,
                nested_resource,
                [*path, reflection_name]
              )
            end
          else
            add_reflection_options(
              reflection_options,
              association_target,
              [*path, reflection_name]
            )
          end
        end

        # Add the :except array from the resource to the current options hash and merge
        # it if one already exist from another resource of the same class.
        options[:except] ||= []
        options[:except] |= Array.wrap(cloneable_options[:except])

        options
      end

      def add_reflection_options(reflection_options, nested_resource, path)
        options = nested_resource.class.try(:cloneable_options)
        return reflection_options unless options

        target_options = build_cloneable_options_tree(nested_resource, path)
        reflection_options.deep_merge!(target_options)
      end

      # Iterates over the generated options tree to extract all the nested :except options
      # into their own separate hash, removing :except keys from the original options
      # tree hash.
      #
      def extract_exceptions_from(tree)
        exceptions = tree.delete(:except) || []
        nested_exceptions = {}

        tree.each do |key, value|
          next unless value.is_a?(Hash) && !value.empty?

          sub_exceptions = extract_exceptions_from(value)
          nested_exceptions[key] = sub_exceptions unless sub_exceptions.empty?
        end

        exceptions += [nested_exceptions] unless nested_exceptions.empty?
        exceptions
      end

      # Iterates over the remaining options tree hash and converts empty hash values' keys
      # to be stored in an array, and returns an array of symbols and hashes that is
      # compatible with what is expected as argument for the :include option of the
      # `deep_clone` method.
      #
      # Example :
      #
      #   clean_options_tree({ category: {}, comments: { author: {} } })
      #   # => [:category, { comments: [:author] }]
      #
      def clean_options_tree(tree)
        shallow_relations = []
        deep_relations = {}

        tree.each do |key, value|
          # If the value is an empty hash, consider it as a shallow relation and add
          # it to the shallow relations array
          if !value || value.empty?
            shallow_relations << key
          # If the value is a hash with nested keys, process its nested values and add
          # the result to the deep relations hash
          else
            deep_relations[key] = clean_options_tree(value)
          end
        end

        deep_relations.empty? ? shallow_relations : shallow_relations + [deep_relations]
      end
    end
  end
end
