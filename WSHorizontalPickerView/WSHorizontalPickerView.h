//
//  WSHPickerView.h
//  WSHorizontalPickerView
//
//  Created by wossoneri on 16/5/5.
//  Copyright © 2016年 wossoneri. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol WSHorizontalPickerViewDelegate <NSObject>

- (void)selectItemAtIndex:(NSInteger)index;

@end


@interface WSHorizontalPickerView : UIView

/// item name to show
@property (nonatomic, strong) NSArray *itemTitles;

/// array of images' name
@property (nonatomic, strong) NSArray *images;

/// scroll speed
@property (nonatomic, assign) BOOL acuteScroll;

/// show scroll indicator
@property (nonatomic, assign) BOOL showIndicator;

@property (nonatomic, weak) id<WSHorizontalPickerViewDelegate> delegate;

- (void)updateData;
- (void)scrollToHead;
- (void)scrollToCenter;
- (void)scrollToTail;


@end
