import mrUtil from './util';

$(document).ready(() => {
  $('.video-cover .video-play-icon').on('click touchstart', function clickedPlay() {
    const $iframe = $(this).closest('.video-cover').find('iframe');
    mrUtil.activateIframeSrc($iframe);
    $(this).parent('.video-cover').addClass('video-cover-playing');
  });

  // Disable video cover behaviour on mobile devices to avoid user having to press twice

  if (document.documentElement.clientWidth < 768) {
    $('.video-cover').each(function activeateMobileIframes() {
      const $iframe = $(this).closest('.video-cover').find('iframe');
      mrUtil.activateIframeSrc($iframe);
    });
  }

  // <iframe> in modals
  $('.modal').on('shown.bs.modal', function modalShown() {
    const $modal = $(this);
    if ($modal.find('iframe[data-src]').length) {
      const $iframe = $modal.find('iframe[data-src]');
      mrUtil.activateIframeSrc($iframe);
    }
  });

  $('.modal').on('hidden.bs.modal', function modalHidden() {
    const $modal = $(this);
    if ($modal.find('iframe[src]').length) {
      const $iframe = $modal.find('iframe[data-src]');
      mrUtil.idleIframeSrc($iframe);
    }
  });

  $('[data-toggle="tooltip"]').tooltip();
});
