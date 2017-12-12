/* global $ */

$(() => {
  $('form#add_task_to_project')
    .on('ajax:success', (e) => {
      const [data] = e.detail;
      const $form = $(e.target);
      const table = $($form.data('results-table'));
      const $tableItem = $(data.tableItem);
      $('tbody', table).append($tableItem);
    })
    .on('ajax:error', (e) => {
      const [data] = e.detail;
      const $form = $(e.target);
      $form.renderFormErrors('task', data.errors);
    });
});
