//
//  FeatReferencesDetails.m
//  SGD_Vivek
//
//  Created by Vivek on 27/04/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*
 Class to implement the References of the Feature.
 The references for the feature is listed out in table view.
 */

#import "FeatReferencesDetails.h"
#import "staticFunctionClass.h"
#import "EmailViewController.h"
#import "SBJSON.h"
#import "webServiceHelper.h"
#import "References.h"
#import "Reachability.h"
#import "BrowseImgView.h"
#import "JSON/JSON.h"

@implementation FeatReferencesDetails


@synthesize allObjects;
@synthesize progAlertView, activityIndView;
@synthesize managedObjectContext;
@synthesize selectedFeature;
@synthesize isPhysNotMapped;

#pragma mark -
#pragma mark Orientation Support 
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

//FOR IOS6
-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	
	[tempTableview reloadData];
}


#pragma mark -
#pragma mark View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
       
	[tempTableview reloadData];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [staticFunctionClass initBrowseImg];

		
	allObjects = [[NSMutableArray alloc] init];
	
	
	
	
	UIView *EmailFavView = [[UIView alloc]initWithFrame:CGRectMake(0,0,35,35)];
	EmailFavView.backgroundColor = [UIColor clearColor];
	
	static UIImage *EmailImage;
	CGRect EmailFrame = CGRectMake(0,1, 35,35);
	EmailButton = [[UIButton alloc]initWithFrame:EmailFrame];
	EmailImage = [UIImage imageNamed:@"email.png"];
	[EmailButton setBackgroundImage:EmailImage forState:UIControlStateNormal];
	EmailButton.backgroundColor = [UIColor clearColor];
	
	[EmailButton addTarget:self action:@selector(pushedEmailButton:) forControlEvents:UIControlEventTouchUpInside];
	
	
	[EmailFavView addSubview:EmailButton];
	
	
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:EmailFavView];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	[EmailButton release];
	[EmailFavView release];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSString *featName = [staticFunctionClass getGeneName];
	
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
	tlabel.text = [NSString stringWithFormat:@"%@ %@",featName,@"References"];
    tlabel.textColor=[UIColor blackColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    [tlabel release];
	
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
	
	selectedFeature = [fetchedObjects objectAtIndex:0];	
	
	[request release];
	
	NSSet *referSet = selectedFeature.references;
	
	if ([referSet count] != 0)
	{
		for (References *referObj in [referSet allObjects]) 
		{
			NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
			[tmpDict setValue:[referObj citation] forKey:@"citation"];
			[tmpDict setValue:[referObj refPubMedId] forKey:@"pubMedId"];
			[allObjects addObject:tmpDict];
			[tmpDict release];
		}
	}
	else
	{
		Reachability *rchbility = [[Reachability reachabilityWithHostName: @"yeastgenome.org"] retain];;
		NetworkStatus remoteHostStatus = [rchbility currentReachabilityStatus];
		[rchbility release];
		
		//CHECKING 'WAN' and Wi-Fi CONNECTION AVAILABILITY
		if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
		{
			//CALLING WEB-SERVICE HELPER CLASS OBJECT FOR CHECKING CONNECTIVITY TO SGD SERVER
			[self createProgressionAlertWithMessage:@"Retrieving from SGD"];
			
			NSString *str;
            
            if(isPhysNotMapped)
            {     
                str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"NotPhysicallyMapped.primaryIdentifier+NotPhysicallyMapped.secondaryIdentifier+NotPhysicallyMapped.symbol+NotPhysicallyMapped.name+NotPhysicallyMapped.organism.shortName+NotPhysicallyMapped.publications.pubMedId+NotPhysicallyMapped.publications.citation+NotPhysicallyMapped.publications.title+NotPhysicallyMapped.publications.journal+NotPhysicallyMapped.featureType\"+sortOrder=\"NotPhysicallyMapped.primaryIdentifier+asc\"><constraint+path=\"NotPhysicallyMapped.secondaryIdentifier\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName];
                
               // NSLog(@"Non phys map");
            }
            else
                str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.publications.citation+Gene.publications.pubMedId\"><constraint+path=\"Gene.secondaryIdentifier\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp", featName];
                
			[self webServiceCall:str];
		}
		
		//IF NOT REACHABLE THEN GIVING ALERT MESSAGE OF CONNECTION NOT AVAILABLE
		else if(remoteHostStatus == NotReachable)
		{
			
			UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
			[dialog setDelegate:self];
            [dialog setTitle:@"No network"];
            [dialog setMessage:@"Please check your network connection"];
			[dialog addButtonWithTitle:@"Ok"];
			[dialog show];	
			[dialog release];
			return;
		}
		
	}

	[tempTableview reloadData];
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark -
#pragma mark Web Service Call 

- (void)webServiceCall:(NSString *)webserviceName
{
	@try
	{
		webServiceHelper *webhelper = [[webServiceHelper alloc]init];
		[webhelper startConnection:webserviceName];
		[webhelper setDelegate:self];
	}
	@catch (NSException *e) 
	{
		NSLog(@"%@",[e description]);
	}
}


// implement the download delegate method

- (void)finishedDownloading:(NSString *)strJSONResponse
{
    
   //NSLog(@"REsponse is :%@",strJSONResponse);
//    
    NSError *error;
    SBJSON *json =  [[SBJSON new] autorelease] ;
    
    strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\\\"" withString:@""];
    NSString *desc = [[strJSONResponse JSONValue] objectForKey:@"description"];
    desc = [desc stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    desc = [desc stringByReplacingOccurrencesOfString:@"\u2018" withString:@""];
    desc = [desc stringByReplacingOccurrencesOfString:@"\u2019" withString:@""];
    
    NSDictionary *dictionary = [json objectWithString:strJSONResponse error:&error];
    
        // NSLog(@"REsponse dict is :%@",[[[dictionary objectForKey:@"results"] objectAtIndex:0] objectForKey:@"publications"]);
    
    @try 
	{
        if ([activityIndView isAnimating]) 
            [activityIndView stopAnimating];
        
        if([(NSArray *)[dictionary objectForKey:@"results"] count] > 0)
        {
            NSArray *arrRef = [[NSArray alloc] initWithArray:[[[dictionary objectForKey:@"results"] objectAtIndex:0] objectForKey:@"publications"]];
        
           // NSLog(@"REsponse dict is :%@",arrRef);
        
            @synchronized(self)
            {
                if ([strJSONResponse length] != 0) 
                {
                    NSString *findStr = [NSString stringWithFormat:@"\"citation\""];
                    
                 //   NSRange arange = [strJSONResponse rangeOfString:findStr];
                    if ([arrRef count] > 0) 
                    {
                        for (int i=0; i<[arrRef count]; i++)
                        {
                            dictionary = [arrRef objectAtIndex:i];
                            [self getResultsAndInsert:dictionary];
                        }
                    }
                    else 
                    {
                        UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
                        [dialog setDelegate:self];
                        [dialog setTitle:@"Reference details not found"];
                        //[dialog setMessage:@"No match found,please try another query."];
                        [dialog addButtonWithTitle:@"OK"];
                        [dialog show];	
                        [dialog release];
                    }

                }
                else
                {
                    UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
                    [dialog setDelegate:self];
                    [dialog setTitle:@"Reference details not found"];
                    //[dialog setMessage:@"No match found,please try another query."];
                    [dialog addButtonWithTitle:@"OK"];
                    [dialog show];	
                    [dialog release];
                }
            }
        }
        else
        {
                
            UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
            [dialog setDelegate:self];
            [dialog setTitle:@"Reference details not found"];
            //[dialog setMessage:@"No match found,please try another query."];
            [dialog addButtonWithTitle:@"OK"];
            [dialog show];	
            [dialog release];
                
        }
        
		[tempTableview reloadData];
	}
	// now we are sure the download is complete
	@catch (NSException *e) 
	{
		NSLog(@"%@",[e description]);
	}
	
}


-(void)getResultsAndInsert:(NSDictionary *)resultSet
{
		
	NSArray *allValues = [resultSet allValues];
    NSArray *allKeys = [resultSet allKeys];
 

	for (int i=0; i<[allValues count]; i++) 
	{
     if ([[allValues objectAtIndex:i] isEqual:[NSNull null] ]) 
 
		{
			[resultSet setValue:@"No Value" forKey:[allKeys objectAtIndex:i]];
		
        }
	}
 
	
	NSError *err;
	[[managedObjectContext undoManager] disableUndoRegistration];
	
	//REFERENCES
	NSManagedObjectContext *referencesMOC = [NSEntityDescription insertNewObjectForEntityForName:@"References" inManagedObjectContext:managedObjectContext];
	[referencesMOC setValue:[resultSet objectForKey:@"citation"] forKey:@"citation"];
	[referencesMOC setValue:[resultSet objectForKey:@"pubMedId"] forKey:@"refPubMedId"];
	
    
	// FEATURES
	[referencesMOC setValue:selectedFeature forKey:@"refertofeat"];
		
	NSMutableSet *referencesSet = [NSMutableSet set]; 
	[referencesSet addObject:referencesMOC];
	[selectedFeature addReferences:referencesSet];
	
	NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
	
	[dnc addObserverForName:NSManagedObjectContextDidSaveNotification
					 object:managedObjectContext
					  queue:nil
				 usingBlock:^(NSNotification *saveNotification)
	 {
		 [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
		 
	 }];
	
	if (![managedObjectContext save:&err])
	{
		NSLog(@"%@",err);
	}
	
	[dnc removeObserver:self
				   name:NSManagedObjectContextDidSaveNotification
				 object:managedObjectContext];
	
	NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[resultSet objectForKey:@"citation"] forKey:@"citation"];
	[tmpDict setValue:[resultSet objectForKey:@"pubMedId"] forKey:@"pubMedId"];
	[allObjects addObject:tmpDict];
	[tmpDict release];
	
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
            
            activityFrame = CGRectMake(500.0f-18.0f, 300.0f, 30.0f, 30.0f); 
            
        }else{
            
            activityFrame = CGRectMake(380.0f-18.0f, 400.0f, 30.0f, 30.0f); 
            
        }
        
        
    }else {
        
        if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) {
            
            activityFrame = CGRectMake(250.0f-18.0f, 100.0f, 30.0f, 30.0f); 
            
            
        }else{
            
            activityFrame = CGRectMake(165.0f-18.0f, 150.0f, 30.0f, 30.0f); 
            
        }
        
    }
    
    
	activityIndView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndView.frame = activityFrame;
	
	[self.view addSubview:activityIndView];
	[activityIndView startAnimating];
	
    
}


#pragma mark -
#pragma mark Action Method 

//Function called when email icon is pressed and mail is composed with feature details

-(IBAction)pushedEmailButton:(id)sender 
{
    NSString *featName = [staticFunctionClass getGeneName];
	NSArray *display = [featName componentsSeparatedByString:@"/"];
	NSString *sysName = [display objectAtIndex:1];

	NSString *allDetails = @"";
	
    NSString *SubjectLine = [NSString stringWithFormat:@"%@, References", featName];
    [staticFunctionClass setSubjectLine:SubjectLine];
    NSMutableArray *arrRec = [[NSMutableArray alloc] init];
    
    EmailViewController *emailView = [[EmailViewController alloc]initWithNibName:@"EmailViewController" bundle:[NSBundle mainBundle]];
    
	
    if ([allObjects count] < 51) {
        for (int i=0; i<[allObjects count]; i++) {
     
			if (i == 0) { // add link to lit guide page
				
				allDetails = [allDetails stringByAppendingFormat:@"<div><a href=\"http://www.yeastgenome.org/cgi-bin/reference/litGuide.pl?locus=%@\">%@ Literature Guide</a><br><br></div><table>", sysName, featName];
			}
			
            NSString *tmpString = [NSString stringWithFormat:@"%@ [PubMed:%@]",[[allObjects objectAtIndex:i] objectForKey:@"citation"],[[allObjects objectAtIndex:i] objectForKey:@"pubMedId"]];
            
            allDetails = [allDetails stringByAppendingFormat:@"<tr><td>%@\t%@\t%@</td></tr>", selectedFeature.geneName, selectedFeature.featureName, tmpString];
        }
        
		allDetails = [allDetails stringByAppendingFormat:@"</table>"];
		
        [staticFunctionClass setMessageBody:[NSString stringWithFormat:@"%@",allDetails]];
        
	//	NSLog(@"FeatReferencesDetails: %@", allDetails);
		
        [self.navigationController pushViewController:emailView animated:YES];	
		
		[emailView release];
                
    }
    
    else if ([allObjects count] > 51){
        
        int count = 51;
		
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM-dd-yyyy"];
        NSString *strcreatedtime = [dateFormat stringFromDate:today];
        [dateFormat release];
        
        for (int i=0; i<[allObjects count]; i++) {
            
            count++;
            
            if (count == 200)
                break;
			
			NSString *tmpString = [NSString stringWithFormat:@"%@ [PubMed:%@]",[[allObjects objectAtIndex:i] objectForKey:@"citation"],[[allObjects objectAtIndex:i] objectForKey:@"pubMedId"]];
            
            allDetails = [allDetails stringByAppendingFormat:@"%@\t%@\t%@\n\n", selectedFeature.geneName, selectedFeature.featureName, tmpString];
        }
  
		//set link to lit guide page in body of e-mail

		//NSString *bodyTitle = [NSString stringByFormat:@"<div><a href=\"http://www.yeastgenome.org/cgi-bin/reference/litGuide.pl?locus=%@\">%@ Literature Guide</a><br><br></div>", sysName, featName];
		
		//NSLog(@"FeatReferencesDetails: %@", bodyTitle);
        
        NSData *fileData = [allDetails dataUsingEncoding:NSUTF8StringEncoding];
        
		controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        
        [controller setSubject:[NSString stringWithFormat:@"Reference List of features from YeastGenome, %@",strcreatedtime]];
        [controller setTitle:@"Export Reference List"];
		[controller setMessageBody:[NSString stringWithFormat:@"<div><a href=\"http://www.yeastgenome.org/cgi-bin/reference/litGuide.pl?locus=%@\">%@ Literature Guide</a><br><br></div>", sysName, featName] isHTML:YES];
        [controller addAttachmentData:fileData mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"ReferenceList_%@.txt",strcreatedtime]];

        [self presentModalViewController:controller animated:NO];

//		[controller release];
        
    }
    
    [arrRec release];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	[controller dismissModalViewControllerAnimated:NO];
	
}


#pragma mark -
#pragma mark AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    @try {
        
        
		switch (buttonIndex) {
				
			case 0:
                
				[self.navigationController popViewControllerAnimated:YES];
				
				break;
				
                
				
			default:
				break;
		}
	}
	@catch (NSException * e) {
		NSLog(@"%@", [e description]);
	}
    
    
}


#pragma mark -
#pragma mark Actionsheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	@try 
	{
		NSString *featName = [staticFunctionClass getGeneName];
		NSString *SubjectLine = [NSString stringWithFormat:@"%@, References", featName];
		[staticFunctionClass setSubjectLine:SubjectLine];
		NSMutableArray *arrRec = [[NSMutableArray alloc] init];
		
		EmailViewController *emailView = [[EmailViewController alloc]initWithNibName:@"EmailViewController" bundle:[NSBundle mainBundle]];	
		
        NSString *message;
        
		switch (buttonIndex) {
				
			case 0:
										
				[staticFunctionClass setMessageBody:[NSString stringWithFormat:@"%@",featName]];
				
				
				[arrRec addObject:@"yeast-curator@genome.standfor.edu"];	
				
				[staticFunctionClass setRecipient:arrRec];
				[arrRec release];
				
				[self.navigationController pushViewController:emailView animated:YES];
				
				break;
				
			case 1:
			
				
				message = [NSString stringWithFormat:@"%@, \n I thought you might be intereted in some information, I found out about\n",featName];
				[staticFunctionClass setMessageBody:message];
				NSMutableArray *arrRec = [[NSMutableArray alloc] init];
				
				[arrRec addObject:@""];	
				[staticFunctionClass setRecipient:arrRec];
				[arrRec release];
				
				[self.navigationController pushViewController:emailView animated:YES];
				
				break;
				
			default:
				break;
		}
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@",[e description]);
	}

}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [allObjects count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    
    NSUInteger row = [indexPath row];
    CGRect contentRect;
    CGRect pubRect;
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    
    static UIImage *PubidImage;
    PubidImage = [UIImage imageNamed:@"pubmedrefsml.png"];

    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   // if (cell == nil)
	   {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        
       
        if (textRange.location != NSNotFound) 
        {	
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
                {
                contentRect = CGRectMake(110, 0.0, 850.0, 80.0);
                    pubRect = CGRectMake(960, 3, 50, 30);
                
                } 
            else
                {
                
                contentRect = CGRectMake(110.0, 0.0, 600.0, 100.0);

                    pubRect = CGRectMake(710, 3, 50, 30);
                }   
                
                UIImageView *sqrimg = [[UIImageView alloc]initWithFrame:CGRectMake(20, 7, 80, 65)];
                
                sqrimg.image = [UIImage imageNamed:@"Square.png"];
                sqrimg.tag = kCellSquareTag;

                
                UILabel *FeatureName = [[UILabel alloc] initWithFrame:CGRectMake(0, 05, 80, 20)];
                FeatureName.backgroundColor = [UIColor clearColor];
                FeatureName.tag = kCellFeatureNmTag;
                FeatureName.textColor = [UIColor redColor];
                FeatureName.font = [UIFont systemFontOfSize:12];
                [FeatureName setTextAlignment:UITextAlignmentCenter];
                
                FeatureName.text = selectedFeature.featureName;
                
                UILabel *geneName = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 80, 20)];
                geneName.backgroundColor = [UIColor clearColor];
                geneName.tag = kCellGeneNmTag;
                geneName.font = [UIFont systemFontOfSize:12];
                [geneName setTextAlignment:UITextAlignmentCenter];
                
                geneName.text = selectedFeature.geneName;
                

                
            UITextView *textView = [[UITextView alloc] initWithFrame:contentRect];
            NSString *tmpString	= [NSString stringWithFormat:@"%@ [PubMed:%@]",[[allObjects objectAtIndex:row] objectForKey:@"citation"],[[allObjects objectAtIndex:row] objectForKey:@"pubMedId"]];
                textView.text = tmpString;
                textView.userInteractionEnabled = NO;
                textView.font = [UIFont systemFontOfSize:15];
                textView.tag = kCellLabelTag;
                textView.backgroundColor = [UIColor clearColor];
                
                [sqrimg addSubview:FeatureName];
                [sqrimg addSubview:geneName];
                [cell.contentView addSubview:sqrimg];
                [cell.contentView addSubview:textView];
                
                         
                
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:pubRect];
                imgView.image = PubidImage;
               
                
                imgView.tag = kCellButtonTag;
                if([[[allObjects objectAtIndex:row] objectForKey:@"pubMedId"] isEqualToString:@"No Value"])
                   imgView.hidden = YES;
                
                
                [cell.contentView addSubview:imgView];
                
            
                [textView release];
                [sqrimg release];
                [imgView release];
                [FeatureName release];
                [geneName release];
                
            }
        else            
            {
            
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                
                contentRect = CGRectMake(85, 5, 350.0, 90.0);
                pubRect = CGRectMake(435, 2, 40, 15);
                
            } else{
                
                contentRect = CGRectMake(85, 5, 200.0, 90.0);
                pubRect = CGRectMake(280, 2, 40, 15);

                
                }
                
                
                UIImageView *sqrview = [[UIImageView alloc]initWithFrame:CGRectMake(02, 13, 80, 65)];
                
                sqrview.image = [UIImage imageNamed:@"Square.png"];
                sqrview.tag = kCellSquareTag;
                
                
                UILabel *FeatureName = [[UILabel alloc] initWithFrame:CGRectMake(0, 05, 80, 20)];
                FeatureName.backgroundColor = [UIColor clearColor];
                FeatureName.tag = kCellFeatureNmTag;
                FeatureName.textColor = [UIColor redColor];
                
                FeatureName.font = [UIFont systemFontOfSize:12];
                [FeatureName setTextAlignment:UITextAlignmentCenter];
                
                FeatureName.text = selectedFeature.featureName;
                
                UILabel *geneName = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 80, 20)];
                geneName.backgroundColor = [UIColor clearColor];
                geneName.tag = kCellGeneNmTag;
                geneName.font = [UIFont systemFontOfSize:12];
                [geneName setTextAlignment:UITextAlignmentCenter];
                geneName.text = selectedFeature.geneName;


                UITextView *textView = [[UITextView alloc] initWithFrame:contentRect];
                NSString *tmpString	= [NSString stringWithFormat:@"%@ [PubMed:%@]",[[allObjects objectAtIndex:row] objectForKey:@"citation"],[[allObjects objectAtIndex:row] objectForKey:@"pubMedId"]];
                textView.contentMode = UIViewContentModeTopLeft;

                textView.text = tmpString;
                textView.userInteractionEnabled = NO;
                textView.font = [UIFont systemFontOfSize:12];
                textView.tag = kCellLabelTag;
                textView.backgroundColor = [UIColor clearColor];
                
                [cell.contentView addSubview:textView];
                
                
                
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:pubRect];
                imgView.image = PubidImage;
             
                imgView.tag = kCellButtonTag;
                if([[[allObjects objectAtIndex:row] objectForKey:@"pubMedId"] isEqualToString:@"No Value"])
                    imgView.hidden = YES;
                
              
                [sqrview addSubview:FeatureName];
                [sqrview addSubview:geneName];
                [cell.contentView addSubview:sqrview];
                [cell.contentView addSubview:textView];
                [cell.contentView addSubview:imgView];
                
                [textView release];
                [sqrview release];
                [imgView release];
                [FeatureName release];
                [geneName release];



                
            }
} 
       
	
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    
	return cell;
}


-(void)tableView: (UITableView*)tableView 
 willDisplayCell: (UITableViewCell*)cell 
forRowAtIndexPath: (NSIndexPath*)indexPath
{
    
    
    
    if (indexPath.row % 2 == 0) {
        
       
        float rd = 255.00/255.00;
		float gr = 255.00/255.00;
		float bl = 255.00/255.00;
        
        [cell setBackgroundColor:[UIColor colorWithRed:rd green:gr blue:bl alpha:1.0]];
        
    } else {
        
        float rd = 245.00/255.00;
		float gr = 245.00/255.00;
		float bl = 245.00/255.00;
		
		[cell setBackgroundColor:[UIColor colorWithRed:rd green:gr blue:bl alpha:1.0]];
       
    }
    
    
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.

	[tempTableview deselectRowAtIndexPath:indexPath animated:NO];
    NSString *urlAddress = [NSString stringWithFormat:@"http://www.yeastgenome.org/cgi-bin/reference/reference.pl?pmid=%@",[[allObjects objectAtIndex:indexPath.row] objectForKey:@"pubMedId"]];//@"http://www.ncbi.nlm.nih.gov/pubmed?term=%@"
    
     
    [staticFunctionClass setBrowseImg:urlAddress];
    
    BrowseImgView *browseImgVC = [[BrowseImgView alloc] initWithNibName:@"BrowseImgView_iPhone" bundle:[NSBundle mainBundle]];
    
    NSString *featName = [staticFunctionClass getGeneName];
    browseImgVC.title = [NSString stringWithFormat:@"%@ %@",featName,@"Reference"];  
    
    [self.navigationController pushViewController:browseImgVC animated:YES];
    
    [browseImgVC release];
}



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}




- (void)dealloc 
{

	[allObjects release];
    [super dealloc];
}


@end

