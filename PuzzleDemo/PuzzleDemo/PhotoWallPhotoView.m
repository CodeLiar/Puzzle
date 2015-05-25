//
//  PhotoWallView.m
//  PuzzleDemo
//
//  Created by Geass on 5/21/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import "PhotoWallPhotoView.h"

static NSTimeInterval const kUIViewAnimationDuration = 0.1f;

typedef NS_ENUM(NSUInteger, PhotoViewImageOrientation) {
    PhotoViewImageOrientationPortrait,
    PhotoViewImageOrientationLandscape
};

@interface PhotoWallPhotoView ()

@property (nonatomic, strong) NSArray *pointsArray;
@property (nonatomic, assign) CGFloat scaleHeight;
@property (nonatomic, assign) CGFloat scaleWidth;
@property (nonatomic, strong) UIBezierPath *bezierPath;

@property (nonatomic, strong) UIImageView *moveImageView;

@property (nonatomic, assign) CGRect moveBeginFrame;
@property (nonatomic, assign) CGRect originFrame;

@property (nonatomic, assign) CGFloat imageScale;               // 图片存放比例
@property (nonatomic, assign) PhotoViewImageOrientation imageOrientation;

@end

@implementation PhotoWallPhotoView

- (instancetype)initWithPointScales:(NSArray *)pointsScales scaleSize:(CGSize)scaleSize image:(NSString *)image
{
    self.scaleWidth = scaleSize.width;
    self.scaleHeight = scaleSize.height;
    self.moveImage = image;
    self.clipsToBounds = YES;
    self.pointsArray = [self getPointValueArrayWithPointScales:pointsScales];
    
    self = [super initWithFrame:[self getViewFrameWithPointScales:pointsScales]];
    if (self)
    {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPanMethod:)];
        [self addGestureRecognizer:panGesture];
        
        self.bezierPath = [self getBezierPath];
        [self setMaskShape];
        [self createMoveImageView];
    }
    return self;
}

// 创建ImageView
- (void)createMoveImageView
{
    self.moveImageView = [[UIImageView alloc] initWithFrame:[self getOriginFrameWithImage:self.moveImage]];
    self.originFrame = self.moveImageView.frame;
    self.moveImageView.image = [UIImage imageNamed:self.moveImage];
    self.moveImageView.userInteractionEnabled = YES;
    [self addSubview:self.moveImageView];
}

// 通过bezzierPath 限定layer.mask
- (UIBezierPath *)getBezierPath
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i=0; i<self.pointsArray.count; i++) {
        CGPoint point = [self.pointsArray[i] CGPointValue];
        point.x = point.x - self.frame.origin.x;
        point.y = point.y - self.frame.origin.y;
        if (i == 0) {
            [path moveToPoint:point];
        }else{
            [path addLineToPoint:point];
        }
    }
    [path closePath];
    return path;
}

// 设置maskShape
- (void)setMaskShape
{
    @synchronized(self){
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = [self.bezierPath CGPath];
        maskLayer.frame = self.bounds;
        self.layer.mask = maskLayer;
        [self setNeedsLayout];
    }
}

// 重设图片坐标
- (void)resetImageFrame:(CGRect)frame
{
    [UIView animateWithDuration:kUIViewAnimationDuration animations:^{
        self.moveImageView.frame = frame;
    }];
}

// 根据点坐标限定
- (CGRect)getViewFrameWithPointScales:(NSArray *)points
{
    CGFloat minX = [points[0] floatValue];
    CGFloat maxX = [points[0] floatValue];
    CGFloat minY = [points[1] floatValue];
    CGFloat maxY = [points[1] floatValue];
    
    for (int i=0; i<points.count; i+=2) {
        CGFloat x = [points[i] floatValue];
        CGFloat y = [points[i+1] floatValue];
        if (minX > x) {
            minX = x;
        }
        if (maxX < x) {
            maxX = x;
        }
        if (minY > y) {
            minY = y;
        }
        if (maxY < y) {
            maxY = y;
        }
    }
    
    return CGRectMake(minX*self.scaleWidth, minY*self.scaleHeight, (maxX-minX)*self.scaleWidth, (maxY-minY)*self.scaleHeight);
}

// 将坐标比例点切换为页面坐标
- (NSArray *)getPointValueArrayWithPointScales:(NSArray *)points
{
    NSMutableArray *tempPointArr = [NSMutableArray array];
    
    for (int i=0; i<points.count; i+=2) {
        CGFloat x = [points[i] floatValue] * self.scaleWidth;
        CGFloat y = [points[i+1] floatValue] * self.scaleHeight;
        CGPoint point  = CGPointMake(x, y);
        NSValue *pointValue = [NSValue valueWithCGPoint:point];
        [tempPointArr addObject:pointValue];
    }
    return tempPointArr;
}

// 判断点击事件
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self isPointInThisPhotoItem:point];
}

- (BOOL)isPointInThisPhotoItem:(CGPoint)point
{
    return  [self.bezierPath containsPoint:point];
}

// 切换图片
- (void)phohoItemChangeImage:(NSString *)image
{
    self.moveImage = image;
    self.originFrame = [self getOriginFrameWithImage:image];
    self.moveBeginFrame = [self getOriginFrameWithImage:image];
    self.moveImageView.image = [UIImage imageNamed:image];
    [self resetImageFrame:self.originFrame];
}

// 根据图片设置imageView的frame的size
- (CGRect)getOriginFrameWithImage:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGFloat wScale = self.bounds.size.width / width;
    CGFloat hScale = self.bounds.size.height / height;
    
    if (wScale >= hScale)
    {
        self.imageOrientation = PhotoViewImageOrientationPortrait;
        self.imageScale = wScale;
    }
    else
    {
        self.imageOrientation = PhotoViewImageOrientationLandscape;
        self.imageScale = hScale;
    }
    
    return CGRectMake(0, 0, width * self.imageScale, height * self.imageScale);
}

// 限制图片的frame，不能有图片空白
- (CGRect)restrictTheMoveImageFrame
{
    CGRect frame = self.moveImageView.frame;
    switch (self.imageOrientation)
    {
        case PhotoViewImageOrientationLandscape:
            frame.origin.y = self.originFrame.origin.y;
            if (-(frame.origin.x + frame.size.width < self.bounds.size.width))
            {
                frame.origin.x = -(self.originFrame.size.width - self.bounds.size.width);
            }
            else if (frame.origin.x > 0)
            {
                frame.origin.x = 0;
            }
            
            break;
            
        case PhotoViewImageOrientationPortrait:
            frame.origin.x = self.originFrame.origin.x;
            if (frame.origin.y + frame.size.height < self.bounds.size.height)
            {
                frame.origin.y = -(self.originFrame.size.height - self.bounds.size.height);
            }
            else if (frame.origin.y > 0)
            {
                frame.origin.y = 0;
            }
            
            break;
            
        default:
            frame = self.originFrame;
            break;
    }
    
    return frame;
}

#pragma makr - GestureMoveMethod
- (void)imageViewPanMethod:(UIPanGestureRecognizer *)panGesture
{
    if ([self.delegate respondsToSelector:@selector(photoItemMoveGesture:)])
    {
        [self.delegate photoItemMoveGesture:panGesture];
    }
    
    
    static CGPoint location;

    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"UIGestureRecognizerStateBegan");
            location = [panGesture locationInView:self];
            self.moveBeginFrame = self.moveImageView.frame;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint newLocation = [panGesture locationInView:self];
            
            CGFloat changeX = newLocation.x - location.x;
            CGFloat changeY = newLocation.y - location.y;
            
            CGPoint center = self.moveImageView.center;
            center.x += changeX;
            center.y += changeY;
            self.moveImageView.center = center;
            
            self.moveBeginFrame = [self restrictTheMoveImageFrame];
            
            location = newLocation;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            [self resetImageFrame:self.moveBeginFrame];
            NSLog(@"UIGestureRecognizerStateEnded");
        }

            break;
            
        case UIGestureRecognizerStateFailed:
        {
            [self resetImageFrame:self.moveBeginFrame];
            NSLog(@"UIGestureRecognizerStateFailed");
        }

            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            [self resetImageFrame:self.moveBeginFrame];
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
