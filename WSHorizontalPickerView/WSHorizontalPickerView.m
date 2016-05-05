//
//  WSHPickerView.m
//  WSHorizontalPickerView
//
//  Created by wossoneri on 16/5/5.
//  Copyright © 2016年 wossoneri. All rights reserved.
//


#import "WSHorizontalPickerView.h"

#define CELL_ID @"WSCell"
#define LAYOUT_ITEM_OFFSET  20

@interface WSCollectionLayout : UICollectionViewFlowLayout

//@property (nonatomic, assign) BOOL enableSelect;

@end

@interface WSCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@interface WSHorizontalPickerView() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    NSInteger _centerIndex;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) WSCollectionLayout *collectionLayout;

@end


# pragma mark - implementation

@implementation WSHorizontalPickerView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initData];
        [self initView];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initView];
    }
    
    return self;
}


# pragma mark - private func
// set default
- (void)initData {
    
    _acuteScroll = YES;
    _showIndicator = NO;
    
    _collectionLayout = [[WSCollectionLayout alloc] init];
    _collectionView = nil;
}

- (void)initView {
    CGRect rct = self.bounds;
    
    if (_collectionView) {
        [_collectionView removeFromSuperview];
        _collectionView = nil;
    }
    _collectionView = [[UICollectionView alloc] initWithFrame:rct collectionViewLayout:_collectionLayout];
    
    
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.showsHorizontalScrollIndicator = _showIndicator;
    _collectionView.decelerationRate = _acuteScroll ? UIScrollViewDecelerationRateNormal : UIScrollViewDecelerationRateFast;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [_collectionView registerClass:[WSCollectionCell class] forCellWithReuseIdentifier:CELL_ID];
    
    [self addSubview:_collectionView];
    
}

- (NSInteger)getCenterCellIndex {
    CGFloat x = (CGRectGetWidth(_collectionView.bounds) / 2.) + _collectionView.contentOffset.x;
    CGFloat y = _collectionView.center.y;
    CGPoint point = CGPointMake(x, y);
    
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:point];
    if (indexPath != nil) {
        return indexPath.row;
    } else {
        return -1;
    }
    
}


# pragma mark - CollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemTitles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WSCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    
    cell.imageView.image = [UIImage imageNamed:_images[indexPath.row]];
    cell.nameLabel.text = _itemTitles[indexPath.row];
    
//    if (_collectionLayout.enableSelect) {
//        
//    } else {
//        
//    }

    return cell;
}

# pragma mark - CollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (!_collectionLayout.enableSelect) {
//        
//    }
    
    // select item
    [_collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
    // scroll to center
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

}


# pragma mark - CollectionViewFlowLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CGFloat imgWidth = [UIImage imageNamed:[_images firstObject]].size.width;
    
    // [item0]-offset-|-offset-[item1]-offset-|-offset-[item2]
    
    // set the height equal to collection to ensure all items stay in one line
    return CGSizeMake(imgWidth + 2 * LAYOUT_ITEM_OFFSET, collectionView.bounds.size.height);
}

//Asks the delegate for the margins to apply to content in the specified section.
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    NSInteger itemCount = [self collectionView:collectionView numberOfItemsInSection:section];
    
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    CGSize firstItemSize = [self collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:firstIndexPath];
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:itemCount - 1 inSection:section];
    CGSize lastItemSize = [self collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:lastIndexPath];
    
    return UIEdgeInsetsMake(0, (collectionView.bounds.size.width - firstItemSize.width) / 2,
                            0, (collectionView.bounds.size.width - lastItemSize.width) / 2);
}

# pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger index = [self getCenterCellIndex];
    if (index < 0) {
        return;
    }
    
    if (_centerIndex == index) {
        return;
    }
    
    _centerIndex = index;
    
    if (_delegate && [_delegate respondsToSelector:@selector(selectItemAtIndex:)]) {
        [_delegate selectItemAtIndex:_centerIndex];
    }
    
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:_centerIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
}



# pragma mark - public func
- (void)scrollToHead {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)scrollToCenter {
    [self.collectionView reloadData];
    NSIndexPath *selection = [NSIndexPath indexPathForItem:(NSInteger)floor([self.itemTitles count] / 2.0) inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:selection atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

}

- (void)scrollToTail {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_itemTitles.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}


- (void)updateData {
    [self initView];
    [self scrollToCenter];
}



@end







# pragma mark - CollectionViewLayout
@implementation WSCollectionLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumInteritemSpacing = LAYOUT_ITEM_OFFSET * 2;
    }
    return self;
}

// return YES to cause the collection view to recall prepareLayout and layoutAttributesForElementsInRect
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}


static CGFloat const ActiveDistance = 80;
static CGFloat const ScaleFactor = 0.2;

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    CGRect visibleRect = (CGRect){self.collectionView.contentOffset, self.collectionView.bounds.size};
    
    for (UICollectionViewLayoutAttributes *attributes in array) {
        
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            
            attributes.alpha = 0.5;
            
            CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;//distance to screen center
            CGFloat normalizedDistance = distance / ActiveDistance;
            
            if (ABS(distance) < ActiveDistance) {
                CGFloat zoom = 1 + ScaleFactor * (1 - ABS(normalizedDistance)); //zoom in
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
                attributes.zIndex = 1;
                attributes.alpha = 1.0;
            }
            
        }
    }
    
    return array;
}

// auto scroll selected item to center
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    ////  |-------[-------]-------|
    ////  |滑动偏移|可视区域 |剩余区域|
    //是整个collectionView在滑动偏移后的当前可见区域的中点
    CGFloat centerX = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    //    CGFloat centerX = self.collectionView.center.x; //这个中点始终是屏幕中点
    //所以这里对collectionView的具体尺寸不太理解，输出的是屏幕大小，但实际上宽度肯定超出屏幕的
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes *layoutAttr in array) {
        CGFloat itemCenterX = layoutAttr.center.x;
        
        if (ABS(itemCenterX - centerX) < ABS(offsetAdjustment)) { // 找出最小的offset 也就是最中间的item 偏移量
            offsetAdjustment = itemCenterX - centerX;
        }
    }
    
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}


@end


#pragma mark - WSCollectionCell
@implementation WSCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    NSLog(@"cell inited");
    
    self.layer.doubleSided = NO;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.origin.x,
                                                               self.contentView.frame.origin.y + 30,
                                                               self.contentView.frame.size.width,
                                                               64)];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.contentMode = UIViewContentModeCenter;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.origin.x,
                                                           _imageView.frame.origin.y + _imageView.frame.size.height + 10,
                                                           self.contentView.frame.size.width,
                                                           20)];
    _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:_imageView];
    [self.contentView addSubview:_nameLabel];

}

//
//- (void)setSelected:(BOOL)selected {
//    [super setSelected:selected];
//
//    self.name.hidden = !selected;
//}


@end




