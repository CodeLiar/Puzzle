//
//  RootViewController.m
//  PuzzleDemo
//
//  Created by Geass on 15-2-27.
//  Copyright (c) 2015年 Geass. All rights reserved.
//

#import "RootViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoWallView.h"

#define kUIScreenHeight  [UIScreen mainScreen].bounds.size.height
#define kUIScreenWidth   [UIScreen mainScreen].bounds.size.width

@interface RootViewController ()

@property (nonatomic, strong) LKAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) ALAssetsLibrary *sysLibrary;

@property (nonatomic, strong) PhotoWallView * photoWallView;

@end

@implementation RootViewController
#if 0
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_assetsLibraryDidSetup:)
                                                 name:LKAssetsLibraryDidSetupNotification
                                               object:nil];
    self.assetsLibrary = [LKAssetsLibrary assetsLibrary];
    [self.assetsLibrary reload];
}

- (void)_assetsLibraryDidSetup:(NSNotification *)notification
{
    NSLog(@"self.assetsLibrary %@", self.assetsLibrary.assetsGroups);
    
    LKAssetsGroup *assetsGroup = self.assetsLibrary.assetsGroups[0];
    NSLog(@"assetsGroup %@", assetsGroup);
    NSLog(@"%ld", (long)assetsGroup.assets.count);
    
    for (LKAsset *asset in assetsGroup.assets) {
        NSLog(@"----> %@", asset);
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sysLibrary = [[ALAssetsLibrary alloc] init];
    
    dispatch_queue_t dispatchQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^(void) {
        // 遍历所有相册
        [self.sysLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                              // 遍历每个相册中的项ALAsset
              [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index,BOOL *stop) {
                  
                  // ALAsset的类型
                  NSString *assetType = [result valueForProperty:ALAssetPropertyType];
                  if ([assetType isEqualToString:ALAssetTypePhoto]){
                      ALAssetRepresentation *assetRepresentation =[result defaultRepresentation];
                      CGFloat imageScale = [assetRepresentation scale];
                      UIImageOrientation imageOrientation = (UIImageOrientation)[assetRepresentation orientation];
                      dispatch_async(dispatch_get_main_queue(), ^(void) {
                          CGImageRef imageReference = [assetRepresentation fullResolutionImage];
                          // 对找到的图片进行操作
                          UIImage *image =[[UIImage alloc] initWithCGImage:imageReference scale:imageScale orientation:imageOrientation];
                          if (image != nil){
                              NSLog(@"%@", image);
                          } else {
                              NSLog(@"Failed to create the image.");
                          } });
                  }
              }];
          }
        failureBlock:^(NSError *error) {
            NSLog(@"Failed to enumerate the asset groups.");
        }];
        
    });
}
#endif

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    NSLog(@"%s", __FUNCTION__);
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PuzzleNote218" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    CGFloat width = kUIScreenWidth - 20.0f;
    PhotoWallView *photoWallView = [[PhotoWallView alloc] initWithFrame:CGRectMake(10, 100, width, width) jsonData:dict puzzleCount:3];
    [self.view addSubview:photoWallView];
    self.photoWallView = photoWallView;
    
    for (int i=0; i<4; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((60+20)*i, 20, 60, 40)];
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
