//
//  FeatGOType.h
//  SGD_2
//
//  Created by Vivek on 7/6/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*Class to implement the list of Gene Ontology according to molecular function
 Biological Process and Cellular component.
 */

#import <UIKit/UIKit.h>

#import "webServiceHelper.h"
#import "Features.h"
#import "FeatGoTypeDetails.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define kCellLabelTag		1001
#define kCellSquareTag      1002
#define kCellFeatureNmTag   1003
#define kCellGeneNmTag      1004
#define kCellEvideNmTag     1005


@class FeatGoTypeDetails;

@interface FeatGOTypeList : UIViewController <UITableViewDelegate, UITableViewDataSource ,DownloadCompleteDelegate, UIActionSheetDelegate,UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
{
	NSMutableArray				*finalListArr;
	
	UIAlertView					*progAlertView;
	UIActivityIndicatorView		*activityIndView;
	NSManagedObjectContext		*managedObjectContext;
	
	Features					*selectedFeature;
	
	UIButton					*EmailButton;
	NSString					*strGOType;
    
    IBOutlet  UITableView       *tempTableview;   
    
    

}

@property (nonatomic, retain) NSMutableArray				*finalListArr;
@property (nonatomic, retain) NSManagedObjectContext        *managedObjectContext;
@property (nonatomic, retain) NSString	                    *strGOType;

@property (nonatomic, retain) UIAlertView                   *progAlertView;
@property (nonatomic, retain) UIActivityIndicatorView       *activityIndView;
@property (nonatomic, retain) Features                      *selectedFeature;

-(void)webServiceCall:(NSString *)featname;
-(void)getResultsAndInsert:(NSDictionary *)resultSet;
-(void)createProgressionAlertWithMessage:(NSString *)message;
-(void)finishedDownloading:(NSString *)strJSONResponse;
-(void)updateInDatabase:(NSArray *)evidenceObjects dictionaryObj:(NSMutableDictionary *)OntologyDict;


-(IBAction)pushedEmailButton:(id)sender;



@end
