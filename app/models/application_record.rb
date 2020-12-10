# Base class used for the `AdminUser` model class as parent but automatically overriden
# by application's own ApplicationRecord definition in Rails 5+
#
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
