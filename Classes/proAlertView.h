//
//  proAlertView.h
//  
//  Created by Vivek on 12/05/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

BOOL canVirate;

@interface proAlertView : UIAlertView {
	
	int canIndex;
	BOOL disableDismiss;

}

-(void) setBackgroundColor:(UIColor *) background 
			withStrokeColor:(UIColor *) stroke;

- (void)disableDismissForIndex:(int)index_;
- (void)dismissAlert;
- (void)vibrateAlert:(float)seconds;

- (void)moveRight;
- (void)moveLeft;

- (void)hideAfter:(float)seconds;

- (void)stopVibration;



@end
