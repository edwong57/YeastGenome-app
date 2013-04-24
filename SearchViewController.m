//
//  SearchViewController.m
//  SGD_2
//
//  Created by Vishwanath on 08/07/11.
//  Copyright 2011 Stanford University. All rights reserved.
//
/*
 
 Class to search the gene and feature from the local database and if not found get the data from the server and display it.
 Data is searched in local database by gene,feature,alias name and its description.If not found found it access the server through webservices and insert the data in local database.
 
 */

#import "SearchViewController.h"
#import "Features.h"
#import "FeatureDetails.h"
#import "FeatAnnotation.h"
#import "FeatLocation.h"
#import "Alias.h"
#import "staticFunctionClass.h"
#import "JSON.h"
#import "SGD_2AppDelegate.h"
#import "Reachability.h"
#import "MyUITextViewController.h"
#import "proAlertView.h"


NSMutableArray *preFeatlist;
@implementation SearchViewController


@synthesize managedObjectContext;
@synthesize sBar, searchResultsTable, featsList;
@synthesize searchFeatureDetailsVC;
@synthesize progAlertView, activityIndView;
@synthesize searchGeneRequest;
@synthesize URLAddress;
@synthesize selectedArray;
@synthesize inPseudoEditMode;
@synthesize selectedImage;
@synthesize unselectedImage;

@synthesize EditButton;
@synthesize CancelButton;

@synthesize geneSearchText,array;

@synthesize currentLastCell;
@synthesize ProgressSearch;


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

/*Function is called when device is rotated and implements 
 the orientation/alignment of the labels*/
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	
	[searchResultsTable reloadData];
}




#pragma mark -
#pragma mark View lifecycle

-(id)init {
	if ((self = [super initWithNibName:@"SearchViewController" bundle:nil])) {
		
		self.title = @"Search";
		
		UITabBarItem *searchItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
		self.tabBarItem = searchItem;
		[searchItem release];		
		
	}
	
	return self;
}

//scrollview delegate of tableview, called when tableview is scrolled
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
        
    
    //check the tableview row index with the count of tableview array
    if (currentLastCell > ([featsList count]-5)) 
    {
         
        progressInd.alpha = 1; 
        [self Pagination];
        
   
    }
    
     
}

 
//Pagination where data is fetch in core data.
-(void)Pagination
{
    
        
    if((tpages-page)<adjacents)
    {
        if([featsList count]<adjacents) // When we ge result less than adjancents
            return;
        
        adjacents = tpages-page;
        
        if(adjacents>0)
            [self performSelectorInBackground:@selector(reloadTableWithNewData) withObject:nil];
       // isScroll = YES;
    }
    else
    {
        adjacents = 30;
    
           
        page = page+adjacents;
  
    
    
        if (page+adjacents<=tpages)
        {        
        
            [self performSelectorInBackground:@selector(reloadTableWithNewData) withObject:nil];
        
        }
        
    }
   
    

}
 

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	test =0;
	page  = 0;
    adjacents = 30 ;
    firstScrollOffset = 0;
    cntScroll = 0;
    
    array = [[NSArray alloc]init];
    
       
    
	[staticFunctionClass initializeSearchObjFeat];
	// sets title to smaller font
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold-BoldOblique" size: 16.0];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setTextColor:[UIColor blackColor]];
	[titleLabel setText:@"Search"];
	[titleLabel sizeToFit];
	[self.navigationController.navigationBar.topItem setTitleView:titleLabel];
	[titleLabel release];
	self.navigationItem.hidesBackButton	= YES;
    
    
    UIView *FavView = [[UIView alloc]initWithFrame:CGRectMake(0,0,100,35)];
    FavView.backgroundColor = [UIColor clearColor];
    
    static UIImage *FavViewImage;
    EditButton = [[UIButton alloc]init];
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    
    if (textRange.location != NSNotFound) {
        FavViewImage = [UIImage imageNamed:@"add_favourite.png"];
        CGRect FavViewFrame = CGRectMake(0,3, 70,30);
        EditButton.frame = FavViewFrame;
    }
    else {
        FavViewImage = [UIImage imageNamed:@"Add Favourite.png"];
        CGRect FavViewFrame = CGRectMake(0,3, 30,30);
        EditButton.frame = FavViewFrame;
    }
    
    EditButton.tag = 1;
    [EditButton setBackgroundImage:FavViewImage forState:UIControlStateNormal];
    [EditButton addTarget:self action:@selector(pushedFavButton:) forControlEvents:UIControlEventTouchUpInside];
    
    if (textRange.location != NSNotFound)
        CancelButton = [[UIButton alloc]initWithFrame:CGRectMake(75,3, 40,30)];
    else
        CancelButton = [[UIButton alloc]initWithFrame:CGRectMake(40,3, 45,30)];
    

    [CancelButton setBackgroundImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
    
    CancelButton.tag = 2;
    
    CancelButton.hidden = YES;
    [CancelButton addTarget:self action:@selector(pushedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    
	[FavView addSubview:EditButton];
    [FavView addSubview:CancelButton];
    
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:FavView];
    self.navigationItem.leftBarButtonItem = leftButton;
    [FavView release];
    [leftButton release];
    
    UIView *EmailView = [[UIView alloc]initWithFrame:CGRectMake(0,0,80,35)];
    EmailView.backgroundColor = [UIColor clearColor];
    
    static UIImage *EmailImage;
    CGRect EmailFrame = CGRectMake(40,1, 35,35);
    EmailButton = [[UIButton alloc]initWithFrame:EmailFrame];
    EmailImage = [UIImage imageNamed:@"email.png"];
    [EmailButton setBackgroundImage:EmailImage forState:UIControlStateNormal];
    EmailButton.backgroundColor = [UIColor clearColor];
    
    [EmailButton addTarget:self action:@selector(pushedEmailButton:) forControlEvents:UIControlEventTouchUpInside];
    [EmailView addSubview:EmailButton];
    
    UIBarButtonItem *addButton =[[UIBarButtonItem alloc] initWithCustomView:EmailView];
    [self.navigationItem setRightBarButtonItem:addButton animated:NO];
    
    if ([featsList count] == 0) {
        EditButton.hidden = YES;
        EmailButton.hidden = YES;
    }
    
    [addButton release];
    [EmailView release];
    
    
    SGD_2AppDelegate *app = (SGD_2AppDelegate*)[[UIApplication sharedApplication] delegate];
    allFeatsToShow = [[NSMutableArray alloc] initWithArray:app.allFeats];
    
	sBar.showsScopeBar = YES;
	sBar.delegate = self;
	
	searchResultsTable.delegate = self;
	searchResultsTable.dataSource = self;
	
	// initialize array
	
	featsList = [[NSMutableArray alloc] init] ;
	gotsearchresult = NO;
    
}



- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	[sBar resignFirstResponder];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    searchResultsTable.editing = NO;
    self.inPseudoEditMode = NO;
    
    self.selectedImage = [UIImage imageNamed:@"check_report.png"];
    self.unselectedImage = [UIImage imageNamed:@"unselected.png"];
    
    EditButton.tag = 1;
    
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if (textRange.location != NSNotFound)
        [EditButton setBackgroundImage:    [UIImage imageNamed:@"add_favourite.png"]
                              forState:UIControlStateNormal];
    else
        [EditButton setBackgroundImage:    [UIImage imageNamed:@"Add Favourite.png"]
                              forState:UIControlStateNormal];    
    
    CancelButton.hidden = YES;
    if ([featsList count] != 0) {
        EditButton.hidden = NO;
        EmailButton.hidden = NO;

    }
    else {
        EditButton.hidden = YES;
        EmailButton.hidden = YES;

    }
    
    
    [self.searchDisplayController setActive:NO animated:YES];
    [self populateSelectedArray];
    
    
    [searchResultsTable reloadData];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
}




- (void)populateSelectedArray
{
	@try {
		NSMutableArray *barray = [[NSMutableArray alloc] initWithCapacity:[featsList count]];
		for (int i=0; i < [featsList count]; i++)
			[barray addObject:[NSNumber numberWithBool:NO]];
		self.selectedArray = barray;
		[barray release];
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@", [e description]);
	}
	
}

#pragma mark -
#pragma mark Action Method
-(void)pushedFavButton:(id)sender{
    
    searchResultsTable.editing = YES;
    
    if ([featsList count]!=0)
        CancelButton.hidden = NO;
    else
        CancelButton.hidden = YES;
    
       
    [searchResultsTable reloadData];
    
}
//Email function called when email button is pressed
-(void)pushedEmailButton:(id)sender {
    
    if ([featsList count] != 0) 
    {
        @try
        {
            
            [self performSelectorOnMainThread:@selector(doFavoriteExp) withObject:nil waitUntilDone:YES];
           
        }
        @catch (NSException * e) 
        {
            NSLog(@"%@",[e description]);
        }
        
    }
    else
    {
        UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
        [dialog setDelegate:self];
        [dialog setTitle:@"No Features are in Search List"];
        [dialog addButtonWithTitle:@"OK"];
        [dialog show];	
        [dialog release];
    }
    
}

//Cancel function called when Done button is pressed in add to favorite mode

-(void)pushedCancelButton:(id)sender{
    
    searchResultsTable.editing = NO;
    inPseudoEditMode = NO;
    CancelButton.hidden = YES;
    [self populateSelectedArray];
    
    EditButton.tag = 1;
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if (textRange.location != NSNotFound)
        [EditButton setBackgroundImage:    [UIImage imageNamed:@"add_favourite.png"]
                              forState:UIControlStateNormal];
    else
        [EditButton setBackgroundImage:    [UIImage imageNamed:@"Add Favourite.png"]
                              forState:UIControlStateNormal];    
    
    [searchResultsTable reloadData];
    
    if ([featsList count] == 0)
        EditButton.hidden = YES;
    else
        EditButton.hidden = NO;
    
    
    
}

//Add to favorite function is called to add feature to favorite class
-(void)addToFavourite{
    
    inPseudoEditMode = NO;
    
    EditButton.tag = 1;
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if (textRange.location != NSNotFound)
        [EditButton setBackgroundImage:    [UIImage imageNamed:@"add_favourite.png"]
                              forState:UIControlStateNormal];
    else
        [EditButton setBackgroundImage:    [UIImage imageNamed:@"add selected.png"]
                              forState:UIControlStateNormal];
    
       
    
    
    NSMutableArray *rowsToBeDeleted = [[NSMutableArray alloc] init];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    int index = 0;
    for (NSNumber *rowSelected in selectedArray)
    {
        if ([rowSelected boolValue])
        {
            
            [rowsToBeDeleted addObject:[featsList objectAtIndex:index]];
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
    [searchResultsTable reloadData];
}

//Compose a mail according to feature details displayed on screen
-(void)doFavoriteExp{
    
    int totalMail = page + adjacents;
    
    int mailToBeSent = totalMail>tpages ? tpages : totalMail;
    
    Features *singleFeat;   
    Alias *aliasObj; 
	
    if (mailToBeSent < 50) {
        @try
        {
            
            NSDate *today = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM-dd-yyyy"];
            NSString *strcreatedtime = [dateFormat stringFromDate:today];
            [dateFormat release];
            
            NSString *textDataString =@"";
            NSString *eMailBody = @"";
            
            int count = -1; 
          
            for (id value1 in featsList)
            {
                if ([value1 isMemberOfClass:[Alias class]])
                {
                    aliasObj = value1;
                    singleFeat = aliasObj.aliasToFeat;
                }
                else
                {
                    singleFeat  = value1;
                }
                count++;
               
                if (count == mailToBeSent)
                { 
                   
                    break;
                }
                if ([singleFeat.geneName length] > 0) {
                    
                    eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b>Standard Name:</b>%@<br><b>Systematic Name: <a href=\"http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%@\">%@</a><br><b>Description:</b>%@</td></tr><br><br>",singleFeat.geneName,singleFeat.featureName,singleFeat.featureName, singleFeat.annotation.descriptions];
                }
                else {
                    
                    eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b>Systematic Name: <a href=\"http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%@\">%@</a><br><b>Description:</b>%@<br></td></tr><br><br>",singleFeat.featureName,singleFeat.featureName, singleFeat.annotation.descriptions];
                }
                
                textDataString = [textDataString stringByAppendingFormat:@"%@",eMailBody];
				
				NSLog(@"%@",textDataString);
            }
            
            
            controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            
            [controller setSubject:[NSString stringWithFormat:@"Search List of features from YeastGenome, %@",strcreatedtime]];
            [controller setTitle:@"Export Search List"];
            
            
            [controller setMessageBody:eMailBody isHTML:YES];
            [self presentModalViewController:controller animated:NO];
          
            
        }
        @catch (NSException * e) 
        {
            NSLog(@"Catch Error: %@", [e description]);
        }
        
    } else if (mailToBeSent > 50){
        
        NSData *fileData;
        @try
        {
            
            NSDate *today = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM-dd-yyyy"];
            NSString *strcreatedtime = [dateFormat stringFromDate:today];
            [dateFormat release];
            
		//	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            
            NSString *textDataString =@"";
            NSString *eMailBody = @"";
            
            int count = 50; 
            
            for (id value1 in featsList)
            {
                count++;
                
                if ([value1 isMemberOfClass:[Alias class]])
                {
                    aliasObj = value1;
                    singleFeat = aliasObj.aliasToFeat;
                }
                else
                {
                    singleFeat  = value1;
                }
                if (count == 130)
                    break;
                
                
                if ([singleFeat.geneName length] > 0) {
                    
                    eMailBody = [eMailBody stringByAppendingFormat:@"Standard Name:%@\nSystematic Name: <a href=\"http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%@\">%@</a>\nDescription:%@\n\n",singleFeat.geneName,singleFeat.featureName, singleFeat.featureName, singleFeat.annotation.descriptions];
                }
                else {
                    
                    eMailBody = [eMailBody stringByAppendingFormat:@"Systematic Name: <a href=\"http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%@\">%@</a>\nDescription:%@\n\n", singleFeat.featureName, singleFeat.featureName, singleFeat.annotation.descriptions];
                }
                
                textDataString = [textDataString stringByAppendingFormat:@"%@",eMailBody];
            }
            
            fileData = [textDataString dataUsingEncoding:NSUTF8StringEncoding];
       
			//MFMailComposeViewController *
			controller = [[MFMailComposeViewController alloc] init];

            controller.mailComposeDelegate = self;
            
            [controller setSubject:[NSString stringWithFormat:@"Search List of features from YeastGenome, %@",strcreatedtime]];
            [controller setTitle:@"Export Search List"];
            [controller addAttachmentData:fileData mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"%@_%@.txt",geneSearchText,strcreatedtime]];
            
            [self presentModalViewController:controller animated:NO];
            
            [controller release];
            
        }
        
        @catch (NSException * e) 
        {
            NSLog(@"Catch Error: %@", [e description]);
        }
    }
    
}

-(void)refreshTable
{
    [searchResultsTable reloadData];
}
#pragma mark -
#pragma mark Alert Delegate
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	NSString *strTitle = [actionSheet title];
	
	
    if([strTitle compare:@"Add Favourite"] == 0) 
	{
		if (buttonIndex == 1) 
		{
			
			[self populateSelectedArray];
			[searchResultsTable reloadData];
		}else if (buttonIndex == 0) 
        {
            self.navigationItem.leftBarButtonItem.title = @"Edit";
            [self populateSelectedArray];
            [searchResultsTable reloadData];
        }{
            
            CancelButton.hidden = YES;
            inPseudoEditMode = NO;
            self.navigationItem.leftBarButtonItem.title = @"Edit";
            [self populateSelectedArray];
            
            [searchResultsTable reloadData];
        }
		
	}
	else {
        if (buttonIndex == 1) {
            //[self performSelectorOnMainThread:@selector(doFavoriteExp) withObject:nil waitUntilDone:YES];
        }
	}
	
	
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	[controller dismissModalViewControllerAnimated:NO];
	
	[self.navigationController popViewControllerAnimated:YES];
	
	
}

#pragma mark -
#pragma mark Table delegate
// TableView Delegate functions



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
 

  	return [featsList count];
	
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (currentLastCell<indexPath.row) {
        currentLastCell = indexPath.row;

    }
   
    
    if ([featsList count]==0)
    {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.backgroundColor=[UIColor clearColor];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIImageView *bgImage=[[UIImageView alloc]initWithFrame:CGRectMake(0,0,286,42)];
        
        bgImage.backgroundColor=[UIColor clearColor];
        
        
        [cell addSubview:bgImage];
        [bgImage release];
        
        
        
        
        UILabel *TitleLable=[[UILabel alloc]init];
        
        
        TitleLable.frame = CGRectMake(10,13,180,15);
         
        
        TitleLable.textColor=[UIColor colorWithRed:(float)33/(float)256 green:(float)47/(float)256 blue:(float)74/(float)256 alpha:1];
        TitleLable.font=[UIFont boldSystemFontOfSize:13];
        TitleLable.text=@"No Result.";
        TitleLable.backgroundColor=[UIColor clearColor];
        [cell addSubview:TitleLable];
        [TitleLable release];
        
        
        return cell;

    }
    
    static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    cell.backgroundColor=[UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    Features *singleFeat;   
    if ([[featsList objectAtIndex:indexPath.row] isMemberOfClass:[Alias class]])
    {
        Alias *aliasObj = [featsList objectAtIndex:indexPath.row];
        singleFeat = aliasObj.aliasToFeat;

    }
    else
    {
        singleFeat  = [featsList objectAtIndex:indexPath.row];

    }
    
    
    UIInterfaceOrientation orientation = self.interfaceOrientation; 
    NSRange textRange =[[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    
    CGRect contentRect;
    if(textRange.location != NSNotFound)
    {
        //iPad code here
        if (searchResultsTable.editing == YES) {
            
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                contentRect = CGRectMake(125, 3, 800, 70);
            }
            else
            {
                contentRect = CGRectMake(125, 3, 500, 70);            
            }
        }
        
        else {
        if(orientation == UIInterfaceOrientationLandscapeLeft || 
           orientation == UIInterfaceOrientationLandscapeRight) 
        {
            contentRect = CGRectMake(125, 3, 870, 70);
        }
        else
        {
            contentRect = CGRectMake(125, 3, 590, 70);            
        }
        }
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(04.0, 30.0, 20.0, 20.0);
        
        
        
        UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(30, 7, 80, 65)];
        
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
       
        NSString *strAllDetails =singleFeat.annotation.descriptions;
        textView.text =  [strAllDetails stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceCharacterSet]];
        textView.userInteractionEnabled = NO;
        textView.textColor = [UIColor blackColor];
        textView.font = [UIFont systemFontOfSize:16];
        textView.editable = false;
        textView.scrollEnabled = false;
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
        //iPhone code here
        
        CGRect contentRect1; 
        
        
        if (searchResultsTable.editing == YES) {
            
            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                contentRect1 = CGRectMake(115, 5, 250,80);  
            }
            else
            {
                contentRect1 = CGRectMake(103, 5, 118,80);            
            }
        }
        
        else {
        if(orientation == UIInterfaceOrientationLandscapeLeft || 
           orientation == UIInterfaceOrientationLandscapeRight) 
        {
            contentRect1 = CGRectMake(115, 5, 270,80);           
            
        }
        else
        {
            
            contentRect1 = CGRectMake(103, 5, 177,80);            
            
            
        }
        }
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(2.0, 30.0, 20.0, 20.0);
        
        
        
        
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
            
        } else 
        {
            favImg.image = nil;                
        }
        
        
        
        
        UITextView *textView = [[UITextView alloc] initWithFrame:contentRect1];
        
        textView.tag = kCellLabelTag;
        
        
        NSString *strAllDetails = singleFeat.annotation.descriptions;
        textView.font = [UIFont systemFontOfSize:11];
        textView.userInteractionEnabled = NO;
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
        [cell.contentView addSubview:favImg];
        
        [textView release];
        [imgview release];
        [favImg release];
        [FeatureName release];
        [geneName release];
        
        
        
    }

        
     
	    
	return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSRange textRange =[[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	
    if(textRange.location != NSNotFound)
        return 80;
	else 
        return 90;
}

//Set alterating color for rows in tableview
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




//function is called when particular row is selected 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    
	@try 
	{
        
        if (inPseudoEditMode)
        {
            [searchResultsTable  deselectRowAtIndexPath:indexPath animated:NO];
            
            
            BOOL selected = [[selectedArray objectAtIndex:[indexPath row]] boolValue];
            [selectedArray replaceObjectAtIndex:[indexPath row] withObject:[NSNumber numberWithBool:!selected]];
            
            [searchResultsTable reloadData];
            
            
        }else{
            
            [searchResultsTable deselectRowAtIndexPath:indexPath animated:NO];
            Features *selectedFeat = [[featsList objectAtIndex:indexPath.row] retain];
            
             
            if ([[featsList objectAtIndex:indexPath.row] isMemberOfClass:[Alias class]])
            {
                Alias *aliasObj = [featsList objectAtIndex:indexPath.row];
                selectedFeat = aliasObj.aliasToFeat;
            }
            else
            {
                selectedFeat  = [featsList objectAtIndex:indexPath.row];
            }

            
           
            
            if (searchFeatureDetailsVC != nil)
            {
                [searchFeatureDetailsVC release];
                searchFeatureDetailsVC = nil;
            }
            NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
            if (textRange.location != NSNotFound) 
            {
                searchFeatureDetailsVC = [[FeatureDetails alloc] initWithNibName:@"FeatureDetails_iPad" bundle:[NSBundle mainBundle]];
            }
            else
            {
                searchFeatureDetailsVC = [[FeatureDetails alloc] initWithNibName:@"FeatureDetails" bundle:[NSBundle mainBundle]];
            }
            searchFeatureDetailsVC.title = selectedFeat.displayName;
            searchFeatureDetailsVC.managedObjectContext = managedObjectContext;
            
            [self.navigationController pushViewController:searchFeatureDetailsVC animated:YES];
            
            [staticFunctionClass setSearchObjFeat:selectedFeat.displayName];
            
        }
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@",[e description]);
	}
	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //----------
    Features *value;
    Alias    *aliasObj;
    
    id value1 = [featsList objectAtIndex:indexPath.row]; 
    
    if ([value1 isMemberOfClass:[Alias class]])
    {
        aliasObj = value1;
        value = aliasObj.aliasToFeat;
    }
    else
    {
        value  = value1;
    }
    
            
    
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
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    inPseudoEditMode = NO;
    
    
    Features *value;
    Alias    *aliasObj;
    
    id value1 = [featsList objectAtIndex:indexPath.row]; 
    
    if ([value1 isMemberOfClass:[Alias class]])
    {
        aliasObj = value1;
        value = aliasObj.aliasToFeat;
    }
    else
    {
        value  = value1;
    }

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
    [searchResultsTable reloadData];
    
         
    
       
    if ([featsList count] == 0)
        CancelButton.hidden = YES;
}



#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{	
	// only show the status bar’s cancel button while in edit mode
	
	[self.searchDisplayController setActive:YES animated:YES];
	sBar.showsCancelButton = YES;	
	sBar.autocorrectionType = UITextAutocorrectionTypeNo;
	
	
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{	
    
	sBar.showsCancelButton = NO;	
	sBar.showsScopeBar = YES;
    
  
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{	
    
	[self.searchDisplayController setActive:YES animated:YES];
	sBar.showsCancelButton = YES;	
	sBar.autocorrectionType = UITextAutocorrectionTypeNo;
	

	    	
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar 
{	
	// if a valid search was entered but the user wanted to cancel, bring back the main list content
    // sets title to smaller font
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold-BoldOblique" size: 16.0];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setText:@"Search"];
    [titleLabel sizeToFit];
    [self.navigationController.navigationBar.topItem setTitleView:titleLabel];
    [titleLabel release];
    self.navigationItem.hidesBackButton	= YES;
    
    
    page = 0;
    adjacents = 30;
    firstScrollOffset = 0;
    cntScroll = 0;
    
	CancelButton.hidden = YES;
	[self.searchDisplayController setActive:YES animated:YES];
	[featsList removeAllObjects];
	
	@try
	{
		[searchResultsTable reloadData];	
	}
	
	@catch(NSException *e)
	{
		NSLog(@"%@",[e description]);
	}
	
	[sBar resignFirstResponder];
	
	sBar.text = @"";
    
    if ([featsList count] == 0) {
        EditButton.hidden = YES;
        EmailButton.hidden = YES;
    }
    else {
        EditButton.hidden = NO;
        EmailButton.hidden = NO;
    }
	
}

 
-(void)hideKeyboard
{
    [sBar resignFirstResponder];
}
// called when Search (in our case “Search”) button pressed

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{	
    NSString *strSearch = sBar.text;
    
     
    [self.sBar resignFirstResponder];    
   
    
    
    self.searchDisplayController.searchBar.text = strSearch;

    
    //Set table scrollview to top position
    [searchResultsTable setContentOffset:CGPointMake(0, 0) animated:NO];
       
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
    
       
        [NSThread detachNewThreadSelector: @selector(showProgress) toTarget:self withObject:nil];
                
    
    page = 0;
    adjacents = 30;
    firstScrollOffset = 0;
    cntScroll = 0;
    
    if (sBar.text!=@"") 
    {
        geneSearchText = [[NSMutableString alloc]initWithFormat:@"%@",strSearch];
        NSUserDefaults *searchTextdefault =[NSUserDefaults standardUserDefaults];
        [searchTextdefault setValue:sBar.text forKey:@"seachKey"];
        [searchTextdefault synchronize];
        
        // sets title to smaller font
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold-BoldOblique" size: 16.0];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setText:[NSString stringWithFormat:@"Search for %@",geneSearchText]];
        [titleLabel sizeToFit];
        [self.navigationController.navigationBar.topItem setTitleView:titleLabel];
        [titleLabel release];
        self.navigationItem.hidesBackButton	= YES;
        
    }
    
    
    
    [featsList removeAllObjects];
    
    featsList = nil;
    [featsList release];
    
    featsList = [[NSMutableArray alloc] init];
   
        
	[self reloadTableWithNewData];
    
          
    [self populateSelectedArray];
        
            
    [self performSelector:@selector(stopProgress) withObject:nil afterDelay:0.1];
        
   
	
    if ([featsList count] == 0) 
	{
       
        
        [self performSelectorOnMainThread:@selector(showProgressIndicator) withObject:nil waitUntilDone:YES];
		Reachability *rchbility = [[Reachability reachabilityWithHostName: @"yeastgenome.org"] retain];;
		NetworkStatus remoteHostStatus = [rchbility currentReachabilityStatus];
		[rchbility release];
		
		//CHECKING 'WAN' and Wi-Fi CONNECTION AVAILABILITY
		if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
		{
			//CALLING WEB-SERVICE HELPER CLASS OBJECT FOR CHECKING CONNECTIVITY TO SGD SERVER
			[self webServiceRequest:searchBar.text];	
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
			
            
            if ([activityIndView isAnimating]) 
                [activityIndView stopAnimating];
            
            [self performSelectorOnMainThread:@selector(stopProgressIndicator) withObject:nil waitUntilDone:YES];
            return;
            
		}
         
        [self performSelectorOnMainThread:@selector(stopProgressIndicator) withObject:nil waitUntilDone:YES];
        
	}
	else
	{
		
	}
    
    if ([activityIndView isAnimating]) 
        [activityIndView stopAnimating];
    
    if ([featsList count] == 0) {
        EditButton.hidden = YES;
        EmailButton.hidden = YES;
    }
    else {
        EditButton.hidden = NO;
        EmailButton.hidden = NO;
    }

    [self viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO animated: YES];
    [self.searchDisplayController setActive:NO animated:YES];
    
    }
    
    
}



-(void)searchDisplayController:(UISearchBar *)searchBar shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    
	[featsList removeAllObjects];
	[searchResultsTable reloadData];
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if([featsList count]==0){
       
        fadeView.alpha=0.6;
        [controller.searchResultsTableView setBackgroundColor:[UIColor darkGrayColor]];
        controller.searchResultsTableView.alpha=0.8;
        [controller.searchResultsTableView setRowHeight:900];
        
    }
    
    return NO;
}

#pragma mark -
#pragma mark Activity Method

-(void)stopProgress{

    if([ProgressSearch isAnimating]){
         [ProgressSearch stopAnimating];
         [ProgressSearch release];
                
        
    }

}
-(void)showProgress{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
    CGRect frame;
    
    
    NSRange textRange1 = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
	if (textRange1.location != NSNotFound) {
        
        if(orientation == UIInterfaceOrientationLandscapeLeft || 
           orientation == UIInterfaceOrientationLandscapeRight) 
        {
            frame = CGRectMake(450, 300, 50, 50);
        }
        else
        {
            frame = CGRectMake(350, 400, 50, 50);
        }
        
        
    }else 
    {
        
        if(orientation == UIInterfaceOrientationLandscapeLeft || 
           orientation == UIInterfaceOrientationLandscapeRight) 
        {
            frame = CGRectMake(235, 110, 30, 30);
        }
        else
        {
            frame = CGRectMake(145, 180, 30, 30);
        }
        
    }
    
    
    ProgressSearch = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    ProgressSearch.frame = frame; 
    
    ProgressSearch.hidden = NO;
    
    [self.view  addSubview:ProgressSearch];
    [ProgressSearch startAnimating];
    
    [pool drain];

    
}

//show the activity indicator for displaying the processing. 

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




#pragma mark -
#pragma mark Web Service Call 
//Web service call function to access the data from server
- (void)webServiceRequest:(NSString *)webserviceName
{
    
    proAlertView *alert;      
    
    alert = [[[proAlertView alloc] initWithTitle:@"Please Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    alert.frame = CGRectMake(20, 50, 280, 200);
    [alert show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // Adjust the indicator so it is up a few pixels from the bottom of the alert
    indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
    [indicator startAnimating];
    [alert addSubview:indicator];
    [indicator release];
    
    
	@try
	{
		NSString *str = sBar.text;
        
		NSRange arsRange = [str rangeOfString:@"ars" options:NSCaseInsensitiveSearch];
		NSRange cenRange = [str rangeOfString:@"cen" options:NSCaseInsensitiveSearch];
		NSRange telRange = [str rangeOfString:@"tel" options:NSCaseInsensitiveSearch];
		NSRange tyRange = [str rangeOfString:@"Ty" options:NSCaseInsensitiveSearch];
		NSRange ltrDRange = [str rangeOfString:@"delta" options:NSCaseInsensitiveSearch];
		NSRange ltrORange = [str rangeOfString:@"omega" options:NSCaseInsensitiveSearch];
		NSRange ltrTRange = [str rangeOfString:@"tau" options:NSCaseInsensitiveSearch];
		NSRange ltrSRange = [str rangeOfString:@"sigma" options:NSCaseInsensitiveSearch];
		
		NSString *strPlistName = [[NSBundle mainBundle] pathForResource:@"webServiceUrlList" ofType:@"plist"];
		NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:strPlistName];
		
	
		[plistDictionary release];
		
		
		if(sBar.selectedScopeButtonIndex == 0)
		{
			if (arsRange.location != NSNotFound) 
                
                URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"ARS.featureType+ARS.secondaryIdentifier+ARS.symbol+ARS.primaryIdentifier+ARS.locations.start+ARS.locations.end+ARS.locations.strand+ARS.locations.locatedOn.primaryIdentifier+ARS.qualifier+ARS.featAttribute+ARS.description+ARS.name+ARS.sgdAlias+ARS.status\"+sortOrder=\"ARS.featureType+asc\"+constraintLogic=\"A+and+(B+or+C+or+D)\"><constraint+path=\"ARS.status\"+op=\"=\"+value=\"Active\"/><constraint+path=\"ARS.secondaryIdentifier\"+op=\"=\"+value=\"%@*\"/><constraint+path=\"ARS.sgdAlias\"+op=\"=\"+value=\"%@*\"/><constraint+path=\"ARS.symbol\"+op=\"=\"+value=\"%@*\"/></query>&format=jsonobjects",webserviceName,webserviceName,webserviceName];
            
            
			else if(cenRange.location != NSNotFound)
				
                URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Centromere.featureType+Centromere.secondaryIdentifier+Centromere.symbol+Centromere.primaryIdentifier+Centromere.locations.end+Centromere.locations.start+Centromere.locations.strand+Centromere.locations.locatedOn.primaryIdentifier+Centromere.qualifier+Centromere.featAttribute+Centromere.description+Centromere.name+Centromere.sgdAlias+Centromere.status\"+sortOrder=\"Centromere.featureType+asc\"+constraintLogic=\"A+and+(B+or+C)\"><constraint+path=\"Centromere.status\"+op=\"=\"+value=\"Active\"/><constraint+path=\"Centromere.secondaryIdentifier\"+op=\"=\"+value=\"%@*\"/><constraint+path=\"Centromere.symbol\"+op=\"=\"+value=\"%@*\"/></query>&format=jsonobjects",webserviceName,webserviceName];
            
			else if(telRange.location != NSNotFound)	
				
                URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Telomere.featureType+Telomere.secondaryIdentifier+Telomere.symbol+Telomere.primaryIdentifier+Telomere.locations.end+Telomere.locations.start+Telomere.locations.strand+Telomere.locations.locatedOn.primaryIdentifier+Telomere.qualifier+Telomere.featAttribute+Telomere.description+Telomere.name+Telomere.sgdAlias+Telomere.status\"+sortOrder=\"Telomere.featureType+asc\"+constraintLogic=\"A+and+(B+or+C)\"><constraint+path=\"Telomere.status\"+op=\"=\"+value=\"Active\"/><constraint+path=\"Telomere.secondaryIdentifier\"+op=\"=\"+value=\"%@*\"/><constraint+path=\"Telomere.symbol\"+op=\"=\"+value=\"%@*\"/></query>&format=jsonobjects",webserviceName,webserviceName];
            
			else if(tyRange.location != NSNotFound)
				
                
                URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Retrotransposon.featureType+Retrotransposon.secondaryIdentifier+Retrotransposon.symbol+Retrotransposon.primaryIdentifier+Retrotransposon.locations.end+Retrotransposon.locations.start+Retrotransposon.locations.strand+Retrotransposon.locations.locatedOn.primaryIdentifier+Retrotransposon.qualifier+Retrotransposon.featAttribute+Retrotransposon.description+Retrotransposon.name+Retrotransposon.sgdAlias+Retrotransposon.status\"+sortOrder=\"Retrotransposon.featureType+asc\"+constraintLogic=\"A+and+(B+or+C)\"><constraint+path=\"Retrotransposon.status\"+op=\"=\"+value=\"Active\"/><constraint+path=\"Retrotransposon.secondaryIdentifier\"+op=\"=\"+value=\"%@*\"/><constraint+path=\"Retrotransposon.symbol\"+op=\"=\"+value=\"%@*\"/></query>&format=jsonobjects",webserviceName,webserviceName];
            
			else if(ltrDRange.location != NSNotFound || ltrORange.location != NSNotFound || ltrTRange.location != NSNotFound || ltrSRange.location != NSNotFound)
                
                
            	URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"LongTerminalRepeat.featureType+LongTerminalRepeat.secondaryIdentifier+LongTerminalRepeat.symbol+LongTerminalRepeat.primaryIdentifier+LongTerminalRepeat.locations.end+LongTerminalRepeat.locations.start+LongTerminalRepeat.locations.strand+LongTerminalRepeat.locations.locatedOn.primaryIdentifier+LongTerminalRepeat.qualifier+LongTerminalRepeat.featAttribute+LongTerminalRepeat.description+LongTerminalRepeat.name+LongTerminalRepeat.sgdAlias+LongTerminalRepeat.status\"+sortOrder=\"LongTerminalRepeat.featureType+asc\"+constraintLogic=\"A+and+(B+or+C)\"><constraint+path=\"LongTerminalRepeat.status\"+op=\"=\"+value=\"Active\"/><constraint+path=\"LongTerminalRepeat.symbol\"+op=\"=\"+value=\"%@*\"/><constraint+path=\"LongTerminalRepeat.secondaryIdentifier\"+op=\"=\"+value=\"%@*\"/></query>&format=jsonobjects",webserviceName,webserviceName];
			else
            {
             
                /*
                 
                 */
                
                
              
               /* 
                NSString *str2 = @"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=%3Cquery+name%3D%22%22+model%3D%22genomic%22+view%3D%22Gene.featureType+Gene.secondaryIdentifier+Gene.symbol+Gene.locations.start+Gene.locations.end+Gene.locations.strand+Gene.locations.locatedOn.primaryIdentifier+Gene.qualifier+Gene.featAttribute+Gene.description+Gene.name+Gene.sgdAlias+Gene.status%22+sortOrder%3D%22Gene.featureType+asc%22+constraintLogic%3D%22A+and+%28B+or+C+or+D%29%22%3E%3Cconstraint+path%3D%22Gene.status%22+code%3D%22A%22+op%3D%22%3D%22+value%3D%22Active%22%2F%3E%3Cconstraint+path%3D%22Gene.secondaryIdentifier%22+code%3D%22B%22+op%3D%22%3D%22+value%3D%22rad31*%22%2F%3E%3Cconstraint+path%3D%22Gene.symbol%22+code%3D%22C%22+op%3D%22%3D%22+value%3D%22rad31*%22%2F%3E%3Cconstraint+path%3D%22Gene.sgdAlias%22+code%3D%22D%22+op%3D%22%3D%22+value%3D%22*RAD31*%22%2F%3E%3C%2Fquery%3E&format=jsonobjects";
               
                NSLog(@"TRY--%@",[str2 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
                */
                URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.featureType+Gene.secondaryIdentifier+Gene.symbol+Gene.locations.start+Gene.locations.end+Gene.locations.strand+Gene.locations.locatedOn.primaryIdentifier+Gene.qualifier+Gene.featAttribute+Gene.description+Gene.name+Gene.sgdAlias+Gene.status+Gene.primaryIdentifier\"+sortOrder=\"Gene.featureType+asc\"+constraintLogic=\"A+and+(B+or+C+or+D)\"><constraint+path=\"Gene.status\"+op=\"=\"+value=\"Active\"/><constraint+path=\"Gene.secondaryIdentifier\"+op=\"=\"+value=\"%@*\"/><constraint+path=\"Gene.symbol\"+op=\"=\"+value=\"%@*\"/><constraint+path=\"Gene.sgdAlias\"+op=\"=\"+value=\"*%@*\"/></query>&format=jsonobjects",webserviceName,webserviceName,webserviceName];
                
              
            }
            
		}
		else if(sBar.selectedScopeButtonIndex == 1)
		{
            
            
            if (arsRange.location != NSNotFound) 
				URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"ARS.featureType+ARS.secondaryIdentifier+ARS.symbol+ARS.primaryIdentifier+ARS.locations.start+ARS.locations.end+ARS.locations.strand+ARS.locations.locatedOn.primaryIdentifier+ARS.qualifier+ARS.featAttribute+ARS.description+ARS.name+ARS.sgdAlias+ARS.status\"+sortOrder=\"ARS.featureType+asc\"+constraintLogic=\"A+and+B\"><constraint+path=\"ARS.status\"+op=\"=\"+value=\"Active\"/><constraint+path=\"ARS.description\"+op=\"LIKE\"+value=\"*%@*\"/></query>&format=jsonobjects",webserviceName];
            
			else if(cenRange.location != NSNotFound)
				URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Centromere.featureType+Centromere.secondaryIdentifier+Centromere.symbol+Centromere.primaryIdentifier+Centromere.locations.end+Centromere.locations.start+Centromere.locations.strand+Centromere.locations.locatedOn.primaryIdentifier+Centromere.qualifier+Centromere.featAttribute+Centromere.description+Centromere.name+Centromere.sgdAlias+Centromere.status\"+sortOrder=\"Centromere.featureType+asc\"+constraintLogic=\"A+and+B\"><constraint+path=\"Centromere.status\"+op=\"=\"+value=\"Active\"/><constraint+path=\"Centromere.description\"+op=\"LIKE\"+value=\"*%@*\"/></query>&format=jsonobjects",webserviceName];
            
			else
				URLAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.featureType+Gene.secondaryIdentifier+Gene.symbol+Gene.primaryIdentifier+Gene.locations.start+Gene.locations.end+Gene.locations.strand+Gene.locations.locatedOn.primaryIdentifier+Gene.qualifier+Gene.featAttribute+Gene.description+Gene.name+Gene.sgdAlias+Gene.status\"+sortOrder=\"Gene.featureType+asc\"+constraintLogic=\"B+and+A\"><constraint+path=\"Gene.status\"+op=\"=\"+value=\"Active\"/><constraint+path=\"Gene.description\"+op=\"LIKE\"+value=\"*%@*\"/></query>&format=jsonobjects",webserviceName];
            

		}
        
		webServiceHelper *webhelper = [[webServiceHelper alloc]init];
		[webhelper startConnection:URLAddress];
		[webhelper setDelegate:self];
		
	}
	@catch (NSException *e) {
		NSLog(@"%@",[e description]);
	}
    
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}


// Implement the finish downloading delegate method

- (void)finishedDownloading:(NSString *)strJSONResponse
{
    
	@try 
	{
		if ([activityIndView isAnimating]) 
			[activityIndView stopAnimating];
		
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
					NSArray *jsonObjects = [strAllGene componentsSeparatedByString:@"},{"];
					
                    //NSLog(@"Feature Recieved %i",[jsonObjects count]);
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
							
                            //NSLog(@"RESPOSE : \n%@",dictionary);
                            
							[self getResultsAndInsert:dictionary];
							
						}
					}
				}
				else
				{
					UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
					[dialog setDelegate:self];
					[dialog setTitle:@"Data not found"];
					[dialog setMessage:@"Your query is not a valid gene name (or feature name), please try a different search."];
					[dialog addButtonWithTitle:@"OK"];
					[dialog show];	
					[dialog release];
				}
			}
			else
			{
				UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
				[dialog setDelegate:self];
				[dialog setTitle:@"Data not found"];
				[dialog setMessage:@"Your query is not a valid gene name (or feature name), please try a different search."];
				[dialog addButtonWithTitle:@"OK"];
				[dialog show];	
				[dialog release];
			}
		}		
		//updating array
		SGD_2AppDelegate *app = (SGD_2AppDelegate*)[[UIApplication sharedApplication] delegate];
		[app getAllGeneNames];
		[self reloadTableWithNewData];
        [self populateSelectedArray];
        [self viewWillAppear:YES];
	}
	// now we are sure the download is complete
	@catch (NSException *e) 
	{
		NSLog(@"%@",[e description]);
	}
	
}

-(void) getResultsAndInsert:(NSDictionary *)resultSet
{
    test++;
    
    //NSLog(@"STEPS %d",test);
	
	NSString *strDate = [NSString stringWithFormat:@"2000-03-19"];
	NSError *error;
	
	NSArray *allValues = [resultSet allValues];
	NSArray *allKeys = [resultSet allKeys];
	for (int i=0; i<[allValues count]; i++) 
	{
		if ([[allValues objectAtIndex:i] isEqual:[NSNull null] ]) 
		{
			[resultSet setValue:@"" forKey:[allKeys objectAtIndex:i]];
			
		}
	}
	
	NSDate *today = [NSDate date];
    
	
	@try
	{
        //Check whether it exists 
        
        
        //===========
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
        Features *feat = [fetchedObjects objectAtIndex:0];

            
        [request release];
        if ([fetchedObjects count] == 0) {
            
            [[managedObjectContext undoManager] disableUndoRegistration];
            //Alias
            
            
         
            //FeatAnnotation
            NSManagedObjectContext *featAnnotMOC = [NSEntityDescription insertNewObjectForEntityForName:@"FeatAnnotation" inManagedObjectContext:managedObjectContext];
            [featAnnotMOC setValue:[resultSet objectForKey:@"description"] forKey:@"descriptions"];
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
            NSManagedObjectContext *featuresMOC = [NSEntityDescription insertNewObjectForEntityForName:@"Features" inManagedObjectContext:managedObjectContext];
            
            
            // ALIAS
            //[aliasMOC setValue:featuresMOC forKey:@"aliasToFeat"];
            
            NSString *aliases = [resultSet objectForKey:@"sgdAlias"];
            NSArray* aliasesComponents = [aliases componentsSeparatedByString:@" "];
            NSMutableSet *aliasSet = [NSMutableSet set];
            
            for (int i = 0; i<[aliasesComponents count]; i++) {
                
                NSManagedObjectContext *aliasMOC = [NSEntityDescription insertNewObjectForEntityForName:@"Alias" inManagedObjectContext:managedObjectContext];
                //[aliasMOC setValue:[resultSet objectForKey:@"sgdAlias"] forKey:@"aliasName"];
                [aliasMOC setValue:[aliasesComponents objectAtIndex:i] forKey:@"aliasName"];
                
                [aliasMOC setValue:strDate forKey:@"dateCreated"];
                [aliasMOC setValue:[NSString stringWithFormat:@"NULL"] forKey:@"aliasType"];
                
                // ALIAS
                [aliasMOC setValue:featuresMOC forKey:@"aliasToFeat"];
                [aliasSet addObject:aliasMOC];
                
            }
            
            
            
            [featuresMOC setValue:aliasSet forKey:@"aliases"];
            // FEAT ANNOTATION
            [featAnnotMOC setValue:featuresMOC forKey:@"annotToFeat"];
            
            // FEAT LOCATION
            [featLocatMOC setValue:featuresMOC forKey:@"locToFeat"];
            
            [featuresMOC setValue:[resultSet objectForKey:@"symbol"] forKey:@"geneName"];
            [featuresMOC setValue:@"SGD" forKey:@"source"];
            [featuresMOC setValue:[resultSet objectForKey:@"primaryIdentifier"] forKey:@"dbxrefId"];
            [featuresMOC setValue:strDate forKey:@"dateCreated"];
            [featuresMOC setValue:[resultSet objectForKey:@"featureType"] forKey:@"featureType"];
            [featuresMOC setValue:[NSNumber numberWithInt:4932] forKey:@"taxonId"];
            [featuresMOC setValue:[resultSet objectForKey:@"secondaryIdentifier"] forKey:@"featureName"];	
            [featuresMOC setValue:today forKey:@"usedDateMoreInfo"];
            
           
            [featuresMOC setValue:featAnnotMOC forKey:@"annotation"];
            [featuresMOC setValue:featLocatMOC forKey:@"location"];
            
            [managedObjectContext processPendingChanges];
            [[managedObjectContext undoManager] enableUndoRegistration];
            
            if (![managedObjectContext save:&error])
            {
                NSLog(@"%@",error);
            }
            
            
            
            
        } else {
            
            
            //NSLog(@"FEATURE EXITS NEED TO UPDATE");
            
            Features *selectedFeatures = [fetchedObjects objectAtIndex:0];
			
			//Alias
            
          
            
            NSSet *featAlias = selectedFeatures.aliases;
            
            for (Alias *alias in [featAlias allObjects]) 
            {
                [self.managedObjectContext deleteObject:alias];
            }

            NSString *aliases = [resultSet objectForKey:@"sgdAlias"];
            NSArray* aliasesComponents = [aliases componentsSeparatedByString:@" "];
            NSMutableSet *aliasSet = [NSMutableSet set];
			//NSLog(@"ALiases Array -->%@",aliasesComponents);
            for (int i = 0; i<[aliasesComponents count]; i++) {
                
                NSManagedObjectContext *aliasMOC = [NSEntityDescription insertNewObjectForEntityForName:@"Alias" inManagedObjectContext:managedObjectContext];
                //[aliasMOC setValue:[resultSet objectForKey:@"sgdAlias"] forKey:@"aliasName"];
                [aliasMOC setValue:[aliasesComponents objectAtIndex:i] forKey:@"aliasName"];
                
                [aliasMOC setValue:strDate forKey:@"dateCreated"];
                [aliasMOC setValue:[NSString stringWithFormat:@"NULL"] forKey:@"aliasType"];
                
                // ALIAS
                [aliasMOC setValue:selectedFeatures forKey:@"aliasToFeat"];
                [aliasSet addObject:aliasMOC];
                
            }
            
            
			//NSLog(@"Alias Set-->%@",aliasSet);
			[selectedFeatures setValue:aliasSet forKey:@"aliases"];
         
			
			//FeatAnnotation
            
           // [self.managedObjectContext deleteObject:selectedFeatures.annotation];

            
            NSManagedObjectContext *featAnnotMOC = [NSEntityDescription insertNewObjectForEntityForName:@"FeatAnnotation" inManagedObjectContext:managedObjectContext];
			[featAnnotMOC setValue:[resultSet objectForKey:@"description"] forKey:@"descriptions"];//[resultSet objectForKey:@"description"]
			[featAnnotMOC setValue:strDate forKey:@"dateCreated"];
			[featAnnotMOC setValue:[NSString stringWithFormat:@"NULL"] forKey:@"geneticPos"];
			[featAnnotMOC setValue:[resultSet objectForKey:@"qualifier"] forKey:@"qualifier"];
			[featAnnotMOC setValue:[resultSet objectForKey:@"featAttribute"] forKey:@"featAttribute"];
			[featAnnotMOC setValue:[resultSet objectForKey:@"name"] forKey:@"nameDescription"];
			
			//FeatLocation
            
           // [self.managedObjectContext deleteObject:selectedFeatures.location];

			NSManagedObjectContext *featLocatMOC = [NSEntityDescription insertNewObjectForEntityForName:@"FeatLocation" inManagedObjectContext:managedObjectContext];
			[featLocatMOC setValue:[[resultSet valueForKeyPath:@"locations.strand"] objectAtIndex:0] forKey:@"strand"];
			[featLocatMOC setValue:strDate forKey:@"coordVer"];
			[featLocatMOC setValue:[NSNumber numberWithInt:[[[resultSet valueForKeyPath:@"locations.end"]  objectAtIndex:0] intValue]] forKey:@"maxCoord"];
			[featLocatMOC setValue:[NSNumber numberWithInt:[[[resultSet valueForKeyPath:@"locations.start"]  objectAtIndex:0] intValue]] forKey:@"minCoord"];
			[featLocatMOC setValue:strDate forKey:@"dateCreated"];
			[featLocatMOC setValue:[[resultSet valueForKeyPath:@"locations.locatedOn.primaryIdentifier"]  objectAtIndex:0] forKey:@"chromosome"];
			
			// FEATURES
			
			
			// ALIAS
			//[aliasMOC setValue:selectedFeatures forKey:@"aliasToFeat"];
			
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
			
			[selectedFeatures setValue:featAnnotMOC forKey:@"annotation"];
			[selectedFeatures setValue:featLocatMOC forKey:@"location"];
            
            
            
        }
        
        
        //---------
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
        
        //----------------- 
	}
    
	@catch (NSException * e)
	{
		NSLog(@"%@",[e description]);
	}
}
//fetch the data from the core data with search text.
-(void) reloadTableWithNewData
{ 
   [self performSelectorOnMainThread:@selector(showProgressIndicator) withObject:nil waitUntilDone:YES];
    
    isDescription = FALSE; 
    
    
    if(sBar.selectedScopeButtonIndex ==0)
    {
        
    tpages=0; 
         
  
    
    // We need an entity.
    
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Features" inManagedObjectContext:managedObjectContext];
        
    NSString *predString1 = [NSString stringWithFormat:
                                @"geneName BEGINSWITH [cd] '%@' OR featureName BEGINSWITH [c] '%@' ",geneSearchText,geneSearchText];
    NSPredicate *pred1 = [NSPredicate 
                             predicateWithFormat:predString1];
    NSFetchRequest *req1 = [[NSFetchRequest alloc] init];
    [req1 setEntity:entity];	
    [req1 setPredicate:pred1];
   
    NSError *error = nil;
    
    NSArray *arrayGenes;
    arrayGenes = [managedObjectContext executeFetchRequest:req1
                                                    error:&error];
        

        preFeatlist = [[NSMutableArray alloc]init];
      
        //NSLog(@"Array Genes Count %i",[arrayGenes count]);

        if([arrayGenes count]>0)
            [preFeatlist addObjectsFromArray:arrayGenes];
 
        isAlias = FALSE;
        
        NSArray *arrayAlias;
    {
         
        NSEntityDescription *entity1 = [NSEntityDescription 
                                       entityForName:@"Alias" inManagedObjectContext:managedObjectContext];
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"aliasName CONTAINS [cd] %@", [geneSearchText uppercaseString]]; ///@"aliasName beginswith %@", @"aliasName BEGINSWITH [cd] %@"
  
        NSFetchRequest *req1 = [[NSFetchRequest alloc] init];
        [req1 setEntity:entity1];	
        [req1 setPredicate:pred1];
        

        NSError *error = nil;
        
        arrayAlias = [managedObjectContext executeFetchRequest:req1
                                                   error:&error];
        isAlias = TRUE; 
       
    }
        

              
    if (arrayGenes == nil)
    {
        NSException *exception = [NSException 
                                  exceptionWithName:@"Core Data exception" 
                                  reason:[error localizedDescription] 
                                  userInfo:nil];
        [exception raise];
    }
        
        //NSLog(@"Array Aliases  Count %i",[arrayAlias count]);

        if ([arrayAlias count]>0) {
            
            //----
            
            NSMutableArray *Aliastemp = [[NSMutableArray alloc]init];
            Features *singleFeat;
            Alias *als;
            for (int i=0; i<[arrayAlias count];i++)
            {
                
                als  = [arrayAlias objectAtIndex:i];
                singleFeat = als.aliasToFeat;
                if(singleFeat != nil) 
                    [Aliastemp addObject:singleFeat];
                
            }

            
            NSMutableArray *Aliases  = [[NSMutableArray alloc] initWithArray:Aliastemp];

           // NSLog(@"Alias feature count %i",[Aliases count]);
            
            NSInteger index = [Aliases count] - 1;
            
            for (id object in [Aliases reverseObjectEnumerator]) 
            {
                if ([Aliastemp indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) 
                {
                   // NSLog(@"Same Alias objects %@",[Aliases objectAtIndex:index]);
                   [Aliastemp removeObjectAtIndex:index];
                }
              
                index--;
            }
        
                    
            [preFeatlist addObjectsFromArray:Aliastemp];
            [Aliastemp release];
            [Aliases release];
            //-----
        }
        
        //================
    
        tpages = [preFeatlist count];
       // NSLog(@"Total Pages Before %i",tpages);
      
        
       NSArray *copy = [preFeatlist copy];
       NSInteger index = [copy count] - 1;
        
        for (id object in [copy reverseObjectEnumerator]) 
        {
            
                          
            if ([preFeatlist indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound)
            {
                //NSLog(@"Same objects %@",[preFeatlist objectAtIndex:index]);
                    
                [preFeatlist removeObjectAtIndex:index];
            }
                
                       
            index--;
        }
        [copy release];

      ///===========  
    // Now, release the fetch request and return the array
    
        [req1 release];
        //[req2 release];
    //---------
        
    tpages = [preFeatlist count];
    
    //NSLog(@"Total Pages After %i",tpages);
    
    NSArray *halfArray;
    NSRange theRange;
    
    //NSLog(@"Pages Accessing %i",page);

    theRange.location = page;
    theRange.length =  adjacents>tpages?tpages:adjacents;
    
   // NSLog(@"Adjacent  %i",adjacents);


    
    halfArray = [preFeatlist subarrayWithRange:theRange];
    
    [featsList addObjectsFromArray:halfArray];
        
    isAlias = FALSE;   
    
    }else if(sBar.selectedScopeButtonIndex ==1)
    {
        
        tpages=0; 
        
        isDescription = TRUE;

       NSString *predString = [NSString stringWithFormat:
                                @"descriptions contains [c] '%@'",geneSearchText];//geneSearchText
        
      
        
        NSPredicate *pred = [NSPredicate 
                             predicateWithFormat:predString];
        
        // We need an entity.
        
        NSEntityDescription *entity = [NSEntityDescription 
                                       entityForName:@"FeatAnnotation" inManagedObjectContext:managedObjectContext];
        
        // And, of course, a fetch request. 
        
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        [req setEntity:entity];	
        [req setPredicate:pred];
        
        // We declare an NSError and handle errors by raising an exception,
        // just like in the previous method
        
        NSError *error = nil;
        
        
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
        
       
        
        preFeatlist = [[NSMutableArray alloc]init];
        
       
        tpages = [array count];
        
        
    
        
        NSArray *halfArray;
     
        
        FeatAnnotation *annotationObj;
        Features *singleFeat;
        for (int i=0; i<[array count];i++)
        {
                     
          annotationObj  = [array objectAtIndex:i];
          singleFeat = annotationObj.annotToFeat;
           if(singleFeat != nil) 
               [preFeatlist addObject:singleFeat];
            
        }
        
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"geneName" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [preFeatlist sortUsingDescriptors:sortDescriptors];
        
         tpages = [preFeatlist count];
  

        NSRange theRange;
        
        theRange.location = page;
        theRange.length =  adjacents>tpages?tpages:adjacents;
        
        halfArray = [preFeatlist subarrayWithRange:theRange];
        
        [featsList addObjectsFromArray:halfArray];

  
    }
    
	@try
	{
		        
		NSString *searchText = sBar.text;
			        
        gotsearchresult = NO;
           
		[self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
		
        

		sBar.showsCancelButton = YES;	
		sBar.showsScopeBar = YES;
		sBar.text = searchText;
        
		
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@", [e description]);
	} 
    
     
     [self performSelectorOnMainThread:@selector(stopProgressIndicator) withObject:nil waitUntilDone:YES]; 
}


#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}




- (void)dealloc {
    
    [controller release];
    [super dealloc];
    [URLAddress release];
	[searchGeneRequest release]; 
 	
	[sBar release];
	[searchResultsTable release];
	
}



@end
