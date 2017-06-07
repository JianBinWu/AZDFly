//
//  AircraftAnnotation.h
//  GSDemo
//
//  Created by 吴剑斌 on 2017/4/21.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AircraftAnnotationView.h"

@interface AircraftAnnotation : NSObject<MAAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, weak) AircraftAnnotationView *annotationView;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (void)updateHeading:(float)heading;

@end
