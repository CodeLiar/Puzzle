//
//  PhotoWallView.m
//  PuzzleDemo
//
//  Created by Geass on 5/21/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import "PhotoWallView.h"
#import "PhotoWallPhotoView.h"
#import "UIColor+Category.h"

@interface PhotoWallView ()<PhotoWallPhotoViewDelegate>

@property (nonatomic, strong) NSDictionary *jsonData;               // 拼图数据Json
@property (nonatomic, strong) NSArray *pointScalesArray;
@property (nonatomic, assign) NSInteger puzzleCount;                // 拼图数量
@property (nonatomic, strong) NSString *puzzleIndex;                // 根据拼图数量选择对应数量的模板
@property (nonatomic, strong) NSString *coverImage;                 // 覆盖图片
@property (nonatomic, strong) NSString *backgroundImage;            // 背景图片

@property (nonatomic, strong) PhotoWallPhotoView *currentPhotoItem; // 当前选中的PhotoItem
@property (nonatomic, strong) PhotoWallPhotoView *changePhotoItem;  // 要交换的PhotoItem

@property (nonatomic, strong) UIView *menuItemView;
// TODO: 删除
@property (nonatomic, strong) NSDictionary *thumbsImageDict;
@property (nonatomic, strong) NSArray *demoImgArray;

@end

@implementation PhotoWallView

- (instancetype)initWithFrame:(CGRect)frame jsonData:(NSDictionary *)jsonData photoArray:(NSMutableArray *)photoArray
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.puzzleCount = photoArray.count;
        self.jsonData = jsonData;
        self.photoArray = photoArray;
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame jsonData:(NSDictionary *)jsonData puzzleCount:(NSInteger)puzzleCount
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.demoImgArray = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg"];
        self.puzzleCount = puzzleCount;
        self.jsonData = jsonData;
        [self setupView];
    }
    return self;
}

- (void)changePuzzleCount:(NSInteger)puzzleCount
{
    if (self.puzzleCount == puzzleCount)
    {
        return;
    }
    self.puzzleCount = puzzleCount;
    [self resetView];
}

- (void)setupView
{
    self.puzzleIndex = [NSString stringWithFormat:@"%@", @(self.puzzleCount)];
    [self analyseJsonData];
    
    [self createBackgroundImageView];
    
    [self createAllPhotoItem];
    
    [self createCoverImageView];
}

- (void)resetView
{
    
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    [self setupView];
}

- (void)analyseJsonData
{
    // background color
    NSString *colorString = [self.jsonData objectForKey:@"bgcolor"];
    self.backgroundColor = [UIColor colorWithHexString:colorString];
    // background image
    self.backgroundImage = [[self.jsonData objectForKey:@"fgpic"] objectForKey:self.puzzleIndex];
    
    // thumbImage
    self.thumbsImageDict = [self.jsonData objectForKey:@"thumbs"];

    
    // point
    NSDictionary *points = [self.jsonData objectForKey:@"point"];
    self.pointScalesArray = [points objectForKey:self.puzzleIndex];
    
    // cover image
    self.coverImage = [[self.jsonData objectForKey:@"maskFgPic"] objectForKey:self.puzzleIndex];
}

- (void)createAllPhotoItem
{
    for (int i=0; i<self.pointScalesArray.count; i++)
    {
        NSString *pointString = self.pointScalesArray[i];
        NSArray *pointScales = [pointString componentsSeparatedByString:@","];
        PhotoWallPhotoView *photoItem = [[PhotoWallPhotoView alloc] initWithPointScales:pointScales scaleSize:self.frame.size image:self.photoArray[i]];
        photoItem.delegate = self;
        [self addSubview:photoItem];
    }
}

- (void)createBackgroundImageView
{
    if (self.backgroundImage)
    {
        [self createImageViewWithImage:self.backgroundImage];
    }
}

- (void)createCoverImageView
{
    if (self.coverImage)
    {
        [self createImageViewWithImage:self.coverImage];
    }
}


- (void)createMenuItemView
{
    self.menuItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.menuItemView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.menuItemView];
    self.menuItemView.hidden = YES;
    NSArray *titleArr = @[@"相册", @"旋转", @"放大", @"缩小"];
    
    for (int i=0; i<4; i++)
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((40+10)*i, 0, 40, 40)];
        [self.menuItemView addSubview:btn];
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(menuItemClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)menuItemClick:(UIButton *)menuItem
{
    
}


- (void)createImageViewWithImage:(NSString *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:imageView];
    imageView.image = [UIImage imageNamed:image];
}

// 根据触摸点获取PhotoItem
- (PhotoWallPhotoView *)getPhotoItemWithGesture:(UIGestureRecognizer *)panGesture
{
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[PhotoWallPhotoView class]])
        {
            PhotoWallPhotoView *photoItem = (PhotoWallPhotoView *)subView;
            CGPoint location = [panGesture locationInView:photoItem];
            
            if ([photoItem isPointInThisPhotoItem:location])
            {
                if ([photoItem isEqual:self.currentPhotoItem])
                {
                    return self.currentPhotoItem;
                }
                else if ([photoItem isEqual:self.changePhotoItem])
                {
                    return self.changePhotoItem;
                }
                else
                {
                    return photoItem;
                }
                break;
            }
        }
    }
    return nil;
}

// 交换Photo
- (void)exchangePhotoItem
{
    if (self.currentPhotoItem && self.changePhotoItem && ![self.currentPhotoItem isEqual:self.changePhotoItem])
    {
        UIImage *currentImg = self.currentPhotoItem.thumbImage;
        [self.currentPhotoItem phohoItemChangeImage:self.changePhotoItem.thumbImage];
        [self.changePhotoItem phohoItemChangeImage:currentImg];
    }
}

- (void)changePhotoItemImage:(UIImage *)image
{
    [self.currentPhotoItem phohoItemChangeImage:image];
}

- (void)changePhotoItemScaleZoomIn:(BOOL)zoom
{
    CGFloat scale ;
    if (zoom)
    {
        scale = 1.1f;
    }
    else
    {
        scale = 0.9f;
    }
    [self.currentPhotoItem changeImageViewScale:scale];
}

- (void)changePhotoItemTransform:(CGFloat)angle
{
    [self.currentPhotoItem changeImageViewTransform:angle];
}

#pragma mark - PhotoWallPhotoViewDelegate
- (void)photoItemMoveGesture:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.currentPhotoItem = nil;
            self.changePhotoItem = nil;
            if ([self getPhotoItemWithGesture:panGesture])
            {
                self.currentPhotoItem = [self getPhotoItemWithGesture:panGesture];
            }
            
            NSLog(@"current PhotoItem%@", self.currentPhotoItem);
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if ([self getPhotoItemWithGesture:panGesture])
            {
                self.changePhotoItem = [self getPhotoItemWithGesture:panGesture];
            }
            
            NSLog(@"change PhotoItem%@", self.changePhotoItem);
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            [self exchangePhotoItem];
            NSLog(@"UIGestureRecognizerStateEnded");
        }
            
            break;
            
        case UIGestureRecognizerStateFailed:
        {
            NSLog(@"UIGestureRecognizerStateFailed");
        }
            
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            
            NSLog(@"UIGestureRecognizerStateCancelled");
        }
            
            break;
            
        case UIGestureRecognizerStatePossible:
        {
            NSLog(@"UIGestureRecognizerStatePossible");
        }
            
            break;
            
        default:
            break;
    }
}


- (void)photoItemTapGesture:(UITapGestureRecognizer *)tipGesture
{
    self.currentPhotoItem = nil;
    self.currentPhotoItem = [self getPhotoItemWithGesture:tipGesture];
    
    if ([self.delegate respondsToSelector:@selector(photoWallViewTransferTapGesture:)])
    {
        [self.delegate photoWallViewTransferTapGesture:tipGesture];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.menuItemView.hidden = YES;
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}


@end
