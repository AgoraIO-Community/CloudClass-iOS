//
//  InputingView.h
//  ChatWidget
//
//  Created by lixiaoming on 2021/7/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol InputingViewDelegate <NSObject>

- (void)msgWillSend:(NSString*)aMsgText;
- (void)keyBoardDidHide:(NSString*)aText;

@end

@interface InputingView : UIView
@property (nonatomic,weak) id<InputingViewDelegate> delegate;
@property (nonatomic,strong) UIButton* sendButton;
@property (nonatomic,strong) UITextField* inputField;
@property (nonatomic,strong) UIButton* emojiButton;
@property (nonatomic,strong) UIButton* exitInputButton;
- (void)changeKeyBoardType;

@end

NS_ASSUME_NONNULL_END
