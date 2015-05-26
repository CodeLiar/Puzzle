//
//  PhotoViewController.m
//  PuzzleDemo
//
//  Created by Geass on 5/22/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoWallView.h"
#import <AssetsLibrary/AssetsLibrary.h>


#define kUIScreenHeight  [UIScreen mainScreen].bounds.size.height
#define kUIScreenWidth   [UIScreen mainScreen].bounds.size.width

@interface PhotoViewController () <PhotoWallViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSString *sourceFile;
@property (nonatomic, assign) NSInteger sceneCount;
@property (nonatomic, strong) PhotoWallView * photoWallView;

@property (nonatomic, strong) ALAssetsLibrary *library;

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
    PhotoWallView *photoWallView = [[PhotoWallView alloc] initWithFrame:CGRectMake(10, 140, width, width) jsonData:dict photoArray:self.photoArray];
    photoWallView.delegate = self;
    [self.view addSubview:photoWallView];
    self.photoWallView = photoWallView;
    
    self.library = [[ALAssetsLibrary alloc] init];
    
    for (int i=0; i<self.sceneCount; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((60+20)*i, 80, 60, 40)];
        btn.tag = i+1;
        [btn setTitle:[NSString stringWithFormat:@"切换 %d", i+1] forState:UIControlStateNormal];
//        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)photoWallViewTransferTapGesture:(UIGestureRecognizer *)gesture
{
    [gesture.view becomeFirstResponder];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *menuItem_1 = [[UIMenuItem alloc] initWithTitle:@"相册" action:@selector(item1Click)];//@selector()括号中为该按钮触发的方法，该方法必须在UIVIewContrller中进行声明，就是投向的view所绑定的viewController类中必须实现这个方法
    UIMenuItem *menuItem_2 = [[UIMenuItem alloc] initWithTitle:@"+" action:@selector(item2Click)];
    UIMenuItem *menuItem_3 = [[UIMenuItem alloc] initWithTitle:@"-" action:@selector(item3Click)];
    
    menuController.menuItems = [NSArray arrayWithObjects: menuItem_1, menuItem_2,menuItem_3,nil];
    [menuController setTargetRect:gesture.view.frame inView:gesture.view.superview];
    [menuController setMenuVisible:YES animated:YES];
}

- (void)item1Click
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)item2Click
{
    [self.photoWallView changePhotoItemScaleZoomIn:YES];
}

- (void)item3Click
{
    [self.photoWallView changePhotoItemScaleZoomIn:NO];
}

- (void)buttonClick:(UIButton *)btn
{
    [self.photoWallView changePuzzleCount:btn.tag];
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
            [self.photoWallView changePhotoItemImage:preview];
        }
        else
        {
            [self.photoWallView changePhotoItemImage:image];
        }
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    } failureBlock:^(NSError *error) {
        NSLog(@"Failed to get asset from library");
    }];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
