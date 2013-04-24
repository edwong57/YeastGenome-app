//
//  SGD_2AppDelegate.m
//  SGD_2
//
//  
//  Copyright 2011 Stanford University. All rights reserved.
//

/*
 Class to initialize the core data, set the persistent store 
 coordinator for the application by copying the sqlite file from bundle to document directory.
 Initialize the view controller for Search,browse feature, favourite and
 info and add those to tabcontroller.
 */

#import "SGD_2AppDelegate.h"
#import "Reachability.h"
#import "FMDatabase.h"

#import "Features.h"
#import "Alias.h"
#import "FeatAnnotation.h"
#import "FeatLocation.h"

#import "GODetails.h"
#import "Interactions.h"
#import "Phenotypes.h"
#import "References.h"

#import "staticFunctionClass.h"
#import "SearchViewController.h"
#import "FeatListViewController.h"
#import "FavoritesListViewController.h"

int bytesCount;
int totalFileSize;

@implementation SGD_2AppDelegate

@synthesize window;
@synthesize searchNavController;
@synthesize featsNavController;
@synthesize favNavController;
@synthesize manageNavController;
@synthesize reportNavController;
@synthesize stdinfoNavController;

@synthesize allFeats;

@synthesize tBController;
@synthesize favoritesListVC, searchVC, featListVC, manageVC,stdinfoVC;//reportVC
@synthesize cleanUpCheckTimer;
@synthesize isTimerEnabled;
@synthesize wasNotified;
@synthesize webData;
@synthesize progAlertView, activityIndView,progressView;
@synthesize alert;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    //------
    
      
	
    // Override point for customization after application launch.
	//NSManagedObjectContext *context
    
    managedObjectContext = [self managedObjectContext];  //grab pointer with managed object context
	
	NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
	
    [dnc addObserverForName:NSManagedObjectContextDidSaveNotification
					 object:managedObjectContext
                      queue:nil
				 usingBlock:^(NSNotification *saveNotification)
	 {
		 [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
		 
	 }];
	
	NSError *error;
	
	if (![managedObjectContext save:&error]) {
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
	}
	
    @try{
        
    
        //navigation and tab Bar; set up navigation controllers for each view controller
        
        tBController = [[UITabBarController alloc] init];	


        searchVC = [[SearchViewController alloc] init];
        searchVC.managedObjectContext = managedObjectContext;
        searchNavController = [[UINavigationController alloc] initWithRootViewController:searchVC];	

        
        featListVC = [[FeatListViewController alloc] init];
        featListVC.managedObjectContext = managedObjectContext;
        featsNavController = [[UINavigationController alloc] initWithRootViewController:featListVC];	
        
        favoritesListVC = [[FavoritesListViewController alloc] init];
        favoritesListVC.managedObjectContext = managedObjectContext;
        favNavController = [[UINavigationController alloc] initWithRootViewController:favoritesListVC];	

        manageVC = [[FeatManageData alloc] init];
        manageVC.managedObjectContext = managedObjectContext;
        
        
        stdinfoVC = [[StandardInfo alloc] init];
        stdinfoVC.managedObjectContext = managedObjectContext;
        stdinfoNavController = [[UINavigationController alloc] initWithRootViewController:stdinfoVC];	
        
        tBController.viewControllers = [NSArray arrayWithObjects:searchNavController, featsNavController, favNavController, stdinfoNavController,nil];
        tBController.delegate = self;
        tBController.customizableViewControllers = NO;
        
        
        [staticFunctionClass initializeMolFnName];
        [staticFunctionClass initializeBioPrName];
        [staticFunctionClass initializeCelCmName];
        [staticFunctionClass initInteractionDict];
        [staticFunctionClass initPhenoDict];
        
        [staticFunctionClass initSubjectLine];
        [staticFunctionClass initMessageBody];
        [staticFunctionClass initRecipient];
        [staticFunctionClass initializeFeatureType];
        [staticFunctionClass initPredicateStr];
        [staticFunctionClass initReferencePub];

    }
    @catch (NSException *ex) {
        NSLog(@"%@",[ex description]);
    }
    
    //Get all gene data
    [self getAllGeneNames];
        
	//[window addSubview:tBController.view];
    
    self.window.rootViewController = tBController;
    [window makeKeyAndVisible];
    
	return YES;
    
}

//Get all gene data function from core data
-(void) getAllGeneNames
{
	@try
	{
        
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features" inManagedObjectContext:self.managedObjectContext];
		
		[request setEntity:entity];
		
		NSSortDescriptor *sortByGeneName = [[NSSortDescriptor alloc	] initWithKey:@"geneName" ascending:YES];
		NSSortDescriptor *sortByFeatureName = [[NSSortDescriptor alloc] initWithKey:@"featureName" ascending:YES];
		
		[request setSortDescriptors:[NSArray arrayWithObjects:sortByGeneName, sortByFeatureName, nil]];
		[sortByGeneName release];
		[sortByFeatureName release];
		
		NSError *error;
		NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:request error:&error];
		if (allFeats != nil) 
		{
			[allFeats release];
			allFeats = nil;
		}
		allFeats = [[NSMutableArray alloc] initWithArray:fetchedObjects];
		[request release];
		
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"geneName" ascending:YES];
		NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
		[allFeats sortUsingDescriptors:sortDescriptors];
		[sortDescriptor release];
	
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@", [e description]);
	}
}

//Get all gene data function
-(NSMutableArray*) getAllGeneNamesCall:(int)offset limit:(int)limit
{
	@try
	{
        
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features" inManagedObjectContext:self.managedObjectContext];
		
		[request setEntity:entity];
        // Set limit for core data //
        [request setFetchLimit:limit];
        [request setFetchOffset:offset];
        
		NSSortDescriptor *sortByGeneName = [[NSSortDescriptor alloc	] initWithKey:@"geneName" ascending:YES];
		NSSortDescriptor *sortByFeatureName = [[NSSortDescriptor alloc] initWithKey:@"featureName" ascending:YES];
		
		[request setSortDescriptors:[NSArray arrayWithObjects:sortByGeneName, sortByFeatureName, nil]];
		[sortByGeneName release];
		[sortByFeatureName release];
		
		NSError *error;
		NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:request error:&error];
		if (allFeats != nil) 
		{
			[allFeats release];
			allFeats = nil;
		}
		allFeats = [[NSMutableArray alloc] initWithArray:fetchedObjects];
		[request release];
		
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"geneName" ascending:YES];
		NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
		[allFeats sortUsingDescriptors:sortDescriptors];
		[sortDescriptor release];
        
        
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@", [e description]);
	}
    
    return allFeats;
    
}


-(void)automaticallyCleanUp:(NSTimer *)Timer
{
	[cleanUpCheckTimer invalidate];
	cleanUpCheckTimer = nil;

	
	//checking array is allocated or not

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSError *error;
    
    for (Features *value in allFeats)
	{
		if (isTimerEnabled) 
		{
			unsigned int unitFlags = NSDayCalendarUnit;
			NSDateComponents *components = [gregorian components:unitFlags fromDate:value.usedDateMoreInfo toDate:[NSDate date] options:0];
			int days = [components day];
						
			if (days > 30) 
			{
				NSArray *tmpGoArray = [value.godetails allObjects];	
				NSArray *tmpIntArray = [value.interaction allObjects];
				NSArray *tmpPhenoArray = [value.phenotype allObjects];
				NSArray *tmpReferArray = [value.references allObjects];
				
				for (GODetails *godetailsObj in tmpGoArray)
				{
					[self.managedObjectContext deleteObject:godetailsObj];
				}
				for (Interactions *intObj in tmpIntArray)
				{
					[self.managedObjectContext deleteObject:intObj];
				}
				for (Phenotypes *phenoObj in tmpPhenoArray)
				{
					[self.managedObjectContext deleteObject:phenoObj];
				}
				for (References *referObj in tmpReferArray)
				{
					[self.managedObjectContext deleteObject:referObj];
				}
            }
		}
	}
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    
    [dnc addObserverForName:NSManagedObjectContextDidSaveNotification
                     object:self.managedObjectContext
                      queue:nil
                 usingBlock:^(NSNotification *saveNotification)
     {
         [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
         
     }];
    
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"%@",[error description]);
    }
    
    [dnc removeObserver:self
                   name:NSManagedObjectContextDidSaveNotification
                 object:self.managedObjectContext];
    

	[gregorian release];
}




//Called when user changes the tab 
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	
    if (tBController.selectedViewController == searchNavController) {
		[searchNavController popToRootViewControllerAnimated:NO];
	} else if (tBController.selectedViewController == featsNavController) {
		[featsNavController popToRootViewControllerAnimated:NO];
	} else if (tBController.selectedViewController	== favNavController) {
		[favNavController popToRootViewControllerAnimated:NO];
	} else if (tBController.selectedViewController == manageNavController){
        [manageNavController popToRootViewControllerAnimated:NO];
    } else if (tBController.selectedViewController == reportNavController){
        [reportNavController popToRootViewControllerAnimated:NO];
    } else if (tBController.selectedViewController == stdinfoNavController){
        [stdinfoNavController popToRootViewControllerAnimated:NO];
    }
	
}

	
- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    NSLog(@"ApplicationWillResignActive..."); 
   
     // Dissmiss without any button clicked

}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    
    NSLog(@"ApplicationDidEnterBackground...");    

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
     NSLog(@"ApplicationWillEnterForeground...");    

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"EEEE"];
	NSString *strcreatedtime = [dateFormat stringFromDate:[NSDate date]];
	[dateFormat release];
	isTimerEnabled = YES;
	if ([strcreatedtime isEqualToString:@"Saturday"]) 
	{
		cleanUpCheckTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(automaticallyCleanUp:) userInfo:nil repeats:YES];
	}
    
    NSLog(@"ApplicationDidBecomeActive...");    

  
   
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
    
    NSLog(@"ApplicationWillTerminate...");    

}


- (void)finishedDownloading:(NSMutableData *)Response
{

    @try 
	{
        if ([activityIndView isAnimating]) {
			[activityIndView stopAnimating];
		
		//[progAlertView dismissWithClickedButtonIndex:(NSInteger)nil animated:YES];
        }
        
        [progAlertView dismissWithClickedButtonIndex:(NSInteger)nil animated:YES];


        
        if([Response length] != 0){
       //NSMutableData *data = [[NSMutableData alloc] initWithData:[Response dataUsingEncoding:NSUTF8StringEncoding]];
       NSString *filePath = [[self applicationDocumentsDirectory] 
                              stringByAppendingPathComponent: @"SGD_2.sqlite"];//[documentsPath stringByAppendingPathComponent:@"SGD_2.sqlite"];
	 
	 NSFileManager *fileManager = [NSFileManager defaultManager];
		
         // Put down default db if it doesn't already exist

	
        if ([fileManager fileExistsAtPath:filePath]) {  //DB file exists already //

            NSLog(@"File exists in documentry...");
            [fileManager removeItemAtPath:filePath error:NULL];
            [Response writeToFile:filePath atomically:YES];
            NSLog(@"File Replaced at documentry...");
  			
            // Override point for customization after application launch.
            
            managedObjectContext_ = nil;
            [managedObjectContext_ release];
            persistentStoreCoordinator_ = nil;
            [persistentStoreCoordinator_ release];
            managedObjectModel_ = nil;
            [managedObjectModel_ release];
            
            managedObjectContext = [self managedObjectContext];  //grab pointer with managed object context
            
            NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
            
            [dnc addObserverForName:NSManagedObjectContextDidSaveNotification
                             object:managedObjectContext
                              queue:nil
                         usingBlock:^(NSNotification *saveNotification)
             {
                 [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
                 
             }];
            
            NSError *error;
            
            if (![managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
            
            searchVC.managedObjectContext = managedObjectContext;             
            featListVC.managedObjectContext = managedObjectContext;        
            favoritesListVC.managedObjectContext = managedObjectContext;        
            manageVC.managedObjectContext = managedObjectContext;  
            stdinfoVC.managedObjectContext = managedObjectContext;
            
            //[searchVC reloadTableWithNewData];
            [searchVC.featsList removeAllObjects];
            [searchVC.searchResultsTable reloadData];
            // set up favorites list -- get it from CoreData
            [favoritesListVC LoadFavList];

            UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
            [dialog setDelegate:self];
            [dialog setTitle:@"Data updated"];
            [dialog setMessage:@"Local database updated succesfully."];
            [dialog addButtonWithTitle:@"Ok"];
            [dialog show];	
            [dialog release];

        }

        }
	}
	// now we are sure the download is complete
	@catch (NSException *e) 
	{
		NSLog(@"%@",[e description]);
	}
	
}

#pragma mark -
#pragma mark TabBarController Delegate 
//TabBar selection delegate function

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	
	SGD_2AppDelegate *app = (SGD_2AppDelegate*)[[UIApplication sharedApplication] delegate];
	if (viewController == searchNavController) 
	{
		[featsNavController popToRootViewControllerAnimated:NO];
		[favNavController popToRootViewControllerAnimated:NO];
        [reportNavController popToRootViewControllerAnimated:NO];
        [stdinfoNavController popToRootViewControllerAnimated:NO];

	} 
	else if (viewController == featsNavController) 
	{
		[favNavController popToRootViewControllerAnimated:NO];
		[searchNavController popToRootViewControllerAnimated:NO];
        [reportNavController popToRootViewControllerAnimated:NO];
        [stdinfoNavController popToRootViewControllerAnimated:NO];

		if ([app.searchVC.featsList count] != 0) 
		{
			
			[app.searchVC.searchDisplayController setActive:YES animated:YES];
		}
		
	}
	else if (viewController == favNavController) 
	{
		[searchNavController popToRootViewControllerAnimated:NO];
		[featsNavController popToRootViewControllerAnimated:NO];
        [reportNavController popToRootViewControllerAnimated:NO];
        [stdinfoNavController popToRootViewControllerAnimated:NO];
        
		[app.searchVC.searchResultsTable reloadData];
		if ([app.searchVC.featsList count] != 0) 
		{
			
			[app.searchVC.searchDisplayController setActive:YES animated:YES];
		}
	}
	else if (viewController == manageNavController)
	{
		[searchNavController popToRootViewControllerAnimated:NO];
		[featsNavController popToRootViewControllerAnimated:NO];
		[favNavController popToRootViewControllerAnimated:NO];
        [reportNavController popToRootViewControllerAnimated:NO];
        
		if ([app.searchVC.featsList count] != 0) 
		{
			
			[app.searchVC.searchDisplayController setActive:YES animated:YES];
		}
	}
	else if (viewController == reportNavController)
	{
		[searchNavController popToRootViewControllerAnimated:NO];
		[featsNavController popToRootViewControllerAnimated:NO];
		[favNavController popToRootViewControllerAnimated:NO];
		
		if ([app.searchVC.featsList count] != 0) 
		{
			
			[app.searchVC.searchDisplayController setActive:YES animated:YES];
		}
	}else if (viewController == stdinfoNavController)
	{
		[searchNavController popToRootViewControllerAnimated:NO];
		[featsNavController popToRootViewControllerAnimated:NO];
		[favNavController popToRootViewControllerAnimated:NO];
		
		if ([app.searchVC.featsList count] != 0) 
		{
			
			[app.searchVC.searchDisplayController setActive:YES animated:YES];
		}
	}

}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
	
    return managedObjectContext_;
}

//
/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model .
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"SGD_2" ofType:@"momd"];	
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    
    [self addSkipBackupAttributeToItemAtURL:modelURL];
    
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
 
 	NSString *storePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) 
							objectAtIndex:0] stringByAppendingPathComponent: @"SGD_2.sqlite"];
	
		//[[self applicationDocumentsDirectory] 
		//				   stringByAppendingPathComponent: @"SGD_2.sqlite"];
	
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
	
    [self addSkipBackupAttributeToItemAtURL:storeURL];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *defaultStorePath = [[NSBundle mainBundle] 
								  pathForResource:@"SGD_2" ofType:@"sqlite"];

	if (![fileManager fileExistsAtPath:storePath]) { 	// Put down default db if it doesn't already exist
			
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
 
            NSUserDefaults *defaultFile =[NSUserDefaults standardUserDefaults];
			NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

			[defaultFile setObject:bundleVersion forKey:@"version"];  //set version #
	
			[defaultFile synchronize];

	} else { //check version number
				
		NSLog(@"%@ Already exists... new filepath %@", storePath, defaultStorePath);
        
		// check version # to see if it is a new version
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
		NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	//	NSLog(@"%@", bundleVersion);
		
		if ([userDefaults objectForKey:@"version"]) {
			
			NSString *version = [userDefaults objectForKey:@"version"];
	//		NSLog(@"%@", version);
	
			if (![version isEqualToString:bundleVersion]) {  // version numbers are not the same
						
				// make temp dbs
				NSString *tempDir = NSTemporaryDirectory();
				
				NSString *newTmpDB = [tempDir stringByAppendingPathComponent: @"newSGD.db"];
				NSString *oldTmpDB = [tempDir stringByAppendingPathComponent: @"oldSGD.db"];
				
				[fileManager copyItemAtPath:defaultStorePath toPath:newTmpDB error:NULL];
				[fileManager copyItemAtPath:storePath toPath:oldTmpDB error:NULL];
				
				
		// 1. get list of features that are 'favorites'; save as NSArray (FavArray) //
				FMDatabase *sgddb = [FMDatabase databaseWithPath:oldTmpDB];
		
	//			NSLog(@"opening %@", sgddb);
				
				[sgddb open];
		
				if (! [sgddb open]) {
					NSLog(@"%@ didn't open", sgddb);
				[sgddb release];
				}
		
				FMDatabase *dbToUpdate = [FMDatabase databaseWithPath:newTmpDB];
				
		//		NSLog(@"Updating favorite features in SQlite file, %@", dbToUpdate);
		
				[dbToUpdate open];
//
				FMResultSet *results = [sgddb executeQuery:@"select ZFEATURENAME, ZFAVORITE from ZFEATURES  where ZFAVORITE = ?", @"1"];
		
				while ([results next]) {
				
					NSString *fName = [results stringForColumn:@"ZFEATURENAME"];
			
		//			NSLog(@"fav: %@", fName);
			
					[dbToUpdate executeUpdate:@"UPDATE ZFEATURES SET ZFAVORITE = ? WHERE ZFEATURENAME = ?", @"1", fName];
			
				}
				[dbToUpdate close];	
				[sgddb close];
		
				// 2. replace old sqlite file with new one sqlite file
		
			//	NSLog(@"File exists in documentry...");
				[fileManager removeItemAtPath:storePath error:NULL];
				[fileManager copyItemAtPath:newTmpDB toPath:storePath error:NULL];
				[fileManager removeItemAtPath:newTmpDB error:NULL];
				[fileManager removeItemAtPath:oldTmpDB error:NULL];

		} // end new version match
			
		[userDefaults setObject:bundleVersion forKey:@"version"];
		[userDefaults synchronize];
		}
		
		[fileManager removeItemAtPath:defaultStorePath error:NULL];
	}
    //-------
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    //--------------
    NSError *error = nil;
    
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType 
												   configuration:nil URL:storeURL options:options error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    else{
    
   //     NSLog(@"PersistentStoreCoordinator  From path... \n%@",storeURL);
    }
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
	[searchNavController release];
	[featsNavController release];
	[favNavController release];
	[tBController release];
	
	[favoritesListVC release];
	[searchVC release];
    [featListVC release];
	
	[window release];
    [super dealloc];
	
}

-(void)startConnection:(NSString*)urlrequest
{
	urlrequest = [urlrequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
	NSURL *myWebserverURL = [[NSURL alloc] initWithString:urlrequest];
    
    [self addSkipBackupAttributeToItemAtURL:myWebserverURL];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myWebserverURL];
	
	NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	[myWebserverURL release];
    
	if( theConnection )
	{
		
		if (webData != nil) {
			webData = nil;
		}
        
        bytesCount = 0;
		webData = [[NSMutableData data] retain];
	}
	else
	{
		[self finishedDownloading:[NSString stringWithFormat:@""]];
	}
	
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	
	if ([httpResponse statusCode] >= 400)
	{
		// do error handling here
        [webData setLength:0];

		[self finishedDownloading:webData];
	} 
	else {
        
        //totalFileSize = 21809148;
        totalFileSize = [response expectedContentLength];
        //NSLog(@"size %i",totalFileSize); 
	}
	
	// Check for webdata and init webdata
	if (webData != nil) {
		webData = nil;
		
	}
    progressView.progress = 0.0;
	webData = [[NSMutableData data] retain];
}	

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	bytesCount = bytesCount + [data length];
    
    //NSLog(@"Total Size %i",totalFileSize);
   // NSLog(@"Byte Count %d",bytesCount);
	[webData appendData:data];
    
    progressView.progress = progressView.progress +((float) [data length] / (float)totalFileSize);
    
    //NSLog(@"Progress--> %f",progressView.progress);
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	@try
	{
        [webData setLength:0];

        [self finishedDownloading:webData];
        
	}
	@catch (NSException *e) {
		NSLog(@"%@",[e description]);
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	@try
	{
        //NSLog(@"DidFinishLoading..");

        
        if ([webData length] != 0)
        {
            
            [self finishedDownloading:webData]; // notify delegate download finished
        }
        else
        {
            //ERROR HANDLING
             [webData setLength:0];
            [self finishedDownloading:webData];
        }
		
	}
	@catch (NSException *e) 
	{
		NSLog(@"%@",[e description]);
	}
}


//Progession Alert message display

-(void) createProgressionAlertWithMessage:(NSString *)message
{
	if (progAlertView != nil) 
		progAlertView = nil;
	
	if (activityIndView != nil) 
		activityIndView = nil;
	
	progAlertView = [[UIAlertView alloc] initWithTitle: message
											   message: @"Please wait..."
											  delegate: self
									 cancelButtonTitle:  nil
									 otherButtonTitles: nil];
    
    // Create the progress bar and add it to the alert
    progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f, 90.0f)];
    [progAlertView addSubview:progressView];
    [progressView setProgressViewStyle:UIProgressViewStyleBar];
    
	[progAlertView show];
	[progAlertView release];
}

#pragma mark -
#pragma mark Exclude backupUrl From Cloud

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL

{
    
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    
    u_int8_t attrValue = 1;
    

    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    return result == 0;
    
}

@end

#pragma mark -
#pragma mark Orientation Support 

@implementation UITabBarController (SGD_2) 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return (UIInterfaceOrientationMaskAll);
}
@end

@implementation UINavigationController (SGD_2) 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return (UIInterfaceOrientationMaskAll);
}
@end
