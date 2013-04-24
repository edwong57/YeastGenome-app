//
//  FeatSyncUpList.m
//  SGD_2
//
//  Created by Vivek on 08/07/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*
 
 Class to manage the features,select the feature and sync to get
 the updated data available from server.The features data is accessed 
 from server and mereged into the local database.
  
 */

#import "FeatManageData.h"
#import "Features.h"
#import "staticFunctionClass.h"
#import "webServiceHelper.h"
#import "SBJSON.h"
#import "SGD_2AppDelegate.h"
#import "FeatAnnotation.h"
#import "Reachability.h"

@implementation FeatManageData

@synthesize managedObjectContext;
@synthesize allSynUpFeats;
@synthesize selectedArray;
@synthesize allFeatures;
@synthesize array; 
@synthesize inPseudoEditMode;
@synthesize selectedImage;
@synthesize unselectedImage;
@synthesize sBar;
@synthesize progAlertView, activityIndView;
@synthesize rowsToBeUpdates;

#pragma mark -
#pragma mark Orientation Support
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

// for ios6
-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

/*Function is called when device is rotated and implements 
 the orientation/alignment of the labels*/
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	
	[tempTableview reloadData];
}



-(void)Pagination
{
    page = page+adjacents; 
    
     
    
    if (isSearch) {
        isSearch = true;
        [self performSelectorInBackground:@selector(getSearchdata) withObject:nil];
        
    }
    else
    {
        if (!isFetching)
        {
        
        
        isFetching = TRUE;
         
        [self performSelectorInBackground:@selector(getdata) withObject:nil];
        
            isSearch = false;
        
        }
    }
    
    
    
}

//function is called when user scrolls the table view
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    NSInteger currentOffset = scrollView.contentOffset.y;
     
    
    if (currentOffset>(scrollView.contentSize.height * 0.50) || cntScroll==0) 
    {
        cntScroll++;
        
        if (currentOffset > firstScrollOffset) 
        {
            progressInd.alpha = 1;             
            firstScrollOffset = currentOffset;
            [self Pagination];            
        }
        else
        {
            firstScrollOffset = currentOffset;
        }
        
        
    }
    
    
    
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated 
{
    isDataNotFound = NO;

    page = 0;
    adjacents = 30;
    firstScrollOffset = 0;
    cntScroll = 0;

    [super viewWillAppear:animated];
	@try
	{
       
        
		self.inPseudoEditMode = YES;
		
		self.selectedImage = [UIImage imageNamed:@"check_report.png"];
		self.unselectedImage = [UIImage imageNamed:@"unselected.png"];
	        
        [self performSelectorInBackground:@selector(doInBackground) withObject:nil];

        
	}
	@catch (NSException * e)
	{
		NSLog(@"%@", [e description]);
	}
		
}




- (void)doInBackground {
    NSAutoreleasePool * pool; 
    pool = [[NSAutoreleasePool alloc] init]; 
    [self getdata];
    [self performSelectorOnMainThread:@selector(stopIndicator) withObject:nil waitUntilDone:NO];
    [pool drain]; 
}

- (void)stopIndicator {
    [activityIndView stopAnimating];

    [self populateSelectedArray];
}


-(void)showProgressIndicator
{
    CGRect frame;
    
    
    NSRange textRange1 = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
	if (textRange1.location != NSNotFound) {
        
        if(orientation == UIInterfaceOrientationLandscapeLeft || 
           orientation == UIInterfaceOrientationLandscapeRight) 
        {
            fadeView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            frame = CGRectMake(450, 300, 50, 50);
        }
        else
        {
            fadeView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
            frame = CGRectMake(350, 400, 50, 50);
        }
        
        
    }else 
    {
        
        if(orientation == UIInterfaceOrientationLandscapeLeft || 
           orientation == UIInterfaceOrientationLandscapeRight) 
        {
            fadeView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
            frame = CGRectMake(235, 110, 30, 30);
        }
        else
        {
            fadeView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
            frame = CGRectMake(145, 180, 30, 30);
        }
        
    }
    
    
    
    
    
    fadeView.backgroundColor = [UIColor blackColor];
    fadeView.alpha=.6;
    progressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    [progressInd startAnimating];
    progressInd.activityIndicatorViewStyle =UIActivityIndicatorViewStyleWhiteLarge ;
    progressInd.backgroundColor = [UIColor clearColor];
    [fadeView addSubview:progressInd];
    [self.view addSubview:fadeView];
}

-(void)stopProgressIndicator
{
    [fadeView removeFromSuperview] ;
}


-(void)reloadTableData
{
    [tempTableview reloadData];
}

//Get data of feature with feature ORF and display in tableview.
-(void)getdata{
    
    isSearch = false;
    
    [self performSelectorOnMainThread:@selector(showProgressIndicator) withObject:nil waitUntilDone:YES];
    
     
     
    @try
	{      
        tpages=0;
        
        [self getORFData:page limit:adjacents];
               
    }
    
	@catch (NSException * e) 
	{
		NSLog(@"%@",[e description]);
	}
    [self performSelectorOnMainThread:@selector(stopProgressIndicator) withObject:nil waitUntilDone:YES];  
       
}


-(void)getORFData:(int)offset limit:(int)limit{

    
       
    NSArray *fetchedObjects;
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    // Set limit for core data //
    [request setFetchLimit:adjacents];
    [request setFetchOffset:page];
    
    
    NSPredicate *fetchByFeatureType = [NSPredicate predicateWithFormat:@"featureType = %@",@"ORF"];
   
    
    [request setPredicate:fetchByFeatureType];

    
    
    NSError *error;
    fetchedObjects = [self.managedObjectContext executeFetchRequest:request error:&error];
   
    [request release];
    

  
    if ([fetchedObjects count]==0) {
        [self performSelectorOnMainThread:@selector(stopProgressIndicator) withObject:nil waitUntilDone:YES]; 
        return;
    }
    if (allSynUpFeats==nil) {
        allSynUpFeats= [[NSMutableArray alloc]init];
    }
    [allSynUpFeats  addObjectsFromArray:fetchedObjects];
    
    if (allFeatures==nil) {
        allFeatures= [[NSMutableArray alloc]init];
    }
    [allFeatures addObjectsFromArray:fetchedObjects];
    
    tpages = [allSynUpFeats count];
  
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"featureName" ascending:YES];
    
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"geneName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,nil];
    [allSynUpFeats sortUsingDescriptors:sortDescriptors];
    [sortDescriptor1 release];
    [sortDescriptor2 release];
    
    isFetching = FALSE;
    [self populateSelectedArray];
    [self performSelectorOnMainThread:@selector(reloadTableData) withObject:nil waitUntilDone:YES];

}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	sBar.delegate = self;
    isDataNotFound = NO;
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];

    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Standard Info" 
																   style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
    
    UIBarButtonItem *synupbtn =	[[[UIBarButtonItem alloc] initWithTitle:@"Sync Up" 
																  style:UIBarButtonItemStyleDone
																 target:self
																 action:@selector(pushedSyncUpButton:)] autorelease];
    [self.navigationItem setRightBarButtonItem:synupbtn animated:NO];

	
	UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
	tlabel.text=self.navigationItem.title;
    tlabel.textColor=[UIColor blackColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
	
	[tlabel release];	
}


-(void) createProgressionAlertWithMessage:(NSString *)message
{
    
   
	if (activityIndView != nil) 
		activityIndView = nil;
	

    CGRect activityFrame; 
    NSRange textRange1 = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
	if (textRange1.location != NSNotFound) {
        
        if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) {
            
            activityFrame = CGRectMake(500.0f-18.0f, 300.0f, 60.0f, 60.0f); 
            
        }else{
            
            activityFrame = CGRectMake(380.0f-18.0f, 400.0f, 60.0f, 60.0f); 
            
        }
        
        
    }else {
        
        if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) {
            
            activityFrame = CGRectMake(250.0f-18.0f, 100.0f, 37.0f, 37.0f); 
            
            
        }else{
            
            activityFrame = CGRectMake(165.0f-18.0f, 150.0f, 37.0f, 37.0f); 
            
        }
        
    }
    
    
	activityIndView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndView.frame = activityFrame;
	
	[self.view addSubview:activityIndView];
	[activityIndView startAnimating];

   }

#pragma mark -
#pragma mark Actions
//Called when Sync Up button is pressed
-(IBAction)pushedSyncUpButton:(id)sender
{
    @try
        {
            BOOL checkSelected = NO;
            for (NSNumber *rowSelected in selectedArray)
            {
                if ([rowSelected boolValue])
                {
                    checkSelected = YES;
                }
            }
            if (checkSelected) 
            {
                Reachability *rchbility = [[Reachability reachabilityWithHostName: @"yeastgenome.org"] retain];;
                NetworkStatus remoteHostStatus = [rchbility currentReachabilityStatus];
                [rchbility release];
                
                //CHECKING 'WAN' and Wi-Fi CONNECTION AVAILABILITY
                if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
                {

                
                UIAlertView	*syncAlert = [[UIAlertView alloc] initWithTitle:@"Sync Up features" 
                                                                    message:@"You want to Sync up selected features?"
                                                                   delegate:self 
                                                          cancelButtonTitle:@"Cancel"  
                                                          otherButtonTitles:@"Yes", nil];
                
                [syncAlert show];
                [syncAlert release];
                    
                    //IF NOT REACHABLE THEN GIVING ALERT MESSAGE OF CONNECTION NOT AVAILABLE
                }else if(remoteHostStatus == NotReachable)
                {
                    
                    UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
                    [dialog setDelegate:self];
                    [dialog setTitle:@"No network"];
                    [dialog setMessage:@"Please check your network connection"];
                    [dialog addButtonWithTitle:@"Ok"];
                    [dialog show];	
                    [dialog release];
                                   
                }
            }else 
            {
                
                UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
                [dialog setDelegate:self];
                [dialog setTitle:@"Please select at least one gene or feature name"];
                [dialog addButtonWithTitle:@"OK"];
                [dialog show];	
                [dialog release];
            }
            
       
             
    }
    @catch (NSException * e) 
    {
        NSLog(@"%@",[e description]);
    }
	


}
    
	


#pragma mark -
#pragma mark Sync Up Methods
//Function to sync the selected feature
-(void)doSyncUp
{
   
    
    
	@try
	{
		if (rowsToBeUpdates == nil) 
		{
			rowsToBeUpdates = [[NSMutableArray alloc] init];
		}
		else 
		{
			rowsToBeUpdates = nil;
			[rowsToBeUpdates release];
			rowsToBeUpdates = [[NSMutableArray alloc] init];
		}

		int index = 0;
		for (NSNumber *rowSelected in selectedArray)
		{
			if ([rowSelected boolValue])
			{
				[rowsToBeUpdates addObject:[allSynUpFeats objectAtIndex:index]];
			}		
			index++;
		}
        
        Counter = 0; 
        
		for (Features *value in rowsToBeUpdates)
		{
			@synchronized(self)
			{
				[self webServiceRequest:value.featureName];
			}
		}
		
                
	}
	@catch (NSException * e) 
	{
		NSLog(@"Catch Error: %@", [e description]);
	}
	
    if(isDataNotFound){
        UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
        [dialog setDelegate:self];
        [dialog setTitle:@"Data not found"];
        [dialog setMessage:@"For given Gene Name/ FeatureName synchronization is not possible"];
        [dialog addButtonWithTitle:@"OK"];
        [dialog show];	
        [dialog release];
    }
    isDataNotFound = NO;
	inPseudoEditMode = YES;
	
	[self searchBar:sBar textDidChange:sBar.text];
	[self populateSelectedArray];

}

#pragma mark -
#pragma mark Web Service Call 

-(void)webServiceRequest:(NSString *)featurename
{
	@try
	{ 
     
		NSString *str = featurename;
		NSString *URLAddress;
		
		NSRange arsRange = [str rangeOfString:@"ars" options:NSCaseInsensitiveSearch];
		NSRange cenRange = [str rangeOfString:@"cen" options:NSCaseInsensitiveSearch];
		NSRange telRange = [str rangeOfString:@"tel" options:NSCaseInsensitiveSearch];
		NSRange tyRange = [str rangeOfString:@"Ty" options:NSCaseInsensitiveSearch];
		NSRange ltrDRange = [str rangeOfString:@"delta" options:NSCaseInsensitiveSearch];
		NSRange ltrORange = [str rangeOfString:@"omega" options:NSCaseInsensitiveSearch];
		NSRange ltrTRange = [str rangeOfString:@"tau" options:NSCaseInsensitiveSearch];
		NSRange ltrSRange = [str rangeOfString:@"sigma" options:NSCaseInsensitiveSearch];
		
		if (arsRange.location != NSNotFound) 
			URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"ARS.featureType+ARS.secondaryIdentifier+ARS.symbol+ARS.primaryIdentifier+ARS.locations.start+ARS.locations.end+ARS.locations.strand+ARS.locations.locatedOn.primaryIdentifier+ARS.qualifier+ARS.featAttribute+ARS.description+ARS.name+ARS.sgdAlias\"+sortOrder=\"ARS.featureType+asc\"+constraintLogic=\"A+and+B\"><constraint+path=\"ARS.status\"+code=\"A\"+op=\"=\"+value=\"Active\"/><constraint+path=\"ARS.secondaryIdentifier\"+code=\"B\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects",featurename];
		else if(cenRange.location != NSNotFound)
			URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Centromere.featureType+Centromere.secondaryIdentifier+Centromere.symbol+Centromere.primaryIdentifier+Centromere.locations.start+Centromere.locations.end+Centromere.locations.strand+Centromere.locations.locatedOn.primaryIdentifier+Centromere.qualifier+Centromere.featAttribute+Centromere.description+Centromere.name+Centromere.sgdAlias\"+sortOrder=\"Centromere.featureType+asc\"+constraintLogic=\"A+and+B\"><constraint+path=\"Centromere.status\"+code=\"A\"+op=\"=\"+value=\"Active\"/><constraint+path=\"Centromere.secondaryIdentifier\"+code=\"B\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects",featurename];
		else if(telRange.location != NSNotFound)	
			URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Telomere.featureType+Telomere.secondaryIdentifier+Telomere.symbol+Telomere.primaryIdentifier+Telomere.locations.start+Telomere.locations.end+Telomere.locations.strand+Telomere.locations.locatedOn.primaryIdentifier+Telomere.qualifier+Telomere.featAttribute+Telomere.description+Telomere.name+Telomere.sgdAlias\"+sortOrder=\"Telomere.featureType+asc\"+constraintLogic=\"A+and+B\"><constraint+path=\"Telomere.status\"+code=\"A\"+op=\"=\"+value=\"Active\"/><constraint+path=\"Telomere.secondaryIdentifier\"+code=\"B\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects",featurename];
		else if(tyRange.location != NSNotFound)
			URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Retrotransposon.featureType+Retrotransposon.secondaryIdentifier+Retrotransposon.symbol+Retrotransposon.primaryIdentifier+Retrotransposon.locations.start+Retrotransposon.locations.end+Retrotransposon.locations.strand+Retrotransposon.locations.locatedOn.primaryIdentifier+Retrotransposon.qualifier+Retrotransposon.featAttribute+Retrotransposon.description+Retrotransposon.name+Retrotransposon.sgdAlias\"+sortOrder=\"Retrotransposon.featureType+asc\"+constraintLogic=\"A+and+B\"><constraint+path=\"Retrotransposon.status\"+code=\"A\"+op=\"=\"+value=\"Active\"/><constraint+path=\"Retrotransposon.secondaryIdentifier\"+code=\"B\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects",featurename];
		else if(ltrDRange.location != NSNotFound || ltrORange.location != NSNotFound || ltrTRange.location != NSNotFound || ltrSRange.location != NSNotFound)
			URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"LongTerminalRepeat.featureType+LongTerminalRepeat.secondaryIdentifier+LongTerminalRepeat.symbol+LongTerminalRepeat.primaryIdentifier+LongTerminalRepeat.locations.start+LongTerminalRepeat.locations.end+LongTerminalRepeat.locations.strand+LongTerminalRepeat.locations.locatedOn.primaryIdentifier+LongTerminalRepeat.qualifier+LongTerminalRepeat.featAttribute+LongTerminalRepeat.description+LongTerminalRepeat.name+LongTerminalRepeat.sgdAlias\"+sortOrder=\"LongTerminalRepeat.featureType+asc\"+constraintLogic=\"A+and+B\"><constraint+path=\"LongTerminalRepeat.status\"+code=\"A\"+op=\"=\"+value=\"Active\"/><constraint+path=\"LongTerminalRepeat.secondaryIdentifier\"+code=\"B\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects",featurename];
		else


		URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.description+Gene.featureType+Gene.primaryIdentifier+Gene.qualifier+Gene.secondaryIdentifier+Gene.symbol+Gene.name+Gene.locations.start+Gene.locations.end+Gene.locations.strand+Gene.featAttribute+Gene.locations.locatedOn.primaryIdentifier+Gene.sgdAlias\"+sortOrder=\"Gene.featureType+desc\"><constraint+path=\"Gene.secondaryIdentifier\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects",featurename];
        
        
        webServiceHelper *webhelper = [[webServiceHelper alloc]init];
		[webhelper startConnection:URLAddress];
		[webhelper setDelegate:self];
		
	}
	@catch (NSException *e) {
		NSLog(@"%@",[e description]);
	}
}

- (void)finishedDownloading:(NSString *)strJSONResponse
{
    

	@try 
	{	
		if ([activityIndView isAnimating]) 
			[activityIndView stopAnimating];
		if ([progAlertView isVisible]) 
			[progAlertView dismissWithClickedButtonIndex:(NSInteger)nil animated:YES];
		@synchronized(self)
		{
			if ([strJSONResponse length] != 0) 
			{
                
				NSRange   arange = [strJSONResponse rangeOfString:@"\"results\":["];
				NSString *strtest = [strJSONResponse substringFromIndex:arange.location+11];
				NSRange   brange = [strtest rangeOfString:@"],\"executionTime\""];
				NSString *strAllGene = [[NSString alloc] initWithString:[strtest substringToIndex:brange.location]];
				
				strAllGene = [strAllGene stringByReplacingOccurrencesOfString:@"\n" withString:@""];
				strAllGene = [strAllGene stringByReplacingOccurrencesOfString:@"\r" withString:@""];
				strAllGene = [strAllGene stringByReplacingOccurrencesOfString:@"\t" withString:@""];
				
				if ([strAllGene length] != 0)
				{
						@synchronized(self) 
						{
							NSError *error;
							SBJSON *json = [[SBJSON new] autorelease];
							int asciiCode = [strAllGene characterAtIndex:[strAllGene length]-1];
							
							if (asciiCode != 125)
							{
								strAllGene  = [strAllGene stringByAppendingFormat:@"}"];
							}
							NSDictionary *dictionary = [json objectWithString:strAllGene error:&error];
							
							[self getResultsAndInsert:dictionary];
							
						}
				}
				else
				{
					UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
					[dialog setDelegate:self];
					[dialog setTitle:@"Unable to Update"];
					[dialog setMessage:@"For given Gene Name/ FeatureName synchronization is not possible"];
					[dialog addButtonWithTitle:@"OK"];
					[dialog show];	
					[dialog release];
				}
			}
			else
			{  
                isDataNotFound = YES;
               
			}
		}		

        if(Counter == [rowsToBeUpdates count]){
            
            UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
            [dialog setDelegate:self];
            //[dialog setTitle:@"Data updated"];
            [dialog setMessage:@"Data updated successfully."];
            [dialog addButtonWithTitle:@"OK"];
            [dialog show];	
            [dialog release];
            
            
            
        }
	}
	// now we are sure the download is complete
	@catch (NSException *e) 
	{
		NSLog(@"%@",[e description]);
	}
	
}

-(void) getResultsAndInsert:(NSDictionary *)resultSet
{
	Counter++;
    
	NSString *strDate = [NSString stringWithFormat:@"2000-03-19"];
	
	NSArray *allValues = [resultSet allValues];
	NSArray *allKeys = [resultSet allKeys];
	for (int i=0; i<[allValues count]; i++) 
	{
		if ([[allValues objectAtIndex:i] isEqual:[NSNull null] ]) 
		{
			[resultSet setValue:@"" forKey:[allKeys objectAtIndex:i]];
			
		}
	}
	
	@try
	{		
		@synchronized(self)
		{
			NSString *featName = [resultSet objectForKey:@"secondaryIdentifier"];
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
            
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features" inManagedObjectContext:self.managedObjectContext];
            
			[request setEntity:entity];
			
			NSArray *display = [featName componentsSeparatedByString: @"/"];
			
			if (display.count > 1) {
				featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:1]];
			} else {
				featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
			}
			
			NSPredicate *fetchByFeatureName = [NSPredicate predicateWithFormat:@"featureName = %@", featName];
			
			[request setPredicate:fetchByFeatureName];
			
			NSError *error;
			NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:request error:&error];
			
			Features *selectedFeatures = [fetchedObjects objectAtIndex:0];
			[request release];
			//Alias
			NSManagedObjectContext *aliasMOC = [NSEntityDescription insertNewObjectForEntityForName:@"Alias" inManagedObjectContext:managedObjectContext];
			[aliasMOC setValue:[resultSet objectForKey:@"sgdAlias"] forKey:@"aliasName"];
			[aliasMOC setValue:strDate forKey:@"dateCreated"];
			[aliasMOC setValue:[NSString stringWithFormat:@"NULL"] forKey:@"aliasType"];
			
			//FeatAnnotation
			NSManagedObjectContext *featAnnotMOC = [NSEntityDescription insertNewObjectForEntityForName:@"FeatAnnotation" inManagedObjectContext:managedObjectContext];
			[featAnnotMOC setValue:[resultSet objectForKey:@"description"] forKey:@"descriptions"];//[resultSet objectForKey:@"description"]
			[featAnnotMOC setValue:strDate forKey:@"dateCreated"];
			[featAnnotMOC setValue:[NSString stringWithFormat:@"NULL"] forKey:@"geneticPos"];
			[featAnnotMOC setValue:[resultSet objectForKey:@"qualifier"] forKey:@"qualifier"];
			[featAnnotMOC setValue:[resultSet objectForKey:@"featAttribute"] forKey:@"featAttribute"];
			[featAnnotMOC setValue:[resultSet objectForKey:@"name"] forKey:@"nameDescription"];
			
			//FeatLocation
			NSManagedObjectContext *featLocatMOC = [NSEntityDescription insertNewObjectForEntityForName:@"FeatLocation" inManagedObjectContext:managedObjectContext];
			[featLocatMOC setValue:[[resultSet valueForKeyPath:@"locations.strand"] objectAtIndex:0] forKey:@"strand"];
			[featLocatMOC setValue:strDate forKey:@"coordVer"];
			[featLocatMOC setValue:[NSNumber numberWithInt:[[[resultSet valueForKeyPath:@"locations.end"]  objectAtIndex:0] intValue]] forKey:@"maxCoord"];
			[featLocatMOC setValue:[NSNumber numberWithInt:[[[resultSet valueForKeyPath:@"locations.start"]  objectAtIndex:0] intValue]] forKey:@"minCoord"];
			[featLocatMOC setValue:strDate forKey:@"dateCreated"];
			[featLocatMOC setValue:[[resultSet valueForKeyPath:@"locations.locatedOn.primaryIdentifier"]  objectAtIndex:0] forKey:@"chromosome"];
			
			// FEATURES
			
			
			// ALIAS
			[aliasMOC setValue:selectedFeatures forKey:@"aliasToFeat"];
			
			// FEAT ANNOTATION
			[featAnnotMOC setValue:selectedFeatures forKey:@"annotToFeat"];
			
			// FEAT LOCATION
			[featLocatMOC setValue:selectedFeatures forKey:@"locToFeat"];
			
			[selectedFeatures setValue:[resultSet objectForKey:@"symbol"] forKey:@"geneName"];
			[selectedFeatures setValue:@"SGD" forKey:@"source"];
			[selectedFeatures setValue:[resultSet objectForKey:@"primaryIdentifier"] forKey:@"dbxrefId"];
			[selectedFeatures setValue:strDate forKey:@"dateCreated"];
			[selectedFeatures setValue:[resultSet objectForKey:@"featureType"] forKey:@"featureType"];
			[selectedFeatures setValue:[NSNumber numberWithInt:4932] forKey:@"taxonId"];
			[selectedFeatures setValue:[resultSet objectForKey:@"secondaryIdentifier"] forKey:@"featureName"];	
			
			NSMutableSet *aliasSet = [NSMutableSet set];
			[aliasSet addObject:aliasMOC];
			
			[selectedFeatures setValue:aliasSet forKey:@"aliases"];
			[selectedFeatures setValue:featAnnotMOC forKey:@"annotation"];
			[selectedFeatures setValue:featLocatMOC forKey:@"location"];
			
			
			NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
			
			[dnc addObserverForName:NSManagedObjectContextDidSaveNotification
							 object:managedObjectContext
							  queue:nil
						 usingBlock:^(NSNotification *saveNotification)
			 {
				 [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
				 
			 }];
			
			if (![managedObjectContext save:&error])
			{
				NSLog(@"%@",error);
			}
			
			[dnc removeObserver:self
						   name:NSManagedObjectContextDidSaveNotification
						 object:managedObjectContext];
		}
	}
	@catch (NSException * e)
	{
		NSLog(@"%@",[e description]);
	}
	
	inPseudoEditMode = YES;
	[tempTableview reloadData];
    
    
	
}
 


#pragma mark -
#pragma mark Alert Delegate
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	NSString *strTitle = [actionSheet title];
	
	if([strTitle compare:@"Delete Features"] == 0) 
	{
		if (buttonIndex == 1) 
		{
			[self populateSelectedArray];
			[tempTableview reloadData];
		}
		
	}
	else if([strTitle compare:@"Sync Up features"] == 0) 
	{
		if (buttonIndex == 1) 
		{
			[self createProgressionAlertWithMessage:@"Retrieving from SGD"];
			[self doSyncUp];
			[self populateSelectedArray];
			[tempTableview reloadData];
		}
		
	}
	else {
		return;
	}
	
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{	
	// only show the status bar’s cancel button while in edit mode
	[self.navigationController setNavigationBarHidden:NO animated:YES];

	sBar.showsCancelButton = YES;	
	sBar.autocorrectionType = UITextAutocorrectionTypeNo;
	
	// flush the previous search content
	
	
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{	
	sBar.showsCancelButton = NO;	
	sBar.showsScopeBar = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar 
{	
    
    page = 0;
    adjacents = 30;
    firstScrollOffset = 0;
    cntScroll = 0;
    
	// if a valid search was entered but the user wanted to cancel, bring back the main list content
	[self.navigationController setNavigationBarHidden:NO animated:YES];


	@try
	{
		[sBar resignFirstResponder];
		
		sBar.text = @"";
        
       // [self viewWillAppear:NO]; 
        [allSynUpFeats removeAllObjects];
        [allFeatures removeAllObjects];
        [self viewWillAppear:NO]; 
        
       
	}
	
	@catch(NSException *e)
	{
		NSLog(@"%@",[e description]);
	}
	
}

// called when Search (in our case “Search”) button pressed

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{	
    // These are the characters that are ~not~ acceptable
    NSCharacterSet *unacceptedInput =
    [[NSCharacterSet characterSetWithCharactersInString:CHARACTERS_NUMBERS] invertedSet];
    
    // Create array of strings from incoming string using the unacceptable
    // characters as the trigger of where to split the string.
    // If array has more than one entry, there was at least one unacceptable character
    if ([[searchBar.text componentsSeparatedByCharactersInSet:unacceptedInput] count] > 1){
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Warning!" message:@"Please enter a valid  text." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    
    
    else 
    {
        
    [self performSelectorOnMainThread:@selector(showProgressIndicator) withObject:nil waitUntilDone:YES];

    isSearch = true;
    
    page = 0;
    adjacents = 30;
    firstScrollOffset = 0;
    cntScroll = 0;
    
    tpages=0;
    
	[self.navigationController setNavigationBarHidden:NO animated:YES];

	[sBar resignFirstResponder];
	
    
    //Fetch from database  
    //------
    [allSynUpFeats removeAllObjects];
    [allFeatures removeAllObjects];
    NSString*geneSearchText = searchBar.text;
    
    NSString *predString = [NSString stringWithFormat:
                            @"geneName BEGINSWITH [c] '%@' OR featureName BEGINSWITH [c] '%@'",geneSearchText,geneSearchText];
    NSPredicate *pred = [NSPredicate 
                         predicateWithFormat:predString];
    
    // We still need an entity description, of course
    
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Features" inManagedObjectContext:managedObjectContext];
    
    // And, of course, a fetch request. This time we give it both the entity
    // description and the predicate we've just created.
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];	
    [req setPredicate:pred];
    
    // We declare an NSError and handle errors by raising an exception,
    // just like in the previous method
	
    NSError *error = nil;
    
    array =nil;
    array = [managedObjectContext executeFetchRequest:req
                                                error:&error];
    
    
   
    
    if (array == nil)
    {
        NSException *exception = [NSException 
                                  exceptionWithName:@"Core Data exception" 
                                  reason:[error localizedDescription] 
                                  userInfo:nil];
        [exception raise];
    }
    
    // Now, release the fetch request and return the array
    
    [req release];
    
    //---------
    tpages = [array count];
   
  
    
    NSArray *halfArray;
    NSRange theRange;
    
    theRange.location = page;
    theRange.length =  adjacents>tpages?tpages:adjacents;
    
    
    
    halfArray = [array subarrayWithRange:theRange];
    
    
     
    
    allSynUpFeats = nil;
    [allSynUpFeats release];
    
    allSynUpFeats= [[NSMutableArray alloc]init];
    

    [allSynUpFeats addObjectsFromArray:halfArray];
      
   
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"geneName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [allSynUpFeats sortUsingDescriptors:sortDescriptors];
    
    
    
    [sortDescriptor release];
    
    [self populateSelectedArray];
    [tempTableview reloadData];
    [self performSelectorOnMainThread:@selector(stopProgressIndicator) withObject:nil waitUntilDone:YES];
    //-------
    if([allSynUpFeats count]==0){
    	UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
        [dialog setDelegate:self];
        [dialog setTitle:@"Data not found"];
        [dialog setMessage:@"Your query is not a valid gene name (or feature name),please try a different search."];
        [dialog addButtonWithTitle:@"OK"];
        [dialog show];	
        [dialog release];
        return;
        }
    }
}

-(void)fnReloadTable
{
    [tempTableview reloadData];
}
-(void)getSearchdata
{
     
    NSString *predString = [NSString stringWithFormat:
                            @"geneName BEGINSWITH [c] '%@' OR featureName BEGINSWITH [c] '%@'",sBar.text,sBar.text];
    NSPredicate *pred = [NSPredicate 
                         predicateWithFormat:predString];
    
    // We still need an entity description, of course
    
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Features" inManagedObjectContext:managedObjectContext];
    
    // And, of course, a fetch request. This time we give it both the entity
    // description and the predicate we've just created.
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];	
    [req setPredicate:pred];
    
    // We declare an NSError and handle errors by raising an exception.
	
    NSError *error = nil;
    
    array =nil;
    array = [managedObjectContext executeFetchRequest:req
                                                error:&error];
    if (page+adjacents<=tpages)
    {
        NSArray *halfArray;
        NSRange theRange;
        
        theRange.location = page;
        theRange.length =  adjacents>tpages?tpages:adjacents;
        
        
        halfArray = [array subarrayWithRange:theRange];
        [allSynUpFeats addObjectsFromArray:halfArray];
        
        [self populateSelectedArray];
        
        [self performSelectorOnMainThread:@selector(fnReloadTable) withObject:nil waitUntilDone:YES];
      
        
    }

}


#pragma mark -
#pragma mark Table view delegate

- (void)populateSelectedArray
{
	@try {
		NSMutableArray *array1 = [[NSMutableArray alloc] initWithCapacity:[allSynUpFeats count]];
		for (int i=0; i < [allSynUpFeats count]; i++)
			[array1 addObject:[NSNumber numberWithBool:NO]];
		self.selectedArray = array1;
		[array1 release];
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@", [e description]);
	}
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [allSynUpFeats count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *myCell = @"myCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
	// Configure the cell...
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    Features *singleFeat = [allSynUpFeats objectAtIndex:indexPath.row];
    CGRect contentRect;
    
	//if (cell == nil)
    {
		
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:myCell] autorelease];
        
        
        NSRange textRange =[[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
        if(textRange.location != NSNotFound)
        {   
            
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                contentRect = CGRectMake(125, 0, 870, 70);
            }
            else
            {
                contentRect = CGRectMake(125, 0, 590, 70);            
            }
            
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(04.0, 30.0, 20.0, 20.0);
            
            NSNumber *selected = [selectedArray objectAtIndex:[indexPath row]];
            UIImage *image = ([selected boolValue]) ? selectedImage : unselectedImage;
            imageView.image = image;
            [cell.contentView addSubview:imageView];
            imageView.hidden = !inPseudoEditMode;
            imageView.tag = kCellImageViewTag;
            
            
                 
            
            
            UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(30, 7, 80, 65)];
            
            imgview.image = [UIImage imageNamed:@"Square.png"];
            imgview.tag = kCellImageTag;
            
            UIImageView *favImg = [[UIImageView alloc]initWithFrame:CGRectMake(110, 02, 15, 20)];
            
            favImg.tag = kCellFavImgTag;
            
            if ([[NSString stringWithFormat:@"%d",singleFeat.favorite] isEqualToString:@"1"]) {		
                favImg.image = nil;
                
            } else {
                favImg.image = nil;
            }
            
            
            UILabel *FeatureName = [[UILabel alloc] initWithFrame:CGRectMake(0, 05, 80, 20)];
            FeatureName.backgroundColor = [UIColor clearColor];
            FeatureName.tag = kCellFeatureNmTag;
            FeatureName.textColor = [UIColor redColor];
            FeatureName.font = [UIFont systemFontOfSize:12];
            [FeatureName setTextAlignment:UITextAlignmentCenter];
            
            FeatureName.text = singleFeat.featureName;
            
            UILabel *geneName = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 80, 20)];
            geneName.backgroundColor = [UIColor clearColor];
            geneName.tag = kCellGeneNmTag;
            geneName.font = [UIFont systemFontOfSize:12];
            [geneName setTextAlignment:UITextAlignmentCenter];
            
            geneName.text = singleFeat.geneName;
            
            
            
            UITextView *textView = [[UITextView alloc] initWithFrame:contentRect];
            NSString *strAllDetails = singleFeat.annotation.descriptions;
            textView.text = strAllDetails;
            textView.textColor = [UIColor blackColor];
            textView.font = [UIFont systemFontOfSize:16];
            textView.userInteractionEnabled = NO;
            textView.tag = kCellLabelTag;
            textView.backgroundColor = [UIColor clearColor];
            
            [imgview addSubview:FeatureName];
            [imgview addSubview:geneName];
            [cell.contentView addSubview:imgview];
            [cell.contentView addSubview:textView];
            [cell.contentView addSubview:favImg];
            
            
            [textView release];
            [imageView release];
            
            [imgview release];
            [favImg release];
            [FeatureName release];
            [geneName release];
            
            
        }
        else
        {
            CGRect contentRect1; 
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                contentRect1 = CGRectMake(115, 3, 270,65);           
                
            }
            else
            {
                
                contentRect1 = CGRectMake(115, 3, 177,65);            
                
                
            }
            
            
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(2.0, 30.0, 20.0, 20.0);
            
            
            NSNumber *selected = [selectedArray objectAtIndex:[indexPath row]];
            UIImage *image = ([selected boolValue]) ? selectedImage : unselectedImage;
            
            imageView.image = image;
            [cell.contentView addSubview:imageView];
            imageView.hidden = !inPseudoEditMode;
            imageView.tag = kCellImageViewTag;
            [imageView release];
            
            
            UILabel *FeatureName = [[UILabel alloc] initWithFrame:CGRectMake(0, 05, 80, 20)];
            FeatureName.backgroundColor = [UIColor clearColor];
            FeatureName.tag = kCellFeatureNmTag;
            FeatureName.textColor = [UIColor redColor];
            
            FeatureName.font = [UIFont systemFontOfSize:12];
            [FeatureName setTextAlignment:UITextAlignmentCenter];
            
            FeatureName.text = singleFeat.featureName;
            
            UILabel *geneName = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 80, 20)];
            geneName.backgroundColor = [UIColor clearColor];
            geneName.tag = kCellGeneNmTag;
            geneName.font = [UIFont systemFontOfSize:12];
            [geneName setTextAlignment:UITextAlignmentCenter];
            geneName.text = singleFeat.geneName;
            
            UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(25, 13, 80, 65)];
            
            imgview.image = [UIImage imageNamed:@"Square.png"];
            imgview.tag = kCellImageTag;
            
            UIImageView *favImg = [[UIImageView alloc]initWithFrame:CGRectMake(100, 02, 15, 20)];
            favImg.tag = kCellFavImgTag;
            
            if ([[NSString stringWithFormat:@"%d",singleFeat.favorite] isEqualToString:@"1"]) {		
                favImg.image = nil;
                
            } else {
                favImg.image = nil;
            }
            
          
            UITextView *textView = [[UITextView alloc] initWithFrame:contentRect1];
            textView.tag = kCellLabelTag;
            
            
            NSString *strAllDetails = singleFeat.annotation.descriptions;
            textView.font = [UIFont systemFontOfSize:11];
            textView.userInteractionEnabled = NO;
            textView.textColor = [UIColor blackColor];
            textView.backgroundColor = [UIColor clearColor];
            
            textView.text = strAllDetails;
            
            
            [imgview addSubview:FeatureName];
            [imgview addSubview:geneName];
            [cell.contentView addSubview:imgview];
            [cell.contentView addSubview:textView];
            [cell.contentView addSubview:favImg];
            
            [textView release];
            [imgview release];
            [favImg release];
            [FeatureName release];
            [geneName release];
            
        }
        
        
    }
        
	
	return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSRange textRange =[[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if(textRange.location != NSNotFound)
	{
        return 80;
	}
	else {
		return 90;
	}
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
    [tempTableview deselectRowAtIndexPath:indexPath animated:YES];
	if (inPseudoEditMode)
	{
		BOOL selected = [[selectedArray objectAtIndex:[indexPath row]] boolValue];
		[selectedArray replaceObjectAtIndex:[indexPath row] withObject:[NSNumber numberWithBool:!selected]];
		[tempTableview reloadData];
	}
	
}


//Set Label Size according to the label text length

- (void)setLabelSizeFor: (UILabel *)labelToSet labelText:(NSString *)labelText {
	
	CGSize maxLabelSize = CGSizeMake(310, 99999);//219
	CGSize expectedLabelSize = [labelText sizeWithFont:labelToSet.font 
									 constrainedToSize:maxLabelSize
										 lineBreakMode:labelToSet.lineBreakMode];
	CGRect newFrame = labelToSet.frame;
	newFrame.size.height = expectedLabelSize.height;	
	labelToSet.frame = newFrame;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	if (allSynUpFeats != nil) 
		[allSynUpFeats release];
	
	[selectedArray release];
	[selectedImage release];
	[unselectedImage release];
	if (progAlertView != nil)
		[progAlertView release];
	if (activityIndView != nil)
		[activityIndView release];
	
    [super dealloc];
}


@end

