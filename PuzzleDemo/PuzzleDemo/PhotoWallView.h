//
//  PhotoWallView.h
//  PuzzleDemo
//
//  Created by Geass on 5/21/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoWallViewDelegate <NSObject>

- (void)photoWallViewTransferTapGesture:(UIGestureRecognizer *)gesture;

@end

@interface PhotoWallView : UIView

@property (nonatomic, strong) NSMutableArray *photoArray;

@property (nonatomic, assign) id<PhotoWallViewDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame jsonData:(NSDictionary *)jsonData puzzleCount:(NSInteger)puzzleCount;

- (instancetype) initWithFrame:(CGRect)frame jsonData:(NSDictionary *)jsonData photoArray:(NSMutableArray *)photoArray;

// 切换该模板数量
- (void)changePuzzleCount:(NSInteger)puzzleCount;


// MenuItem事件
// 切换图片
- (void)changePhotoItemImage:(UIImage *)image;
// 放大或缩小图片
- (void)changePhotoItemScaleZoomIn:(BOOL)zoom;

@end
