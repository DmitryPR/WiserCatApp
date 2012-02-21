//
//  WisercatViewController.m
//  WisercatApp
//
//  Created by Dmitry Preobrazhenskiy on 21.02.12.
//  Copyright (c) 2012 TTU. All rights reserved.
//

#import "WisercatViewController.h"

@implementation WisercatViewController


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (IBAction)proceedButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"ShowMainScreen" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if ([segue.identifier hasPrefix:@"ShowMainScreen"]) {
        //TODO modify as needed 
    }
}
@end
