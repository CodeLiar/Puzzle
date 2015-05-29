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

@property (nonatomic, strong) UIImageView *moveImageView;                       // 移动的图片

@property (nonatomic, assign) CGRect moveBeginFrame;
@property (nonatomic, assign) CGRect originFrame;

@property (nonatomic, assign) CGFloat imageScale;                               // 图片存放比例
@property (nonatomic, assign) PhotoViewImageOrientation imageOrientation;       // 图片延展方向（暂时未用到）

@end

@implementation PhotoWallPhotoView

- (instancetype)initWithPointScales:(NSArray *)pointsScales scaleSize:(CGSize)scaleSize image:(UIImage *)image
{
    self.scaleWidth = scaleSize.width;
    self.scaleHeight = scaleSize.height;
    self.thumbImage = image;
    self.clipsToBounds = YES;
    self.pointsArray = [self getPointValueArrayWithPointScales:pointsScales];
    
    self = [super initWithFrame:[self getViewFrameWithPointScales:pointsScales]];
    if (self)
    {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPanMethod:)];
        [self addGestureRecognizer:panGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPinchMethod:)];
        [self addGestureRecognizer:pinchGesture];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapMethod:)];
        [self addGestureRecognizer:tap];
        
        self.bezierPath = [self getBezierPath];
        [self setMaskShape];
        [self createMoveImageView];
    }
    return self;
}

// 创建ImageView
- (void)createMoveImageView
{
    self.moveImageView = [[UIImageView alloc] initWithFrame:[self getOriginFrameWithImage:self.thumbImage]];
    self.moveImageView.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    self.originFrame = self.moveImageView.frame;
    self.moveImageView.image = self.thumbImage;
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
- (void)phohoItemChangeImage:(UIImage *)image
{
    self.thumbImage = image;
    self.moveImageView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
    
    self.moveImageView.frame = [self getOriginFrameWithImage:image];
    self.moveImageView.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    
    self.originFrame = self.moveImageView.frame;
    self.moveBeginFrame = self.moveImageView.frame;
    self.moveImageView.image = _thumbImage;
}

// 根据图片设置imageView的frame的size
- (CGRect)getOriginFrameWithImage:(UIImage *)image
{
//    UIImage *image = [UIImage imageNamed:imageName];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGFloat scale = [self getBigScaleWithHeight:height width:width];
    
    return CGRectMake(0, 0, width * scale, height * scale);
}

// 旋转后根据ImageView设置新的frame
- (CGRect)getTransformFrame
{
    CGFloat width = self.moveImageView.frame.size.width;
    CGFloat height = self.moveImageView.frame.size.height;
    CGFloat scale = [self getBigScaleWithHeight:height width:width];
    return CGRectMake(0, 0, width*scale, height*scale);
}

// 获取最大
- (CGFloat)getBigScaleWithHeight:(CGFloat)height width:(CGFloat)width
{
    CGFloat wScale = self.bounds.size.width / width;
    CGFloat hScale = self.bounds.size.height / height;
    CGFloat scale = 0;
    if (wScale >= hScale)
    {
        self.imageOrientation = PhotoViewImageOrientationPortrait;
        scale = wScale;
    }
    else
    {
        self.imageOrientation = PhotoViewImageOrientationLandscape;
        scale = hScale;
    }
    return scale;
}

// 限制图片的frame，不能有图片空白
- (CGRect)restrictTheMoveImageFrame
{
    CGRect frame = self.moveImageView.frame;
    
    if (-(frame.origin.x + frame.size.width < self.bounds.size.width))
    {
        frame.origin.x = -(self.moveImageView.frame.size.width - self.bounds.size.width);
    }
    else if (frame.origin.x > 0)
    {
        frame.origin.x = 0;
    }

    if (frame.origin.y + frame.size.height < self.bounds.size.height)
    {
        frame.origin.y = -(self.moveImageView.frame.size.height - self.bounds.size.height);
    }
    else if (frame.origin.y > 0)
    {
        frame.origin.y = 0;
    }
    
    return frame;
}

// 转换图片的scale
- (void)changeImageViewScale:(CGFloat)scale
{
    CGAffineTransform currentTransform = self.moveImageView.transform;
    CGAffineTransform transform = CGAffineTransformScale(currentTransform, scale, scale);
    self.moveImageView.transform = transform;

    CGRect frame = self.moveImageView.frame;
    if (frame.size.width / self.originFrame.size.width >3 || frame.size.width / self.originFrame.size.width < 1)
    {
        self.moveImageView.transform = currentTransform;
    }
}

- (void)changeImageViewTransform:(CGFloat)angle
{
    self.moveImageView.transform = CGAffineTransformRotate(self.moveImageView.transform, angle);
    self.moveImageView.frame = [self getTransformFrame];
    self.moveImageView.center= CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    self.originFrame = self.moveImageView.frame;
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

- (void)imageViewPinchMethod:(UIPinchGestureRecognizer *)pinchGesture
{
    static CGFloat lastScale = 1.0f;
    
    switch (pinchGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"UIGestureRecognizerStateBegan");
            lastScale = 1.0f;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            NSLog(@"UIGestureRecognizerStateChanged");
            CGFloat scale = pinchGesture.scale / lastScale;
            NSLog(@"%f", scale);
            [self changeImageViewScale:scale];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"UIGestureRecognizerStateEnded");
            [self resetImageFrame:[self restrictTheMoveImageFrame]];
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
    lastScale = [pinchGesture scale];
}

- (void)imageViewTapMethod:(UITapGestureRecognizer *)tapGesture
{
    if ([self.delegate respondsToSelector:@selector(photoItemTapGesture:)])
    {
        [self.delegate photoItemTapGesture:tapGesture];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
