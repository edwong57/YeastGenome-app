//
//  BrowseGeneList.m
//  SGD_2

//  Copyright 2011 Stanford University. All rights reserved.
//

/*Class to display the feature with particular feature type and qualifier
 eg: feature type 'ORF' with qualifier 'Verified'.
 
 It Implements add to favorite functionality and composing email to send
 details of features in the list.
*/

#import "BrowseGeneList.h"
#import "FeatureDetails.h"
#import "SGD_2AppDelegate.h"
#import "staticFunctionClass.h"
#import "Features.h"
#import "FeatAnnotation.h"
#import "Features.h"

@implementation BrowseGeneList

@synthesize allFeatsOfFeatureType;
@synthesize resAllFeatsOfFeatureType;
@synthesize managedObjectContext;
@synthesize browseFeatureDetailsVC;

@synthesize selectedArray;
@synthesize inPseudoEditMode;
@synthesize selectedImage;
@synthesize unselectedImage;

@synthesize FavButton;
@synthesize CancelButton,activityIndView,progressInd;
@synthesize currentLastCell,isScroll;

-(id)init {
	if ((self=[super initWithNibName:@"BrowseGeneList" bundle:nil])) {
		//self.title = @"Browse Features";
		
		NSString* buttonImg = [[NSBundle mainBundle] pathForResource:@"BrowseButton" ofType:@"png"];
		UIImage* browseImg = [[UIImage alloc] initWithContentsOfFile:buttonImg];
		
		
		UITabBarItem *browseItem = [[UITabBarItem alloc] initWithTitle:@"Browse" image:browseImg tag:0];
		self.tabBarItem = browseItem;
		
        [browseImg release];
		[browseItem release];
		
	}
	
	return self;
}





#pragma mark -
#pragma mark Orientation Support 

/*Function is called when device is rotated */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	
	[tempTableview reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

//FOR IOS6
- (BOOL)shouldAutorotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
#pragma mark -
#pragma mark Activity Method

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

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)viewDidLoad
{
        
    [super viewDidLoad];    
    
    
    page = 0;
    adjacents = 30;
    firstScrollOffset = 0;
    cntScroll = 0;
    
    // sets title to smaller font
    
	UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(100,0, 150, 40)];
	tlabel.text=self.navigationItem.title;
    tlabel.textColor=[UIColor blackColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    
    
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Browse" 
																   style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
    
    
    UIView *FavView = [[UIView alloc]initWithFrame:CGRectMake(0,0,90,35)];
    FavView.backgroundColor = [UIColor clearColor];
    
    static UIImage *FavViewImage;
    FavButton = [[UIButton alloc] init];     
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
    {
        FavView.frame = CGRectMake(0,0,150,35);
        FavViewImage = [UIImage imageNamed:@"add_favourite.png"];
        CGRect FavViewFrame = CGRectMake(60,0, 70,30); 
        FavButton.frame = FavViewFrame;
    }
    else 
    {
        FavViewImage = [UIImage imageNamed:@"Add Favourite.png"];
        CGRect FavViewFrame = CGRectMake(55,0, 30,30); 
        FavButton.frame = FavViewFrame;
    }
    [FavButton setBackgroundImage:FavViewImage forState:UIControlStateNormal];
    FavButton.tag = 1;
    [FavButton addTarget:self action:@selector(pushedFavButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    CancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	if (textRange.location != NSNotFound)    
        CancelButton.frame = CGRectMake(0,0, 50,30);
    else
        CancelButton.frame = CGRectMake(0,05, 50,30);
    
    [CancelButton setBackgroundImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
    CancelButton.tag =2;
    
    
    CancelButton.hidden = NO;
    [CancelButton addTarget:self action:@selector(pushedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [FavView addSubview:FavButton];
    [FavView addSubview:CancelButton];
    
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:FavView];
    self.navigationItem.rightBarButtonItem  = leftButton;
    [leftButton release];
    
    
    
    if(allFeatsOfFeatureType != nil)
    {
        [allFeatsOfFeatureType release];
        allFeatsOfFeatureType = nil;
    } 
    allFeatsOfFeatureType = [[NSMutableArray alloc] init] ;
       
    [self performSelectorInBackground:@selector(doInBackground) withObject:nil];
    
   
    
}




- (void)viewDidUnload
{
    [super viewDidUnload];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    
    
    self.inPseudoEditMode = NO;
    
    self.selectedImage = [UIImage imageNamed:@"check_report.png"];
    self.unselectedImage = [UIImage imageNamed:@"unselected.png"];
    
    CancelButton.hidden = YES;
    
    [tempTableview reloadData];
}



- (void)doInBackground {
    NSAutoreleasePool * pool; 
    pool = [[NSAutoreleasePool alloc] init]; 
    [self getdata];  
    
    
    [pool drain]; 
}

- (void)refreshTable {
    
    
    [tempTableview reloadData];
}




-(void)newPagination
{
        
    
    NSArray *halfArray;
    NSRange theRange;
    
    theRange.location = page;
    theRange.length =  adjacents;
    
    
    halfArray = [resAllFeatsOfFeatureType subarrayWithRange:theRange];
    
    [allFeatsOfFeatureType addObjectsFromArray:halfArray];        
    
    [self populateSelectedArray];
    [tempTableview reloadData]; 
    isScroll = NO;
     
}


-(void)Pagination
{
    [self performSelectorOnMainThread:@selector(showProgressIndicator) withObject:nil waitUntilDone:YES];
    if(tpages-page<adjacents)
    {
        adjacents = tpages-page;
        if(adjacents>0)
            [self performSelectorOnMainThread:@selector(newPagination) withObject:nil waitUntilDone:YES];
    }
    else
    {
        adjacents = 30;
        
             
        page = page+adjacents;
        
            
        if (page+adjacents<=tpages)
        {        
             
            [self performSelectorOnMainThread:@selector(newPagination) withObject:nil waitUntilDone:YES];
            
        }
        
        isScroll = NO;
        
    }
[self performSelectorOnMainThread:@selector(stopProgressIndicator) withObject:nil waitUntilDone:YES]; 
    

    
    
}

//function is called when user scrolls the table view 

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (currentLastCell > ([allFeatsOfFeatureType count]-5)) 
    {
        
        if(!isScroll)
        {
            isScroll = YES;
            [self performSelectorInBackground:@selector(Pagination) withObject:nil];
        }
    }
     
       
    
}


//Get data from core database
-(void)getdata{
    
    [self performSelectorOnMainThread:@selector(showProgressIndicator) withObject:nil waitUntilDone:YES];
    @try
	{      
        NSArray *fetchedObjects;
        //Get Predicate String 
        NSString *PredicateString  = [staticFunctionClass getFeatureType];
        
        NSArray *arrPredicates = [PredicateString componentsSeparatedByString:@"#"];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features" inManagedObjectContext:managedObjectContext];
        
        [request setEntity:entity];
        
        
        
        if (arrPredicates.count > 1)
        {
            NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:2];
            
            NSPredicate *fetchByFeatureType = [NSPredicate predicateWithFormat:@"featureType = %@",[arrPredicates objectAtIndex:0]];
            [predicates addObject:fetchByFeatureType];
            
            NSPredicate *fetchByQualifier = [NSPredicate predicateWithFormat:@"annotation.qualifier = %@",[arrPredicates objectAtIndex:1]];
            [predicates addObject:fetchByQualifier];
            
            // build the compound predicate
            NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
            
            [request setPredicate:predicate];
            
            NSError *error;
            fetchedObjects = [managedObjectContext executeFetchRequest:request error:&error];
            [request release];
            
        }
        else
        {
            
            NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:2];
            
            NSPredicate *fetchByFeatureType = [NSPredicate predicateWithFormat:@"featureType = %@",[arrPredicates objectAtIndex:0]];
            [predicates addObject:fetchByFeatureType];
            NSString *nullString = @"";
            NSPredicate *fetchByQualifier = [NSPredicate predicateWithFormat:@"annotation.qualifier = %@",nullString];
            [predicates addObject:fetchByQualifier];
            
            // build the compound predicate
            NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
            
            [request setPredicate:predicate];
            
            NSError *error;
            fetchedObjects = [managedObjectContext executeFetchRequest:request error:&error];
            [request release];
            
            
            
        }
        
     
        if ([fetchedObjects count]==0) {
            [self performSelectorOnMainThread:@selector(stopProgressIndicator) withObject:nil waitUntilDone:YES]; 
            return;
        }

        if(resAllFeatsOfFeatureType!=nil)
        {    
            resAllFeatsOfFeatureType = nil;
            [resAllFeatsOfFeatureType removeAllObjects];
            [resAllFeatsOfFeatureType release];
        }
        resAllFeatsOfFeatureType = [[NSMutableArray alloc]init];
        [resAllFeatsOfFeatureType addObjectsFromArray:fetchedObjects];
          
        // Sort the features by feat name
		NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"featureName" ascending:YES];
        
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"geneName" ascending:YES];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,nil];
        [resAllFeatsOfFeatureType sortUsingDescriptors:sortDescriptors];
		[sortDescriptor1 release];
        [sortDescriptor2 release];
        
        
        
        tpages = [resAllFeatsOfFeatureType count];
       
        
        NSArray *halfArray;
        NSRange theRange;
        
        theRange.location = 0;
        theRange.length =  30;
        if(tpages-page<adjacents)
        {
            adjacents = tpages-page;
            theRange.length =  adjacents;
        }
        
        halfArray = [resAllFeatsOfFeatureType subarrayWithRange:theRange];
        
        [allFeatsOfFeatureType addObjectsFromArray:halfArray];        
         
        isFetching = FALSE;
        [self populateSelectedArray];
        
        [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
        
        
    }
    
	@catch (NSException * e) 
	{
        [self performSelectorOnMainThread:@selector(stopProgressIndicator) withObject:nil waitUntilDone:YES];
		NSLog(@"%@",[e description]);
        return;
	}
    
    [self performSelectorOnMainThread:@selector(stopProgressIndicator) withObject:nil waitUntilDone:YES];  
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark -
#pragma mark Acton Method 

//Function to set tableview in editing mode
-(void)pushedFavButton:(id)sender{
    
    tempTableview.editing = YES;
    
    if ([allFeatsOfFeatureType count]!=0)
        CancelButton.hidden = NO;
    else
        CancelButton.hidden = YES;
       
    [tempTableview reloadData];
    
}


-(void)pushedCancelButton:(id)sender{
    
    tempTableview.editing = NO;
    inPseudoEditMode = NO;
    CancelButton.hidden = YES;
    [self populateSelectedArray];
    
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if (textRange.location != NSNotFound)
        [FavButton setBackgroundImage:[UIImage imageNamed:@"add_favourite.png"] forState:UIControlStateNormal];        
    else
        [FavButton setBackgroundImage:[UIImage imageNamed:@"Add Favourite.png"] forState:UIControlStateNormal];
    
    FavButton.tag =1;
    
    [tempTableview reloadData];
    
}

//Function to add selected features to  favorite  category
-(void)addToFavourite{
    
    inPseudoEditMode = NO;
    
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if (textRange.location != NSNotFound)
        [FavButton setBackgroundImage:[UIImage imageNamed:@"add_favourite.png"] forState:UIControlStateNormal];        
    else
        [FavButton setBackgroundImage:[UIImage imageNamed:@"Add Favourite.png"] forState:UIControlStateNormal];
    FavButton.tag =1;
    
    NSMutableArray *rowsToBeDeleted = [[NSMutableArray alloc] init];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    int index = 0;
    for (NSNumber *rowSelected in selectedArray)
    {
        if ([rowSelected boolValue])
        {
            
            [rowsToBeDeleted addObject:[allFeatsOfFeatureType objectAtIndex:index]];
            NSUInteger pathSource[2] = {0, index};
            NSIndexPath *path = [NSIndexPath indexPathWithIndexes:pathSource length:2];
            [indexPaths addObject:path];
        }		
        index++;
    }
	
    for (Features *value in rowsToBeDeleted)
    {
		static int boolFav;
		
		boolFav = 1;
        
        
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
		
		
	        
        
    }
    
    [indexPaths release];
    [rowsToBeDeleted release];
    
    [self populateSelectedArray];
    SGD_2AppDelegate *app = (SGD_2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.favoritesListVC LoadFavList];
    [tempTableview reloadData];
}

- (void)populateSelectedArray
{
	@try {
		NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[allFeatsOfFeatureType count]];
		for (int i=0; i < [allFeatsOfFeatureType count]; i++)
			[array addObject:[NSNumber numberWithBool:NO]];
		self.selectedArray = array;
		[array release];
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@", [e description]);
	}
	
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [allFeatsOfFeatureType count];
}




//Tabelview displays feature and its description for iPad and iPhone
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(currentLastCell<indexPath.row)
        currentLastCell = indexPath.row;
    
 
	static NSString *myCell = @"myCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
	// Configure the cell...
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    Features *singleFeat  = [allFeatsOfFeatureType objectAtIndex:indexPath.row];
    CGRect contentRect;
    
	//if (cell == nil) 
    {
		
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:myCell] autorelease];
        
        
        NSRange textRange =[[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
        if(textRange.location != NSNotFound)
        {   
            //iPad code here
            if (tempTableview.editing == YES) {
                
                if(orientation == UIInterfaceOrientationLandscapeLeft || 
                   orientation == UIInterfaceOrientationLandscapeRight) 
                {
                    contentRect = CGRectMake(120, 5, 800, 70);
                }
                else
                {
                    contentRect = CGRectMake(120, 8, 500, 70);            
                }
            }else{

            
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                contentRect = CGRectMake(120, 5, 865, 70);
            }
            else
            {
                contentRect = CGRectMake(120, 3, 585, 70);            
            }
            }
            //-----
            
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(04.0, 30.0, 20.0, 20.0);
            
            NSNumber *selected = [selectedArray objectAtIndex:[indexPath row]];
            UIImage *image = ([selected boolValue]) ? selectedImage : unselectedImage;
            imageView.image = image;
            [cell.contentView addSubview:imageView];
            imageView.hidden = !inPseudoEditMode;
            imageView.tag = kCellImageViewTag;
            
            
            
            UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(29, 7, 80, 65)];
            
            imgview.image = [UIImage imageNamed:@"Square.png"];
            imgview.tag = kCellImageTag;
            
            UIImageView *favImg = [[UIImageView alloc]initWithFrame:CGRectMake(55, 47, 25, 25)];
            
            favImg.tag = kCellFavImgTag;
            
            if ([[NSString stringWithFormat:@"%d",singleFeat.favorite] isEqualToString:@"1"]) {		
                favImg.image = [UIImage imageNamed:@"starFilledYellow.png"];
                
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
            textView.userInteractionEnabled= NO;
            textView.textColor = [UIColor blackColor];
            textView.font = [UIFont systemFontOfSize:16];
            textView.tag = kCellLabelTag;
            textView.backgroundColor = [UIColor clearColor];
            
            [imgview addSubview:FeatureName];
            [imgview addSubview:geneName];
            [cell.contentView addSubview:imgview];
            [cell.contentView addSubview:textView];
            [cell.contentView addSubview:favImg];
            
            
            [textView release];
            [imgview release];
            [favImg release];
            [geneName release];
            
            
        }
        else
        {
            CGRect contentRect1; 
            
            
            if (tempTableview.editing == YES) {
                
                if(orientation == UIInterfaceOrientationLandscapeLeft || 
                   orientation == UIInterfaceOrientationLandscapeRight) 
                {
                    contentRect1 = CGRectMake(115, 5, 250,65);  
                }
                else
                {
                    contentRect1 = CGRectMake(103, 5, 118,65);            
                }
            }else{

            
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                contentRect1 = CGRectMake(115, 5, 270,65);           
                
            }
            else
            {
                
                contentRect1 = CGRectMake(103, 5, 172,65);            
                
                
            }
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
            
            UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(15, 13, 80, 65)];
            
            imgview.image = [UIImage imageNamed:@"Square.png"];
            imgview.tag = kCellImageTag;
            
            UIImageView *favImg = [[UIImageView alloc]initWithFrame:CGRectMake(41, 55, 25, 25)];
            favImg.tag = kCellFavImgTag;
            
            if ([[NSString stringWithFormat:@"%d",singleFeat.favorite] isEqualToString:@"1"]) {		
                favImg.image = [UIImage imageNamed:@"starFilledYellow.png"];
                
            } else {
                favImg.image = nil;
            }
            
            UITextView  *textView = [[UITextView alloc] initWithFrame:contentRect1];
            textView.tag = kCellLabelTag;
            textView.backgroundColor = [UIColor clearColor];
            
            
            NSString *strAllDetails = singleFeat.annotation.descriptions;
            textView.font = [UIFont systemFontOfSize:11];
            textView.textColor = [UIColor blackColor];
            textView.text = strAllDetails;
            textView.userInteractionEnabled = NO;
            
            
            [imgview addSubview:FeatureName];
            [imgview addSubview:geneName];
            [cell.contentView addSubview:imgview];
            [cell.contentView addSubview:textView];
            [cell.contentView addSubview:favImg];
            
            [textView release];
            [imgview release];
            [favImg release];
            
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


// Delegate called when tableview cell row is selected
#pragma mark - Table view delegate
//Tabel cell selected and push view on navgation controller
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    @try 
	{
        if (inPseudoEditMode)
        {
            [tempTableview  deselectRowAtIndexPath:indexPath animated:NO];
            
            
            BOOL selected = [[selectedArray objectAtIndex:[indexPath row]] boolValue];
            [selectedArray replaceObjectAtIndex:[indexPath row] withObject:[NSNumber numberWithBool:!selected]];
            
            [tempTableview reloadData];
            
            
        }else{
            
            
            
            Features *selectedFeat = [[allFeatsOfFeatureType objectAtIndex:indexPath.row] retain];
            if (browseFeatureDetailsVC != nil) 
            {
                [browseFeatureDetailsVC release];
                browseFeatureDetailsVC = nil;
            }
            NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
            
            if (textRange.location != NSNotFound) 
            {
                browseFeatureDetailsVC = [[FeatureDetails alloc] initWithNibName:@"FeatureDetails_iPad" bundle:[NSBundle mainBundle]];
            }
            else
            {
                browseFeatureDetailsVC = [[FeatureDetails alloc] initWithNibName:@"FeatureDetails" bundle:[NSBundle mainBundle]];
            }
            
            browseFeatureDetailsVC.title = selectedFeat.displayName;
            browseFeatureDetailsVC.managedObjectContext = managedObjectContext;
            
            [self.navigationController pushViewController:browseFeatureDetailsVC animated:YES];
            [staticFunctionClass setFeatObjFeat:selectedFeat.displayName];
            [tempTableview deselectRowAtIndexPath:indexPath animated:NO];
        }
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@",[e description]);
        return;
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    //----------
    Features *value = [allFeatsOfFeatureType objectAtIndex:indexPath.row];  
     
    
    
    if ([[NSString stringWithFormat:@"%d",value.favorite] isEqualToString:@"1"]) 
    {
        
        return UITableViewCellEditingStyleDelete;
        
        
    } else {
        
        return UITableViewCellEditingStyleInsert;
    }
    
    
    //--------------
    //return UITableViewCellEditingStyleInsert;//UITableViewCellEditingStyleDelete
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *deleteTitle = @"Remove";
    return deleteTitle;
    
}

//Delegate function to add selected row to favorite from tableview

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  
    
    Features *value = [allFeatsOfFeatureType objectAtIndex:indexPath.row];  

    
        
    if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        
        static int boolFav;
        
        boolFav = 1;
        
        
        [value setFavorite:boolFav];
        
    }else if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        static int boolFav;
        
        boolFav = 0;
        
        
        [value setFavorite:boolFav];	
        
    }
    
    
    
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
    
    [self populateSelectedArray];
    SGD_2AppDelegate *app = (SGD_2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.favoritesListVC LoadFavList];
    [tempTableview reloadData];
    

    if ([allFeatsOfFeatureType count] == 0)
        CancelButton.hidden = YES;
    
}

#pragma mark - Memory Management 

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
@end
