//
//  FeatListViewController.m
//  SGD_2
//
//  Created by Vishwanath on 08/07/11.
//  Copyright 2011 Stanford University. All rights reserved.
//
/*
 Class to browse the features according to the feature type and qualifier.
 eg: feature type 'ORF' with qualifier 'Verified'.
 */

#import "FeatListViewController.h"
#import "BrowseGeneList.h"
#import "SGD_2AppDelegate.h"
#import "staticFunctionClass.h"
#import "Features.h"
#import "FeatAnnotation.h"

@implementation FeatListViewController

@synthesize allFeatsList;
@synthesize managedObjectContext;
@synthesize browseFeatureListVC;

@synthesize progAlertView, activityIndView;

#pragma mark -
#pragma mark Orientation Support 
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
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

//Initalize the view with Nib file
-(id)init {
	if ((self=[super initWithNibName:@"FeatListViewController" bundle:nil])) {
		self.title = @"Feature Types";
		
		NSString* buttonImg = [[NSBundle mainBundle] pathForResource:@"BrowseButton" ofType:@"png"];
		UIImage* browseImg = [[UIImage alloc] initWithContentsOfFile:buttonImg];
		
		
		UITabBarItem *browseItem = [[UITabBarItem alloc] initWithTitle:@"Browse" image:browseImg tag:0];
		self.tabBarItem = browseItem;
		[browseImg release];
		[browseItem release];
		
	}
	
	return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	    
	// sets title to smaller font
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold-BoldOblique" size: 16.0];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setTextColor:[UIColor blackColor]];
	[titleLabel setText:@"Feature Types"];
	[titleLabel sizeToFit];
	[self.navigationController.navigationBar.topItem setTitleView:titleLabel];
	[titleLabel release];
	self.navigationItem.hidesBackButton	= YES;
	[staticFunctionClass initializeFeatObjListFeat];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Browse" 
																   style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
    
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features" inManagedObjectContext:managedObjectContext];
    
    [request setEntity:entity];
    
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"featureType",@"annotation.qualifier", nil]];
    
    
    // Execute the fetch to display features by Feature Type
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    
    if (allFeatsList != nil) 
    {
        [allFeatsList removeAllObjects];
        [allFeatsList release];
        allFeatsList = nil;
    }
    
    allFeatsList = [[NSMutableArray alloc] init];
    
    for( NSDictionary* obj in objects ) {
        NSString *tmpFeatTyp = [obj objectForKey:@"featureType"];
        NSString *tmpQualifier = [NSString stringWithFormat:@"%@",[obj objectForKey:@"annotation.qualifier"]];
        
        if([tmpFeatTyp isEqualToString:@"ORF"] && ([tmpQualifier isEqualToString:@"Verified"]||[tmpQualifier isEqualToString:@"Dubious"]||[tmpQualifier isEqualToString:@"Uncharacterized"])||[tmpFeatTyp isEqualToString:@"ncRNA"]||[tmpFeatTyp isEqualToString:@"rRNA"]||[tmpFeatTyp isEqualToString:@"snRNA"]||[tmpFeatTyp isEqualToString:@"snoRNA"]||[tmpFeatTyp isEqualToString:@"tRNA"]){
            
            [allFeatsList  addObject:obj]; 
            
        }
        
    }
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"featureType" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"annotation.qualifier" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,nil];
    [allFeatsList sortUsingDescriptors:sortDescriptors];
    [sortDescriptor1 release];
    [sortDescriptor2 release];

    
 
}




- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    @try 
    {
       [tempTableview reloadData]; 
        
        
    }
    @catch (NSException *exception) 
    {
        NSLog(@"%@",[exception description]);
    }

}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    if ([activityIndView isAnimating]) 
        [activityIndView stopAnimating];
    
}





#pragma mark -
#pragma mark Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1; 
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [allFeatsList count];

}




// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
  
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];	
     
    }
                   
  	
     NSString *tmpStrFeatType; 
    if(![[[allFeatsList objectAtIndex:indexPath.row] objectForKey:@"annotation.qualifier"] isEqualToString:@""]){
    tmpStrFeatType = [NSString stringWithFormat:@"%@, %@",[[allFeatsList objectAtIndex:indexPath.row] objectForKey:@"featureType"],[[allFeatsList objectAtIndex:indexPath.row] objectForKey:@"annotation.qualifier"]];
    }
    else{
       tmpStrFeatType =[NSString stringWithFormat:@"%@",[[allFeatsList objectAtIndex:indexPath.row] objectForKey:@"featureType"]];
    }
    
    cell.textLabel.text = tmpStrFeatType;    
    NSRange textRange =[[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if(textRange.location != NSNotFound)
	{   
        
    
    }
    else
    {
        cell.textLabel.font = [UIFont systemFontOfSize:14];
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
		return 44;
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




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        
    // Navigation logic may go here. Create and push another view controller.
	@try 
	{

		if (browseFeatureListVC != nil) 
		{
			[browseFeatureListVC release];
			browseFeatureListVC = nil;
		}
		
		browseFeatureListVC = [[BrowseGeneList alloc] initWithNibName:@"BrowseGeneList" bundle:[NSBundle mainBundle]];
		
		browseFeatureListVC.title = @"Browse Features";
		browseFeatureListVC.managedObjectContext = managedObjectContext;
        if ([[[allFeatsList objectAtIndex:indexPath.row] objectForKey:@"annotation.qualifier"] isEqualToString:@""]) 
        {
            [staticFunctionClass setFeatureType:[[allFeatsList objectAtIndex:indexPath.row] objectForKey:@"featureType"]];  
        }
        else
        {
            NSString *tmpStrFeatType = [NSString stringWithFormat:@"%@#%@",[[allFeatsList objectAtIndex:indexPath.row] objectForKey:@"featureType"],[[allFeatsList objectAtIndex:indexPath.row] objectForKey:@"annotation.qualifier"]];
            [staticFunctionClass setFeatureType:tmpStrFeatType];
        }
             
		[self.navigationController pushViewController:browseFeatureListVC animated:YES];
           
 
	    [tempTableview deselectRowAtIndexPath:indexPath animated:NO];
        
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@",[e description]);
	}
}




#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}



- (void)dealloc
{
    [super dealloc];
	[allFeatsList release];
	
}


@end

