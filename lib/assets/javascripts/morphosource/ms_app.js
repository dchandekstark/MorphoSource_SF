Hyrax.workEditor = function () {
  var element = $("[data-behavior='work-form']")
  if (element.length > 0) {
    var Editor = require('morphosource/ms_editor');
    new Editor(element).init();
  }
}
