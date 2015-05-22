//
//  PhotoWallView.m
//  PuzzleDemo
//
//  Created by Geass on 5/21/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import "PhotoWallPhotoView.h"

@interface PhotoWallPhotoView ()

@property (nonatomic, strong) NSArray *pointsArray;
@property (nonatomic, assign) CGFloat scaleHeight;
@property (nonatomic, assign) CGFloat scaleWidth;
@property (nonatomic, strong) UIBezierPath *bezierPath;

@property (nonatomic, strong) UIImageView *moveImageView;
@property (nonatomic, strong) NSString *moveImage;

@property (nonatomic, assign) CGRect moveBeginFrame;
@property (nonatomic, assign) CGRect originFrame;

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
    self.moveImageView = [[UIImageView alloc] initWithFrame:self.bounds];
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
    return [self isPointInActiveRect:point];
}

// 切换图片
- (void)phohoItemchangeImage:(NSString *)image
{
    self.moveImageView.image = [UIImage imageNamed:image];
    [UIView animateWithDuration:0.25 animations:^{
        self.moveImageView.frame = self.originFrame;
    }];
}

- (BOOL)isPointInActiveRect:(CGPoint)point
{
    BOOL containted = [self.bezierPath containsPoint:point];
    return containted;
}

#pragma makr - GestureMoveMethod
- (void)imageViewPanMethod:(UIPanGestureRecognizer *)panGesture
{
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
            
            location = newLocation;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"UIGestureRecognizerStateEnded");
        }

            break;
            
        case UIGestureRecognizerStateFailed:
        {
            self.moveImageView.frame = self.moveBeginFrame;
            NSLog(@"UIGestureRecognizerStateFailed");
        }

            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            self.moveImageView.frame = self.moveBeginFrame;
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
