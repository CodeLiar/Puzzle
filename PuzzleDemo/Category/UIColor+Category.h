//
//  wiUIColor.h
//  wiIos
//
//  Created by qq on 12-1-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (id) colorWithHex:(unsigned int)hex;
+ (id) colorWithHex:(unsigned int)hex alpha:(CGFloat)alpha;
+ (UIColor *) colorWithHexString:(NSString *)stringToConvert;

@end
