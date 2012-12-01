//
//  FeatGoDetails.h
//  SGD_Vivek
//
//  Created by Vivek on 09/03/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <sys/xattr.h>
#import "webServiceHelper.h"
#import "Features.h"
#import "CustomURLConnection.h"

@interface FeatGoDetails : UITableViewController<DownloadCompleteDelegate>
{
	NSString                *strgenename;
	NSManagedObjectContext  *managedObjectContext;
    
    UIActivityIndicatorView		*activityIndView;
	
	Features					*selectedFeature;
    NSString					*strGOType;
	NSMutableArray				*finalListArr;
     BOOL                       isSuccess;
    NSMutableDictionary         *receivedData;
    NSMutableData				*webData;
    NSMutableData				*webData1;
    NSURLConnection             *myconnection;
    NSURLConnection             *myconnection1;
}

@property(nonatomic,retain) NSString               *strgenename;
@property(nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString	                    *strGOType;
@property (nonatomic, retain) UIActivityIndicatorView       *activityIndView;
@property (nonatomic, retain) Features                      *selectedFeature;
@property (nonatomic, retain) NSMutableArray				*finalListArr;

@property(nonatomic, retain) NSMutableData *webData;
@property(nonatomic, retain) NSMutableData *webData1;
@property(nonatomic, retain) NSURLConnection *myconnection;
@property(nonatomic, retain) NSURLConnection *myconnection1;

//*****
-(void)webServiceCall:(NSString *)featname;
-(void)getResultsAndInsert:(NSDictionary *)resultSet;
-(void)createProgressionAlertWithMessage:(NSString *)message;
-(void)finishedDownloading:(NSString *)strJSONResponse;
-(void)updateInDatabase:(NSArray *)evidenceObjects dictionaryObj:(NSMutableDictionary *)OntologyDict;
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
//****
@end
