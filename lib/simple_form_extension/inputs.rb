module SimpleFormExtension
  module Inputs
    extend ActiveSupport::Autoload

    autoload :DateTimeInput
    autoload :BooleanInput
    autoload :NumericInput
    autoload :CollectionCheckBoxesInput
    autoload :CollectionRadioButtonsInput
    autoload :ColorInput
    autoload :SelectizeInput
    autoload :SliderInput

    if Para.config.load_file_inputs
      autoload :FileInput
      autoload :ImageInput
    end
  end
end
