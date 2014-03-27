//
//  TutorialBalloon.h


#import <Foundation/Foundation.h>

#define ARROW_OFFSET    6.0f
#define STROKE_WIDTH    2.0f
#define ARROW_SIZE      20.0f
#define FONT_SIZE       12.0f
#define CORNER_RADIUS   11.0f
#define MAX_HEIGHT      CGFLOAT_MAX
#define PADDING_WIDTH   12.0f
#define PADDING_HEIGHT  10.0f
#define MAX_WIDTH       (320.0f - 2*PADDING_WIDTH - 2*MARGIN - 2*STROKE_WIDTH)
#define MARGIN          5.0f
#define ALPHA           0.9f
#define BUTTON_HEIGHT   25.0f
#define BUTTON_WIDTH    50.0f
#define BUTTON_MARGIN   6.0f

typedef enum _BalloonOrientation {
    POINTING_UP,
    POINTING_DOWN,
    POINTING_NONE
} BalloonOrientation;

@interface TutorialBalloon : UIView {
    
}

@property (nonatomic, copy) NSString *text;
@property BalloonOrientation orientation;
@property int px;
@property int py;
@property SEL callback;
@property id sender;
@property CGFloat textHeight;

- (id)initWithX:(int)x withY:(int)y withText:(NSString *)string withOrientation:(BalloonOrientation)orientation;
- (void) drawOutlineInContext:(CGContextRef)context withDirection:(BalloonOrientation)direction;
- (void) drawTextInContext:(CGContextRef)context;

@end
