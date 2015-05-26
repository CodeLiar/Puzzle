//
//  RootViewController.m
//  PuzzleDemo
//
//  Created by Geass on 15-2-27.
//  Copyright (c) 2015年 Geass. All rights reserved.
//

#import "RootViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoViewController.h"

@interface RootViewController ()

@property (nonatomic, strong) LKAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) ALAssetsLibrary *sysLibrary;


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
    for (int i=0; i<2; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, (50+100)*i + 100, 100, 100)];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i + 3;
        [btn setTitle:[NSString stringWithFormat:@"第%d种场景", i+1] forState:UIControlStateNormal];
        [self.view addSubview:btn];
    }
    
}

- (void)btnClick:(UIButton *)sender
{
    PhotoViewController *vc = [[PhotoViewController alloc] initWithSourceFile:nil count:sender.tag];
    vc.photoArray = self.photoArray;
    [self.navigationController pushViewController:vc animated:YES];
}



@end
