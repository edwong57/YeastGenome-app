//
//  SGD_2AppDelegate.h
//  SGD_2
//
// 
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#include <sys/xattr.h>
#import "FavoritesListViewController.h"
#import "SearchViewController.h"
#import "FeatListViewController.h"
#import "FeatManageData.h"
#import "StandardInfo.h"
#import "webServiceHelper.h"

@class FavoritesListViewController;
@class SearchViewController;
@class FeatListViewController;
@class StandardInfo;
@class FeatManageData;

@interface SGD_2AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate,DownloadCompleteDelegate> 
{
    
	NSManagedObjectModel         *managedObjectModel;
	NSManagedObjectContext       *managedObjectContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
    NSMutableArray         *allFeats;
    
	UIWindow               *window;
	UINavigationController *searchNavController;
	UINavigationController *featsNavController;
	UINavigationController *favNavController;
	UINavigationController *manageNavController;
	UINavigationController *reportNavController;
	
	IBOutlet UITabBarController *tBController;
	
	FavoritesListViewController *favoritesListVC;
	SearchViewController        *searchVC;
	FeatListViewController      *featListVC;
	FeatManageData              *manageVC;
	StandardInfo                *stdinfoVC;
    
	NSTimer			*cleanUpCheckTimer;
	BOOL			isTimerEnabled;
	UIBackgroundTaskIdentifier	bgTask;
    BOOL			wasNotified;
    
    NSMutableData				*webData;
    UIAlertView					*progAlertView;
	UIActivityIndicatorView		*activityIndView;
    UIProgressView              *progressView;
    UIAlertView                 *alert;
    long long bytesReceived;
    long long expectedBytes;
	
@private
    NSManagedObjectContext       *managedObjectContext_;
    NSManagedObjectModel         *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext       *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel         *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain, readonly) NSMutableArray               *allFeats;


@property (nonatomic, retain) IBOutlet UINavigationController *searchNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *featsNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *favNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *manageNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *reportNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *stdinfoNavController;


@property (nonatomic, retain) IBOutlet UITabBarController *tBController;

@property (nonatomic, retain) FavoritesListViewController *favoritesListVC;
@property (nonatomic, retain) SearchViewController        *searchVC;
@property (nonatomic, retain) FeatListViewController      *featListVC;
@property (nonatomic, retain) FeatManageData              *manageVC;
@property (nonatomic, retain) StandardInfo                *stdinfoVC;




@property (nonatomic, retain) NSTimer *cleanUpCheckTimer;
@property (nonatomic) BOOL isTimerEnabled;
@property (nonatomic) BOOL wasNotified;
@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) UIAlertView                   *progAlertView;
@property (nonatomic, retain) UIActivityIndicatorView       *activityIndView;
@property (nonatomic, retain) UIAlertView                   *alert;
@property (nonatomic, retain) UIProgressView                *progressView;


-(void)automaticallyCleanUp:(NSTimer *)timer;
- (NSString *)applicationDocumentsDirectory;
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
-(void)getAllGeneNames;
-(NSMutableArray*) getAllGeneNamesCall:(int)offset limit:(int)limit;
-(void)startConnection:(NSString*)urlrequest;
- (void)finishedDownloading:(NSMutableData *)Response;
-(void)createProgressionAlertWithMessage:(NSString *)message;

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
@end


@interface UITabBarController (SGD_2)
@end

@interface UINavigationController (SGD_2)
@end
