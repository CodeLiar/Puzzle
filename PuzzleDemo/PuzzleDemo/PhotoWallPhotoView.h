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

@end

@interface PhotoWallPhotoView : UIView


@property (nonatomic, strong) NSString *moveImage;                      // 图片
@property (nonatomic, assign) id<PhotoWallPhotoViewDelegate> delegate;

- (instancetype)initWithPointScales:(NSArray *)pointsScales scaleSize:(CGSize)scaleSize image:(NSString *)image;

// 切换图片
- (void)phohoItemchangeImage:(NSString *)image;

// 判断点是否在改PhotoItem中
- (BOOL)isPointInThisPhotoItem:(CGPoint)point;

@end
