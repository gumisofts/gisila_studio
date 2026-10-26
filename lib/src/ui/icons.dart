/// Inline SVGs from the Carbon icon set (32×32 artboard), so pages need no
/// icon font or extra request.
library gisila_studio.ui.icons;

const _paths = {
  'add': '<path d="M17 15V8h-2v7H8v2h7v7h2v-7h7v-2z"/>',
  'search': '<path d="M29 27.586l-7.552-7.552a11.018 11.018 0 1 0-1.414 '
      '1.414L27.586 29zM4 13a9 9 0 1 1 9 9 9.01 9.01 0 0 1-9-9z"/>',
  'close': '<path d="M17.414 16L24 9.414 22.586 8 16 14.586 9.414 8 8 '
      '9.414 14.586 16 8 22.586 9.414 24 16 17.414 22.586 24 24 22.586 '
      '17.414 16z"/>',
  'trash': '<path d="M12 12h2v12h-2zM18 12h2v12h-2z"/><path d="M4 6v2h2v20a2 '
      '2 0 0 0 2 2h16a2 2 0 0 0 2-2V8h2V6zm4 22V8h16v20zM12 2h8v2h-8z"/>',
  'arrow-right': '<path d="M18 6l-1.43 1.393L24.15 15H4v2h20.15l-7.58 '
      '7.573L18 26l10-10L18 6z"/>',
  'logout': '<path d="M6 30h12a2 2 0 0 0 2-2v-3h-2v3H6V4h12v3h2V4a2 2 0 0 '
      '0-2-2H6a2 2 0 0 0-2 2v24a2 2 0 0 0 2 2z"/><path d="M20.586 '
      '20.586L24.172 17H10v-2h14.172l-3.586-3.586L22 10l6 6-6 6z"/>',
  'chevron-left': '<path d="M10 16L20 6l1.4 1.4-8.6 8.6 8.6 8.6L20 26z"/>',
  'chevron-right': '<path d="M22 16L12 26l-1.4-1.4 8.6-8.6-8.6-8.6L12 6z"/>',
  'dashboard': '<path d="M24 21h2v5h-2zM20 16h2v10h-2zM11 26a5 5 0 0 '
      '1-5-5h2a3 3 0 1 0 3-3v-2a5 5 0 0 1 0 10z"/><path d="M28 2H4a2 2 0 '
      '0 0-2 2v24a2 2 0 0 0 2 2h24a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2zm0 '
      '9H14V4h14zM12 4v7H4V4zM4 28V13h24v15z"/>',
  'menu': '<path d="M4 6h24v2H4zM4 24h24v2H4zM4 12h24v2H4zM4 18h24v2H4z"/>',
  'checkmark-filled': '<path d="M16 2a14 14 0 1 0 14 14A14 14 0 0 0 16 '
      '2zm-2 19.59l-5-5L10.59 15 14 18.41 21.41 11l1.596 1.586z"/>',
  'error-filled': '<path d="M16 2a14 14 0 1 0 14 14A14 14 0 0 0 16 2zm5.4 '
      '21L16 17.6 10.6 23 9 21.4l5.4-5.4L9 10.6 10.6 9l5.4 5.4L21.4 9 23 '
      '10.6 17.6 16l5.4 5.4z"/>',
  'warning-filled': '<path d="M16 2a14 14 0 1 0 14 14A14 14 0 0 0 16 '
      '2zm-1.125 6h2.25v11h-2.25zM16 25a1.5 1.5 0 1 1 1.5-1.5A1.5 1.5 0 0 '
      '1 16 25z"/>',
  'data-table': '<path d="M27 3H5a2 2 0 0 0-2 2v22a2 2 0 0 0 2 2h22a2 2 0 0 '
      '0 2-2V5a2 2 0 0 0-2-2zm0 2v4H5V5zm-10 6h10v7H17zm-2 7H5v-7h10zM5 '
      '20h10v7H5zm12 7v-7h10v7z"/>',
};

/// An inline Carbon icon. [cls] is added to the `svg` element.
String icon(String name, {int size = 16, String cls = ''}) =>
    '<svg class="cds-icon${cls.isEmpty ? '' : ' $cls'}" width="$size" '
    'height="$size" viewBox="0 0 32 32" fill="currentColor" '
    'aria-hidden="true" focusable="false">${_paths[name]!}</svg>';
