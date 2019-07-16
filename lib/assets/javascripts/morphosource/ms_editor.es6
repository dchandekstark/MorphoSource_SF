import Editor from 'hyrax/editor'
import RelationshipsControl from 'hyrax/relationships/control'
import MorphosourceSaveWorkControl from './ms_save_work_control'

export default class MorphosourceEditor extends Editor {

  relationshipsControl() {
    let collections = this.element.find('[data-behavior="collection-relationships"]')
    collections.each((_idx, element) =>
        new RelationshipsControl(element,
                                 collections.data('members'),
                                 collections.data('paramKey'),
                                 'member_of_collections_attributes',
                                 'tmpl-collection').init())
     let works = this.element.find('[data-behavior="child-relationships"]')
    works.each((_idx, element) =>
        new RelationshipsControl(element,
                                 works.data('members'),
                                 works.data('paramKey'),
                                 'work_members_attributes',
                                 'tmpl-child-work').init())
     let works_parents = this.element.find('[data-behavior="parent-relationships"]')
    works_parents.each((_idx, element) =>
        new RelationshipsControl(element,
                                 works_parents.data('members'),
                                 works_parents.data('paramKey'),
                                 'work_parents_attributes',
                                 'tmpl-parent-work').init())
     let works_parents_institutions = this.element.find('[data-behavior="parent-relationships-institutions"]')
    works_parents_institutions.each((_idx, element) =>
        new RelationshipsControl(element,
                                 works_parents_institutions.data('members'),
                                 works_parents_institutions.data('paramKey'),
                                 'work_parents_attributes',
                                 'tmpl-parent-work-institutions').init())
     let works_parents_taxonomies = this.element.find('[data-behavior="parent-relationships-taxonomies"]')
    works_parents_taxonomies.each((_idx, element) =>
        new RelationshipsControl(element,
                                 works_parents_taxonomies.data('members'),
                                 works_parents_taxonomies.data('paramKey'),
                                 'work_parents_attributes',
                                 'tmpl-parent-work-taxonomies').init())
  }

  saveWorkControl(){
    new MorphosourceSaveWorkControl(this.element.find("#form-progress"), this.adminSetWidget)
  }
}
