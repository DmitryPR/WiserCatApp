//
//  MainScreenViewController.h
//  WisercatApp
//
//  Created by Dmitry Preobrazhenskiy on 21.02.12.
//  Copyright (c) 2012 TTU. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MainScreenViewController;
@protocol MainScreenViewControllerDelegate
@required
-(void)mainScreenDidUpdateTheGpsCoordinates:(MainScreenViewController *)sender;
@end

@interface MainScreenViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *cityNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *timezoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *localTimeTextField;
@property (nonatomic, weak) id <MainScreenViewControllerDelegate> delegate;
- (IBAction)gpsCoordinatesButtonPressed:(id)sender;

@end
