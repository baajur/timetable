/* global $, Pikaday, moment */

$(document).on('turbolinks:load', () => {
  $('.seek-time-view').each((i, el) => {
    const $el = $(el);
    const url = $el.attr('href');
    const picker = new Pikaday({
      onSelect: (date) => {
        const formatted = moment(date).format('YYYY-MM-DD');
        window.location = url.replace(/:time_view/, formatted);
      },
    });
    $el.click(e => e.preventDefault());
    $el.popover({
      content: picker.el,
      html: true,
      placement: 'bottom',
    });
  });
});
