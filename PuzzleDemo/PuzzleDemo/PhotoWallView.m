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
// TODO: 删除
@property (nonatomic, strong) NSDictionary *thumbsImageDict;
@property (nonatomic, strong) NSArray *demoImgArray;

@end

@implementation PhotoWallView

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
        PhotoWallPhotoView *photoItem = [[PhotoWallPhotoView alloc] initWithPointScales:pointScales scaleSize:self.frame.size image:self.demoImgArray[i]];
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

- (void)createImageViewWithImage:(NSString *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:imageView];
    imageView.image = [UIImage imageNamed:image];
}

// 根据触摸点获取PhotoItem
- (PhotoWallPhotoView *)getPhotoItemWithGesture:(UIPanGestureRecognizer *)panGesture
{
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[PhotoWallPhotoView class]])
        {
            PhotoWallPhotoView *photoItem = (PhotoWallPhotoView *)subView;
            CGPoint location = [panGesture locationInView:photoItem];
            
            if ([photoItem isPointInThisPhotoItem:location])
            {
                if ([photoItem isEqual:self.currentPhotoItem] || [photoItem isEqual:self.changePhotoItem])
                {
                    return nil;
                }
                else
                {
                    return photoItem;
                }
                break;
            }

            NSLog(@"%d", [photoItem isPointInThisPhotoItem:location]);
        }
    }
    return nil;
}

// 交换Photo
- (void)exchangePhotoItem
{
    if (self.currentPhotoItem && self.changePhotoItem)
    {
        NSString *currentImg = [self.currentPhotoItem.moveImage mutableCopy];
        [self.currentPhotoItem phohoItemChangeImage:self.changePhotoItem.moveImage];
        [self.changePhotoItem phohoItemChangeImage:currentImg];
    }
    else
    {
        
    }
}

#pragma mark - PhotoWallPhotoViewDelegate
- (void)photoItemMoveGesture:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
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
            self.currentPhotoItem = nil;
            self.changePhotoItem = nil;
            NSLog(@"UIGestureRecognizerStateEnded");
        }
            
            break;
            
        case UIGestureRecognizerStateFailed:
        {
            self.currentPhotoItem = nil;
            self.changePhotoItem = nil;
            NSLog(@"UIGestureRecognizerStateFailed");
        }
            
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            self.currentPhotoItem = nil;
            self.changePhotoItem = nil;
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


@end
