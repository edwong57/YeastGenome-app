//
//  StandardInfo.h
//  SGD_2
//
//  Created by Avinash on 9/30/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sys/xattr.h>
#import "FeatManageData.h"
#import "FeatureDetails.h"
#import "sqlite3.h"

@interface StandardInfo : UIViewController<UIWebViewDelegate,MFMailComposeViewControllerDelegate>{
    
    IBOutlet UIWebView               *wBrowseImg;
    
    IBOutlet UIButton                *syncbtn;
    FeatManageData                   *manageVC;
    NSManagedObjectContext           *managedObjectContext;
    UIButton                         *backbtn; 
    UIActivityIndicatorView		     *activityIndView;
    BOOL isLoading;
    
}


@property (nonatomic, retain) FeatManageData          *manageVC;
@property (nonatomic, retain) UIButton                *backbtn; 

@property (nonatomic, retain) UIActivityIndicatorView *activityIndView;

@property (nonatomic, retain) NSManagedObjectContext  *managedObjectContext;

@property (nonatomic, retain) IBOutlet UIWebView      *wBrowseImg;

-(IBAction)pushedSyncButton:(id)sender;
-(void)pushedBackButton:(id)sender;
-(void) createProgressionAlertWithMessage:(NSString *)message;
//-(void)updateDatabase;
//- (void)downloadFileIfUpdated;  
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end
