//
//  ViewController.m
//  Snake
//
//  Created by work on 6/1/17.
//  Copyright © 2017 GlucoSavvy. All rights reserved.
//

#import "ViewController.h"

static NSUInteger defaultSize = 10;

@interface ViewController ()

@property (nonatomic) UIView *newGameFieldView;
@property (nonatomic) UIView *ballView;
@property (nonatomic) NSTimer *ballTimer;
@property (nonatomic) NSMutableArray<UIView *> *snakeViews;

@property (nonatomic) UISwipeGestureRecognizerDirection direction;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    
    _direction = UISwipeGestureRecognizerDirectionRight;
    
    // Background color
    [self.view setBackgroundColor:[UIColor greenColor]];

    
    // Game view
    [self .view addSubview:[self newGameFieldView]];
    
    // Snake
    UIView *snakeHead = [self newSnakeHeadView];
    [self.view addSubview:snakeHead];
    
    _snakeViews = [NSMutableArray array];
    [_snakeViews addObject:snakeHead];
    
    // Ball
    [self  updateNewBallView];
    
    _ballTimer = [NSTimer timerWithTimeInterval:0.20 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        [self updateSnakeLocation];
    }];
    
    
    // Tap recognizer
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasSwiped:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasSwiped:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasSwiped:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasSwiped:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    [self.view addGestureRecognizer:swipeUp];
    [self.view addGestureRecognizer:swipeDown];
    
    [[NSRunLoop currentRunLoop] addTimer:_ballTimer forMode:NSRunLoopCommonModes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_ballTimer invalidate];
}


#pragma mark - Game Field View

- (UIView *)newGameFieldView
{
    if (_newGameFieldView) {
        return _newGameFieldView;
    }
    
    CGFloat viewWidth = self.view.frame.size.width;     // 375
    CGFloat viewHeight = self.view.frame.size.height;   // 672
    
    int borderX = (int)viewWidth % defaultSize;
    int borderY = (int)viewHeight  % defaultSize;
    
    CGFloat xMin = borderX / 2;
    CGFloat xMax = borderX - xMin;
    CGFloat width = viewWidth - xMax - xMin;
    
    CGFloat yMin = borderY / 2;
    CGFloat yMax = borderY - yMin;
    CGFloat height = viewHeight - yMax - yMin;
    
    xMin += defaultSize;
    width -= 2 * defaultSize;

    yMin += defaultSize;
    height -= (2 * defaultSize);
    
    _newGameFieldView = [[UIView alloc] initWithFrame:CGRectMake(xMin, yMin, width, height)];
    [_newGameFieldView setBackgroundColor:[UIColor redColor]];
    
    return _newGameFieldView;
}

#pragma mark - Snake Head View

- (UIView *)newSnakeHeadView
{
    CGFloat xMin = self.newGameFieldView.frame.origin.x + defaultSize;
    CGFloat yMin = self.newGameFieldView.frame.origin.y + defaultSize;
    
    UIView *sqaureView = [[UIView alloc] initWithFrame:CGRectMake(xMin, yMin, defaultSize, defaultSize)];
    [sqaureView setBackgroundColor:[UIColor blueColor]];
    return sqaureView;
}

#pragma mark - Ball view

- (void)updateNewBallView
{
    CGFloat xMin = self.newGameFieldView.frame.origin.x + defaultSize;
    CGFloat yMin = self.newGameFieldView.frame.origin.y + defaultSize;
    
    int scaleX = self.newGameFieldView.frame.size.width / defaultSize;
    
    int scaleY = self.newGameFieldView.frame.size.height / defaultSize;
    
    CGFloat randomX = arc4random_uniform(scaleX) * defaultSize + xMin;
    CGFloat randomY = arc4random_uniform(scaleY) * defaultSize + yMin;
    
    self.ballView = [[UIView alloc] initWithFrame:CGRectMake(randomX, randomY, defaultSize, defaultSize)];
    [self.ballView setBackgroundColor:[UIColor yellowColor]];
    [self.view addSubview:self.ballView];
}

#pragma mark - View Swiped

- (void)viewWasSwiped:(UISwipeGestureRecognizer *)sender
{
    self.direction = sender.direction;
}

- (UIView *)headOfSnake
{
    return [self.snakeViews lastObject];
}

- (void)updateSnakeLocation
{
    UIView *snakeView = [self headOfSnake];
    CGPoint snakeOrigin = snakeView.frame.origin;
    
    CGFloat snakeXPoint = snakeOrigin.x;
    CGFloat snakeYPoint = snakeOrigin.y;
    
//    NSLog(@"P: %@ - Q: %@", @(snakeXPoint), @(snakeYPoint));
    
    // Check if we hit the borders
    if ([self snakeHitTheWallWithPointX:snakeXPoint pointY:snakeYPoint]) {
        NSLog(@"Hit the wall");
        [[self  ballTimer] invalidate];
        [self alertWithMessage:@"Hit the wall!" type:0];
    }
    
    // Check of we hit the ball
    if ([self snakeHitTheBallWithFrame:snakeView.frame]) {
        [self eatTheBall];
        [self  updateNewBallView];
    }
    
    // Right of the snake
    switch (self.direction) {
        case UISwipeGestureRecognizerDirectionRight:    snakeXPoint += defaultSize;  break;
        case UISwipeGestureRecognizerDirectionLeft:     snakeXPoint -= defaultSize;  break;
        case UISwipeGestureRecognizerDirectionUp:       snakeYPoint -= defaultSize;  break;
        case UISwipeGestureRecognizerDirectionDown:     snakeYPoint += defaultSize;  break;
        default:                                                                     break;
    }
    
    // Update all snake views
    for (int i = 0; i < self.snakeViews.count - 1; i++) {
        
        UIView *view = [self.snakeViews objectAtIndex:i];
        UIView *nextView = [self.snakeViews objectAtIndex:i+1];
        view.frame = nextView.frame;
    }
    
    // Update snake head
    CGRect frame = snakeView.frame;
    frame.origin = CGPointMake(snakeXPoint, snakeYPoint);
    snakeView.frame = frame;
}

- (void)eatTheBall
{
    // Ball view will be the new head
    [self.ballView setBackgroundColor:[UIColor blueColor]];
    [self.snakeViews addObject:self.ballView];
}


#pragma mark - Snake Hitting the Ball

- (BOOL)snakeHitTheBallWithFrame:(CGRect)frame
{
    // Snake location
    CGFloat xMin = frame.origin.x;
    CGFloat yMin = frame.origin.y;
    
    CGFloat xMax = xMin + frame.size.width;
    CGFloat yMax = yMin + frame.size.height;
    
    // Ball location
    CGFloat ballXMin = _ballView.frame.origin.x;
    CGFloat ballYMin = _ballView.frame.origin.y;
    
    CGFloat ballXMax = ballXMin + _ballView.frame.size.width;
    CGFloat ballYMax = ballYMin + _ballView.frame.size.height;
    
    NSLog(@"P: %@ - Q: %@", @(xMin), @(yMin));
    NSLog(@"X: %@ - Y: %@", @(ballXMin), @(ballYMin));
    
    if (ballXMin >= xMin && ballXMax <= xMax && ballYMin >= yMin && ballYMax <= yMax) {
        NSLog(@"Hit the ball");
        return YES;
    }
    
    return NO;
}

#pragma mark - Snake Hitting the Wall

- (BOOL)snakeHitTheWallWithPointX:(CGFloat)x pointY:(CGFloat)y
{
    CGFloat gameXMin = _newGameFieldView.frame.origin.x;
    CGFloat gameYMin = _newGameFieldView.frame.origin.y;
    
    CGFloat gameXMax = gameXMin + _newGameFieldView.frame.size.width;
    CGFloat gameYMax = gameYMin + _newGameFieldView.frame.size.height;
    
    if (x <= gameXMin || y <= gameYMin || x >= gameXMax || y >= gameYMax) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Alert Message

- (void)alertWithMessage:(NSString *)message type:(NSUInteger)alertType
{
    NSString *title = alertType == 0 ? @"You Lost!" : @"You Won!";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Restart" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSLog(@"Restarting the game");
    
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
