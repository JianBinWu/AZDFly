//
//  ImageViewLayer.m
//  DJIUIDemo
//
//  Created by 吴剑斌 on 2017/5/12.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "ImageViewLayer.h"
#import "Line.h"

@implementation ImageViewLayer

- (instancetype)init{
    if (self = [super init]) {
        self.lineArr = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx{

    UIGraphicsPushContext(ctx);
    UIColor *blackColor = [UIColor blackColor];
    if (self.lineArr.count == 0) {
        return;
    }
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = 3.0;
    NSString *string;
    Line *lastLine = [self.lineArr lastObject];
    if (lastLine.isBegin == NO) {
        for (Line *line in self.lineArr) {
            [aPath moveToPoint:line.beginPoint];
            [aPath addLineToPoint:line.endPoint];
            [blackColor set];
            [aPath stroke];
            [aPath fill];
            
            CGPoint centerPoint = CGPointMake((line.beginPoint.x + line.endPoint.x) / 2, (line.beginPoint.y + line.endPoint.y) / 2);
            //get real length via shootedHeight
            CGFloat length = line.length * self.shootedHeight / 135;
            string = [NSString stringWithFormat:@"%.2fcm", length];
            [string drawAtPoint:centerPoint withAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}];
            
        }
    }else{
        for (int i = 0; i < self.lineArr.count - 1; i++) {
            Line *line = self.lineArr[i];
            [aPath moveToPoint:line.beginPoint];
            [aPath addLineToPoint:line.endPoint];
            [blackColor set];
            [aPath stroke];
            [aPath fill];
            
            CGPoint centerPoint = CGPointMake((line.beginPoint.x + line.endPoint.x) / 2, (line.beginPoint.y + line.endPoint.y) / 2);
            //get real length via shootedHeight
            CGFloat length = line.length * self.shootedHeight / 135;
            string = [NSString stringWithFormat:@"%.2fcm", length];
            [string drawAtPoint:centerPoint withAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}];

        }
        [aPath moveToPoint:lastLine.beginPoint];
        [aPath addArcWithCenter:lastLine.beginPoint radius:3.0 startAngle:0.0 endAngle:180.0 clockwise:YES];
        [blackColor set];
        [aPath stroke];
        [aPath fill];
    }
    [aPath closePath];
    
}
    
@end
