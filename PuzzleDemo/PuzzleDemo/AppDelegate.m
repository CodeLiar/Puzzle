//
//  AppDelegate.m
//  PuzzleDemo
//
//  Created by Geass on 15-2-27.
//  Copyright (c) 2015年 Geass. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

@interface AppDelegate ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) ALAssetsLibrary *library;
@property (nonatomic, strong) UIView *imageSelectView;
@property (nonatomic, strong) NSMutableArray *imageArray;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
#if 0
    
#else
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    self.window.rootViewController = picker;
    self.library = [[ALAssetsLibrary alloc] init];
#endif
    
    self.imageArray = [NSMutableArray array];
    [self createImageSelectView];
    
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)createImageSelectView
{
    self.imageSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 400, [UIScreen mainScreen].bounds.size.width, 200)];
    [self.window addSubview:self.imageSelectView];
    self.imageSelectView.backgroundColor = [UIColor greenColor];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.imageSelectView.frame.size.width - 100, 0, 80, 40)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"下一步" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.imageSelectView addSubview:btn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    label.text = @"最多添加三张图片";
    [self.imageSelectView addSubview:label];
}

- (void)nextBtnClick
{
    [self.imageSelectView removeFromSuperview];
    
    RootViewController *rootVC = [[RootViewController alloc] init];
    rootVC.photoArray = [_imageArray mutableCopy];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    self.window.rootViewController = nc;}

- (void)addSelectItem:(UIImage *)image
{
    [self.imageArray addObject:image];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100*(self.imageArray.count-1), 50, 90, 90)];
    imageView.image = image;
    [self.imageSelectView addSubview:imageView];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - UIImagePickerDelegate
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    [self.library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        UIImage *preview = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
        if (preview)
        {
            [self addSelectItem:preview];
        }
        else
        {
            [self addSelectItem:image];
        }
        
        [self.window bringSubviewToFront:self.imageSelectView];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"Failed to get asset from library");
    }];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cancel"
                                                    message:@"Nowhere to go my friend. This is a demo."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles: nil];
    [alert show];
}

@end
