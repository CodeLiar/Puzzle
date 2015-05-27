//
//  PhotoWallView.h
//  PuzzleDemo
//
//  Created by Geass on 5/21/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoWallPhotoViewDelegate <NSObject>

- (void)photoItemMoveGesture:(UIPanGestureRecognizer *)panGesture;
- (void)photoItemTapGesture:(UITapGestureRecognizer *)tipGesture;

@end

@interface PhotoWallPhotoView : UIView


@property (nonatomic, strong) NSString *moveImage;                      // 图片
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, assign) id<PhotoWallPhotoViewDelegate> delegate;
@property (nonatomic, assign) BOOL isSelected;

- (instancetype)initWithPointScales:(NSArray *)pointsScales scaleSize:(CGSize)scaleSize image:(UIImage *)image;

// 切换图片
- (void)phohoItemChangeImage:(UIImage *)image;

// 判断点是否在改PhotoItem中
- (BOOL)isPointInThisPhotoItem:(CGPoint)point;

- (void)changeImageViewScale:(CGFloat)scale;

- (void)changeImageViewTransform:(CGFloat)angle;

@end
