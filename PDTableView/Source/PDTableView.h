//
//  PDTableView.h
//  PDTableView
//
//  Created by didi on 2019/4/15.
//  Copyright © 2019年 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDTableView;

NS_ASSUME_NONNULL_BEGIN

@protocol PDTableViewDelegate <UIScrollViewDelegate, NSObject>

- (CGFloat)tableView:(PDTableView *)tableView widthForRowAtIndex:(NSInteger)index;

@end

@protocol PDTableViewDataSource <NSObject>

- (NSInteger)numberOfRowsInTableView:(PDTableView *)tableView;

- (__kindof UIView *)tableView:(PDTableView *)tableView viewForRowAtIndex:(NSInteger)index;

@end

@interface PDTableView : UIScrollView

@property (nonatomic, weak) id<PDTableViewDelegate> delegate;
@property (nonatomic, weak) id<PDTableViewDataSource> dataSource;

- (nullable __kindof UIView *)dequeueReuseView;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
