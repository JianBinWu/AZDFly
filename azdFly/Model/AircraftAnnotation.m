//
//  AircraftAnnotation.m
//  GSDemo
//
//  Created by 吴剑斌 on 2017/4/21.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "AircraftAnnotation.h"

@implementation AircraftAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    _coordinate = newCoordinate;
}

- (void)updateHeading:(float)heading{
    if (self.annotationView) {
        [self.annotationView updateHeading:heading];
    }
}
@end
