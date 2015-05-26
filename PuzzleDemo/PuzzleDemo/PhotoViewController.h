//
//  PhotoViewController.h
//  PuzzleDemo
//
//  Created by Geass on 5/22/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *photoArray;

- (instancetype)initWithSourceFile:(NSString *)file count:(NSInteger)count;

@end
