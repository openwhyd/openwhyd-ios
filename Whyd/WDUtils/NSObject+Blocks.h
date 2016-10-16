#import <Foundation/Foundation.h>

@interface NSObject (Blocks)

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;

@end
