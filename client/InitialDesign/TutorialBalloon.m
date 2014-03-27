//
//  TutorialBalloon.m
//  MiniProject
//
//  Created by David Wiza on 12/7/13.
//  Copyright (c) 2013 Capstone Student. All rights reserved.
//

#import "TutorialBalloon.h"



@implementation TutorialBalloon

@synthesize text;

/*#pragma mark NSObject
 
 - (void) dealloc {
 [text release];
 [super dealloc];
 }*/

static const CGFloat F_PI = (CGFloat)M_PI;

#pragma mark UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [self drawOutlineInContext:contextRef withDirection:self.orientation];
    [self drawTextInContext:contextRef];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    if (self.callback) {
        [button setTitle:@"Next" forState:UIControlStateNormal];
    } else {
        [button setTitle:@"Close" forState:UIControlStateNormal];
    }
    if (self.orientation == POINTING_UP) {
        button.frame = CGRectMake(PADDING_WIDTH, self.textHeight + ARROW_SIZE + BUTTON_MARGIN + PADDING_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT);
    } else {
        button.frame = CGRectMake(PADDING_WIDTH, self.textHeight + PADDING_HEIGHT + BUTTON_MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT);
    }
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [[UIColor blackColor] CGColor];
    button.layer.cornerRadius = CORNER_RADIUS;
    [self addSubview:button];
}

- (IBAction)buttonPressed:(id)sender
{
    [self touchesBegan:NULL withEvent:NULL];
}

- (IBAction)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Balloon touched");
    [self removeFromSuperview];
    if (self.callback && self.sender) {
        NSLog(@"Performing callback");
        [self.sender performSelector:self.callback];
    }
}

- (id)initWithX:(int)x withY:(int)y withText:(NSString *)string withOrientation:(BalloonOrientation)orientation{
    self.orientation = orientation;
    self.px = x - MARGIN;
    self.py = y;
    CGRect rect;
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:CGSizeMake(MAX_WIDTH, MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping];
    self.textHeight = size.height;
    NSLog(@"text height = %f", self.textHeight);
    size.height += BUTTON_HEIGHT + BUTTON_MARGIN;
    switch (orientation) {
        case POINTING_UP:
            rect = CGRectMake(5, y, 310, size.height + PADDING_HEIGHT * 2.0f + ARROW_SIZE);
            break;
        case POINTING_DOWN:
            rect = CGRectMake(5, y - size.height - PADDING_HEIGHT * 2.0f - ARROW_SIZE, 310, size.height + PADDING_HEIGHT * 2.0f + ARROW_SIZE);
            break;
        default:
            rect = CGRectMake(5, y, 310, size.height + PADDING_HEIGHT * 2.0f);
    }
    if ((self = [super initWithFrame:rect])) {
        self.text = string;
        UIColor *clearColor = [[UIColor alloc] initWithWhite:0.0f alpha:0.0f];
        self.backgroundColor = clearColor;
        //[clearColor release];
    }
    return self;
}

- (void)drawOutlineInContext:(CGContextRef)context withDirection:(BalloonOrientation)direction {
    CGRect rect = self.bounds;
    rect.origin.x += (STROKE_WIDTH/2.0f);
    if (direction == POINTING_DOWN) {
        rect.origin.y += STROKE_WIDTH/2.0f;
    } else if (direction == POINTING_UP) {
        rect.origin.y += STROKE_WIDTH + ARROW_SIZE;
    }
    rect.size.width -= STROKE_WIDTH;
    rect.size.height -= STROKE_WIDTH*1.5f;
    if (self.orientation != POINTING_NONE){
        rect.size.height -= ARROW_SIZE;
    }
    
    CGFloat radius = CORNER_RADIUS;
    CGFloat left = rect.origin.x;
    CGFloat right = left + rect.size.width;
    CGFloat top = rect.origin.y;
    CGFloat bottom = top + rect.size.height;
    CGFloat arrowLeft = MAX(self.px - ARROW_OFFSET, CORNER_RADIUS);
    arrowLeft = MIN(arrowLeft, right - ARROW_OFFSET - ARROW_OFFSET - CORNER_RADIUS);
    CGFloat arrowRight = MIN(self.px + ARROW_OFFSET, right - CORNER_RADIUS);
    arrowRight = MAX(arrowRight, ARROW_OFFSET * 2 + CORNER_RADIUS);
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, STROKE_WIDTH);
    CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 1.0f); // black
    CGContextSetGrayFillColor(context, 1.0f, ALPHA); // white background
    
    if (direction == POINTING_DOWN) {
        CGContextMoveToPoint(context, left+radius, bottom);
        CGContextAddLineToPoint(context, arrowLeft, bottom);
        CGContextAddLineToPoint(context, self.px, bottom + ARROW_SIZE);
        CGContextAddLineToPoint(context, arrowRight, bottom);
        CGContextAddArc(context, right - radius, bottom - radius, radius, F_PI/2.0f, 0.0f, 1);
        CGContextAddArc(context, right - radius, top + radius, radius, 0.0f, 3.0f*F_PI/2.0f, 1);
        CGContextAddArc(context, left + radius, top + radius, radius, 3.0f*F_PI/2.0f, F_PI, 1);
        CGContextAddArc(context, left + radius, bottom - radius, radius, F_PI, F_PI/2.0f, 1);
    } else if (direction == POINTING_UP) {
        CGContextMoveToPoint(context, left + radius, top);
        CGContextAddLineToPoint(context, arrowLeft, top);
        CGContextAddLineToPoint(context, self.px, top - ARROW_SIZE);
        CGContextAddLineToPoint(context, arrowRight, top);
        CGContextAddArc(context, right - radius, top + radius, radius, 3.0f*F_PI/2.0f, 0.0f, 0);
        CGContextAddArc(context, right - radius, bottom - radius, radius, 0.0f, F_PI/2.0f, 0);
        CGContextAddArc(context, left + radius, bottom - radius, radius, F_PI/2.0f, F_PI, 0);
        CGContextAddArc(context, left + radius, top + radius, radius, F_PI, 3.0f*F_PI/2.0f, 0);
    } else {
        CGContextMoveToPoint(context, left+radius, bottom);
        //CGContextAddLineToPoint(context, arrowLeft, bottom);
        //CGContextAddLineToPoint(context, self.px, bottom + ARROW_SIZE);
        //CGContextAddLineToPoint(context, arrowRight, bottom);
        CGContextAddArc(context, right - radius, bottom - radius, radius, F_PI/2.0f, 0.0f, 1);
        CGContextAddArc(context, right - radius, top + radius, radius, 0.0f, 3.0f*F_PI/2.0f, 1);
        CGContextAddArc(context, left + radius, top + radius, radius, 3.0f*F_PI/2.0f, F_PI, 1);
        CGContextAddArc(context, left + radius, bottom - radius, radius, F_PI, F_PI/2.0f, 1);
    }
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawTextInContext:(CGContextRef)context {
    CGRect rect = self.bounds;
    rect.origin.x += PADDING_WIDTH;
    rect.size.width -= PADDING_WIDTH*2.0f;
    if (self.orientation == POINTING_UP) {
        rect.origin.y += PADDING_HEIGHT + ARROW_SIZE;
    } else {
        rect.origin.y = PADDING_HEIGHT;
    }
    rect.size.height -= PADDING_HEIGHT*2.0f;
    
    CGContextSetGrayFillColor(context, 0.0f, 1.0f); // black text
    [text drawInRect:rect withFont:[UIFont systemFontOfSize:FONT_SIZE]
       lineBreakMode:NSLineBreakByWordWrapping];
}

@end
