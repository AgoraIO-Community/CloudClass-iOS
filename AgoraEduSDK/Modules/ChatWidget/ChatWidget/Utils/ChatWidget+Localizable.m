//
//  ChatWidget+Localizable.m
//  ChatWidget
//
//  Created by lixiaoming on 2021/7/13.
//

#import "ChatWidget+Localizable.h"

@implementation ChatWidget (Localizable)
+ (NSString*)LocalizedString:(NSString*)aString
{
    NSBundle* bundle = [NSBundle bundleForClass:[ChatWidget class]];
    return NSLocalizedStringFromTableInBundle(aString, nil, bundle, nil);
}
@end
