//import Registry from 'hyrax/relationships/registry'
import Registry from './ms_registry'
import Resource from 'hyrax/relationships/resource'

/**
 * This depends on the passed in element containing `data-autocomplete="work'"`
 * that is also a select2 element.
*/
export default class RelationshipsControl {

  /**
   * Initializes the class in the context of an individual table element
   * @param {HTMLElement} element the table element that this class represents.
   * @param {Array} members the members to display in the table
   * @param {String} paramKey the key for the type of object we're submitting (e.g. 'generic_work')
   * @param {String} property the property to submit
   * @param {String} templateId the template identifier for new rows
   * @param {String}  indexStart : (Customized) when creating the input hidden field, start the index using this number.  This 
   *                      will prevent Hyrax to overwrite a property (e.g. work_parents_attributes) which is used
   *                      in more than one form element 
   */
  constructor(element, members, paramKey, property, templateId, indexStart = 0) {
    this.element = $(element)
    this.members = this.element.data('members')
    this.registry = new Registry(this.element.find('tbody'), paramKey, property, templateId, indexStart)
    this.input = this.element.find(`[data-autocomplete]`)
    this.warning = this.element.find(".message.has-warning")
    this.addButton = this.element.find("[data-behavior='add-relationship']")
    this.errors = null
  }

  init() {
    this.bindAddButton();
    this.displayMembers();
  }

  validate() {
    if (this.input.val() === "") {
      this.errors = ['ID cannot be empty.']
    }
    /* to-do: check to see if possible to restrict only 1 item added for non-repeatable fields
    console.log(this.element.find('[data-behavior="remove-relationship"]').length);
    if (this.repeatable && this.members.length == 1) {
      this.errors = ['Only one item is allowed.']
    } 
    */
  }

  displayMembers() {
    this.members.forEach((elem) =>
      this.registry.addResource(new Resource(elem.id, elem.label))
    )
  }

  isValid() {
    this.validate()
    return this.errors === null
  }

  /**
   * Handle click events by the "Add" button in the table, setting a warning
   * message if the input is empty or calling the server to handle the request
   */
  bindAddButton() {
    this.addButton.on("click", () => this.attemptToAddRow())
  }

  attemptToAddRow() {
      // Display an error when the input field is empty, or if the resource ID is already related,
      // otherwise clone the row and set appropriate styles
      if (this.isValid()) {
        this.addRow()
      } else {
        this.setWarningMessage(this.errors.join(', '))
      }
  }

  addRow() {
    this.hideWarningMessage()
    let data = this.searchData()
    //console.log('select2 data : ',data)






    // if the attribute is not repeatable, remove the rest of the items.   
    console.log(this.registry.items.length)
    this.registry.items.forEach((item, index) => {
      item.removeResource();
    })





    this.registry.addResource(new Resource(data.id, data.text))

    // finally, empty the "add" row input value
    this.clearSearch();
  }

  searchData() {
    // if new work has been created, use data from new work instead
    var new_data = this.element.data("new-work-created")
    //console.log('new_data : ', new_data)
    if ($.isEmptyObject(new_data)) {
      return this.input.select2('data')
    } else {
      return new_data
    }
  }

  clearSearch() {
    this.input.select2("val", '');
    this.element.data("new-work-created", '');
  }

  /**
   * Set the warning message related to the appropriate row in the table
   * @param {String} message the warning message text to set
   */
  setWarningMessage(message) {
    this.warning.text(message).removeClass("hidden");
  }

  /**
   * Hide the warning message on the appropriate row
   */
  hideWarningMessage(){
    this.warning.addClass("hidden");
  }
}