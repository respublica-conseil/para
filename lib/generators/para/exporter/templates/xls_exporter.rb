class <%= exporter_class_name %> < Para::Exporter::Xls
  def name
    '<%= file_name %>'
  end

  protected

  # Defining the fields that you want to export will export all those fields
  # directly to the XLS file
  #
  def fields
    [:id]
  end

  # If you need special behavior in the row generation (rendering associated
  # models or other specific logic), you can return an array here that will
  # be written to the XLS
  #
  # For safe XLS writing, use the #encode method on every string in the
  # returned array.
  #
  # Example :
  #
  #   fields = [...]
  #   fields.map!(&:encode)
  #
  # def row_for(resource)
  # end

  # Whitelist params to be fetched from the controller and passed down to the
  # exporter.
  #
  # For example, if you want to export posts for a given category, you
  # can add the `:category_id` param to your export link, and whitelist
  # this param here with :
  #
  #   def self.params_whitelist
  #     [:category_id]
  #   end
  #
  # It will be passed from the controller to the importer so it can be used
  # to scope resources before exporting.
  #
  # Note that you'll manually need to scope the resources by overriding the
  # #resources method.
  #
  # If you need automatic scoping, please use the `:q` param that accepts
  # ransack search params and applies it to the resources.
  #
  # def self.params_whitelist
  #   []
  # end

  # If you need complete control over you XLS generation, use the following
  # method instead of the #fields or #row_for methods, and return a valid XLS
  # StringIO object.
  #
  # A `#generate_workbook` method is provided, which will yield the workbook to
  # you so you can just fill it, and then returns a StringIO that can be
  # directly written to the Excel file.
  #
  # Please check the [Spreadsheet](https://github.com/zdavatz/spreadsheet) gem
  # documentation for more informations about how to build your Excel document.
  #
  # def generate
  #   generate_workbook do |workbook|
  #     sheet = workbook.create_worksheet
  #     sheet.row(0).concat ['data', 'row']
  #     sheet.row(1).concat ['other', 'row']
  #   end
  # end
end
