module Para
  class ActiveStorageDownloader
    include ActiveStorage::Downloading if defined?(ActiveStorage::Downloading)

    attr_reader :attachment

    delegate :blob, to: :attachment

    def initialize(attachment)
      @attachment = attachment
    end

    if defined?(ActiveStorage::Downloading)
      public :download_blob_to_tempfile
    elsif defined?(ActiveStorage)
      # For versions of ActiveStorage that don't have an ActiveStorage::Downloading
      # module, we define the method ourselves, as defined in the ActiveStorage::Analyzer
      # and ActiveStorage::Previewer classes, which is simple enough to be copied here.
      #
      def download_blob_to_tempfile(&block)
        blob.open tmpdir: Dir.tmpdir, &block
      end
    else
      define_method(:download_blob_to_tempfile) do
        raise NoMethodError, 'ActiveStorage is not included in your application'
      end
    end
  end
end
