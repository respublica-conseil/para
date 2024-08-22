import { application } from "./application";

import ParaAdminModalController from "./para_admin_modal_controller";
application.register("para-admin-modal", ParaAdminModalController);

import ParaAdminFlashMessageController from "./para_admin_flash_message_controller";
application.register("para-admin-flash-message", ParaAdminFlashMessageController);

import SelectizeFieldController from "./selectize_field_controller";
application.register("selectize-field", SelectizeFieldController);

import NestedManyInputController from "./nested_many_input_controller";
application.register("nested-many-input", NestedManyInputController);
