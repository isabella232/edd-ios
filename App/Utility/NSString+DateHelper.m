#import "NSString+DateHelper.h"

@implementation NSString (DateHelper)

+ (BOOL)isNullOrWhiteSpace:(id)string {
	if (![string isKindOfClass:[NSString class]]) return YES;
	
	NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *trimmed = [string stringByTrimmingCharactersInSet:whitespace];
	return [(NSString *)trimmed length] == 0;
}

- (NSDate *) dateValue {
    NSDate *date = nil;
    if (![NSString isNullOrWhiteSpace:self]) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
        NSString* RFC3339String = [[self uppercaseString] stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"];
        // Remove colon in timezone as it breaks NSDateFormatter in iOS 4+.
        // - see https://devforums.apple.com/thread/45837
        if (RFC3339String.length > 20) {
            RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@":"
                                                                     withString:@""
                                                                        options:0
                                                                          range:NSMakeRange(20, RFC3339String.length-20)];
        }
        
        if (!date) { // 2012-11-01 11:07:08 -0500
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
            date = [dateFormatter dateFromString:RFC3339String];
        }
        if (!date) { // 1996-12-19T16:39:57-0800
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"];
            date = [dateFormatter dateFromString:RFC3339String];
        }
        if (!date) { // 1937-01-01T12:00:27.87+0020
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"];
            date = [dateFormatter dateFromString:RFC3339String];
        }
        if (!date) { // 1937-01-01T12:00:27
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
            date = [dateFormatter dateFromString:RFC3339String];
        }
        if (!date) { // 2013-03-01 10:16:02
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            date = [dateFormatter dateFromString:RFC3339String];
        }
        if (!date) {
            NSLog(@"Could not parse RFC3339 date: \"%@\" Possible invalid format.", RFC3339String);
        }
    }
	return date;
}

- (NSString *)trimmed {
	NSString *trimmed = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return trimmed;
}

@end
