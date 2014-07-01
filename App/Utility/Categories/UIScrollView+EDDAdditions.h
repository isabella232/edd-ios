//
// UIScrollView+EDDAdditions.h
//
// Based off of: https://github.com/samvermette/SVPullToRefresh
//

#import <UIKit/UIKit.h>

@class EDDInfiniteScrollingView;

@interface UIScrollView (EDDAdditions)

- (void)edd_addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler;

- (void)edd_triggerInfiniteScrolling;

@property (nonatomic, strong, readonly) EDDInfiniteScrollingView *infiniteScrollingView;

@property (nonatomic, assign) BOOL showsInfiniteScrolling;

@end

enum {
	EDDInfiniteScrollingStateStopped = 0,
    EDDInfiniteScrollingStateTriggered,
    EDDInfiniteScrollingStateLoading,
    EDDInfiniteScrollingStateAll = 10
};

typedef NSUInteger EDDInfiniteScrollingState;

@interface EDDInfiniteScrollingView : UIView

@property (nonatomic, readwrite) UIActivityIndicatorViewStyle activityIndicatorViewStyle;

@property (nonatomic, readonly) EDDInfiniteScrollingState state;

@property (nonatomic, readwrite) BOOL enabled;

@property (nonatomic, readwrite) NSInteger sensitivity;

- (void)setCustomView:(UIView *)view forState:(EDDInfiniteScrollingState)state;

- (void)startAnimating;

- (void)stopAnimating;

@end
