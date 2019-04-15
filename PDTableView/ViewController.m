//
//  ViewController.m
//  PDTableView
//
//  Created by didi on 2019/4/15.
//  Copyright © 2019年 liang. All rights reserved.
//

#import "ViewController.h"
#import "PDTableView.h"

@interface ViewController () <PDTableViewDelegate, PDTableViewDataSource>

@property (nonatomic, strong) PDTableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];
}

- (UIColor*)randomColor {
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
    CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

#pragma mark - PDTableViewDelegate && PDTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(PDTableView *)tableView {
    return 20;
}

- (CGFloat)tableView:(PDTableView *)tableView widthForRowAtIndex:(NSInteger)index {
    return index * 10 + 50;
}

- (__kindof UIView *)tableView:(PDTableView *)tableView viewForRowAtIndex:(NSInteger)index {
    UILabel *view = [tableView dequeueReuseView];
    if (!view) {
        view = [[UILabel alloc] init];
        NSLog(@"====== 创建 ======, index = %zd", index);
    } else {
        NSLog(@"重用 %zd", index);
    }
    view.backgroundColor = [self randomColor];
    view.textAlignment = NSTextAlignmentCenter;
    view.text = [NSString stringWithFormat:@"%zd", index];
    return view;
}

#pragma mark - Getter Methods
- (PDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[PDTableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _tableView;
}

@end
