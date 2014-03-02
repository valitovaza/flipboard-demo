//
//  BDViewController.m
//  FlipDemo
//
//  Created by bananadev on 21/02/14.
//  Copyright (c) 2014 bananadev. All rights reserved.
//

//  This controller shows how to use images for 'flip animation'
//  Method has a problem - diffuse image if you use UILabel, UIBUtton and ect

#import "BDViewController.h"
#import "BDSecondViewController.h"

@interface BDViewController (){
    UIImageView *_topImageView;
    UIImageView *_bottomImageView;
    UIImageView *_selectedImageView;
}

@end

@implementation BDViewController
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //create 2 images
    //top and bottom
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //screenshot
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //slpit screenshot
    CGImageRef tmpImgRef = image.CGImage;
    CGImageRef topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 0, image.size.width, image.size.height / 2.0));
    UIImage *topImage = [UIImage imageWithCGImage:topImgRef];
    CGImageRelease(topImgRef);

    CGImageRef bottomImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, image.size.height / 2.0,  image.size.width, image.size.height / 2.0));
    UIImage *bottomImage = [UIImage imageWithCGImage:bottomImgRef];
    CGImageRelease(bottomImgRef);

    //add UIImageViews
    _topImageView = [[UIImageView alloc] initWithImage:topImage];
    [_topImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_topImageView];
    _bottomImageView = [[UIImageView alloc] initWithImage:bottomImage];
    [_bottomImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_bottomImageView];

    //add NSLayoutConstraints
    // Get the views dictionary
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_topImageView, _bottomImageView);

    //metrics
    NSDictionary *metrics = @{@"contentHeight":[NSNumber numberWithFloat:self.view.frame.size.height / 2], @"topSpace":[NSNumber numberWithFloat: _topImageView.frame.size.height / 2], @"bottomSpace":[NSNumber numberWithFloat: _topImageView.frame.size.height - _bottomImageView.frame.size.height / 2]};

    //Create the constraints using the visual language format
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"|[_topImageView]|" options:NSLayoutFormatAlignAllBaseline metrics:metrics views:viewsDictionary];
    [self.view addConstraints:constraintsArray];
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"|[_bottomImageView]|" options:NSLayoutFormatAlignAllBaseline metrics:metrics views:viewsDictionary];
    [self.view addConstraints:constraintsArray];

    NSArray *verticalConstraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topSpace-[_topImageView(contentHeight)]" options:0 metrics:metrics views:viewsDictionary];
    [self.view addConstraints:verticalConstraintsArray];
    verticalConstraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-bottomSpace-[_bottomImageView(contentHeight)]" options:0 metrics:metrics views:viewsDictionary];
    [self.view addConstraints:verticalConstraintsArray];

    //set UIImageViews anchor points
    _topImageView.layer.anchorPoint = CGPointMake(0.5f, 1.f);
    _bottomImageView.layer.anchorPoint = CGPointMake(0.5f, 0.f);
    [self.view layoutIfNeeded];

    //Getting some perspective
    CATransform3D aTransform = CATransform3DIdentity;
    float zDistance = 1000;
    aTransform.m34 = 1.0 / -zDistance;
    self.view.layer.sublayerTransform = aTransform;

    //hide images until flip
    _topImageView.hidden = YES;
    _bottomImageView.hidden = YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        //stateBegan
        if (velocity.y > 0) {
            //flip down
            _selectedImageView = _topImageView;
        }else{
            //flip up
            _selectedImageView = _bottomImageView;
        }
        _topImageView.hidden = NO;
        _bottomImageView.hidden = NO;
    }
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled){
        //flip up or down
        //depends on selectedImageView
        CATransform3D transform3d = CATransform3DMakeRotation(0, 1.0, 0.0, 0.0);
        [UIView animateWithDuration:0.3 animations:^{
            _selectedImageView.layer.transform = transform3d;
            self.view.userInteractionEnabled = NO;
        }completion:^(BOOL finished){
            _topImageView.hidden = YES;
            _bottomImageView.hidden = YES;
            self.view.userInteractionEnabled = YES;
        }];
        _selectedImageView = nil;
        return;
    }
    //rotate UIImageViews
    //NSLog(@"∆Y : %f",translation.y);
    if (_selectedImageView) {
        float maxYdiff = 100.f; // == M_PI
        float angle = 0;
        if (translation.y > 0) {
            angle = translation.y > maxYdiff ? -M_PI + 0.001f : (-M_PI + 0.001f) * translation.y / maxYdiff;
        }else{
            translation.y = fabs(translation.y);
            angle = translation.y > maxYdiff ? M_PI - 0.001f : (M_PI - 0.001f) * translation.y / maxYdiff;
        }
        if ((_selectedImageView == _topImageView && angle > 0) || (_selectedImageView == _bottomImageView && angle < 0)) {
            angle = 0;
        }
        NSLog(@"angle : %f",angle);
        CATransform3D transform3d = CATransform3DMakeRotation(angle, 1.0, 0.0, 0.0);
        _selectedImageView.layer.transform = transform3d;
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openUrl:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://en.wikipedia.org/wiki/Salawat_Yulayev"]];
}
- (IBAction)showSecondWay:(id)sender {
    BDSecondViewController *secondViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"SecondViewController"];
    secondViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:secondViewController animated:YES completion:nil];
}
@end
