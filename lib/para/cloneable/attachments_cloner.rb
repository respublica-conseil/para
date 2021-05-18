module Para
  module Cloneable
    class AttachmentsCloner
      attr_reader :original, :clone, :dictionary

      # Handle both one and many attachment relations
      ATTACHMENTS_RELATION_REGEX = /_attachments?\z/

      def initialize(original, clone, dictionary)
        @original = original
        @clone = clone
        @dictionary = dictionary
      end

      def clone!
        return unless defined?(ActiveStorage)

        attachment_reflections = original.class.reflections.select do |name, reflection|
          name.to_s.match(ATTACHMENTS_RELATION_REGEX) &&
          reflection.options[:class_name] == "ActiveStorage::Attachment"
        end

        attachment_reflections.each do |name, reflection|
          association_target = original.send(name)
          next unless association_target

          if reflection.collection?
            association_target.each do |attachment|
              clone_attachment(name, attachment)
            end
          else
            clone_attachment(name, association_target)
          end
        end
      end

      def clone_attachment(name, original_attachment)
        association_name = name.gsub(ATTACHMENTS_RELATION_REGEX, "")
        original_blob = original_attachment.blob

        # Handle missing file in storage service by bypassing the attachment cloning
        return unless ActiveStorage::Blob.service.exist?(original_blob&.key)

        Para::ActiveStorageDownloader.new(original_attachment).download_blob_to_tempfile do |tempfile|
          attachment_target = clone.send(association_name)

          attachment_target.attach({
            io: tempfile,
            filename: original_blob.filename,
            content_type: original_blob.content_type
          })

          cloned_attachment = find_cloned_attachment(attachment_target, original_blob)

          # Store the cloned attachment and blob into the deep_cloneable dictionary used
          # by the `deep_clone` method to ensure that, if needed during the cloning
          # operation, they won't be cloned once more and are accessible for processing
          store_cloned(original_attachment, cloned_attachment)
          store_cloned(original_blob, cloned_attachment.blob)
        end
      end

      # Seemlessly handle one and many attachment relations return values and fetch
      # the attachment that we just cloned by comparing blobs checksum, as depending
      # which ActiveStorage version we're on (Rails 5.2 or 6), the `#attach` method
      # doesn't always return the same, so for now we still handle the Rails 5.2 case.
      def find_cloned_attachment(attachment_target, original_blob)
        attachments = if attachment_target.attachments.any?
          attachment_target.attachments
        else
          [attachment_target.attachment]
        end

        attachment = attachments.find do |att|
          att.blob.checksum == original_blob.checksum
        end
      end

      # This stores the source and clone resources into the deep_clone dictionary, which
      # simulates what the deep_cloneable gem does when it clones a resource
      #
      def store_cloned(source, clone)
        store_key = source.class.name.tableize.to_sym

        dictionary[store_key] ||= {}
        dictionary[store_key][source] = clone
      end
    end
  end
end
