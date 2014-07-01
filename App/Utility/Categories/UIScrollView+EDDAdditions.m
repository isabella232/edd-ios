//
// UIScrollView+EDDAdditions.m
//
// Based off of: https://github.com/samvermette/SVPullToRefresh
//

#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+EDDAdditions.h"


static CGFloat const EDDInfiniteScrollingViewHeight = 60;

@interface EDDInfiniteScrollingDotView : UIView

@property (nonatomic, strong) UIColor *arrowColor;

@end

@interface EDDInfiniteScrollingView ()

@property (nonatomic, copy) void (^infiniteScrollingHandler)(void);

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, readwrite) EDDInfiniteScrollingState state;
@property (nonatomic, strong) NSMutableArray *viewForState;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, readwrite) CGFloat originalBottomInset;
@property (nonatomic, assign) BOOL wasTriggeredByUser;
@property (nonatomic, assign) BOOL isObserving;

- (void)resetScrollViewContentInset;
- (void)setScrollViewContentInsetForInfiniteScrolling;
- (void)setScrollViewContentInset:(UIEdgeInsets)insets;

@end

#pragma mark - UIScrollView (EDDInfiniteScrollingView)
#import <objc/runtime.h>

static char UIScrollViewInfiniteScrollingView;
UIEdgeInsets scrollViewOriginalContentInsets;

@implementation UIScrollView (EDDAdditions)

@dynamic infiniteScrollingView;

- (void)edd_addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler {
    
    if (!self.infiniteScrollingView) {
        EDDInfiniteScrollingView *view = [[EDDInfiniteScrollingView alloc] initWithFrame:CGRectMake(0, self.contentSize.height, self.bounds.size.width, EDDInfiniteScrollingViewHeight)];
		view.sensitivity = 100;
        view.infiniteScrollingHandler = actionHandler;
        view.scrollView = self;
        [self addSubview:view];
        
        view.originalBottomInset = self.contentInset.bottom;
        self.infiniteScrollingView = view;
        self.showsInfiniteScrolling = YES;
    }
}

- (void)edd_triggerInfiniteScrolling {
    self.infiniteScrollingView.state = EDDInfiniteScrollingStateTriggered;
    [self.infiniteScrollingView startAnimating];
}

- (void)setInfiniteScrollingView:(EDDInfiniteScrollingView *)infiniteScrollingView {
    [self willChangeValueForKey:@"UIScrollViewInfiniteScrollingView"];
    objc_setAssociatedObject(self, &UIScrollViewInfiniteScrollingView,
                             infiniteScrollingView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"UIScrollViewInfiniteScrollingView"];
}

- (EDDInfiniteScrollingView *)infiniteScrollingView {
    return objc_getAssociatedObject(self, &UIScrollViewInfiniteScrollingView);
}

- (void)setShowsInfiniteScrolling:(BOOL)showsInfiniteScrolling {
    self.infiniteScrollingView.hidden = !showsInfiniteScrolling;
    
    if (!showsInfiniteScrolling) {
        if (self.infiniteScrollingView.isObserving) {
            [self removeObserver:self.infiniteScrollingView forKeyPath:@"contentOffset"];
            [self removeObserver:self.infiniteScrollingView forKeyPath:@"contentSize"];
            [self.infiniteScrollingView resetScrollViewContentInset];
            self.infiniteScrollingView.isObserving = NO;
        }
    }
    else {
        if (!self.infiniteScrollingView.isObserving) {
            [self addObserver:self.infiniteScrollingView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.infiniteScrollingView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self.infiniteScrollingView setScrollViewContentInsetForInfiniteScrolling];
            self.infiniteScrollingView.isObserving = YES;
            
            [self.infiniteScrollingView setNeedsLayout];
            self.infiniteScrollingView.frame = CGRectMake(0, self.contentSize.height, self.infiniteScrollingView.bounds.size.width, EDDInfiniteScrollingViewHeight);
        }
    }
}

- (BOOL)showsInfiniteScrolling {
    return !self.infiniteScrollingView.hidden;
}

@end

#pragma mark - EDDInfiniteScrollingView

@implementation EDDInfiniteScrollingView

// public properties
@synthesize infiniteScrollingHandler, activityIndicatorViewStyle;

@synthesize state = _state;

@synthesize scrollView = _scrollView;

@synthesize activityIndicatorView = _activityIndicatorView;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // default styling values
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = EDDInfiniteScrollingStateStopped;
        self.enabled = YES;
        
        self.viewForState = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsInfiniteScrolling) {
            if (self.isObserving) {
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                self.isObserving = NO;
            }
        }
    }
}

- (void)layoutSubviews {
    self.activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForInfiniteScrolling {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset + EDDInfiniteScrollingViewHeight;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:NULL];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if ([keyPath isEqualToString:@"contentSize"]) {
        [self layoutSubviews];
        self.frame = CGRectMake(0, self.scrollView.contentSize.height, self.bounds.size.width, EDDInfiniteScrollingViewHeight);
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
	if (contentOffset.y <= 0) return;
	
    if (self.state != EDDInfiniteScrollingStateLoading && self.enabled) {
        CGFloat scrollViewContentHeight = self.scrollView.contentSize.height;
        UIView *customView = [self.viewForState objectAtIndex:self.state];
        BOOL hasCustomView = [customView isKindOfClass:[UIView class]];
        float currentViewHeight = hasCustomView ?customView.bounds.size.height : EDDInfiniteScrollingViewHeight;
        float sensitivityHeight = self.sensitivity ? (self.sensitivity + currentViewHeight) : 0;
        CGFloat scrollOffsetThreshold = scrollViewContentHeight - self.scrollView.bounds.size.height - sensitivityHeight;
        
        if (!self.scrollView.isDragging && self.state == EDDInfiniteScrollingStateTriggered)
            self.state = EDDInfiniteScrollingStateLoading;
        else if (contentOffset.y > scrollOffsetThreshold && self.state == EDDInfiniteScrollingStateStopped && self.scrollView.isDragging)
            self.state = EDDInfiniteScrollingStateTriggered;
        else if (contentOffset.y < scrollOffsetThreshold  && self.state != EDDInfiniteScrollingStateStopped)
            self.state = EDDInfiniteScrollingStateStopped;
    }
}

#pragma mark - Getters

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

- (UIActivityIndicatorViewStyle)activityIndicatorViewStyle {
    return self.activityIndicatorView.activityIndicatorViewStyle;
}

#pragma mark - Setters

- (void)setCustomView:(UIView *)view forState:(EDDInfiniteScrollingState)state {
    id viewPlaceholder = view;
    
    if (!viewPlaceholder)
        viewPlaceholder = @"";
    
    if (state == EDDInfiniteScrollingStateAll) {
        [self.viewForState replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[viewPlaceholder, viewPlaceholder, viewPlaceholder]];
	} else {
        [self.viewForState replaceObjectAtIndex:state withObject:viewPlaceholder];
	}
    
    self.state = self.state;
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)viewStyle {
    self.activityIndicatorView.activityIndicatorViewStyle = viewStyle;
}

#pragma mark -

- (void)triggerRefresh {
    self.state = EDDInfiniteScrollingStateTriggered;
    self.state = EDDInfiniteScrollingStateLoading;
}

- (void)startAnimating{
    self.state = EDDInfiniteScrollingStateLoading;
}

- (void)stopAnimating {
    self.state = EDDInfiniteScrollingStateStopped;
}

- (void)setState:(EDDInfiniteScrollingState)newState {
    if (_state == newState) return;
    
    EDDInfiniteScrollingState previousState = _state;
    _state = newState;
    
    for (id otherView in self.viewForState) {
        if ([otherView isKindOfClass:[UIView class]])
            [otherView removeFromSuperview];
    }
    
    id customView = [self.viewForState objectAtIndex:newState];
    BOOL hasCustomView = [customView isKindOfClass:[UIView class]];
    
    if (hasCustomView) {
        [self addSubview:customView];
        CGRect viewBounds = [customView bounds];
        CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), roundf((self.bounds.size.height-viewBounds.size.height)/2));
        [customView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
    } else {
        CGRect viewBounds = [self.activityIndicatorView bounds];
        CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), roundf((self.bounds.size.height-viewBounds.size.height)/2));
        [self.activityIndicatorView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
        
        switch (newState) {
            case EDDInfiniteScrollingStateStopped:
                [self.activityIndicatorView stopAnimating];
                break;
                
            case EDDInfiniteScrollingStateTriggered:
                break;
                
            case EDDInfiniteScrollingStateLoading:
                [self.activityIndicatorView startAnimating];
                break;
        }
    }
    
    if (previousState == EDDInfiniteScrollingStateTriggered && newState == EDDInfiniteScrollingStateLoading && self.infiniteScrollingHandler && self.enabled) {
        self.infiniteScrollingHandler();
	}
}

@end
