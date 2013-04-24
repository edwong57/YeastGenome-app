//
//  FeatPhenoType.m
//  SGD_Vivek
//
//  Created by Vivek on 09/03/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*
 Class to implement the Phenotype list of Feature.
 */

#import "FeatPhenoType.h"
#import "staticFunctionClass.h"
#import "FeatPhenoTypeDetails.h"
#import "EmailViewController.h"
#import "SBJSON.h"
#import "Reachability.h"

@implementation FeatPhenoType

@synthesize allNewObjectsPhenoList;
@synthesize progAlertView, activityIndView;
@synthesize objPhenoDetails;
@synthesize managedObjectContext;
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

/*Function is called when device is rotated and tableview cells are redisgn*/

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    //NSLog(@"---");
    
    respCnt =0;
    [super viewDidLoad];
	allNewObjectsPhenoList = [[NSMutableArray alloc] init];
	
	
	@try {
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
		
			
		NSString *featName = [staticFunctionClass getGeneName];
		
		NSArray *display = [featName componentsSeparatedByString: @"/"];
        
        
        UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
        tlabel.text= [NSString stringWithFormat:@"%@ %@", featName, @"Phenotype Details"];
        tlabel.textColor=[UIColor blackColor];
        tlabel.backgroundColor =[UIColor clearColor];
        tlabel.adjustsFontSizeToFitWidth=YES;
        self.navigationItem.titleView=tlabel;

		
		if (display.count > 1) {
			featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:1]];
            
		} else {
			featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
            
		}
		
    
		Reachability *rchbility = [[Reachability reachabilityWithHostName: @"yeastgenome.org"] retain];;
		NetworkStatus remoteHostStatus = [rchbility currentReachabilityStatus];
		[rchbility release];
		
		//CHECKING 'WAN' and Wi-Fi CONNECTION AVAILABILITY
		if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
		{
			//CALLING WEB-SERVICE HELPER CLASS OBJECT FOR CHECKING CONNECTIVITY TO SGD SERVER
			[self createProgressionAlertWithMessage:@"Retrieving from SGD"];
            //NSLog(@"00000");
        
            
            NSString *str;
            
            if(isPhysNotMapped)
                str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"NotPhysicallyMapped.primaryIdentifier+NotPhysicallyMapped.secondaryIdentifier+NotPhysicallyMapped.symbol+NotPhysicallyMapped.name+NotPhysicallyMapped.organism.shortName+NotPhysicallyMapped.phenotypes.experimentType+NotPhysicallyMapped.phenotypes.mutantType+NotPhysicallyMapped.phenotypes.observable+NotPhysicallyMapped.phenotypes.allele+NotPhysicallyMapped.phenotypes.strainBackground+NotPhysicallyMapped.phenotypes.chemical+NotPhysicallyMapped.phenotypes.condition+NotPhysicallyMapped.phenotypes.details+NotPhysicallyMapped.phenotypes.reporter+NotPhysicallyMapped.featureType\"+sortOrder=\"NotPhysicallyMapped.primaryIdentifier+asc\"><constraint+path=\"NotPhysicallyMapped.secondaryIdentifier\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName];
            else
                str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.phenotypes.observable+Gene.phenotypes.publications.citation+Gene.phenotypes.publications.pubMedId+Gene.phenotypes.qualifier+Gene.phenotypes.experimentType+Gene.phenotypes.mutantType+Gene.phenotypes.chemical\"+sortOrder=\"Gene.phenotypes.observable+asc\"><constraint+path=\"Gene.secondaryIdentifier\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName];
            
           
           
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
	@catch (NSException * e)
	{
		NSLog(@"%@",[e description]);
	}
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
   // NSLog(@"respose is:%@",strJSONResponse);
    
    respCnt++;
	@try 
	{
		if ([activityIndView isAnimating]) 
			[activityIndView stopAnimating];
		
		if(respCnt>1)
        {  
            respCnt = 0;
            return;
		}
		@synchronized(self)
		{
			if ([strJSONResponse length] != 0) 
			{
				strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\n" withString:@""];
				strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\r" withString:@""];
				strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\\\"" withString:@""];
				
				NSRange   arange = [strJSONResponse rangeOfString:@"phenotypes\":["];
				if (arange.length != 0) 
				{
					NSString *strtest = [strJSONResponse substringFromIndex:arange.location+13];
					NSRange   brange = [strtest rangeOfString:@"],\"objectId"];
					NSString *strAllGene = [[NSString alloc] initWithString:[strtest substringToIndex:brange.location]];
					
					if ([strAllGene length] != 0)
					{
						NSArray *jsonObjects = [strAllGene componentsSeparatedByString:@"},{"];
						
						for (int i=0; i<[jsonObjects count];i++) 
						{
							@synchronized(self) 
							{
								NSError *error;
								SBJSON *json = [[SBJSON new] autorelease];
								
								NSString *JSONstring = [jsonObjects objectAtIndex:i];
								
								int asciiCode = [JSONstring characterAtIndex:[JSONstring length]-1];
								
								if (asciiCode != 125)
								{
									JSONstring  = [JSONstring stringByAppendingFormat:@"}"];
								}
								
								if (i != 0) 
								{
									NSString *strTemp = [NSString stringWithFormat:@"{"];
									JSONstring = [strTemp stringByAppendingString:JSONstring];
								}
								
								NSDictionary *dictionary = [json objectWithString:JSONstring error:&error];
								
								NSArray *allValues = [dictionary allValues];
								NSArray *allKeys = [dictionary allKeys];
								for (int i=0; i<[allValues count]; i++) 
								{
									if ([[allValues objectAtIndex:i] isEqual:[NSNull null] ]) 
									{
										[dictionary setValue:@"" forKey:[allKeys objectAtIndex:i]];
										
									}
								}
								
								NSArray *publArr = [dictionary objectForKey:@"publications"];
								if([dictionary count]!=0){
								NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
								[tmpDict setValue:[dictionary objectForKey:@"observable"] forKey:@"Observable"];
								[tmpDict setValue:[dictionary objectForKey:@"qualifier"] forKey:@"Qualifier"];
								[tmpDict setValue:[dictionary objectForKey:@"chemical"] forKey:@"Chemical"];
								[tmpDict setValue:[dictionary objectForKey:@"experimentType"] forKey:@"ExpType"];
								[tmpDict setValue:[[publArr objectAtIndex:0] objectForKey:@"citation"] forKey:@"Citation"];
                                //----
                                [tmpDict setValue:[[publArr objectAtIndex:0] objectForKey:@"pubMedId"] forKey:@"pubMedId"];
                                //-----
                                
                                [tmpDict setValue:[dictionary objectForKey:@"mutantType"] forKey:@"mutantinfo"];
								[allNewObjectsPhenoList addObject:[tmpDict copy]];
								[tmpDict release];
                                }
							}
						}
					}
					else
					{
						UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
						[dialog setDelegate:self];
						[dialog setTitle:@"Phenotype details not found"];
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
					[dialog setTitle:@"Phenotype details not found"];
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
				[dialog setTitle:@"Phenotype details not found"];
				//[dialog setMessage:@"No match found,please try another query."];
				[dialog addButtonWithTitle:@"OK"];
				[dialog show];	
				[dialog release];
			}
		}	
		[tempTableview reloadData];
	}
	// now we are sure the download is complete
	@catch (NSException *e) 
	{
		NSLog(@"%@",[e description]);
	}
	
}


-(void)getResultsAndInsert:(NSMutableArray *)resultSet
{
	if ([activityIndView isAnimating]) 
		[activityIndView stopAnimating];
	
	[tempTableview reloadData];
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
		NSString *SubjectLine = [NSString stringWithFormat:@"%@, Pheno type List", featName];
		
		
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
    return [allNewObjectsPhenoList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSUInteger row = [indexPath row];
    CGRect contentRect;
    CGRect EvideRect;
    NSString *gene;
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
    NSString *featName = [staticFunctionClass getGeneName];
    
    NSArray *display = [featName componentsSeparatedByString: @"/"];
    
    if (display.count > 1) 
    {
        featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:1]];
        gene = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
    } 
    else 
    {
        featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
        gene = @"";
    }
    
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    
   
    NSString *mutant;
    
    if(![[[allNewObjectsPhenoList objectAtIndex:row] objectForKey:@"mutantinfo"] isEqualToString:@"null"]||[[[allNewObjectsPhenoList objectAtIndex:row] objectForKey:@"mutantinfo"] isEqualToString:@"(null)"])
        mutant =  [NSString stringWithFormat:@"Mutant Type:%@", [[allNewObjectsPhenoList objectAtIndex:row] objectForKey:@"mutantinfo"]];
    else
        mutant = @"";//[NSString stringWithFormat:@"Mutant Type:null"];//@"";
    
    NSString *qualifier;
    
    if(![[[allNewObjectsPhenoList objectAtIndex:row] objectForKey:@"Qualifier"] isEqualToString:@"none"]||[[[allNewObjectsPhenoList objectAtIndex:row] objectForKey:@"Qualifier"] isEqualToString:@"none "])
        qualifier = [NSString stringWithFormat:@": %@",[[allNewObjectsPhenoList objectAtIndex:row] objectForKey:@"Qualifier"]];
    else
        qualifier = @"";
    
    NSString *strEvidence  = [NSString stringWithFormat:@"%@%@", [[allNewObjectsPhenoList objectAtIndex:row] objectForKey:@"Observable"],qualifier];

      
    NSString *strChemical = [[allNewObjectsPhenoList objectAtIndex:row] objectForKey:@"Chemical"];
	
    if ([strChemical length] != 0) 
	{
		strChemical = [NSString stringWithFormat:@"Chemical:%@",strChemical];
	}
	else 
    {
		strChemical = @"";
	}
    
    NSString *detailLabel;
    
    if([mutant isEqualToString:@""])
        detailLabel  = [NSString stringWithFormat:@"Mutant Type:Null"];
    else
        detailLabel  = [NSString stringWithFormat:@"%@", mutant];
    
    
    if([strChemical length]>0)
    {
        detailLabel = [NSString stringWithFormat:@"%@ \n%@",detailLabel,strChemical];
    }
    
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        if (textRange.location != NSNotFound) 
        {	
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                contentRect = CGRectMake(20, 0.0, 850.0, 40);
                EvideRect  =   CGRectMake(20, 25.0, 850.0, 40);
                
            } 
            else
            {
                contentRect = CGRectMake(20.0, 0.0, 600.0, 50);
                EvideRect  =   CGRectMake(20, 25.0, 600.0, 50);
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
            
            FeatureName.text = featName;
            
            UILabel *geneName = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 80, 20)];
            geneName.backgroundColor = [UIColor clearColor];
            geneName.tag = kCellGeneNmTag;
            geneName.font = [UIFont systemFontOfSize:12];
            [geneName setTextAlignment:UITextAlignmentCenter];
            
            geneName.text = gene;
            
            UILabel *textView = [[UILabel alloc] initWithFrame:contentRect];
            
            textView.text = strEvidence;
            textView.numberOfLines = 0;
            
            textView.font = [UIFont boldSystemFontOfSize:15];
            textView.tag = kCellLabelTag;
            textView.backgroundColor = [UIColor clearColor];
            
            UILabel *EvidView = [[UILabel alloc] initWithFrame:EvideRect];
            
            EvidView.text = detailLabel;
            EvidView.numberOfLines = 0;
            EvidView.textColor = [UIColor darkGrayColor];

            EvidView.font = [UIFont systemFontOfSize:15];
            EvidView.tag = kCellEvideNmTag;
            EvidView.backgroundColor = [UIColor clearColor];
            
            [sqrimg addSubview:FeatureName];
            [sqrimg addSubview:geneName];
            [cell.contentView addSubview:textView];
            
            [cell.contentView addSubview:EvidView];
            
            [textView release];
            [EvidView release];
            [sqrimg release];
            [FeatureName release];
            [geneName release];
            
        }
        else 
        {
            
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                
                contentRect = CGRectMake(02, 2, 390.0, 40);
                EvideRect = CGRectMake(02, 40, 390.0, 40);
                
            } 
            else
            {
                contentRect = CGRectMake(02, 2, 240.0, 40);
                EvideRect = CGRectMake(02, 40, 240.0, 40);
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
            
            FeatureName.text = featName;
            
            UILabel *geneName = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 80, 20)];
            geneName.backgroundColor = [UIColor clearColor];
            geneName.tag = kCellGeneNmTag;
            geneName.font = [UIFont systemFontOfSize:12];
            [geneName setTextAlignment:UITextAlignmentCenter];
            geneName.text = gene;
            
            
            UILabel *textView = [[UILabel alloc] initWithFrame:contentRect];
            
            textView.contentMode = UIViewContentModeTopLeft;
            
            textView.text = strEvidence;
            textView.numberOfLines = 0;
            textView.font = [UIFont boldSystemFontOfSize:12];

            textView.tag = kCellLabelTag;
            textView.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:textView];
            
            UILabel *EvidView = [[UILabel alloc] initWithFrame:EvideRect];
            
            EvidView.text = detailLabel;
            EvidView.textColor = [UIColor darkGrayColor];
            EvidView.numberOfLines = 0;
            
            EvidView.font = [UIFont systemFontOfSize:12];
            EvidView.tag = kCellEvideNmTag;
            EvidView.backgroundColor = [UIColor clearColor];
            
            [sqrview addSubview:FeatureName];
            [sqrview addSubview:geneName];
            [cell.contentView addSubview:textView];
            [cell.contentView addSubview:EvidView];
            
            
            [textView release];
            [EvidView release];
            
            [sqrview release];
            [FeatureName release];
            [geneName release];
            
        }
    } 
    else
    {
        if (textRange.location != NSNotFound) 
        {	
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                contentRect = CGRectMake(20, 0.0, 850.0, 40);
                EvideRect  =   CGRectMake(20, 25.0, 850.0, 40);
                
            } 
            else
            {
                
                contentRect = CGRectMake(20.0, 0.0, 600.0, 50);
                EvideRect   =  CGRectMake(20, 25.0, 600.0, 50);
            }   
            
            
            UIImageView *sqrimg = (UIImageView *)[cell.contentView viewWithTag:kCellSquareTag];
            sqrimg.image = [UIImage imageNamed:@"Square.png"];
            
            
            UILabel *textView = (UILabel *)[cell.contentView viewWithTag:kCellLabelTag];
            
            
            textView.text = strEvidence;
            textView.numberOfLines = 0;
            textView.backgroundColor = [UIColor clearColor];
            textView.frame = contentRect;
            textView.font = [UIFont boldSystemFontOfSize:15];

            textView.tag = kCellLabelTag;
            
            UILabel *EvidView = (UILabel *)[cell.contentView viewWithTag:kCellEvideNmTag];
            
            EvidView.text = detailLabel;
            EvidView.numberOfLines = 0;
            EvidView.frame = EvideRect;
            EvidView.font = [UIFont systemFontOfSize:15];
            EvidView.tag = kCellEvideNmTag;
            EvidView.backgroundColor = [UIColor clearColor];
            EvidView.textColor = [UIColor darkGrayColor];

        }
        else
        {
            
            
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                
                contentRect = CGRectMake(02, 2, 390.0, 40);
                EvideRect = CGRectMake(02, 40, 390.0, 40);
                
            } else{
                
                contentRect = CGRectMake(02, 2, 240.0, 40);
                EvideRect = CGRectMake(02, 40, 240.0, 40);
            }
            

            UILabel *textView = (UILabel *)[cell.contentView viewWithTag:kCellLabelTag];
            textView.frame = contentRect;
            
            
            textView.contentMode = UIViewContentModeTopLeft;
            textView.frame = contentRect;
            textView.text = strEvidence;
            textView.numberOfLines = 0;
            textView.font = [UIFont boldSystemFontOfSize:12];

            textView.tag = kCellLabelTag;
            textView.backgroundColor = [UIColor clearColor];
            
            
            UILabel *EvidView = (UILabel *)[cell.contentView viewWithTag:kCellEvideNmTag];
            
            EvidView.text = detailLabel;
            EvidView.numberOfLines = 0;
            EvidView.frame = EvideRect;
            EvidView.font = [UIFont systemFontOfSize:12];
            EvidView.tag = kCellEvideNmTag;
            EvidView.backgroundColor = [UIColor clearColor];
            EvidView.textColor = [UIColor darkGrayColor];
            
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	@try {
		//NSUInteger row = [indexPath row];
        
		//NSLog(@">>%@",[allNewObjectsPhenoList objectAtIndex:indexPath.row]);
		[staticFunctionClass setPhenoDict:[allNewObjectsPhenoList objectAtIndex:indexPath.row]];
        
        
		[tempTableview deselectRowAtIndexPath:indexPath animated:NO];
		
		NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
		if (textRange.location != NSNotFound) 
		{
			objPhenoDetails = [[FeatPhenoTypeDetails alloc] initWithNibName:@"FeatPhenoTypeDetails_iPad" bundle:[NSBundle mainBundle]];
		}
		else
		{
			objPhenoDetails = [[FeatPhenoTypeDetails alloc] initWithNibName:@"FeatPhenoTypeDetails" bundle:[NSBundle mainBundle]];
		}

		objPhenoDetails.title = self.title;
		objPhenoDetails.managedObjectContext = managedObjectContext;
		[self.navigationController pushViewController:objPhenoDetails animated:YES];
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@",[e description]);
	}
}


#pragma mark -
#pragma mark Mail delegate
//Function called when email icon is pressed and mail is composed with feature details

-(IBAction)pushedEmailButton:(id)sender 
{
	
    NSString *featName = [staticFunctionClass getGeneName];
	NSArray *display = [featName componentsSeparatedByString:@"/"];
	NSString *sysName = [display objectAtIndex:1];

    NSString *SubjectLine = [NSString stringWithFormat:@"%@, Phenotype List", featName];
    
    
    [staticFunctionClass setSubjectLine:SubjectLine];
    
    
    NSMutableArray *arrRec = [[NSMutableArray alloc] init];
    
    EmailViewController *emailView = [[EmailViewController alloc]initWithNibName:@"EmailViewController" bundle:[NSBundle mainBundle]];
    
    NSString *textDataString =@"";
    NSString *strAllDetails = @"";
    NSString *gene;
  
    
    if (display.count > 1) {
        featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:1]];
        gene = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
    } else {
        
        featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
        gene = @"";
    }
    
    if ([allNewObjectsPhenoList count] < 51) {
        
        for (int i =0; i<[allNewObjectsPhenoList count];i++)
        {
            
            NSString *mutant;
            if(![[[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"mutantinfo"] isEqualToString:@"null"])
                mutant =  [NSString stringWithFormat:@"<b>Mutant Type:</b>%@", [[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"mutantinfo"]];
            
            else
                mutant = @"";
            
            NSString *qualifier;
            if(![[[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"Qualifier"] isEqualToString:@"none"]||[[[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"Qualifier"] isEqualToString:@"none "])
                qualifier = [NSString stringWithFormat:@"<b>Qualifier:</b>%@",[[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"Qualifier"]];
            else
                qualifier = @"";
            
            NSString *strEvidence  = [NSString stringWithFormat:@"<b>Observable:</b>%@", [[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"Observable"]];
            
            NSString *strChemical = [[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"Chemical"];
            if ([strChemical length] != 0) 
            {
                strChemical = [NSString stringWithFormat:@"<b>Chemical:</b>(%@)",strChemical];
            }
            else {
                strChemical = @"";
            }
            
            strAllDetails = [strAllDetails stringByAppendingFormat:@"%@\t%@\t%@\t%@\t%@\t%@<br><br>",gene,featName, mutant, qualifier,strEvidence,strChemical];
            
			if (i==0) { //add link to phenotype page
				textDataString = [textDataString stringByAppendingFormat:@"<div><a href=\"http://www.yeastgenome.org/cgi-bin/phenotype/phenotype.fpl?locus=%@\">%@/%@ Phenotypes</a><br><br></div><div>", sysName, gene, featName];
			}
			
            textDataString = [textDataString stringByAppendingFormat:@"%@",strAllDetails];
        }
		
		textDataString = [textDataString stringByAppendingFormat:@"</div>"];
		
		NSLog(@"FeatPhenotype: %@", textDataString);
		
        [staticFunctionClass setMessageBody:[NSString stringWithFormat:@"%@",textDataString]];
        [self.navigationController pushViewController:emailView animated:YES];
    }
    
    else if ([allNewObjectsPhenoList count] > 51) {
        
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM-dd-yyyy"];
        NSString *strcreatedtime = [dateFormat stringFromDate:today];
        [dateFormat release];
        
        int count = 51;
        
        for (int i =0; i<[allNewObjectsPhenoList count];i++)
        {
            
            count++;
            
            if (count == 200)
                break;
            
            NSString *mutant;
            if(![[[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"mutantinfo"] isEqualToString:@"null"])
                mutant =  [NSString stringWithFormat:@"Mutant Type:%@", [[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"mutantinfo"]];
            
            else
                mutant = @"";
            
            NSString *qualifier;
            if(![[[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"Qualifier"] isEqualToString:@"none"]||[[[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"Qualifier"] isEqualToString:@"none "])
                qualifier = [NSString stringWithFormat:@"Qualifier:%@",[[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"Qualifier"]];
            else
                qualifier = @"";
            
            NSString *strEvidence  = [NSString stringWithFormat:@"Observable:%@", [[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"Observable"]];
            
            NSString *strChemical = [[allNewObjectsPhenoList objectAtIndex:i] objectForKey:@"Chemical"];
            if ([strChemical length] != 0) 
            {
                strChemical = [NSString stringWithFormat:@"Chemical:(%@)",strChemical];
            }
            else {
                strChemical = @"";
            }
            
            
            strAllDetails = [strAllDetails stringByAppendingFormat:@"%@\t%@\t%@\t%@\t%@\t%@\n\n",gene,featName, mutant, qualifier,strEvidence,strChemical];
            
            
            textDataString = [textDataString stringByAppendingFormat:@"%@",strAllDetails];
        }
        
        
        NSData *fileData;
		NSString *bodyTitle = @"";
        
        fileData = [textDataString dataUsingEncoding:NSUTF8StringEncoding];
		bodyTitle = [bodyTitle stringByAppendingFormat:@"<div><a href=\"http://www.yeastgenome.org/cgi-bin/phenotype/phenotype.fpl?locus=%@\">%@ Phenotypes</a><br><br></div>", sysName, featName];
		
		NSLog(@"FeatPhenotype: %@", bodyTitle);

      
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        
        [controller setSubject:[NSString stringWithFormat:@"Phenotype List of features from YeastGenome, %@",strcreatedtime]];
        [controller setTitle:@"Export Phenotype List"];
		[controller setMessageBody:bodyTitle isHTML:YES];
        [controller addAttachmentData:fileData mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"PhenotypeList_%@.txt",strcreatedtime]];
        
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
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}




- (void)dealloc 
{

	[allNewObjectsPhenoList release];
    [super dealloc];
}


@end
