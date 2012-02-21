//
//  MapViewAnnotaions.h
//  WisercatApp
//
//  Created by Dmitry Preobrazhenskiy on 22.02.12.
//  Copyright (c) 2012 TTU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface MapViewAnnotaion : NSObject <MKAnnotation>
+ (MapViewAnnotaion *)annotationForMapView:(NSDictionary *)coordinateDictionary;

@property (nonatomic, strong) NSDictionary *coordinateDictionary;
@end
