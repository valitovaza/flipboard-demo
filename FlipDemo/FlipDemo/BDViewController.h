//
//  BDViewController.h
//  FlipDemo
//
//  Created by bananadev on 21/02/14.
//  Copyright (c) 2014 bananadev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDViewController : UIViewController<UIGestureRecognizerDelegate>
- (IBAction)openUrl:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonWiki;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
- (IBAction)showSecondWay:(id)sender;

@end
