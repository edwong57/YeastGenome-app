//
//  FeatGoDetails.m
//  SGD_Vivek
//
//  Created by Vivek on 09/03/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*
 Class to display the list of type of GO Term. 
 eg: Molecular Function,Biological Process and Cellular Component.
 */
#import "FeatGoDetails.h"
#import "FeatGOTypeList.h"

#import "staticFunctionClass.h"
#import "SBJSON.h"
#import "webServiceHelper.h"
#import "GODetails.h"
#import "FeatGoTypeDetails.h"
#import "Reachability.h"


FeatGOTypeList *FeatGOTypeListVC;
NSString *goTypeMolecular;
NSString *goTypeBiological;
NSString *goTypeCellular;
int SelectedType;

@implementation FeatGoDetails

@synthesize strgenename;
@synthesize managedObjectContext;

@synthesize activityIndView;
@synthesize finalListArr;
@synthesize selectedFeature;

@synthesize strGOType;

@synthesize webData;
@synthesize webData1;
@synthesize myconnection;
@synthesize myconnection1;

#pragma mark -
#pragma mark Orientation Support 
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}
// for IOS6
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
	
    
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
	
	strgenename = [[NSString alloc] init];
	strgenename = self.title;
	self.title = @"GO Details";
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
	tlabel.text=self.title;
    tlabel.textColor=[UIColor blackColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;

    goTypeMolecular  = @"Molecular Function#";// [NSString stringWithFormat:@"Molecular Function"];
    goTypeBiological = @"Biological Process#"; //[NSString stringWithFormat:@"Biological Process"];
    goTypeCellular   = @"Cellular Component#";//[NSString stringWithFormat:@"Cellular Component"];


}


- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1; 
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		
	}
	
	// Configure the cell...
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
	{
		cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:18];
	}
	else {
		cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];

	}

	if (indexPath.row ==0) 
	{
        NSArray *arr1 = [goTypeMolecular componentsSeparatedByString:@"#"];
		cell.textLabel.text =[arr1 objectAtIndex:0];//goTypeMolecular;//[NSString stringWithFormat:@"Molecular Function"];
        cell.detailTextLabel.text = [arr1 objectAtIndex:1];
	}
	else if (indexPath.row ==1) 
	{
		//cell.textLabel.text = goTypeBiological;//[NSString stringWithFormat:@"Biological Process"];
        NSArray *arr1 = [goTypeBiological componentsSeparatedByString:@"#"];
		cell.textLabel.text =[arr1 objectAtIndex:0];
        cell.detailTextLabel.text = [arr1 objectAtIndex:1];

    }
	else if (indexPath.row == 2) 
	{
		//cell.textLabel.text = goTypeCellular;//[NSString stringWithFormat:@"Cellular Component"];
        NSArray *arr1 = [goTypeCellular componentsSeparatedByString:@"#"];
		cell.textLabel.text =[arr1 objectAtIndex:0];  
        cell.detailTextLabel.text = [arr1 objectAtIndex:1];
	}
	
   
    NSRange textRange1 = [cell.detailTextLabel.text rangeOfString:@"unknown"];
    
	if (textRange1.location != NSNotFound) {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
       

	}else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }
    

    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

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


#pragma mark - Multiple NSUrlconnection 

-(void)startAsyncLoad:(NSURL*)url tag:(NSString*)tag
{
    
   if(!isSuccess) 
   {
       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    CustomURLConnection *connection = [[CustomURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES tag:tag];
   
    
    if (connection) {
        
        [receivedData setObject:[[NSMutableData data] retain] forKey:connection.tag];
    }
       
   }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// Navigation logic may go here. Create and push another view controller.
	[staticFunctionClass initFeatGOTypeStr];
	[staticFunctionClass setGeneName:strgenename];
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
	SelectedType = indexPath.row;
    
	FeatGOTypeListVC = [[FeatGOTypeList alloc] initWithNibName:@"FeatGOTypeList" bundle:[NSBundle mainBundle]];
	FeatGOTypeListVC.managedObjectContext = managedObjectContext;

	if (indexPath.row ==0) 
	{
		FeatGOTypeListVC.title = @"Molecular Function"; 
		[staticFunctionClass setFeatGOTypeStr:@"molecular_function"];
	}
	else if (indexPath.row ==1) 
	{
		FeatGOTypeListVC.title = @"Biological Process"; 
		[staticFunctionClass setFeatGOTypeStr:@"biological_process"];
	}
	else if (indexPath.row == 2) 
	{
		FeatGOTypeListVC.title = @"Cellular Component"; 
		[staticFunctionClass setFeatGOTypeStr:@"cellular_component"];
	}
	
    //[self AccessServer];
    /*
	[self.navigationController pushViewController:FeatGOTypeListVC animated:YES];
	
	[FeatGOTypeListVC release];
     */
    
    
    @try
    {
        
        if (finalListArr != nil) 
        {
            [finalListArr release];
            finalListArr = nil;
        }
        finalListArr = [[NSMutableArray alloc] init];
        
        strGOType = [staticFunctionClass getFeatGOTypeStr];
        
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features" inManagedObjectContext:managedObjectContext];
        [request setEntity:entity];
        
        NSString *featName = [staticFunctionClass getGeneName];
        
        UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
        tlabel.text=[NSString stringWithFormat:@"%@ %@",featName,self.navigationItem.title];
        
        tlabel.textColor=[UIColor blackColor];
        tlabel.backgroundColor =[UIColor clearColor];
        tlabel.adjustsFontSizeToFitWidth=YES;
        self.navigationItem.titleView=tlabel;
        
        
        NSArray *display = [featName componentsSeparatedByString: @"/"];
        
        if (display.count > 1) {
            featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:1]];
        } else {
            featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
        }
        
        
        NSPredicate *fetchByFeatureName = [NSPredicate predicateWithFormat:@"featureName = %@", featName];
        
// NSLog(@"%@",fetchByFeatureName);
		
        [request setPredicate:fetchByFeatureName];
        
        NSError *error;
        NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:request error:&error];
        
        selectedFeature = [fetchedObjects objectAtIndex:0];  //gets the feature object		
        [request release];
        
        NSSet *goDetailsSet = selectedFeature.godetails;
//		NSLog (@"GO details set size for %@: %i", selectedFeature.featureName, [goDetailsSet count]);
 
		NSPredicate *goTypePredicate = [NSPredicate predicateWithFormat:@"goType == %@",strGOType];
		
		NSSet *filteredGoDetailsSet = [goDetailsSet filteredSetUsingPredicate:goTypePredicate];
		
//		NSLog (@"Filtered GO %@ details set size for %@: %i", strGOType, selectedFeature.featureName, [filteredGoDetailsSet count]);
		
		
        //CHECKING CONNECTIVITY TO SGD
        Reachability *rchbility = [[Reachability reachabilityWithHostName: @"yeastgenome.org"] retain];
        NetworkStatus remoteHostStatus = [rchbility currentReachabilityStatus];
        [rchbility release];
        
		
        if ([filteredGoDetailsSet count] != 0) {  //something in the database
			
            for (GODetails *goDetObj in [filteredGoDetailsSet allObjects]) {
					NSMutableDictionary *tmpAnnotDict = [[NSMutableDictionary alloc] init];
                    [tmpAnnotDict setValue:goDetObj.annotation forKey:@"Annotation"];
                    [tmpAnnotDict setValue:goDetObj.definition  forKey:@"definition"];
                    [tmpAnnotDict setValue:goDetObj.annotationType forKey:@"CurationType"];
                    //Get Code Evidence term 
                    [tmpAnnotDict setValue:goDetObj.evidence forKey:@"code"];
                    [tmpAnnotDict setValue:goDetObj.goReferences forKey:@"References"];
                    
                    [tmpAnnotDict setValue:goDetObj.goId forKey:@"identifier"];
                    
                    
                    [finalListArr addObject:[tmpAnnotDict copy]];
                    [tmpAnnotDict release];
            }
          
		//	if ([finalListArr count] != 0) {
                [FeatGOTypeListVC initwithArray:finalListArr];
                [self.navigationController pushViewController:FeatGOTypeListVC animated:YES];
                
                [FeatGOTypeListVC release];
                
         //  } else {
				
	//			NSLog(@"going to YeastMine");
				
    //            //CHECKING 'WAN' and Wi-Fi CONNECTION AVAILABILITY
   //             if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) {
    //                //CALLING WEB-SERVICE HELPER CLASS OBJECT FOR CHECKING CONNECTIVITY TO SGD SERVER
   //                 [self createProgressionAlertWithMessage:@"Retrieving from SGD"];
                    
   //                 NSString *str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.primaryIdentifier+Gene.secondaryIdentifier+Gene.symbol+Gene.goAnnotation.ontologyTerm.identifier+Gene.goAnnotation.ontologyTerm.name+Gene.goAnnotation.evidence.code.code+Gene.goAnnotation.ontologyTerm.namespace+Gene.goAnnotation.qualifier+Gene.goAnnotation.evidence.code.annotType+Gene.goAnnotation.ontologyTerm.description+Gene.goAnnotation.ontologyTerm.dataSets.dataSource.name\"+longDescription=\"List+all+GO+annotations+for+a+specified+gene.+Searches+for+the+primaryIdentifier+(SGDID),+secondaryIdentifier+(Systematic+Name),+symbol+(Standard+Gene+Name)+and+wild+card+queries+(such+as+*YAL*)+are+supported.++Manually+curated,+high-throughput,+and+computational+GO+annotations+are+included.+Genes+include+Uncharacterized+and+Verified+ORFs,+pseudogenes,+transposable+element+genes,+RNAs,+and+genes+Not+in+Systematic+Sequence+of+S228C.\"+sortOrder=\"Gene.primaryIdentifier+asc\"+constraintLogic=\"A+and+(B+or+C)+and+(D+or+E)+and+F\"><pathDescription+pathString=\"Gene.goAnnotation\"+description=\"GO+annotation\"/><constraint+path=\"Gene.status\"+code=\"B\"+op=\"=\"+value=\"Active\"/><constraint+path=\"Gene.status\"+code=\"C\"+op=\"IS+NULL\"/><constraint+path=\"Gene.qualifier\"+code=\"D\"+op=\"!=\"+value=\"Dubious\"/><constraint+path=\"Gene.qualifier\"+code=\"E\"+op=\"IS+NULL\"/><constraint+path=\"Gene\"+code=\"A\"+op=\"LOOKUP\"+value=\"%@\"+extraValue=\"S.+cerevisiae\"/><constraint+path=\"Gene.goAnnotation.ontologyTerm.namespace\"+code=\"F\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName,strGOType];
                    
   //                 [self webServiceCall:str];
   //             }
   //             //IF NOT REACHABLE THEN GIVING ALERT MESSAGE OF CONNECTION NOT AVAILABLE
  //              else if(remoteHostStatus == NotReachable) {
                    
                    
 //                   UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
 //                   [dialog setDelegate:self];
//                    [dialog setTitle:@"No network"];
//				    [dialog setMessage:@"Please check your network connection"];
 //                   [dialog addButtonWithTitle:@"Ok"];
    //                [dialog show];	
     //               [dialog release];
     //               [self.navigationController popViewControllerAnimated:NO];
    //                return;
    //           }
                
    //        }
        } else {  // nothing in Database
			
//			NSLog(@"going directly to yeastmine");
			
            //CHECKING 'WAN' and Wi-Fi CONNECTION AVAILABILITY
            if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
            {
                //CALLING WEB-SERVICE HELPER CLASS OBJECT FOR CHECKING CONNECTIVITY TO SGD SERVER
                [self createProgressionAlertWithMessage:@"Retrieving from SGD"];
            
                
                NSString *str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.primaryIdentifier+Gene.secondaryIdentifier+Gene.symbol+Gene.goAnnotation.ontologyTerm.identifier+Gene.goAnnotation.ontologyTerm.name+Gene.goAnnotation.evidence.code.code+Gene.goAnnotation.ontologyTerm.namespace+Gene.goAnnotation.qualifier+Gene.goAnnotation.evidence.code.annotType+Gene.goAnnotation.ontologyTerm.description+Gene.goAnnotation.ontologyTerm.dataSets.dataSource.name\"+longDescription=\"List+all+GO+annotations+for+a+specified+gene.+Searches+for+the+primaryIdentifier+(SGDID),+secondaryIdentifier+(Systematic+Name),+symbol+(Standard+Gene+Name)+and+wild+card+queries+(such+as+*YAL*)+are+supported.++Manually+curated,+high-throughput,+and+computational+GO+annotations+are+included.+Genes+include+Uncharacterized+and+Verified+ORFs,+pseudogenes,+transposable+element+genes,+RNAs,+and+genes+Not+in+Systematic+Sequence+of+S228C.\"+sortOrder=\"Gene.primaryIdentifier+asc\"+constraintLogic=\"A+and+(B+or+C)+and+(D+or+E)+and+F\"><pathDescription+pathString=\"Gene.goAnnotation\"+description=\"GO+annotation\"/><constraint+path=\"Gene.status\"+code=\"B\"+op=\"=\"+value=\"Active\"/><constraint+path=\"Gene.status\"+code=\"C\"+op=\"IS+NULL\"/><constraint+path=\"Gene.qualifier\"+code=\"D\"+op=\"!=\"+value=\"Dubious\"/><constraint+path=\"Gene.qualifier\"+code=\"E\"+op=\"IS+NULL\"/><constraint+path=\"Gene\"+code=\"A\"+op=\"LOOKUP\"+value=\"%@\"+extraValue=\"S.+cerevisiae\"/><constraint+path=\"Gene.goAnnotation.ontologyTerm.namespace\"+code=\"F\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName,strGOType];
                
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
                //[self.navigationController popViewControllerAnimated:NO];
                
                return;
            }	
        }
    }
    @catch (NSException * e)
    {
        NSLog(@"%@", [e description]);
    }
    
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

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    @try{
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if ([httpResponse statusCode] >= 400)
        {
            // do error handling here
            //NSLog(@"Received Error");
            //[delegate finishedDownloading:[NSString stringWithFormat:@""]];
        } 
        
        
        // Check for webdata and init webdata
        if (webData != nil) {
            webData = nil;
            
        }
        webData = [[NSMutableData data] retain];
        
    }
    @catch (NSException *ex) {
        
        if ([activityIndView isAnimating]) 
            [activityIndView stopAnimating];
        
        NSLog(@"%@",[ex description]);
    }
    
}	


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
   [webData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	@try
	{
        if ([activityIndView isAnimating]) 
            [activityIndView stopAnimating];
        
        NSLog(@"%@",[error description]);
		//[delegate finishedDownloading:[NSString stringWithFormat:@""]];
	}
	@catch (NSException *e) {
		NSLog(@"%@",[e description]);
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
	if ([activityIndView isAnimating]) 
		[activityIndView stopAnimating];
	
	@try 
	{	
       
        if ([webData length] != 0)
        {
            NSString *strJSONResponse = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
        
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
                    
                    UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
                    [dialog setDelegate:self];
                    [dialog setTitle:@"GO details not found"];
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
            [dialog setTitle:@"GO details not found"];
            //[dialog setMessage:@"No match found,please try another query."];
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

// Implement the finish downloading delegate method

- (void)finishedDownloading:(NSString *)strJSONResponse
{

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
					
                    NSDictionary *tempdictionary1 = [json objectWithString:strAllGene error:&error];
                    
                    
                    NSArray *allValues = [tempdictionary1 allValues];
                    NSArray *allKeys = [tempdictionary1 allKeys];
                    
                    for (int i=0; i<[allValues count]; i++) 
                    {
                        if ([[allValues objectAtIndex:i] isEqual:[NSNull null] ]) 
                        {
                            [tempdictionary1 setValue:@"" forKey:[allKeys objectAtIndex:i]];
                        }
                    }
                    
                    NSArray *items = [tempdictionary1 valueForKeyPath:@"goAnnotation"];
                    
                    for (int k = 0; k<[items count]; k++) 
                    {
                        NSArray *evidenceArr = [[items objectAtIndex:k] objectForKey:@"evidence"];
                        NSMutableDictionary *codeDict = [[evidenceArr objectAtIndex:0] objectForKey:@"code"];
                        NSString *codeValue = [codeDict valueForKey:@"code"];
                        
                        if([codeValue isEqualToString:@"ND"])
                        {
                            if ([activityIndView isAnimating]) 
                                [activityIndView stopAnimating];
                            
                            if (SelectedType == 0) 
                            {
                                goTypeMolecular  = @"Molecular Function#unknown";                            
                            }
                            else if (SelectedType ==1) 
                            {
                               goTypeBiological = @"Biological Process#unknown";
                            }
                            else if (SelectedType == 2) 
                            {
                                goTypeCellular   = @"Cellular Component#unknown";
                            }
                            
                            [self.tableView reloadData];
                            
                            return;
                        }
                    }
                    
                    
                    NSString *featName = [staticFunctionClass getGeneName];
                    NSArray *display = [featName componentsSeparatedByString: @"/"];
                    
                    if (display.count > 1) {
                        featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:1]];
                    } else {
                        featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
                    }
                    
                    NSString *str1 = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.primaryIdentifier+Gene.secondaryIdentifier+Gene.symbol+Gene.goAnnotation.ontologyTerm.identifier+Gene.goAnnotation.ontologyTerm.name+Gene.goAnnotation.evidence.code.code+Gene.goAnnotation.ontologyTerm.namespace+Gene.goAnnotation.qualifier+Gene.goAnnotation.evidence.publications.citation+Gene.goAnnotation.evidence.publications.pubMedId+Gene.goAnnotation.evidence.code.annotType+Gene.goAnnotation.ontologyTerm.description+Gene.goAnnotation.ontologyTerm.dataSets.dataSource.name\"+longDescription=\"List+all+GO+annotations+for+a+specified+gene.+Searches+for+the+primaryIdentifier+(SGDID),+secondaryIdentifier+(Systematic+Name),+symbol+(Standard+Gene+Name)+and+wild+card+queries+(such+as+*YAL*)+are+supported.++Manually+curated,+high-throughput,+and+computational+GO+annotations+are+included.+Genes+include+Uncharacterized+and+Verified+ORFs,+pseudogenes,+transposable+element+genes,+RNAs,+and+genes+Not+in+Systematic+Sequence+of+S228C.\"+sortOrder=\"Gene.primaryIdentifier+asc\"+constraintLogic=\"A+and+(B+or+C)+and+(D+or+E)+and+F\"><pathDescription+pathString=\"Gene.goAnnotation\"+description=\"GO+annotation\"/><constraint+path=\"Gene.status\"+code=\"B\"+op=\"=\"+value=\"Active\"/><constraint+path=\"Gene.status\"+code=\"C\"+op=\"IS+NULL\"/><constraint+path=\"Gene.qualifier\"+code=\"D\"+op=\"!=\"+value=\"Dubious\"/><constraint+path=\"Gene.qualifier\"+code=\"E\"+op=\"IS+NULL\"/><constraint+path=\"Gene\"+code=\"A\"+op=\"LOOKUP\"+value=\"%@\"+extraValue=\"S.+cerevisiae\"/><constraint+path=\"Gene.goAnnotation.ontologyTerm.namespace\"+code=\"F\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName,strGOType];
                    
                    NSURL *url = [[NSURL alloc] initWithString:[str1 stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
                    
                    [self addSkipBackupAttributeToItemAtURL:url];
                    
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                    
                    
                    myconnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
                    
                }
				else
				{
                    if ([activityIndView isAnimating]) 
                        [activityIndView stopAnimating];
                    
                     UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
                     [dialog setDelegate:self];
                     [dialog setTitle:@"GO details not found"];
                     //[dialog setMessage:@"No match found,please try another query."];
                     [dialog addButtonWithTitle:@"OK"];
                     [dialog show];	
                     [dialog release];
                     
                }
            }
        }
		else
		{
            if ([activityIndView isAnimating]) 
                [activityIndView stopAnimating];
                                
             UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
             [dialog setDelegate:self];
             [dialog setTitle:@"GO details not found"];
             //[dialog setMessage:@"No match found,please try another query."];
             [dialog addButtonWithTitle:@"OK"];
             [dialog show];	
             [dialog release];
        }
		
	}
	// now we are sure the download is complete
	@catch (NSException *e) 
	{
        if ([activityIndView isAnimating]) 
            [activityIndView stopAnimating];
        
		NSLog(@"%@",[e description]);
	}
	
    
}

-(void) getResultsAndInsert:(NSDictionary *)resultSet
{
   // NSLog(@"Result Insert.....");
    
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
	
	//[tempTableview reloadData];
    
    if ([finalListArr count] != 0)
    {
        [FeatGOTypeListVC initwithArray:finalListArr];
        [self.navigationController pushViewController:FeatGOTypeListVC animated:YES];
        
        [FeatGOTypeListVC release];
        
    }
    
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
				
				for (int i =0; i<[codeDict count]; i++) 
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
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}




- (void)dealloc 
{
	[super dealloc];
	[strgenename release];
}


- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    
    
    const char* attrName = "com.apple.MobileBackup";
    
    u_int8_t attrValue = 1;
    
    
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    return result == 0;
    
}

@end
