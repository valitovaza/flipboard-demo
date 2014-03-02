//
//  BDSecondViewController.m
//  FlipDemo
//
//  Created by bananadev on 25/02/14.
//  Copyright (c) 2014 bananadev. All rights reserved.
//

//  This controller shows how to use duplicated view for 'flip animation'
//  Method solve diffuse image problem showed in BDViewController

#import "BDSecondViewController.h"
#import "UIView+Autolayout.h"

@interface BDSecondViewController (){
    UIView *_duplicateView;
}

@end

@implementation BDSecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panRecognizer.maximumNumberOfTouches = 1;
    panRecognizer.delegate = self;
    panRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:panRecognizer];
}
-(void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    //cancel button touching
    [self.buttonWiki cancelTrackingWithEvent:nil];
    [self.buttonNext cancelTrackingWithEvent:nil];

    CGPoint translation = [gestureRecognizer translationInView:self.view];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        //stateBegan
        _duplicateView.hidden = NO;
    }
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled){
        //flip up or down
        CATransform3D transform3d = CATransform3DMakeRotation(0, 1.0, 0.0, 0.0);
        [UIView animateWithDuration:0.3 animations:^{
            _duplicateView.layer.transform = transform3d;
            self.view.userInteractionEnabled = NO;
        }completion:^(BOOL finished){
            _duplicateView.hidden = YES;
            self.view.userInteractionEnabled = YES;
        }];
        return;
    }
    //NSLog(@"∆Y : %f",translation.y);
    float maxYdiff = 100.f; // == M_PI
    float angle = 0;
    if (translation.y > 0) {
        angle = translation.y > maxYdiff ? -M_PI + 0.001f : (-M_PI + 0.001f) * translation.y / maxYdiff;
    }else{
        translation.y = fabs(translation.y);
        angle = translation.y > maxYdiff ? M_PI - 0.001f : (M_PI - 0.001f) * translation.y / maxYdiff;
    }
    NSLog(@"angle : %f",angle);
    CATransform3D transform3d = CATransform3DMakeRotation(angle, 1.0, 0.0, 0.0);
    _duplicateView.layer.transform = transform3d;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _duplicateView = [UIView autolayoutView];
    _duplicateView.backgroundColor = [UIColor whiteColor];

    NSMutableDictionary *equivalentDict = [[NSMutableDictionary alloc] init];
    //copy all subviews
    for (UIView *subview in self.view.subviews) {
        NSData *subviewArchive = [NSKeyedArchiver archivedDataWithRootObject:subview];
        UIView *duplicatedSubview = nil;
        if ([subview conformsToProtocol:@protocol(UILayoutSupport)]) {
            duplicatedSubview = [UIView autolayoutView];
            [_duplicateView addSubview:duplicatedSubview];

            //set the lenght of the UILayout View
            // Get the views dictionary
            NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(duplicatedSubview);

            //metrics
            NSDictionary *metrics = @{@"height":[NSNumber numberWithFloat:[((id<UILayoutSupport>)subview) length]]};

            //Create the constraints using the visual language format
            NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[duplicatedSubview(height)]" options:NSLayoutFormatAlignAllBaseline metrics:metrics views:viewsDictionary];
            [_duplicateView addConstraints:constraintsArray];

            [equivalentDict setObject:_duplicateView forKey:[subview description]];
        }else{
            duplicatedSubview = [NSKeyedUnarchiver unarchiveObjectWithData:subviewArchive];
            [_duplicateView addSubview:duplicatedSubview];
        }
        [equivalentDict setObject:duplicatedSubview forKey:[subview description]];
    }
    [equivalentDict setObject:_duplicateView forKey:[self.view description]];

    //make constraints for new view and its subviews
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if ([equivalentDict objectForKey:[constraint.firstItem description]] && [equivalentDict objectForKey:[constraint.secondItem description]]) {
            NSLayoutConstraint *duplicateConstraint = [NSLayoutConstraint constraintWithItem:[equivalentDict objectForKey:[constraint.firstItem description]] attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:[equivalentDict objectForKey:[constraint.secondItem description]] attribute:constraint.secondAttribute multiplier:constraint.multiplier constant:constraint.constant];
            [_duplicateView addConstraint:duplicateConstraint];
        }
    }
    //

    [self.view addSubview:_duplicateView];

    // Get the views dictionary
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_duplicateView);

    //Create the constraints using the visual language format
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"|[_duplicateView]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewsDictionary];
    [self.view addConstraints:constraintsArray];

    NSArray *verticalConstraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_duplicateView]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewsDictionary];
    [self.view addConstraints:verticalConstraintsArray];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)openInfo:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://en.wikipedia.org/wiki/Salawat_Yulayev"]];
}
@end
