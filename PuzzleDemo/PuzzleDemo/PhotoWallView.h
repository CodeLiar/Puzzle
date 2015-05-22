//
//  PhotoWallView.h
//  PuzzleDemo
//
//  Created by Geass on 5/21/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoWallView : UIView


- (instancetype)initWithFrame:(CGRect)frame jsonData:(NSDictionary *)jsonData puzzleCount:(NSInteger)puzzleCount;

// 切换该模板数量
- (void)changePuzzleCount:(NSInteger)puzzleCount;


@end
