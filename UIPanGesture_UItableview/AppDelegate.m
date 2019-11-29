//
//  AppDelegate.m
//  UIPanGesture_UItableview
//
//  Created by 唐蒙波 on 2019/11/29.
//  Copyright © 2019 Meng. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    ViewController *VC = [[ViewController alloc] init];
    self.window.rootViewController = VC;
    return YES;
}





@end
