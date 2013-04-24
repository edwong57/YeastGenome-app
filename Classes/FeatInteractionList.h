//
//  FeatInteractionList.h
//  SGD_Vivek
//
//  Created by Vivek on 09/03/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeatInteractionDetails.h"
#import "webServiceHelper.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


#define kCellLabelTag			1001
#define kCellImageTag           1002 
#define kCellSquareTag          1002
#define kCellFeatureNmTag       1003
#define kCellGeneNmTag          1004

@class FeatInteractionDetails;
@interface FeatInteractionList : UITableViewController <UITableViewDelegate, UITableViewDataSource, DownloadCompleteDelegate, UIActionSheetDelegate,UIAlertViewDelegate, MFMailComposeViewControllerDelegate> 
{
	IBOutlet UITableView        *tblInteraction;
	
	UIAlertView					*progAlertView;
	UIActivityIndicatorView		*activityIndView;
	NSManagedObjectContext		*managedObjectContext;	
	
	NSMutableArray				*allNewObjectsInteraction;
	
	UIButton					*EmailButton;
	
	MFMailComposeViewController *controller;

}

@property (nonatomic, retain) NSMutableArray                *allNewObjectsInteraction;
@property (nonatomic, retain) NSManagedObjectContext		*managedObjectContext;	

@property (nonatomic, retain) UIAlertView                   *progAlertView;
@property (nonatomic, retain) UIActivityIndicatorView       *activityIndView;

-(void)webServiceCall:(NSString *)webserviceName;
-(void)createProgressionAlertWithMessage:(NSString *)message;
-(IBAction)pushedEmailButton:(id)sender;

@end
