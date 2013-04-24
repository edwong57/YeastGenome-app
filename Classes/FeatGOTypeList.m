//
//  FeatGOType.m
//  SGD_2
//
//  Created by Vivek on 7/6/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*
 Class to implement the list of Gene Ontology according to molecular function
 Biological Process and Cellular component.
 */

#import "FeatGOTypeList.h"
#import "staticFunctionClass.h"
#import "SBJSON.h"
#import "webServiceHelper.h"
#import "GODetails.h"
#import "EmailViewController.h"
#import "FeatGoTypeDetails.h"
#import "Reachability.h"

@implementation FeatGOTypeList



@synthesize progAlertView, activityIndView;
@synthesize finalListArr;
@synthesize managedObjectContext;
@synthesize selectedFeature;

@synthesize strGOType;

-(void)initwithArray:(NSMutableArray *)array{

    
	if (finalListArr != nil) 
	{
		[finalListArr release];
		finalListArr = nil;
	}
	//finalListArr = [[NSMutableArray alloc] initWithArray:array];
    finalListArr= [[NSMutableArray alloc]initWithArray:array copyItems:YES];

}

#pragma mark -
#pragma mark Orientation Support 

/*Function is called when device is rotated */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	
	[tempTableview reloadData];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

//for ios6

-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark -
#pragma mark View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
   // NSLog(@"View Will Appear..");
	[tempTableview reloadData];
}

/*Implements the fetching of data in database if not found, it accces the server
and displays the gene ontology detail*/
- (void)viewDidLoad 
{

   // NSLog(@"View Did Load..");
    [super viewDidLoad];
	strGOType = [staticFunctionClass getFeatGOTypeStr];

	
	//Display buttons of the navigation bar at top
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
	
         
    }

- (void)viewDidAppear:(BOOL)animated {
    
    NSLog(@"View Did Appear..");

    [super viewDidAppear:animated];
    
    
       
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
	@catch (NSException *e) {
		NSLog(@"%@",[e description]);
	}
}

// Implement the finish downloading delegate method

- (void)finishedDownloading:(NSString *)strJSONResponse
{
    
	if ([activityIndView isAnimating]) 
		[activityIndView stopAnimating];
	
	
	@try 
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
			
			@synchronized(self) 
			{
				if ([strAllGene length] != 0) 
				{
					NSError *error;
					SBJSON *json = [[SBJSON new] autorelease];
					
					
					
					int asciiCode = [strAllGene characterAtIndex:[strAllGene length]-1];
					
					if (asciiCode != 125)
					{
						strAllGene  = [strAllGene stringByAppendingFormat:@"}"];
					}
					
					NSDictionary *dictionary = [json objectWithString:strAllGene error:&error];
					
					//call insert data 
					[self getResultsAndInsert:dictionary];
				}
				else
				{
                    
                    [self.navigationController popViewControllerAnimated:YES];
				}
				
			}
			
		}
		else
		{
            [self.navigationController popViewControllerAnimated:YES];
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
	NSArray *allValues = [resultSet allValues];
	NSArray *allKeys = [resultSet allKeys];
	for (int i=0; i<[allValues count]; i++) 
	{
		if ([[allValues objectAtIndex:i] isEqual:[NSNull null] ]) 
		{
			[resultSet setValue:@"" forKey:[allKeys objectAtIndex:i]];
			
		}
	}
	
	NSArray *items = [resultSet valueForKeyPath:@"goAnnotation"];
	
	for (int k = 0; k<[items count]; k++) 
	{
		NSArray *evidenceArr = [[items objectAtIndex:k] objectForKey:@"evidence"];
		NSMutableDictionary *ontologydict = [[items objectAtIndex:k] objectForKey:@"ontologyTerm"];
		[self updateInDatabase:evidenceArr dictionaryObj:ontologydict];
	}
	
	[tempTableview reloadData];
}

//Insert the retrieved data in core data

-(void) updateInDatabase:(NSArray *)evidenceObjects dictionaryObj:(NSMutableDictionary *)OntologyDict
{
	@try
	{
		@synchronized (self)
		{
			NSError *error;
			
			
			for (int j = 0; j<[evidenceObjects count]; j++) 
			{
				NSMutableDictionary *codeDict = [[evidenceObjects objectAtIndex:j] objectForKey:@"code"];
				
				
				NSArray *pubArray = [[evidenceObjects objectAtIndex:j] objectForKey:@"publications"];
				
				for (int i =0; i<[pubArray count]; i++) 
				{
					//GODetails
					NSManagedObjectContext *GODetailsMOC = [NSEntityDescription insertNewObjectForEntityForName:@"GODetails" inManagedObjectContext:managedObjectContext];
					//REFERENCES
					
				
					NSDictionary *citationDict = [pubArray objectAtIndex:i];
					
                    
					[GODetailsMOC setValue:[citationDict objectForKey:@"citation"] forKey:@"goReferences"];
                    
                    [GODetailsMOC setValue:[citationDict objectForKey:@"pubMedId"] forKey:@"pubMedId"];
					[GODetailsMOC setValue:[codeDict objectForKey:@"code"] forKey:@"evidence"];
					[GODetailsMOC setValue:[codeDict objectForKey:@"annotType"] forKey:@"annotationType"];
					[GODetailsMOC setValue:[OntologyDict objectForKey:@"name"] forKey:@"annotation"];
                    
                    //GOID 
                    
                    [GODetailsMOC setValue:[OntologyDict objectForKey:@"identifier"] forKey:@"goId"];

					//----
                    [GODetailsMOC setValue:[OntologyDict objectForKey:@"description"] forKey:@"definition"];

                    //------------
					NSArray *pubArray = [OntologyDict objectForKey:@"dataSets"];
					NSMutableDictionary *dataSourceDict = [[pubArray objectAtIndex:0] objectForKey:@"dataSource"];
					
					[GODetailsMOC setValue:[dataSourceDict objectForKey:@"name"] forKey:@"assignedBy"];
					[GODetailsMOC setValue:[staticFunctionClass getFeatGOTypeStr] forKey:@"goType"];
					
			
					// FEATURES
					[GODetailsMOC setValue:selectedFeature forKey:@"gotofeat"];
					
                    
					NSMutableSet *goDetailsSet = [NSMutableSet set]; 
					[goDetailsSet addObject:GODetailsMOC];
					[selectedFeature addGodetails:goDetailsSet];
					
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
					
					NSMutableDictionary *tmpAnnotDict = [[NSMutableDictionary alloc] init];
					
					[tmpAnnotDict setValue:[codeDict objectForKey:@"annotType"] forKey:@"CurationType"];
					[tmpAnnotDict setValue:[OntologyDict objectForKey:@"name"] forKey:@"Annotation"];
					
                    //GOID
                    [tmpAnnotDict setValue:[OntologyDict objectForKey:@"identifier"] forKey:@"identifier"];
                    
					//Get Code Evidence term 
					
					[tmpAnnotDict setValue:[codeDict objectForKey:@"code"] forKey:@"code"];
					[tmpAnnotDict setValue:[citationDict objectForKey:@"citation"] forKey:@"References"];
                   	[tmpAnnotDict setValue:[citationDict objectForKey:@"pubMedId"] forKey:@"PubMedId"];
                    
					
					
					[finalListArr addObject:[tmpAnnotDict copy]];
					[tmpAnnotDict release];
				}
			}
		}
	}
	@catch (NSException * e) 
	{
		NSLog(@"Error Description: %@",[e description]);
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
	@try {
        
		NSString *featName = [staticFunctionClass getGeneName];
		
		
		NSString *SubjectLine = [NSString stringWithFormat:@"%@, %@",featName,self.title]; 
		
		[staticFunctionClass setSubjectLine:SubjectLine];
		NSMutableArray *arrRec = [[NSMutableArray alloc] init];
		
		EmailViewController *emailView = [[EmailViewController alloc]initWithNibName:@"EmailViewController" bundle:[NSBundle mainBundle]];	
		NSString *message;
        
		switch (buttonIndex) {
				
			case 0:
							
				[staticFunctionClass setMessageBody:[NSString stringWithFormat:@"%@",featName]];
				
				
				[arrRec addObject:@"yeast-curator@genome.stanford.edu"];	
				
				[staticFunctionClass setRecipient:arrRec];
				[arrRec release];
				
				[self.navigationController pushViewController:emailView animated:YES];
				
				break;
				
			case 1:
				
				
				
				message = [NSString stringWithFormat:@"%@,\n I thought you might be intereted in some information, I found out about\n",featName];
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
	@catch (NSException * e) {
		NSLog(@"%@", [e description]);
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
    return [finalListArr count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSUInteger row = [indexPath row];
    CGRect contentRect;
    CGRect EvideRect;
    int  textlimit;
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    
    NSString *evide = [[finalListArr objectAtIndex:row] objectForKey:@"code"];
    NSString *strPlistName = [[NSBundle mainBundle] pathForResource:@"goEvidenceCodes" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:strPlistName];
    NSString *strEvidence = [plistDictionary objectForKey:evide];
    
    NSString *detailLabel = [NSString stringWithFormat:@"%@, %@", [[finalListArr objectAtIndex:row] objectForKey:@"CurationType"],strEvidence];
    NSString *goid = [[finalListArr objectAtIndex:row] objectForKey:@"identifier"];                    

    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  //  if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        
        
        if (textRange.location != NSNotFound) 
        {	
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                contentRect = CGRectMake(110, 0.0, 850.0, 40);
                EvideRect   = CGRectMake(110, 25.0, 850.0, 40);
                textlimit   = 840;
            } else{
                
                contentRect = CGRectMake(110.0, 0.0, 600.0, 40);
                
                EvideRect   = CGRectMake(110, 25.0, 600.0, 40);
                textlimit   = 590;
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
            
            FeatureName.text = goid;
            
            UILabel *geneName = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 80, 20)];
            geneName.backgroundColor = [UIColor clearColor];
            geneName.tag = kCellGeneNmTag;
            geneName.font = [UIFont systemFontOfSize:12];
            [geneName setTextAlignment:UITextAlignmentCenter];
            
            geneName.text = selectedFeature.geneName;
            
            
            
            UILabel *textView = [[UILabel alloc] initWithFrame:contentRect];
            NSString *tmpString	=[[finalListArr objectAtIndex:row] objectForKey:@"Annotation"];
             textView.text = [tmpString length]>textlimit?[NSString stringWithFormat:@"%@%@",[tmpString substringToIndex:textlimit],@"..."]:tmpString;
            //textView.text = [tmpString length]>30?[tmpString substringToIndex:30]:tmpString;
            textView.userInteractionEnabled = NO;
            textView.font = [UIFont systemFontOfSize:20];
            textView.tag = kCellLabelTag;
            textView.backgroundColor = [UIColor clearColor];
            
            
            
            UITextView *EvidView = [[UITextView alloc] initWithFrame:EvideRect];
            EvidView.userInteractionEnabled = NO;
           
            EvidView.text = detailLabel;
        
            EvidView.font = [UIFont systemFontOfSize:15];
            EvidView.tag = kCellEvideNmTag;
            EvidView.backgroundColor = [UIColor clearColor];
            
            [sqrimg addSubview:FeatureName];
            [cell.contentView addSubview:sqrimg];
            [cell.contentView addSubview:textView];
            
            [cell.contentView addSubview:EvidView];
          
            
            
            [textView release];
            [EvidView release];
            [sqrimg release];
            [FeatureName release];
            [geneName release];
            
        }else 
            
        {
            
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                
                contentRect = CGRectMake(85, 2, 350.0, 40);
                EvideRect = CGRectMake(85, 40, 350.0, 40);
                textlimit = 50;
            
            } else{
                
                contentRect = CGRectMake(85, 2, 200.0, 40);
                EvideRect = CGRectMake(85, 40, 200.0, 40);
                textlimit = 25;
                
                
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
            
            FeatureName.text = goid;
            
            UILabel *geneName = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 80, 20)];
            geneName.backgroundColor = [UIColor clearColor];
            geneName.tag = kCellGeneNmTag;
            geneName.font = [UIFont systemFontOfSize:12];
            [geneName setTextAlignment:UITextAlignmentCenter];
            geneName.text = selectedFeature.geneName;
            
            
            UILabel *textView = [[UILabel alloc] initWithFrame:contentRect];
            NSString *tmpString	=[[finalListArr objectAtIndex:row] objectForKey:@"Annotation"];

            textView.contentMode = UIViewContentModeTopLeft;
            
            textView.text = [tmpString length]>textlimit?[NSString stringWithFormat:@"%@%@",[tmpString substringToIndex:textlimit],@"..."]:tmpString;
            textView.numberOfLines = 1;
            textView.userInteractionEnabled = NO;
            textView.font = [UIFont systemFontOfSize:15];
            textView.tag = kCellLabelTag;
            textView.backgroundColor = [UIColor clearColor];
            

            [cell.contentView addSubview:textView];
            
            

            UITextView *EvidView = [[UITextView alloc] initWithFrame:EvideRect];
            
            EvidView.text = detailLabel;
            EvidView.userInteractionEnabled = NO;
            EvidView.font = [UIFont systemFontOfSize:12];
            EvidView.tag = kCellEvideNmTag;
            EvidView.backgroundColor = [UIColor clearColor];
         

            [sqrview addSubview:FeatureName];
            [cell.contentView addSubview:sqrview];
            [cell.contentView addSubview:textView];
            [cell.contentView addSubview:EvidView];

            
            [textView release];
            [EvidView release];

            [sqrview release];
            [FeatureName release];
            [geneName release];
            
            
            
            
        }
    }
      
    
	
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	@try
	{
		[tempTableview deselectRowAtIndexPath:indexPath animated:NO];
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		
		[staticFunctionClass setMolFnName:cell.textLabel.text];
		
		// Navigation logic may go here. Create and push another view controller.
	
		FeatGoTypeDetails *objFeatGoTypeDetails;
		NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
		if (textRange.location != NSNotFound) 
		{
			objFeatGoTypeDetails = [[FeatGoTypeDetails alloc]initWithNibName:@"FeatGOTypeDetails_iPad" bundle:[NSBundle mainBundle]];
		}
		else
		{
			objFeatGoTypeDetails = [[FeatGoTypeDetails alloc]initWithNibName:@"FeatGoTypeDetails" bundle:[NSBundle mainBundle]];
		}

		objFeatGoTypeDetails.managedObjectContext = managedObjectContext;
		// set predicate string 
		NSString *predicateStr = [NSString stringWithFormat:@"%@#%@#%@#%@", [[finalListArr objectAtIndex:indexPath.row] objectForKey:@"Annotation"], [[finalListArr objectAtIndex:indexPath.row] objectForKey:@"code"],[[finalListArr objectAtIndex:indexPath.row] objectForKey:@"References"],strGOType];
		[staticFunctionClass setPredicateStr:predicateStr];
        
        [staticFunctionClass setReferencePub:[NSString stringWithFormat:@"%i",indexPath.row]];
       

		
		objFeatGoTypeDetails.title = self.title;
		
		[self.navigationController pushViewController:objFeatGoTypeDetails animated:YES];
		
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@", [e description]);
	}
		
}


#pragma mark -
#pragma mark Mail Method

//Function called when email icon is pressed and mail is composed.
-(IBAction)pushedEmailButton:(id)sender 
{
	
    NSString *featName = [staticFunctionClass getGeneName];
	NSArray *names = [featName componentsSeparatedByString:@"/"]; //split featName into standard and systematic names
	NSString *sysName = [names lastObject];
	// NSLog(@"%@ and %@\n", sysName, featName);

    
    NSString *strAllDetails = @"";
    
    NSMutableArray *arrRec = [[NSMutableArray alloc] init];
    
    EmailViewController *emailView = [[EmailViewController alloc]initWithNibName:@"EmailViewController" bundle:[NSBundle mainBundle]];
    
    if ([finalListArr count] < 51) {
        
        for (int i=0; i<[finalListArr count]; i++) {
            
            NSString *evide = [[finalListArr objectAtIndex:i] objectForKey:@"code"];
            NSString *strPlistName = [[NSBundle mainBundle] pathForResource:@"goEvidenceCodes" ofType:@"plist"];
            NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:strPlistName];
            NSString *strEvidence = [plistDictionary objectForKey:evide];
            
            NSString *detailLabel = [NSString stringWithFormat:@"<b>Curation Type:</b>%@<br><b>Evidence:</b>%@", [[finalListArr objectAtIndex:i] objectForKey:@"CurationType"],strEvidence];
            
            NSString *tmpString	=[[finalListArr objectAtIndex:i] objectForKey:@"Annotation"];
			
			//for first one only, link it to the appropriate GO page //
			
			if (i == 0) {
				
				strAllDetails = [strAllDetails stringByAppendingFormat:@"<div><a href=\"http://www.yeastgenome.org/cgi-bin/GO/goAnnotation.pl?locus=%@\">%@ GO Annotations </a><br><br></div><tr><td><b>Gene Ontology Term:</b>%@<br>%@</td></tr><br><br>",sysName, featName, tmpString, detailLabel];
			} else {
				strAllDetails = [strAllDetails stringByAppendingFormat:@"<tr><td><b>Gene Ontology Term:</b>%@<br>%@</td></tr><br><br>", tmpString, detailLabel];

			}
        }
        
        NSString *SubjectLine = [NSString stringWithFormat:@"%@, %@",featName,self.title]; 
		NSLog(@"%@",strAllDetails);
        
        [staticFunctionClass setSubjectLine:SubjectLine];
        
        [staticFunctionClass setMessageBody:[NSString stringWithFormat:@"%@",strAllDetails]];
        
        [self.navigationController pushViewController:emailView animated:YES];
        
    }
    
    else if ([finalListArr count] > 51) {
        
        int count = 51;
        
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM-dd-yyyy"];
        NSString *strcreatedtime = [dateFormat stringFromDate:today];
        [dateFormat release];
        
        for (int i=0; i<[finalListArr count]; i++) {
            
            count++;
            
            if (count == 200)
                break;
            
            NSString *evide = [[finalListArr objectAtIndex:i] objectForKey:@"code"];
            NSString *strPlistName = [[NSBundle mainBundle] pathForResource:@"goEvidenceCodes" ofType:@"plist"];
            NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:strPlistName];
            NSString *strEvidence = [plistDictionary objectForKey:evide];
            
            NSString *detailLabel = [NSString stringWithFormat:@"Curation Type:%@\nEvidence:%@", [[finalListArr objectAtIndex:i] objectForKey:@"CurationType"],strEvidence];
            
            NSString *tmpString	=[[finalListArr objectAtIndex:i] objectForKey:@"Annotation"];
            
			if (i == 0) {
				
				strAllDetails = [strAllDetails stringByAppendingFormat:@"<div><a href=\"http://www.yeastgenome.org/cgi-bin/GO/goAnnotation.pl?locus=%@\">%@ GO Annotations </a></div><br><br><table><tr><td><b>Gene Ontology Term:</b>%@<br>%@</td></tr><br><br>",sysName, featName, tmpString, detailLabel];
			} else {
				strAllDetails = [strAllDetails stringByAppendingFormat:@"<tr><td><b>Gene Ontology Term:</b>%@<br>%@</td></tr><br><br>", tmpString, detailLabel];
				
			}
			
			strAllDetails = [strAllDetails stringByAppendingFormat:@"</table>"];
			
		//	NSLog(@"%@",strAllDetails);
			
           // strAllDetails = [strAllDetails stringByAppendingFormat:@"%@\t%@\nGene Ontology Term:%@\n%@\n\n",featName, selectedFeature.featureName, tmpString, detailLabel];
        }
        
        NSData *fileData;
        
        fileData = [strAllDetails dataUsingEncoding:NSUTF8StringEncoding];
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        
        [controller setSubject:[NSString stringWithFormat:@"Gene Ontology List of features from YeastGenome, %@",strcreatedtime]];
        [controller setTitle:@"Export Gene Ontology List"];
		[controller setMessageBody:strAllDetails isHTML:YES];
        [controller addAttachmentData:fileData mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"GeneOntologyList_%@.txt",strcreatedtime]];
        
        [self presentModalViewController:controller animated:NO];
        
        [controller release];
        
    }
    
    [arrRec release];
    
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	[controller dismissModalViewControllerAnimated:NO];
	
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
	[finalListArr release];
	[strGOType release];
	
    [super dealloc];
}


@end

