//
//  BDSecondViewController.h
//  FlipDemo
//
//  Created by bananadev on 25/02/14.
//  Copyright (c) 2014 bananadev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDSecondViewController : UIViewController<UIGestureRecognizerDelegate>

- (IBAction)closeViewController:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonWiki;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
- (IBAction)openInfo:(id)sender;

@end
