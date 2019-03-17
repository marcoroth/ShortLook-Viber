#import <sqlite3.h>
#import "FolderFinder.h"
#import "ViberContactPhotoProvider.h"

@implementation ViberContactPhotoProvider
  - (DDNotificationContactPhotoPromiseOffer *)contactPhotoPromiseOfferForNotification:(DDUserNotification *)notification {
    NSString *containerPath = [FolderFinder findSharedFolder:@"group.viber.share.container"];
    NSString *databasePath = [NSString stringWithFormat:@"%@/com.viber/database/Contacts.data", containerPath];
    NSString *iconsPath = [NSString stringWithFormat:@"%@/com.viber/ViberIcons", containerPath];

    NSString *senderMemberId = [notification.applicationUserInfo valueForKey:@"senderMemberId"];

    const char *dbpath = [databasePath UTF8String];
    sqlite3 *_viberdb;

    if (sqlite3_open(dbpath, &_viberdb) == SQLITE_OK) {
      const char *stmt = [[NSString stringWithFormat:@"SELECT ZICONID FROM ZMEMBER WHERE ZMEMBERID = '%@' AND ZICONSTATE = 'iconExist';", senderMemberId] UTF8String];
      sqlite3_stmt *statement;

      if (sqlite3_prepare_v2(_viberdb, stmt, -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
          const unsigned char *result = sqlite3_column_text(statement, 0);
          NSString *imageName = [NSString stringWithUTF8String:(char *)result];
          NSString *imageURL = [NSString stringWithFormat:@"%@/%@.jpg", iconsPath, imageName];
          UIImage *image = [UIImage imageWithContentsOfFile:imageURL];

          return [NSClassFromString(@"DDNotificationContactPhotoPromiseOffer") offerInstantlyResolvingPromiseWithPhotoIdentifier:imageURL image:image];
        }
        sqlite3_finalize(statement);
      }
      sqlite3_close(_viberdb);
    }

    return nil;
  }
@end
