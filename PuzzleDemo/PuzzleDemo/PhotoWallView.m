//
//  PhotoWallView.m
//  PuzzleDemo
//
//  Created by Geass on 5/21/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import "PhotoWallView.h"
#import "PhotoWallPhotoView.h"

@interface PhotoWallView ()

@property (nonatomic, strong) NSDictionary *jsonData;               // 拼图数据Json
@property (nonatomic, strong) NSArray *pointScalesArray;
@property (nonatomic, assign) NSInteger puzzleCount;                // 拼图数量
@property (nonatomic, strong) NSString *puzzleIndex;                // 根据拼图数量选择对应数量的模板
@property (nonatomic, strong) NSString *coverImage;

// TODO: 删除
@property (nonatomic, strong) NSArray *demoImageArray;

@end

@implementation PhotoWallView

- (instancetype)initWithFrame:(CGRect)frame jsonData:(NSDictionary *)jsonData puzzleCount:(NSInteger)puzzleCount
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        self.demoImageArray = @[@"PuzzleNote218thumb1.jpg", @"PuzzleNote218thumb2.jpg", @"PuzzleNote218thumb3.jpg", @"PuzzleNote218thumb4.jpg"];

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
    [self createAllPhotoItem];
    [self createCoverImageView];
}

- (void)resetView
{
    for (int i=0; i<self.subviews.count; i++)
    {
        UIView *subView = self.subviews[i];
        [subView removeFromSuperview];
    }
    [self setupView];
}

- (void)analyseJsonData
{
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
        PhotoWallPhotoView *photoItem = [[PhotoWallPhotoView alloc] initWithPointScales:pointScales scaleSize:self.frame.size image:self.demoImageArray[i]];
        photoItem.backgroundColor = [UIColor redColor];
        [self addSubview:photoItem];
    }
}

- (void)createCoverImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:imageView];
    imageView.image = [UIImage imageNamed:self.coverImage];
}



@end
