//
//  FeatInteractionList.m
//  SGD_Vivek
//
//  Created by Vivek on 09/03/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "FeatInteractionList.h"
#import "staticFunctionClass.h"
#import "FeatInteractionDetails.h"
#import "EmailViewController.h"
#import "SBJSON.h"
#import "webServiceHelper.h"
#import "Reachability.h"
#import "Features.h"
#import "FeatAnnotation.h"

@implementation FeatInteractionList

@synthesize allNewObjectsInteraction;
@synthesize progAlertView, activityIndView;
@synthesize managedObjectContext;



#pragma mark -
#pragma mark Orientation Support 

/*Function is called when device is rotated */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	
	[tblInteraction reloadData];
}


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

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[tblInteraction reloadData];
}

/*Function to retreive the interacting gene/features list by accessing server 
 and displaying those in tableview */
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    
	allNewObjectsInteraction = [[NSMutableArray alloc] init];
	
        
    NSString *featName = [staticFunctionClass getGeneName];
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text= [NSString stringWithFormat:@"%@ %@", featName, @"Interaction Details"];
    tlabel.textColor=[UIColor blackColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    
	@try {
		
        //Set navigation bar buttons at top
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
			
		
		
		tblInteraction.dataSource = self;
		tblInteraction.delegate = self;
		
		
		NSString *featName = [staticFunctionClass getGeneName];
		
		NSArray *display = [featName componentsSeparatedByString: @"/"];
		
		if (display.count > 1) {
			featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:1]];
		} else {
			featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
		}
		
		Reachability *rchbility = [[Reachability reachabilityWithHostName: @"yeastgenome.org"] retain];
		NetworkStatus remoteHostStatus = [rchbility currentReachabilityStatus];
		[rchbility release];
		
		//CHECKING 'WAN' CONNECTION AVAILABILITY
		if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
		{
			//CALLING WEB-SERVICE HELPER CLASS OBJECT FOR CHECKING CONNECTIVITY TO SGD SERVER
			[self createProgressionAlertWithMessage:@"Retrieving from SGD"];
            
 //           @try { // new URL
        
             NSString *newStr = [NSString stringWithFormat: @"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.primaryIdentifier+Gene.secondaryIdentifier+Gene.symbol+Gene.name+Gene.sgdAlias+Gene.organism.shortName+Gene.interactions.details.annotationType+Gene.interactions.details.phenotype+Gene.interactions.details.role1+Gene.interactions.details.type+Gene.interactions.details.experimentType+Gene.interactions.gene2.symbol+Gene.interactions.gene2.briefDescription+Gene.interactions.gene2.secondaryIdentifier+Gene.interactions.details.experiment.name+Gene.interactions.details.experiment.publication.citation+Gene.interactions.details.experiment.publication.pubMedId\"+longDescription=\"List+all+interactions+for+a+specified+gene.+Genes+include+Uncharacterized+and+Verified+ORFs,+pseudogenes,+transposable+element+genes,+RNAs,+and+genes+Not+in+Systematic+Sequence+of+S228C.+Caution:+all+reciprocal+interactions+will+be+duplicated.\"+sortOrder=\"Gene.primaryIdentifier+asc\"><constraint+path=\"Gene\"+op=\"LOOKUP\"+value=\"%@\"+extraValue=\"S.+cerevisiae\"/></query>&format=jsonobjects&source=YeastGenomeapp<", featName];
            
      //      NSLog(@"string: %@", newStr);
 
               [self webServiceCall:newStr];
        }
		//IF NOT REACHABLE THEN GIVING ALERT MESSAGE OF CONNECTION NOT AVAILABLE
		else if(remoteHostStatus == NotReachable)
		{
			
			UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
			[dialog setDelegate:self];
            [dialog setTitle:@"No network available"];
            [dialog setMessage:@"Please check your network connection"];
			[dialog addButtonWithTitle:@"Ok"];
			[dialog show];	
			[dialog release];
			return;
		}
	}
	@catch (NSException * e)
	{
		NSLog(@"%@", [e description]);
	}
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
  
    //    NSLog(@"before set webhelper delegate; response %i", webhelper.httpR);
       [webhelper setDelegate:self];
		[webhelper release];
   // NSLog(@"set webhelper delegate; response %i", webhelper.httpR);
 
	}
    
	@catch (NSException *e) {
		NSLog(@"Web services error: %@",[e description]);
        return;
	}
}

// Implement this delegate method if the URL response is > 400
-(void)alternateResponse:(NSInteger *) number {
   // NSLog(@"alternativeUrl method: %i",  number);
    
  //  webServiceHelper.delegate = nil;
    NSString *featName = [staticFunctionClass getGeneName];
    NSArray *display = [featName componentsSeparatedByString: @"/"];
    
    if (display.count > 1) {
        featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:1]];
    } else {
        featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
    }
    
    NSLog(@"First URL failed for %@", featName);
    
    NSString *str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.interactions.annotationType+Gene.interactions.role+Gene.interactions.interactionType+Gene.interactions.name+Gene.interactions.shortName+Gene.interactions.interactingGenes.symbol+Gene.interactions.interactingGenes.secondaryIdentifier+Gene.interactions.experiment.publication.citation+Gene.interactions.experiment.publication.pubMedId+Gene.interactions.interactingGenes.headline+Gene.interactions.type.description+Gene.interactions.experimentType\"+longDescription=\"List+all+interactions+for+a+specified+gene.++Genes+include+Uncharacterized+and+Verified+ORFs,+pseudogenes,+transposable+element+genes,+RNAs,+and+genes+Not+in+Systematic+Sequence+of+S228C.++Caution:+all+reciprocal+interactions+will+be+duplicated.\"+sortOrder=\"Gene.interactions.annotationType+asc\"><constraint+path=\"Gene\"+op=\"LOOKUP\"+value=\"%@\"+extraValue=\"S.+cerevisiae\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName];
    
    
    [self webServiceCall:str];
}

- (void)quitWebServices:(NSString *) webserviceResponse {
    @try {
        if ([activityIndView isAnimating])
			[activityIndView stopAnimating];
        
        
        UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
        [dialog setDelegate:self];
        [dialog setTitle:@"Server is temporarily unavailable."];
        [dialog setMessage:@"Please try your search again shortly. If the problem persists, please contact SGD at sgd-helpdesk@lists.stanford.edu"];
        [dialog addButtonWithTitle:@"Ok"];
        [dialog show];
        [dialog release];
          
    }
    @catch (NSException *exception) {
        NSLog(@"err: %@", exception);
        
    }
   }

// Implement the finish downloading delegate method

- (void)finishedDownloading:(NSString *)strJSONResponse
{
	@try 
	{
		if ([activityIndView isAnimating]) 
			[activityIndView stopAnimating];
		
		@synchronized(self)
		{
           
          //  NSLog(@"in finished downloading, response: %d", [strJSONResponse length]);
               //-----
            if ([strJSONResponse length] != 0)
            {
                NSError *error;
                SBJSON *json = [[SBJSON new] autorelease];
                
                strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\t" withString:@""];
       
                strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\\\"" withString:@""];
                
                NSDictionary *dictionary = [json objectWithString:strJSONResponse error:&error];
                NSArray *allValues = [dictionary allValues];
                NSArray *allKeys = [dictionary allKeys];
                
             //   NSLog(@"all keys: %@", allKeys);
            //    NSLog(@"all vals: %@", allValues);
                
                for (int i=0; i<[allValues count]; i++) 
                {
                    if ([[allValues objectAtIndex:i] isEqual:[NSNull null] ]) 
                    {
                        [dictionary setValue:@"No Value" forKey:[allKeys objectAtIndex:i]];
                        
                    }
                }
            
            
            
                NSArray *layOuts =  [dictionary objectForKey:@"results"];
                int numLayouts = [layOuts count];
        
                if ([layOuts count]!=0) 
                {
                                
                    NSArray *Interactions = [layOuts objectAtIndex:0];
                    NSArray *Interactions1 = [Interactions objectForKey:@"interactions"];
                                        
                     for (int i=0; i<[Interactions1 count];i++)
                    {
        
                        NSDictionary *InteractionsData =  [Interactions1 objectAtIndex:i];
                        NSArray *intObjKeys = [InteractionsData allKeys];

                        NSArray *interactions;
                        NSDictionary *publication;
                        NSDictionary *Experiment;
                        NSDictionary *interactiongenes;
                        NSString *action;
                        NSString *featType;
                        NSString *headline;
                        NSString *exptType;
                        
                        NSMutableDictionary *tmpInterDict = [[NSMutableDictionary alloc] init];
           
                        if ([intObjKeys containsObject:@"gene2"]) { // YeastMine 1.0 web services
                            interactiongenes = [InteractionsData objectForKey:@"gene2"];
                            
                        } else {
                            interactions = [InteractionsData
                                            objectForKey:@"interactingGenes"];
                            
                            interactiongenes = [interactions objectAtIndex:0];                            
                        }
                        
                        if ([intObjKeys containsObject: @"details"]) { // YeastMine 1.0 web services
                            NSArray *details = [InteractionsData objectForKey:@"details"];
                            Experiment = [details objectAtIndex:0];
                             
                            NSDictionary *RefObj = [Experiment
                                                    objectForKey:@"experiment"];
                            
                            publication = [RefObj
                                           objectForKey:@"publication"];
 
                            action = [Experiment objectForKey:@"role1"];
                            featType = [Experiment objectForKey:@"type"] ;//
                           headline =[interactiongenes objectForKey:@"briefDescription"];
                            exptType = [Experiment objectForKey:@"experimentType"];
                    
                        } else { // YeastMine 0.8 web services
                            
                            Experiment = [InteractionsData
                                          objectForKey:@"experiment"];
                        
                            publication = [Experiment
                                           objectForKey:@"publication"];
                            
                            action = [InteractionsData objectForKey:@"role"];
                            featType = [InteractionsData objectForKey:@"interactionType"];
                            headline = [interactiongenes objectForKey:@"headline"];
                            exptType = [InteractionsData objectForKey:@"experimentType"];
 
                        }
                        
                        NSString *citation = [publication objectForKey:@"citation"];
                        NSString *pubID = [publication objectForKey:@"pubMedId"];
        
                        NSString *gene = [interactiongenes objectForKey:@"symbol"];
                         
                        if (gene == (id)[NSNull null] || gene.length == 0 ) gene = @"";
 
                        [tmpInterDict setValue: exptType forKey:@"experimentType"];//
                        [tmpInterDict setValue:[interactiongenes objectForKey:@"secondaryIdentifier"] forKey:@"featureName"];//
                        [tmpInterDict setValue:gene forKey:@"geneName"];
                    
                        [tmpInterDict setValue: action forKey:@"action"];//
                        [tmpInterDict setValue: featType forKey:@"featureType"];//
                        [tmpInterDict setValue: headline forKey:@"intDescription"];


                       // [tmpInterDict setValue:[InteractionsData objectForKey:@"role"] forKey:@"action"];
                        [tmpInterDict setValue:citation forKey:@"citation"];
                        [tmpInterDict setValue:pubID forKey:@"pubMedId"];
                     
                    
                        [allNewObjectsInteraction addObject:[tmpInterDict copy]];

                        [tmpInterDict release];
                    }
                 } else { // no results
               //     NSLog(@"test");
                   
                    UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
                    [dialog setDelegate:self];
                    [dialog setTitle:@"Interaction details not found"];
                     [dialog addButtonWithTitle:@"OK"];
                    [dialog show];	
                    [dialog release];
                }
            } else { // no JSON response
              //  NSLog(@"test2");
                
                UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
                [dialog setDelegate:self];
                [dialog setTitle:@"Interaction details not found"];
                //[dialog setMessage:@"No match found,please try another query."];
                [dialog addButtonWithTitle:@"OK"];
                [dialog show];	
                [dialog release];
            }
        
        }
        
        [tblInteraction reloadData];
	}
 //   }
	// now we are sure the download is complete
	@catch (NSException *e) 
	{
		NSLog(@"%@",[e description]);
	}
	
}

//Progession Alert message display
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
		
		NSString *SubjectLine = [NSString stringWithFormat:@"%@, Interaction List", featName];
		
		
		
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
#pragma mark Mail delegate

//Function called when email icon is pressed and mail is composed
-(IBAction)pushedEmailButton:(id)sender 
{
    
    @try
	{
		
		NSDate *today = [NSDate date];
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"MM-dd-yyyy"];
		NSString *strcreatedtime = [dateFormat stringFromDate:today];
		[dateFormat release];
		
		NSString *featName = [staticFunctionClass getGeneName];		
		NSArray *display = [featName componentsSeparatedByString: @"/"];
		NSString *sysName = [display objectAtIndex:1];
		
		NSString *eMailBody = @"";
		NSString *textDataString =@"";
       
        if ([allNewObjectsInteraction count] < 51) {
            for (int i=0; i<[allNewObjectsInteraction count]; i++)
            {
                
                NSString *intgeneName = [[allNewObjectsInteraction objectAtIndex:i] objectForKey:@"geneName"];
                
                NSString *intfeatureName = [[allNewObjectsInteraction objectAtIndex:i] objectForKey:@"featureName"];
                
                NSString *description = [[allNewObjectsInteraction objectAtIndex:i] objectForKey:@"intDescription"];
                
				if (i == 0) {
					eMailBody = [eMailBody stringByAppendingFormat:@"<div><a href=\"http://www.yeastgenome.org/cgi-bin/interactions.pl?locus=%@\">%@ Physical and Genetic Interactions</a><br><br></div><table>", sysName, featName];
				}
							
                eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b>Standard Name:</b>%@<br><b>Systematic Name:</b>%@<br><b>Description:</b>%@<br></td></tr>",intgeneName, intfeatureName, description];
                
          //      textDataString = [textDataString stringByAppendingFormat:@"%@",eMailBody];
            }
            
		//	textDataString = [textDataString stringByAppendingFormat:@"</table>"];
			eMailBody = [eMailBody stringByAppendingFormat:@"</table>"];
            
            controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            
            [controller setSubject:[NSString stringWithFormat:@"Interaction List of features from YeastGenome, %@",strcreatedtime]];
            [controller setTitle:@"Export Interaction List"];
            
            
            [controller setMessageBody:eMailBody isHTML:YES];
            [self presentModalViewController:controller animated:NO];
            
   //         [controller release];
            
        }
		
        else if ([allNewObjectsInteraction count] > 51) {
            
            int count = 51;
			
            for (int i=0; i < [allNewObjectsInteraction count]; i++)
            {
                
                count++;
                if (count == 130)
                    break;
                
                NSString *intgeneName = [[allNewObjectsInteraction objectAtIndex:i] objectForKey:@"geneName"];
                
                NSString *intfeatureName = [[allNewObjectsInteraction objectAtIndex:i] objectForKey:@"featureName"];
                
                NSString *description = [[allNewObjectsInteraction objectAtIndex:i] objectForKey:@"intDescription"];
                
                eMailBody = [eMailBody stringByAppendingFormat:@"\nStandard Name:%@\nSystematic Name:%@\nDescription:%@\n\n",intgeneName, intfeatureName, description];
                
                textDataString = [textDataString stringByAppendingFormat:@"%@",eMailBody];
			   
            }
            
            NSData *fileData = [textDataString dataUsingEncoding:NSUTF8StringEncoding];
            
            controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
          
            [controller setSubject:[NSString stringWithFormat:@"Interaction List of features from YeastGenome, %@",strcreatedtime]];
            [controller setTitle:@"Export Interaction List"];
			[controller setMessageBody:[NSString stringWithFormat:@"<div><a href=\"http://www.yeastgenome.org/cgi-bin/interactions.pl?locus=%@\">%@ Physical and Genetic Interactions</a><br><br></div>", sysName, featName] isHTML:YES];
            [controller addAttachmentData:fileData mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"Interactions_%@.txt",strcreatedtime]];
            
            [self presentModalViewController:controller animated:NO];
        
			//[controller release];
			
		//	NSLog(@"email message: %@", bodyTitle);
            
        }
			
	}
	@catch (NSException * e) 
	{
		NSLog(@"Catch Error: %@", [e description]);
	}
	
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	[controller dismissModalViewControllerAnimated:NO];
		
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [allNewObjectsInteraction count];
    
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    
    
    
    static NSString *myCell = @"myCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
	// Configure the cell...
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    CGRect contentRect;
    NSString *interfeatureName = [[allNewObjectsInteraction objectAtIndex:indexPath.row] objectForKey:@"featureName"];
    
    NSString *intergeneName;
    if ([[NSNull null] isEqual:[[allNewObjectsInteraction objectAtIndex:indexPath.row] objectForKey:@"geneName"]]) {
        intergeneName = @"";
    }else{

    intergeneName = [[allNewObjectsInteraction objectAtIndex:indexPath.row] objectForKey:@"geneName"];
    }
    NSString *description = [[allNewObjectsInteraction objectAtIndex:indexPath.row] objectForKey:@"intDescription"];

    
//	if (cell == nil)
    {
		
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:myCell] autorelease];
        
        
        NSRange textRange =[[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
        if(textRange.location != NSNotFound)
        {   
            
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                contentRect = CGRectMake(125, 5, 870, 70);
            }
            else
            {
                contentRect = CGRectMake(125, 5, 590, 70);            
            }
            
            //-------        
            
            
            UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(30, 7, 80, 65)];
            
            imgview.image = [UIImage imageNamed:@"Square.png"];
            imgview.tag = kCellImageTag;
            
            
            
            UILabel *FeatureName = [[UILabel alloc] initWithFrame:CGRectMake(0, 05, 80, 20)];
            FeatureName.backgroundColor = [UIColor clearColor];
            FeatureName.tag = kCellFeatureNmTag;
            FeatureName.textColor = [UIColor redColor];
            FeatureName.font = [UIFont systemFontOfSize:12];
            [FeatureName setTextAlignment:UITextAlignmentCenter];
            
            FeatureName.text = interfeatureName;
            
            UILabel *geneName = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 80, 20)];
            geneName.backgroundColor = [UIColor clearColor];
            geneName.tag = kCellGeneNmTag;
            geneName.font = [UIFont systemFontOfSize:12];
            [geneName setTextAlignment:UITextAlignmentCenter];
            
            geneName.text = intergeneName;
            
            
            
            UITextView *textView = [[UITextView alloc] initWithFrame:contentRect];
            NSString *strAllDetails = description;
            textView.text = strAllDetails;
            textView.userInteractionEnabled = NO;
            textView.textColor = [UIColor blackColor];
            textView.font = [UIFont systemFontOfSize:16];
            textView.tag = kCellLabelTag;
            textView.backgroundColor = [UIColor clearColor];
            
            [imgview addSubview:FeatureName];
            [imgview addSubview:geneName];
            [cell.contentView addSubview:imgview];
            [cell.contentView addSubview:textView];
            
            
            [textView release];
            
            [imgview release];
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
            
            
            
            UILabel *FeatureName = [[UILabel alloc] initWithFrame:CGRectMake(0, 05, 80, 20)];
            FeatureName.backgroundColor = [UIColor clearColor];
            FeatureName.tag = kCellFeatureNmTag;
            FeatureName.textColor = [UIColor redColor];
            
            FeatureName.font = [UIFont systemFontOfSize:12];
            [FeatureName setTextAlignment:UITextAlignmentCenter];
            
            FeatureName.text = interfeatureName;
            
            UILabel *geneName = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 80, 20)];
            geneName.backgroundColor = [UIColor clearColor];
            geneName.tag = kCellGeneNmTag;
            geneName.font = [UIFont systemFontOfSize:12];
            [geneName setTextAlignment:UITextAlignmentCenter];
            geneName.text =intergeneName;
            
            UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(25, 13, 80, 65)];
            
            imgview.image = [UIImage imageNamed:@"Square.png"];
            imgview.tag = kCellImageTag;
           
            
            
            UITextView *textView = [[UITextView alloc] initWithFrame:contentRect1];
            textView.tag = kCellLabelTag;
            
            
            textView.userInteractionEnabled = NO;
            textView.font = [UIFont systemFontOfSize:11];
            textView.textColor = [UIColor blackColor];
            textView.backgroundColor = [UIColor clearColor];
            
            textView.text = description;
            
            
            [imgview addSubview:FeatureName];
            [imgview addSubview:geneName];
            [cell.contentView addSubview:imgview];
            [cell.contentView addSubview:textView];
            
            [textView release];
            [imgview release];
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSRange textRange =[[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	
    if(textRange.location != NSNotFound)
        return 80;
	else 
        return 90;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Navigation logic may go here. Create and push another view controller.
	@try 
	{
		NSUInteger row = [indexPath row];
		NSDictionary *tmpIntDict = [allNewObjectsInteraction objectAtIndex:row];
        
		[staticFunctionClass setInteractionDict:tmpIntDict];
		
		
		[tblInteraction  deselectRowAtIndexPath:indexPath animated:NO];
		
		FeatInteractionDetails *objFeatInterDetails;
		NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
		if (textRange.location != NSNotFound) 
		{
			objFeatInterDetails = [[FeatInteractionDetails alloc] initWithNibName:@"FeatInteractionDetails_iPad" bundle:[NSBundle mainBundle]];
		}
		else
		{
			objFeatInterDetails = [[FeatInteractionDetails alloc] initWithNibName:@"FeatInteractionDetails" bundle:[NSBundle mainBundle]];
		}

		
		objFeatInterDetails.title = self.title;
		objFeatInterDetails.managedObjectContext = managedObjectContext;
		
		[self.navigationController pushViewController:objFeatInterDetails animated:YES];
		
		[objFeatInterDetails release];
	}
	@catch (NSException * e) {
		NSLog(@"%@",[e description]);
	}
	
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
    [super dealloc];
	[allNewObjectsInteraction release];

	
}


@end

