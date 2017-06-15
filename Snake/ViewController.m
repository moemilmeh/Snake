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

@property (nonatomic) UITextField *scoreView;
@property (nonatomic) UITextField *levelView;

@property (nonatomic) UISwipeGestureRecognizerDirection direction;

@property (nonatomic) NSUInteger score;
@property (nonatomic) NSUInteger level;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    
    // Background color
    [self.view setBackgroundColor:[UIColor greenColor]];

    // Game view
    [self newGameFieldView];

    // Draw vertical grid lines
    [self addVerticalGridLinesWithLineWidth:0.17f];
    
    // Draw horizontal grid lines
    [self addHorizontalGridLinesWithLineWidth:0.17f];
    
    // Start the game
    [self startGame];
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_ballTimer invalidate];
}

- (void)startGame
{
    // Remove existing views
    for (UIView *view in self.snakeViews) {
        [view removeFromSuperview];
    }
    
    if (self.ballView) {
        [self.ballView removeFromSuperview];
    }
    
    _score = 0;
    _level = 1;
    
    self.scoreView.text = [NSString stringWithFormat:@"%@", @(_score)];
    self.levelView.text = [NSString stringWithFormat:@"%@", @(_level)];
    
    [self setDirection:UISwipeGestureRecognizerDirectionRight];
    [self setSnakeViews:[NSMutableArray array]];
    
    // Snake
    CGFloat xMin = self.newGameFieldView.frame.origin.x + defaultSize;
    CGFloat yMin = self.newGameFieldView.frame.origin.y + defaultSize;
    
    UIView *sqaureView = [[UIView alloc] initWithFrame:CGRectMake(xMin, yMin, defaultSize, defaultSize)];
    [sqaureView setBackgroundColor:[UIColor greenColor]];
    [sqaureView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    sqaureView.layer.borderWidth = 0.50f;
    [self.view addSubview:sqaureView];

    [self.snakeViews addObject:sqaureView];
    
    // Ball
    [self  updateNewBallView];
    
    [self updateTime:0.25];
}

- (void)updateTime:(NSTimeInterval)interval
{
    _ballTimer = [NSTimer timerWithTimeInterval:interval repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        [self updateSnakeLocation];
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:_ballTimer forMode:NSRunLoopCommonModes];
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
    
    // Game + Scoreboard view
    CGFloat height = viewHeight - yMax - yMin;
    
    xMin += defaultSize;
    width -= 2 * defaultSize;
    
    yMin += defaultSize;
    
    CGFloat scoreboardHeight = 6 * defaultSize;
    
    // Scoreboard
    UIView *scoreBoard = [[UIView alloc] initWithFrame:CGRectMake(xMin, yMin, width, scoreboardHeight)];
    
    [scoreBoard setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:scoreBoard];
    
    // Score View
    UITextField *scoreTextField = [[UITextField alloc] initWithFrame:CGRectMake(scoreBoard.bounds.origin.x, scoreBoard.bounds.origin.y,
                                                                                width / 2, scoreboardHeight / 2)];
    [scoreTextField setBackgroundColor:[UIColor orangeColor]];
    scoreTextField.text = @"Score: ";
    [scoreBoard addSubview:scoreTextField];
    
    _scoreView = [[UITextField alloc] initWithFrame:CGRectMake(scoreTextField.frame.origin.x + scoreTextField.frame.size.width,
                                                               scoreTextField.frame.origin.y, width / 2, scoreboardHeight / 2)];
    
    _scoreView.textAlignment = NSTextAlignmentCenter;
    [_scoreView setBackgroundColor:[UIColor redColor]];
    [scoreBoard addSubview:_scoreView];
    
    // Level View
    UITextField *levelTextField = [[UITextField alloc] initWithFrame:CGRectMake(scoreBoard.bounds.origin.x, scoreBoard.bounds.origin.y + scoreTextField.bounds.size.height, scoreTextField.bounds.size.width, scoreTextField.bounds.size.height)];
    [levelTextField setBackgroundColor:[UIColor yellowColor]];
    levelTextField.text = @"Level: ";
    [scoreBoard addSubview:levelTextField];

    _levelView = [[UITextField alloc] initWithFrame:CGRectMake(levelTextField.frame.origin.x + levelTextField.frame.size.width,
                                                               levelTextField.frame.origin.y, width / 2, scoreboardHeight / 2)];
    
    _levelView.textAlignment = NSTextAlignmentCenter;
    [_levelView setBackgroundColor:[UIColor blueColor]];
    [scoreBoard addSubview:_levelView];
    
    CGFloat gameYMin = yMin + scoreboardHeight;
    
    
    CGFloat gameHeight = height - scoreboardHeight;
    gameHeight -= (2 * defaultSize);
    
    _newGameFieldView = [[UIView alloc] initWithFrame:CGRectMake(xMin, gameYMin, width, gameHeight)];
    [_newGameFieldView setBackgroundColor:[UIColor blackColor]];
    
    [self.view addSubview:_newGameFieldView];
    
    return _newGameFieldView;
}

- (void)addVerticalGridLinesWithLineWidth:(CGFloat)lineWidth
{
    CGFloat xMin = self.newGameFieldView.frame.origin.x;
    CGFloat yMin = self.newGameFieldView.frame.origin.y;
    
    CGFloat height = self.newGameFieldView.frame.size.height;
    CGFloat width  = self.newGameFieldView.frame.size.width;
    
    // Draw grid line
    int x = xMin + width;
    while (x > xMin) {
        
        UIView *gridLine = [[UIView alloc] initWithFrame:CGRectMake(x, yMin, lineWidth, height)];
        [gridLine setBackgroundColor:[UIColor grayColor]];
        [self.view addSubview:gridLine];
        x -= defaultSize;
    }
}

- (void)addHorizontalGridLinesWithLineWidth:(CGFloat)lineWidth
{
    CGFloat xMin = self.newGameFieldView.frame.origin.x;
    CGFloat yMin = self.newGameFieldView.frame.origin.y;
    
    CGFloat height = self.newGameFieldView.frame.size.height;
    CGFloat width  = self.newGameFieldView.frame.size.width;

    // Draw grid line
    int y = yMin + height;
    while (y > yMin) {
        
        UIView *gridLine = [[UIView alloc] initWithFrame:CGRectMake(xMin, y, width, lineWidth)];
        [gridLine setBackgroundColor:[UIColor grayColor]];
        [self.view addSubview:gridLine];
        y -= defaultSize;
    }
}

#pragma mark - Ball view

- (void)updateNewBallView
{
    CGFloat xMin = self.newGameFieldView.frame.origin.x;
    CGFloat yMin = self.newGameFieldView.frame.origin.y;
    
    int scaleX = self.newGameFieldView.frame.size.width / defaultSize;
    int scaleY = self.newGameFieldView.frame.size.height / defaultSize;
    
    CGFloat randomX = arc4random_uniform(scaleX) * defaultSize + xMin;
    CGFloat randomY = arc4random_uniform(scaleY) * defaultSize + yMin;
    
    self.ballView = [[UIView alloc] initWithFrame:CGRectMake(randomX, randomY, defaultSize, defaultSize)];
    [self.ballView setBackgroundColor:[UIColor redColor]];
    [self.ballView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    self.ballView.layer.borderWidth = 0.50f;
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
        return;
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
    _score ++;
    
    if (_score % 20 == 0) {
        _level++;
    }
    
    self.scoreView.text = [NSString stringWithFormat:@"%@", @(_score)];
    self.levelView.text = [NSString stringWithFormat:@"%@", @(_level)];
    
    // Ball view will be the new head
    UIColor *color = self.snakeViews.firstObject.backgroundColor;
    [self.ballView setBackgroundColor:color];
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
    
//    // From Right
//    if (yMin == ballYMin && yMax == ballYMax && xMax == ballYMin) {
//        return YES;
//    }
//    
//    // From Left
//    if (yMin == ballYMin && yMax == ballYMax && xMin == ballXMax) {
//        return YES;
//    }
//    
//    // From Top
//    if (xMin == ballXMin && xMax == ballXMax && yMin == ballYMax) {
//        return YES;
//    }
//    
//    // From Bottom
//    if (xMin == ballXMin && xMax == ballXMax && yMax == ballYMin) {
//        return YES;
//    }

    
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
    
    CGFloat xMin = x;
    CGFloat xMax = x + defaultSize;
    CGFloat yMin = y;
    CGFloat yMax = y + defaultSize;
    
    // Right Wall
    if (xMax >= gameXMax) {
        return YES;
    }
    
    // Left Wall
    if (xMin <= gameXMin) {
        return YES;
    }
    
    // Top Wall
    if (yMax <= gameYMin || yMin <= gameYMin) {
        return YES;
    }
    
    // Bottom Wall
    if (yMin >= gameYMax || yMax >= gameYMax) {
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
        [self startGame];
    }];
    
    [alertController addAction:action];
    [self presentViewController:alertController animated:NO completion:nil];
}


@end
