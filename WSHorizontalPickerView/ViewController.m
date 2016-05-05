//
//  ViewController.m
//  WSHorizontalPickerView
//
//  Created by wossoneri on 16/5/5.
//  Copyright © 2016年 wossoneri. All rights reserved.
//

#import "ViewController.h"

#import "WSHorizontalPickerView.h"

@interface ViewController () <WSHorizontalPickerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSArray *itemNames = @[@"AA", @"BM", @"CM", @"DOOM", @"DP", @"DW", @"ES", @"FV", @"JUGG", @"Lich", @"Lina", @"LOA", @"Oracle", @"PA", @"POM", @"Puck", @"Pudge", @"QOP", @"SB", @"Silencer", @"SS", @"TA", @"VIP", @"WD"];
    
    NSArray *imageNames = [itemNames copy];
    
    
    WSHorizontalPickerView *WSHPickerView = [[WSHorizontalPickerView alloc] initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 150)];
    WSHPickerView.itemTitles = itemNames;
    WSHPickerView.images = imageNames;
    WSHPickerView.delegate = self;
    [WSHPickerView updateData];
    
    [self.view addSubview:WSHPickerView];
    
    
    
}

- (void)selectItemAtIndex:(NSInteger)index {
    NSLog(@"index is %ld", (long)index);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
