//
//  PDTableView.m
//  PDTableView
//
//  Created by didi on 2019/4/15.
//  Copyright © 2019年 liang. All rights reserved.
//

#import "PDTableView.h"

@interface PDTableView () {
    NSInteger _numberOfRows;
    CGFloat _totalWidth;
    
    struct {
        unsigned widthForRowAtIndex : 1;
    } _hasDelegate;
    
    struct {
        unsigned numberOfRowsInTableView : 1;
        unsigned viewForRowAtIndex : 1;
    } _hasDataSource;
}

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIView *> *visibleViews;
@property (nonatomic, strong) NSMutableSet<UIView *> *cachedViews;
@property (nonatomic, strong) NSMutableArray<NSValue *> *viewFrames;

@end

@implementation PDTableView

@synthesize delegate = _delegate;

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _visibleViews = [NSMutableDictionary dictionary];
        _cachedViews = [NSMutableSet set];
        _viewFrames = [NSMutableArray array];
        
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

#pragma mark - Public Methods
- (UIView *)dequeueReuseView {
    UIView *view = [self.cachedViews anyObject];
    if (view) {
        [self.cachedViews removeObject:view];
    }
    return view;
}

- (void)reloadData {
    if (!_hasDelegate.widthForRowAtIndex || !_hasDataSource.numberOfRowsInTableView) {
        return;
    }
    
    // Move views from visible rect to cache pool
    for (NSNumber *key in [self.visibleViews.allKeys copy]) {
        UIView *view = self.visibleViews[key];
        [view removeFromSuperview];
        [self.visibleViews removeObjectForKey:key];
        [self.cachedViews addObject:view];
    }
    
    _numberOfRows = [self.dataSource numberOfRowsInTableView:self];
    if (!_numberOfRows) { return; }
    
    // Calculate the frames of the views
    _totalWidth = 0;
    [_viewFrames removeAllObjects];
    
    for (NSInteger index = 0; index < _numberOfRows; index ++) {
        CGFloat width = [self.delegate tableView:self widthForRowAtIndex:index];
        CGFloat height = CGRectGetHeight(self.bounds);
        
        CGRect rect = CGRectMake(_totalWidth, 0, width, height);
        NSValue *rectValue = [NSValue valueWithCGRect:rect];
        [self.viewFrames addObject:rectValue];
        
        _totalWidth += width;
    }
    
    // Reset contentSize
    self.contentSize = CGSizeMake(_totalWidth, CGRectGetHeight(self.bounds));
    
    [self loadVisibleViews];
}

#pragma mark - Observer Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:@"contentOffset"]) { return; }
    
    [self loadVisibleViews];
}

#pragma mark - Private Methods
- (void)loadVisibleViews { /* Core Method */
    if (!_hasDataSource.viewForRowAtIndex) {
        return;
    }
    
    // Get visible frame
    CGRect visibleRect = CGRectMake(self.contentOffset.x,
                                    self.contentOffset.y,
                                    CGRectGetWidth(self.bounds),
                                    CGRectGetHeight(self.bounds));
    
    for (NSInteger index = 0; index < _numberOfRows; index ++) {
        NSValue *rectValue = self.viewFrames[index];
        CGRect rect = [rectValue CGRectValue];
        UIView *view = self.visibleViews[@(index)];
        
        // Add view to visible area
        if (CGRectIntersectsRect(visibleRect, rect) && !view) {
            view = [self.dataSource tableView:self viewForRowAtIndex:index];
            view.frame = rect;
            [self addSubview:view];
            [self.visibleViews setObject:view forKey:@(index)];
        }
        
        // Remove view to cache pool
        if (!CGRectIntersectsRect(visibleRect, rect) && view) {
            [view removeFromSuperview];
            [self.visibleViews removeObjectForKey:@(index)];
            [self.cachedViews addObject:view];
        }
    }
}

#pragma mark - Override Methods
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self reloadData];
}

#pragma mark - Setter Methods
- (void)setDelegate:(id<PDTableViewDelegate>)delegate {
    _delegate = delegate;
    
    _hasDelegate.widthForRowAtIndex = [_delegate respondsToSelector:@selector(tableView:widthForRowAtIndex:)];
}

- (void)setDataSource:(id<PDTableViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    _hasDataSource.numberOfRowsInTableView = [_dataSource respondsToSelector:@selector(numberOfRowsInTableView:)];
    _hasDataSource.viewForRowAtIndex = [_dataSource respondsToSelector:@selector(tableView:viewForRowAtIndex:)];
}

@end
