enum NotificationType {
  like('like'),
  reply('reply'),
  follow('follow'),
  complain('complain'),
  comment('comment');

  final String type;
  const NotificationType(this.type);
}

extension ConvertTweet on String {
  NotificationType toNotificationTypeEnum() {
    switch (this) {

      case 'follow':
        return NotificationType.follow;
      case 'reply':
        return NotificationType.reply;
      case 'complain':
        return NotificationType.complain;
      case 'comment':
        return NotificationType.comment;
      default:
        return NotificationType.like;
    }
  }
}