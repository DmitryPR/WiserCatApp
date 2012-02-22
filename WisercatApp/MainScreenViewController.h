//
//  MainScreenViewController.h
//  WisercatApp
//
//  Created by Dmitry Preobrazhenskiy on 21.02.12.
//  Copyright (c) 2012 TTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>

#define COORDINATE_LATITUDE @"latitude"
#define COORDINATE_LONGITUDE @"longitude"
#define COORDINATE_CITYNAME @"cityname"
#define COORDINATE_TIMEZONE @"timezone"
#define COORDINATE_LOCALTIME @"localtime"

@class MainScreenViewController;

@interface MainScreenViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UITextField *cityNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *timezoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *localTimeTextField;

@property (nonatomic, weak) NSMutableDictionary *coordinateDictionary;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
- (IBAction)gpsCoordinatesButtonPressed:(id)sender;
- (IBAction)saveToMapButtonPressed:(id)sender;


@end
