//
//  UIView+Autolayout.m
//  Accordion
//
//  Created by bananadev on 19/02/14.
//  Copyright (c) 2014 bananadev. All rights reserved.
//

#import "UIView+Autolayout.h"

@implementation UIView (Autolayout)
+(id)autolayoutView
{
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}
@end
