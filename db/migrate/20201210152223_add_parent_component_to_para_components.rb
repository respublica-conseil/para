class AddParentComponentToParaComponents < ActiveRecord::Migration[5.0]
  def change
    add_reference :para_components, :parent_component, foreign_key: false
    add_foreign_key :para_components, :para_components, column: :parent_component_id
  end
end
