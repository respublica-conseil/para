module Para
  class ComponentResource < Para::ApplicationRecord
    belongs_to :component, class_name: 'Para::Component::Base'
    belongs_to :resource, polymorphic: true
  end
end
