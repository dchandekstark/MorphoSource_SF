import RegistryEntry from 'hyrax/relationships/registry_entry'
import ConfirmRemoveDialog from 'hyrax/relationships/confirm_remove_dialog'

export default class MsRegistryEntry extends RegistryEntry {

    constructor(resource, registry, template) {
      super(resource, registry, template) 
    }

    createView(resource, templateId) {
        let row = $(tmpl(templateId, resource))
        let removeButton = row.find('[data-behavior="remove-relationship"]')
        removeButton.click((e) => {
          e.preventDefault()
          if (typeof removeButton.data('confirmText') === 'undefined') {
            this.removeResource(e);
          } else {
            var dialog = new ConfirmRemoveDialog(removeButton.data('confirmText'),
                                                 removeButton.data('confirmCancel'),
                                                 removeButton.data('confirmRemove'),
                                                 () => this.removeResource(e));
            dialog.launch();
          }
        });
        return row;
    }

    // Hides the row and adds a _destroy=true field to the form
    removeResource(evt) {

      if (evt) {
        evt.preventDefault();
        let button = $(evt.target);        
      }
      this.view.addClass('hidden'); // do not show the block
      this.destroyed = true
      this.registry.showSaveNote();
    }

}