//
//  ViteUtilsInitializer.m
//  Action
//
//  Created by Stone on 2018/12/6.
//

#import "ViteUtilsInitializer.h"
#import <ViteUtils/ViteUtils-Swift.h>

@implementation ViteUtilsInitializer

+ (void)load
{
    [ViteUtilsLocalizationService ocSharedInstance];
}

@end
