///
//  VoteListCell.h
//  AgoraEducation
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoteListCell : UITableViewCell
- (void)setIsMulSel:(BOOL)mulSel;
- (void)setSelStatus:(NSString*)title seleted:(BOOL)sel;
- (void)setResStatus:(NSString*)title selNum:(NSInteger)sel percent:(float)fte;
@end

NS_ASSUME_NONNULL_END
