//
//  GoogleMapViewController.h
//  WisercatApp
//
//  Created by Dmitry Preobrazhenskiy on 21.02.12.
//  Copyright (c) 2012 TTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>

@interface GoogleMapViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
