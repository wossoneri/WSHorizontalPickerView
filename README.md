**最新更新: 简单封装了一下代码，参考新文章：[UICollectionView实现图片水平滚动](http://wossoneri.github.io/2016/01/09/[iOS]Horizon-Scroll-UICollectionView/)**

----

先简单看一下效果：
![result](https://raw.githubusercontent.com/wossoneri/iosdemos/master/HorizontalPickerView2/gifs/7.gif)
新博客：[http://wossoneri.github.io](http://wossoneri.github.io/2016/01/09/[iOS]Horizon-Scroll-UICollectionView/)

## 准备数据
首先先加入一些资源文件：

先建立一个`xcassets`文件，放入图片：

![xcassets](https://github.com/wossoneri/iosdemos/blob/master/HorizontalPickerView2/gifs/hpicker2.png?raw=true)

再建立一个plist文件，写入与图片对应的内容：

![plist](https://github.com/wossoneri/iosdemos/blob/master/HorizontalPickerView2/gifs/hpicker1.png?raw=true)

在ViewController中读取`plist`到词典中：

```objectivec
@property (nonatomic, strong) NSArray *itemTitles;

NSString *path = [[NSBundle mainBundle] pathForResource:@"titles" ofType:@"plist"];
NSDictionary *rootDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
self.itemTitles = [rootDictionary objectForKey:@"heros"];
```

可以打`log`输出，可以看到`plist`的内容已经读取出来，后面就可以用`_itemTitle`作为数据源了。

## 添加UICollectionView初步显示图片
每个`CollectionView`都有一个对应的布局`layout`，对于默认的的`UICollectionViewFlowLayout`，效果是类似Android的`GridView`的布局。如果要自定义`CollectionView`的样式，就要对这个`layout`进行修改。

建立自己的`HorizontalFlowLayout`，继承自`UICollectionViewFlowLayout`，然后在初始化方法里将滚动方向设置为水平：

```objectivec
- (instancetype) init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
    }
    return self;
}
```

接下来定制我们的`cell`的显示样式，建立`DotaCell`，继承自`UICollectionViewCell`。由于我们要实现的是图片和文字的上下布局，所以增加两个属性：

```objectivec
@interface DotaCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *name;

@end
```

然后设置图片与文字上下对齐布局，这里我使用`pod`导入`Masonry`库来写自动布局：
```objectivec

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.layer.doubleSided = NO;
    
    self.image = [[UIImageView alloc] init];
    self.image.backgroundColor = [UIColor clearColor];
    self.image.contentMode = UIViewContentModeCenter;
    self.image.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.name = [[UILabel alloc] init];
    self.name.font = [UIFont fontWithName:@"Helvetica Neue" size:20];
    self.name.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:self.image];
    [self.contentView addSubview:self.name];

    [_image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(30);
        make.bottom.equalTo(_name.mas_top).offset(-10);
    }];
    
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(_image.mas_bottom).offset(10);
        make.bottom.equalTo(self.contentView).offset(-20);
    }];
}

```

写好`layout`和`cell`后就可以用这两个类来初始化我们的`collectionView`了:

```objectivec
//add in view did load
    self.layout = [[HorizontalFlowLayout alloc] init];
    
    CGRect rct = self.view.bounds;
    rct.size.height = 150;
    rct.origin.y = [[UIScreen mainScreen] bounds].size.height / 2.0 - rct.size.height;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:rct collectionViewLayout:_layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    [self.collectionView registerClass:[DotaCell class] forCellWithReuseIdentifier:NSStringFromClass([DotaCell class])];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];

    [self.view addSubview:_collectionView];
    
```

添加`UICollectionViewDataSource`的代理方法，使其显示数据。

```objectivec

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.itemTitles count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DotaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DotaCell class]) forIndexPath:indexPath];
    
    cell.image.image = [UIImage imageNamed:[self.itemTitles objectAtIndex:indexPath.row]];
    cell.name.text = [self.itemTitles objectAtIndex:indexPath.row];
    
    return cell;
}

```

这样程序就有了我们想要的初步效果：
![gif1](https://github.com/wossoneri/iosdemos/blob/master/HorizontalPickerView2/gifs/1.gif?raw=true)

## 图片水平排放
但...效果的确很差！
下面要做的就是逐步完善效果，首先我们要让两排图像变成一排去展示。那要怎么去做？首先，我们在初始化`collectionView`的地方设置了高度为150，所以图片就挤在这个150的高度里尽可能的压缩显示。由于`collectionView`的尺寸已经设定，那么就剩`cell`的尺寸可以控制了。实现`CollectionViewFlowLayoutDelegate`的代理方法`sizeForItemAtIndexPath`：

```objectivec

- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(64, collectionView.bounds.size.height); 
}

```
> 这里宽度64是图片的尺寸，高度设置填满`collectionView`的高度是为了防止上图中两行图片挤压的情况，所以直接让一个`cell`的高度占满整个容器。

这时候的效果好了很多，已经有点样子了：
![gif2](https://github.com/wossoneri/iosdemos/blob/master/HorizontalPickerView2/gifs/2.gif?raw=true)

## 顶端图片滑到中间
但这离我们最终的效果还差很远，接下来我需要实现让第一张图片和最后一张图片都能滑到屏幕中点的位置，这应该是很常见的效果，实现起来也很简单。首先我们的一排`cell`都默认为顶端与`collectionView`的两端对齐的，`collectionView`的左右两端与`viewController.view`也是对齐的，所以显示的效果是，两端的图片都与屏幕对齐。知道这个关系就好办了，直接设置`collectionView`与其父`view`的内间距即可。
依旧是实现`flowLayout`的代理方法：

```objectivec

//Asks the delegate for the margins to apply to content in the specified section.安排初始位置
//使前后项都能居中显示
- (UIEdgeInsets)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    NSInteger itemCount = [self collectionView:collectionView numberOfItemsInSection:section];

    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    CGSize firstSize = [self collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:firstIndexPath];
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:itemCount - 1 inSection:section];
    CGSize lastSize = [self collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:lastIndexPath];
    
    return UIEdgeInsetsMake(0, (collectionView.bounds.size.width - firstSize.width) / 2,
                            0, (collectionView.bounds.size.width - lastSize.width) / 2);
    
    
}

```

效果如图：
![gif3](https://github.com/wossoneri/iosdemos/blob/master/HorizontalPickerView2/gifs/3.gif?raw=true)

## 居中图片放大显示
接下来添加一个我们需要的特效，就是中间的图片放大显示，其余的缩小并且增加一层半透明效果。
在`FlowLayout`中有一个名为`layoutAttributesForElementsInRect`的方法，功能如其名，就是设置范围内元素的`layout`属性。对于这个效果，首先需要设置放大的比例，其次要根据图片大小和间距来设定一个合适的触发放大的区域宽度，当图滑入这个区域就进行缩放。

```objectivec

static CGFloat const ActiveDistance = 80;
static CGFloat const ScaleFactor = 0.2;
//这里设置放大范围
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    CGRect visibleRect = (CGRect){self.collectionView.contentOffset, self.collectionView.bounds.size};
    
    for (UICollectionViewLayoutAttributes *attributes in array) {
        //如果cell在屏幕上则进行缩放
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            
            attributes.alpha = 0.5;
   
            CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;//距离中点的距离
            CGFloat normalizedDistance = distance / ActiveDistance;
            
            if (ABS(distance) < ActiveDistance) {
                CGFloat zoom = 1 + ScaleFactor * (1 - ABS(normalizedDistance)); //放大渐变
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
                attributes.zIndex = 1;
                attributes.alpha = 1.0;
            }
        }
    }
    
    return array;
}

```

效果如下：
![gif4](https://github.com/wossoneri/iosdemos/blob/master/HorizontalPickerView2/gifs/4.gif?raw=true)

## 滑动校正
这时候几乎完成了，但还差点东西，就是让其在滚动停止的时候，离屏幕中间最近的`cell`自动矫正位置到中间。还是在`FlowLayout`添加该方法，具体说明我都写到注释里了：

```objectivec

//scroll 停止对中间位置进行偏移量校正
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

```

![gif5](https://github.com/wossoneri/iosdemos/blob/master/HorizontalPickerView2/gifs/5.gif?raw=true)

## 增加图片点击效果
最后 添加一个点击cell 将其滚动到中间
在`viewcontroller`添加`CollectionViewDelegate`的代理方法
```objectivec
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
    //滚动到中间
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}
```

![gif6](https://github.com/wossoneri/iosdemos/blob/master/HorizontalPickerView2/gifs/6.gif?raw=true)

## 封装成控件
当我们把效果实现之后，就可以考虑将代码优化一下，合到一个类里，减少书写常量，增加接口，封装成一个控件去使用。比如可以设定文字的显示与隐藏接口，再比如增加适应各种尺寸的图片等等。这个代码就不放了，毕竟不难，有问题给我留言好了。
