class EntryUtils {
  static markEntryAsRead(entry_group_id) {
    // Hide "Mark Entry as Read" button automatically because it is automatically as read when you answer to it
    // so that user don't need to refresh page
    // jquery because #parentElement is not supported in IE

    jQuery(`#entry_group_${entry_group_id} a[data-confirm]`).parent().hide();
  }
}

export default EntryUtils;
