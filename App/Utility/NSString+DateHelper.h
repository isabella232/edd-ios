#import <Foundation/Foundation.h>

@interface NSString (DateHelper)

+ (BOOL)isNullOrWhiteSpace:(id)string;
- (NSDate *) dateValue;
- (NSString *)trimmed;

@end
