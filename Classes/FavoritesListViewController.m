//
//  FavoritesListViewController.m
//  SGD_2
//
//  Created by Vivek on 08/07/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*
 
 Class to display the favorite features added by the user.
 class also implements the ability to remove the features
 from the favorite category,and composing email with the details 
 of those features.
 */

#import "FavoritesListViewController.h"
#import "FeatureDetails.h"
#import "staticFunctionClass.h"
#import "Features.h"
#import "SGD_2AppDelegate.h"
#import "FeatAnnotation.h"
#import "MyUITextViewController.h"

@implementation FavoritesListViewController

@synthesize favFeatsList;
@synthesize managedObjectContext;
@synthesize favFeatureDetailsVC;
@synthesize selectedArray;

@synthesize inPseudoEditMode;
@synthesize selectedImage;
@synthesize unselectedImage;

@synthesize EditButton;
@synthesize CancelButton;


#pragma mark -
#pragma mark Orientation Support 
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

//for iOS6

- (BOOL)shouldAutorotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}



/*Function is called when device is rotated and implements 
 the orientation/alignment of the labels*/
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
    if (textRange.location == NSNotFound) {
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            EditButton.frame = CGRectMake(0, 5, 40, 25);
            CancelButton.frame = CGRectMake(45,05, 40,25);
        }
        else {
            EditButton.frame = CGRectMake(0, 5, 40, 30);
            CancelButton.frame = CGRectMake(45,05, 40,30);
        }
    }	
	[self.tableView reloadData];
}



#pragma mark -
#pragma mark View lifecycle

-(id)init {
	if ((self=[super initWithNibName:@"FavoritesListViewController" bundle:nil])) {
		self.title = @"Favorites";
		
		UITabBarItem *faveItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:0];
		self.tabBarItem = faveItem;
		[faveItem release];
        
       

		
	}
	
	return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    self.editing = NO;
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
    if (textRange.location == NSNotFound) {
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            EditButton.frame = CGRectMake(0, 5, 40, 25);
            CancelButton.frame = CGRectMake(45,05, 40,25);
        }
        else {
            EditButton.frame = CGRectMake(0, 5, 40, 30);
            CancelButton.frame = CGRectMake(45,05, 40,30);
        }
    }
    self.tableView.editing = NO;
    inPseudoEditMode = NO;
    CancelButton.hidden = YES;
    [self populateSelectedArray];
   
    
    [EditButton setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
    EditButton.tag =1;
    
    if ([favFeatsList count] == 0){
        EditButton.hidden = YES;
        EmailButton.hidden = YES;
    }
    else{
        EditButton.hidden = NO;
        EmailButton.hidden = NO;
    }
	[self.tableView reloadData];
    
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[staticFunctionClass initializeFavObjFeat];
	// sets title to smaller font
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold-BoldOblique" size: 16.0];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setTextColor:[UIColor blackColor]];
	[titleLabel setText:@"Favorite Features"];
	[titleLabel sizeToFit];
	[self.navigationController.navigationBar.topItem setTitleView:titleLabel];
	[titleLabel release];
	self.navigationItem.hidesBackButton	= YES;
    
    UIView *EmailView = [[UIView alloc]initWithFrame:CGRectMake(0,0,80,35)];
    EmailView.backgroundColor = [UIColor clearColor];

    static UIImage *EmailImage;
    CGRect EmailFrame = CGRectMake(40,1, 35,35);
    EmailButton = [[UIButton alloc]initWithFrame:EmailFrame];
    EmailImage = [UIImage imageNamed:@"email.png"];
    [EmailButton setBackgroundImage:EmailImage forState:UIControlStateNormal];
    EmailButton.backgroundColor = [UIColor clearColor];
    
    [EmailButton addTarget:self action:@selector(pushedExFavoritesButton:) forControlEvents:UIControlEventTouchUpInside];
    [EmailView addSubview:EmailButton];
    
    UIBarButtonItem *addButton =[[UIBarButtonItem alloc] initWithCustomView:EmailView];
    [self.navigationItem setRightBarButtonItem:addButton animated:NO];
  

    
    UIView *EditView = [[UIView alloc]initWithFrame:CGRectMake(0,0,100,35)];
    EditView.backgroundColor = [UIColor clearColor];
    
    static UIImage *FavViewImage;
    CGRect EditFrame = CGRectMake(0,05, 40,30);

    EditButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    FavViewImage = [UIImage imageNamed:@"edit.png"];

    [EditButton setBackgroundImage:FavViewImage forState:UIControlStateNormal];
    
    EditButton.frame = EditFrame;
    EditButton.tag = 1;
    
       
    [EditButton addTarget:self action:@selector(pushedEditButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    CancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];    
    CancelButton.frame = CGRectMake(45,05, 40,30);
    [CancelButton setBackgroundImage:[UIImage imageNamed:@"done.png"]forState:UIControlStateNormal];
    CancelButton.tag =2;
    
 
    CancelButton.hidden = YES;
    [CancelButton addTarget:self action:@selector(pushedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
      
    [EditView addSubview:EditButton];
    [EditView addSubview:CancelButton];
    
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:EditView];
    self.navigationItem.leftBarButtonItem  = leftButton;

    // set up favorites list -- get it from CoreData
	[self LoadFavList];
    
}




//function to fetch the favorite marked features in core data

-(void) LoadFavList
{
	@try
	{
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features" inManagedObjectContext:managedObjectContext];
		
		NSString *value = @"1";
		
        NSPredicate *favoriteFilter = [NSPredicate predicateWithFormat: @"(favorite=%@)",value];

		[request setEntity:entity];
		[request setPredicate:favoriteFilter];
		
		NSError *error;	
		NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:request error:&error];
		
		favFeatsList = [[NSMutableArray alloc] initWithArray:fetchedObjects];
		[request release];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"geneName" ascending:YES];
		NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
		[favFeatsList sortUsingDescriptors:sortDescriptors];
		[sortDescriptor release];
		
		[self.tableView reloadData];
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@",[e description]);
	}
    
}




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    @try
	{
				
		self.inPseudoEditMode = NO;
		
		self.selectedImage = [UIImage imageNamed:@"check_report.png"];
		self.unselectedImage = [UIImage imageNamed:@"unselected.png"];
		
        self.navigationItem.leftBarButtonItem.title = @"Edit";
      

		[self populateSelectedArray];
	}
	@catch (NSException * e)
	{
		NSLog(@"%@", [e description]);
	}
    
	[self.tableView reloadData];

}



- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: 
    //	self.myOutlet = nil;
}

- (void)populateSelectedArray
{
	@try {
		NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[favFeatsList count]];
		for (int i=0; i < [favFeatsList count]; i++)
			[array addObject:[NSNumber numberWithBool:NO]];
		self.selectedArray = array;
		[array release];
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@", [e description]);
	}
	
}


#pragma mark -
#pragma mark Alert Delegate
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	NSString *strTitle = [actionSheet title];
	
	if([strTitle compare:@"Favorite List"] == 0) 
	{
		if (buttonIndex == 1) 
		{
			//[self performSelectorOnMainThread:@selector(doFavoriteExp) withObject:nil waitUntilDone:YES];
		}
		
	}
    if([strTitle compare:@"Delete Favourite"] == 0) 
	{
		if (buttonIndex == 1) 
		{
			[self deletefavorite];
            [EditButton setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
            EditButton.tag =1;
			[self populateSelectedArray];
			[self.tableView reloadData];
		}else{
        
            CancelButton.hidden = YES;
            inPseudoEditMode = NO;
            [EditButton setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
            EditButton.tag =1;
            [self populateSelectedArray];
            
            [self.tableView reloadData];
        }
		
	}
	else {
		return;
	}
	
	
}


#pragma mark -
#pragma mark Mail delegate


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	[controller dismissModalViewControllerAnimated:NO];
	
	[self.navigationController popViewControllerAnimated:YES];
	
	
}




#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1; 
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [favFeatsList count]; 
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *myCell = @"myCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
	// Configure the cell...
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    Features *singleFeat  = [favFeatsList objectAtIndex:indexPath.row];
    CGRect contentRect;
    
	//if (cell == nil) 
    {
		
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:myCell] autorelease];
        
        
        NSRange textRange =[[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
        if(textRange.location != NSNotFound)
        {   
            
            if (self.editing == YES) {
                
                if(orientation == UIInterfaceOrientationLandscapeLeft || 
                   orientation == UIInterfaceOrientationLandscapeRight) 
                {
                    contentRect = CGRectMake(115, 5, 800, 70);
                }
                else
                {
                    contentRect = CGRectMake(115, 5, 500, 70);            
                }
            }
            
            else {
                if(orientation == UIInterfaceOrientationLandscapeLeft || 
                   orientation == UIInterfaceOrientationLandscapeRight) 
                {
                    contentRect = CGRectMake(115, 5, 870, 70);
                }
                else
                {
                    contentRect = CGRectMake(115, 5, 590, 70);            
                }                
            }
            
            
            
            UIButton *imageView = [[UIButton alloc] init];
            imageView.frame = CGRectMake(4.0, 30.0, 20.0, 20.0);
            
           
            NSNumber *selected = [selectedArray objectAtIndex:[indexPath row]];
            UIImage *image = ([selected boolValue]) ? selectedImage : unselectedImage;
            [imageView setBackgroundImage:image forState:UIControlStateNormal];
           
            [cell.contentView addSubview:imageView];
            imageView.hidden = !inPseudoEditMode;
            imageView.tag = kCellImageViewTag;
            imageView.titleLabel.text = [NSString stringWithFormat:@"%i",indexPath.row];

            [imageView release];
            
            
            UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(29, 7, 80, 65)];
            
            imgview.image = [UIImage imageNamed:@"Square.png"];
            imgview.tag = kCellImageTag;
                       
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
            
            textView.userInteractionEnabled = NO;
            textView.font = [UIFont systemFontOfSize:16];
            textView.textColor = [UIColor blackColor];
            textView.scrollEnabled = false;
            textView.editable = false;
            
            textView.backgroundColor = [UIColor clearColor];
            
            textView.text = [strAllDetails stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceCharacterSet]];
            textView.tag = kCellLabelTag;
             
            

            [imgview addSubview:FeatureName];
            [imgview addSubview:geneName];
            [cell.contentView addSubview:imgview];
            [cell.contentView addSubview:textView];
         

            [textView release];
            [imgview release];
            [geneName release];
            
            
        }
        else
        {
            CGRect contentRect1; 
            
            if (self.editing == YES) {
                
                if(orientation == UIInterfaceOrientationLandscapeLeft || 
                   orientation == UIInterfaceOrientationLandscapeRight) 
                {
                    contentRect1 = CGRectMake(110, 3, 250,65);  
                }
                else
                {
                    contentRect1 = CGRectMake(110, 3, 118,65);            
                }
            }
            
            else {
                if(orientation == UIInterfaceOrientationLandscapeLeft || 
                   orientation == UIInterfaceOrientationLandscapeRight) 
                {
                    contentRect1 = CGRectMake(110, 3, 275,65);           
                    
                }
                else
                {
                    
                    contentRect1 = CGRectMake(110, 3, 182,65);            
                    
                    
                }            
            }
            

           
                                
            UIButton *imageView = [[UIButton alloc] init];
            imageView.frame = CGRectMake(4.0, 30.0, 20.0, 20.0);
            [imageView addTarget:self action:@selector(pushedSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
            
            NSNumber *selected = [selectedArray objectAtIndex:[indexPath row]];
            UIImage *image = ([selected boolValue]) ? selectedImage : unselectedImage;
            [imageView setBackgroundImage:image forState:UIControlStateNormal];
            
            [cell.contentView addSubview:imageView];
            imageView.hidden = !inPseudoEditMode;
            imageView.tag = kCellImageViewTag;
            imageView.titleLabel.text = [NSString stringWithFormat:@"%i",indexPath.row];
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
            
            UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(15, 13, 80, 65)];
            
            imgview.image = [UIImage imageNamed:@"Square.png"];
            imgview.tag = kCellImageTag;
          
            
            UITextView *textView = [[UITextView alloc] initWithFrame:contentRect1];

            textView.tag = kCellLabelTag;
            
            textView.userInteractionEnabled = NO;
            NSString *strAllDetails = singleFeat.annotation.descriptions;
            textView.font = [UIFont systemFontOfSize:11];
            textView.textColor = [UIColor blackColor];
            textView.scrollEnabled = false;
            textView.editable = false;
            
            textView.backgroundColor = [UIColor clearColor];
            
            textView.text = [strAllDetails stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceCharacterSet]]; 
            
            
            
            [imgview addSubview:FeatureName];
            [imgview addSubview:geneName];
            [cell.contentView addSubview:imgview];
            [cell.contentView addSubview:textView];
            
            [textView release];
            [imgview release];
            
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
	{
        return 80;
	}
	else {
		return 90;
	}
    
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	@try 
	{
        if (inPseudoEditMode)
        {
         [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            
            
        BOOL selected = [[selectedArray objectAtIndex:[indexPath row]] boolValue];
        [selectedArray replaceObjectAtIndex:[indexPath row] withObject:[NSNumber numberWithBool:!selected]];
            
            [self.tableView reloadData];

            
        }else{
		Features *selectedFeat = [favFeatsList objectAtIndex:indexPath.row];
		
		if (favFeatureDetailsVC != nil) 
		{
			[favFeatureDetailsVC release];
			favFeatureDetailsVC = nil;
		}
		
		NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
		if (textRange.location != NSNotFound) 
		{
			favFeatureDetailsVC = [[FeatureDetails alloc] initWithNibName:@"FeatureDetails_iPad" bundle:[NSBundle mainBundle]];
		}
		else
		{
			favFeatureDetailsVC = [[FeatureDetails alloc] initWithNibName:@"FeatureDetails" bundle:[NSBundle mainBundle]];
		}
		
		favFeatureDetailsVC.title = selectedFeat.displayName; 
		favFeatureDetailsVC.managedObjectContext = managedObjectContext;
		
		[self.navigationController pushViewController:favFeatureDetailsVC animated:YES];
        
		[staticFunctionClass setFavObjFeat:selectedFeat.displayName];
        }
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@",[e description]);
	}
	
	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL selected = [[selectedArray objectAtIndex:[indexPath row]] boolValue];
    [selectedArray replaceObjectAtIndex:[indexPath row] withObject:[NSNumber numberWithBool:!selected]];
    [self deletefavorite];
    
    if ([favFeatsList count] == 0){
        CancelButton.hidden = YES;
        EditButton.hidden = YES;
        EmailButton.hidden = YES;

    }
}


#pragma mark -
#pragma mark Action Method

-(void)pushedSelectedButton:(id)sender{
    
    UIButton *btn = (UIButton*)sender;
    
    
    
    BOOL selected = [[selectedArray objectAtIndex:[btn.titleLabel.text intValue]] boolValue];
    [selectedArray replaceObjectAtIndex:[btn.titleLabel.text intValue] withObject:[NSNumber numberWithBool:!selected]];
    
    [self.tableView reloadData];
    
}


//function called when email button is pressed 
-(void)pushedExFavoritesButton:(id)sender
{
    
    if ([favFeatsList count] != 0) 
    {
        if (self.editing == NO) {
            @try
            {
                
                [self performSelectorOnMainThread:@selector(doFavoriteExp) withObject:nil waitUntilDone:YES];
                
            }
            @catch (NSException * e) 
            {
                NSLog(@"%@",[e description]);
            }
        }
        
        else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please exit the edit mode" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
        
    }
    else
    {
        UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
        [dialog setDelegate:self];
        [dialog setTitle:@"No Features are in Favorite List"];
        [dialog addButtonWithTitle:@"OK"];
        [dialog show];	
        [dialog release];
    }
    
}




//Function called when Edit icon is clicked

-(void)pushedEditButton:(id)sender{
    
    self.editing = YES;
    
    if ([favFeatsList count]!=0)
        CancelButton.hidden = NO;
    else 
        CancelButton.hidden = YES;
    
    [self.tableView reloadData];
}



-(void)deletefavorite{
    
    
    NSMutableArray *rowsToBeDeleted = [[NSMutableArray alloc] init];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    int index = 0;
    for (NSNumber *rowSelected in selectedArray)
    {
        if ([rowSelected boolValue])
        {
            
            [rowsToBeDeleted addObject:[favFeatsList objectAtIndex:index]];
            NSUInteger pathSource[2] = {0, index};
            NSIndexPath *path = [NSIndexPath indexPathWithIndexes:pathSource length:2];
            [indexPaths addObject:path];
        }		
        index++;
    }
	
    for (Features *value in rowsToBeDeleted)
    {
		static int boolFav;
		
		boolFav = 0;
        
        
		[value setFavorite:boolFav];	
		
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
			NSLog(@"Couldn't save change to favorite\n");
		}		  
		
		[dnc removeObserver:self
					   name:NSManagedObjectContextDidSaveNotification
					 object:managedObjectContext];
		
		
		
		[self LoadFavList];
		
        
        
    }
    
    [indexPaths release];
    [rowsToBeDeleted release];
    
    inPseudoEditMode = NO;
    [self populateSelectedArray];
    
    [self.tableView reloadData];
    
    
}


/*Compose the email message body with the details of 
 the features in favorite catogory*/

-(void)doFavoriteExp{
    
    @try
	{
		
		NSDate *today = [NSDate date];
		NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormat setDateFormat:@"MM-dd-yyyy"];
		NSString *strcreatedtime = [dateFormat stringFromDate:today];
//		[dateFormat release];
		
		NSString *eMailBody = @"";
        
        if ([favFeatsList count] < 51) {
            for (Features *value in favFeatsList)
            {
                
                if ([value.geneName length] > 0) {
                    
                    eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b>Standard Name:</b>%@<br><b>Systematic Name: <a href=\"http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%@\">%@</a><br><b>Description:</b>%@</td></tr><br><br>",value.geneName,value.featureName,value.featureName, value.annotation.descriptions];
                }
                else {
                    
                    eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b><a href=\"http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%@\">%@</a><br><b>Description:</b>%@<br></td></tr><br><br>",value.featureName,value.featureName,value.annotation.descriptions];
                }
                
            //    textDataString = [textDataString stringByAppendingFormat:@"%@",eMailBody];
            }
            
            
//            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
			controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            
            [controller setSubject:[NSString stringWithFormat:@"Favorite List of features from YeastGenome, %@",strcreatedtime]];
            [controller setTitle:@"Export Favorite List"];
            
            
            [controller setMessageBody:eMailBody isHTML:YES];
            [self presentModalViewController:controller animated:NO];
	
	//		[eMailBody retain];
	//		[controller release];

            
		} else if ([favFeatsList count] > 51) {
            
            int count = 51;
			NSString *textDataString =@"";
            
            for (Features *value in favFeatsList)
            {
                
                count++;
                if (count == 130)
                    break;
                
                if ([value.geneName length] > 0) {
					
                    
                    eMailBody = [eMailBody stringByAppendingFormat:@"\nStandard Name:%@\nSystematic Name: <a href=\"http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%@\">%@</a>\nDescription:%@\n\n",value.geneName,value.featureName,value.featureName,value.annotation.descriptions];
                }
                else {
                    
                    eMailBody = [eMailBody stringByAppendingFormat:@"\n<a href=\"http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%@\">%@</a>\nDescription:%@\n\n",value.featureName,value.featureName, value.annotation.descriptions];
                }
                
                textDataString = [textDataString stringByAppendingFormat:@"%@",eMailBody];
            }
            
            
            NSData *fileData = [textDataString dataUsingEncoding:NSUTF8StringEncoding];
			
			NSLog(@"email: %@",eMailBody);
            
            //MFMailComposeViewController *
			controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            
            [controller setSubject:[NSString stringWithFormat:@"Favorite List of features from YeastGenome, %@",strcreatedtime]];
            [controller setTitle:@"Export Favorite List"];
            [controller addAttachmentData:fileData mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"Favorites_%@.txt",strcreatedtime]];
            
            [self presentModalViewController:controller animated:NO];
            
	//		[textDataString retain];
	//		[controller release];

        }

	}
	@catch (NSException * e) 
	{
		NSLog(@"Catch Error: %@", [e description]);
	}
    

}


-(void)pushedCancelButton:(id)sender{
    
    self.editing = NO;
    
    inPseudoEditMode = NO;
    CancelButton.hidden = YES;
    [self populateSelectedArray];
    
    [EditButton setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
    EditButton.tag =1;
    
    [self.tableView reloadData];
}




#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}




- (void)dealloc {
		
    [super dealloc];
}


@end

