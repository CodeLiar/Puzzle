//
//  PhotoWallView.h
//  PuzzleDemo
//
//  Created by Geass on 5/21/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoWallPhotoView : UIView

- (instancetype)initWithPointScales:(NSArray *)pointsScales scaleSize:(CGSize)scaleSize image:(NSString *)image;

// 切换图片
- (void)phohoItemchangeImage:(NSString *)image;
// 判断某个点是否在View中
- (BOOL)isPointInActiveRect:(CGPoint)point;

@end
