//
//  PhotoViewController.m
//  PuzzleDemo
//
//  Created by Geass on 5/22/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoWallView.h"


#define kUIScreenHeight  [UIScreen mainScreen].bounds.size.height
#define kUIScreenWidth   [UIScreen mainScreen].bounds.size.width

@interface PhotoViewController ()

@property (nonatomic, strong) NSString *sourceFile;
@property (nonatomic, assign) NSInteger sceneCount;
@property (nonatomic, strong) PhotoWallView * photoWallView;

@end

@implementation PhotoViewController

- (instancetype)initWithSourceFile:(NSString *)file count:(NSInteger)count
{
    self = [super init];
    if (self) {
        self.sourceFile = file;
        self.sceneCount = count;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    NSString *filePath;
    if (self.sceneCount == 3)
    {
        filePath = [[NSBundle mainBundle] pathForResource:@"PuzzleWall021" ofType:@"json"];
    }
    else
    {
        filePath = [[NSBundle mainBundle] pathForResource:@"PuzzleNote218" ofType:@"json"];

    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    CGFloat width = kUIScreenWidth - 20.0f;
    PhotoWallView *photoWallView = [[PhotoWallView alloc] initWithFrame:CGRectMake(10, 140, width, width) jsonData:dict puzzleCount:1];
    [self.view addSubview:photoWallView];
    self.photoWallView = photoWallView;
    
    for (int i=0; i<self.sceneCount; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((60+20)*i, 80, 60, 40)];
        btn.tag = i+1;
        [btn setTitle:[NSString stringWithFormat:@"切换 %d", i+1] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)buttonClick:(UIButton *)btn
{
    [self.photoWallView changePuzzleCount:btn.tag];
}

@end
