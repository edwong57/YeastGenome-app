//
//  StandardInfo.m
//  SGD_2
//
//  Created by Avinash on 9/30/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*
 Standard info class to display the info page about YeastGenome in webview
 
 */
#import "StandardInfo.h"
#import "FeatManageData.h"
#import "Reachability.h"
#import "SGD_2AppDelegate.h"

@implementation StandardInfo

@synthesize manageVC;
@synthesize managedObjectContext;
@synthesize backbtn;
@synthesize activityIndView;

@synthesize wBrowseImg;


#pragma mark -
#pragma mark Orientation Support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

//for IOS6

-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

/*Function is called when device is rotated and implements 
 the orientation/alignment of the webview*/
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
    
	UIInterfaceOrientation orientation = self.interfaceOrientation;
    
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            
            wBrowseImg.frame = CGRectMake(00, 00, 1024, 650);
            syncbtn.frame = CGRectMake(440, 600, 134, 35);
            
		}
		else			
		{
            
            wBrowseImg.frame = CGRectMake(0, 0, 768, 908);
            syncbtn.frame = CGRectMake(318, 845, 120, 35);
            
        }
	}
	else
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            wBrowseImg.frame = CGRectMake(0, 0, 480, 217);
            syncbtn.frame = CGRectMake(160, 172, 150, 31);
            
        }
		else			
		{
            wBrowseImg.frame = CGRectMake(0, 0, 320, 366);
            syncbtn.frame = CGRectMake(109, 322, 124, 31);
            
            
		}
	}
    
    
    
	
}

#pragma mark - View lifecycle

-(id)init {
    
	if ((self=[super initWithNibName:@"StandardInfo_iPhone" bundle:nil])) {
		self.title = @"About YeastGenome";
		
		NSString* buttonImg = [[NSBundle mainBundle] pathForResource:@"info" ofType:@"png"];
		UIImage* browseImg = [[UIImage alloc] initWithContentsOfFile:buttonImg];
		
		
		UITabBarItem *browseItem = [[UITabBarItem alloc] initWithTitle:@"Info" image:browseImg tag:0];
		self.tabBarItem = browseItem;
		[browseImg release];
		[browseItem release];
		
	}
	
	return self;
}





// viewWillAppear loads every time you open up this View

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    
	UIInterfaceOrientation orientation = self.interfaceOrientation;
    
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            
            wBrowseImg.frame = CGRectMake(00, 00, 1024, 650);
            syncbtn.frame = CGRectMake(440, 600, 134, 35);
            
		}
		else			
		{
           

            wBrowseImg.frame = CGRectMake(0, 0, 768, 908);
            syncbtn.frame = CGRectMake(318, 845, 120, 35);
            
            
		}
	}
	else
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            wBrowseImg.frame = CGRectMake(0, 0, 480, 217);
            syncbtn.frame = CGRectMake(160, 172, 150, 31);
            
        }
		else			
		{
            wBrowseImg.frame = CGRectMake(0, 0, 320, 366);
            syncbtn.frame = CGRectMake(109, 322, 124, 31);
            
            
		}
	}
    
    

 }
- (void)viewDidLoad
{
    //NSLog(@"Standard info View did load");
    [super viewDidLoad];
    wBrowseImg = [[UIWebView alloc]init];

    UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold-BoldOblique" size: 16.0];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setTextColor:[UIColor blackColor]];
	[titleLabel setText:@"About YeastGenome"];
	[titleLabel sizeToFit];
	[self.navigationController.navigationBar.topItem setTitleView:titleLabel];
	[titleLabel release];

    
    backbtn.hidden = YES;
    
 	UIInterfaceOrientation orientation = self.interfaceOrientation;
    
	NSRange textRange1 = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange1.location != NSNotFound) 
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
            
		{   wBrowseImg.frame = CGRectMake(00, 0, 1024, 650);
            syncbtn.frame = CGRectMake(440, 600, 134, 35);
            
		}
		else			
		{
            
            wBrowseImg.frame = CGRectMake(0, 0, 768, 908);
            syncbtn.frame = CGRectMake(318, 845, 120, 35);
            
		}
	}
	else
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            wBrowseImg.frame = CGRectMake(0, 0, 480, 217);
            syncbtn.frame = CGRectMake(160, 172, 150, 31);
            
        }
		else			
		{
            wBrowseImg.frame = CGRectMake(0, 0, 320,366);
            syncbtn.frame = CGRectMake(109, 322, 124, 31);
            
		}
	}
    
    
    
    
    //Load the request in the UIWebView.
    NSString *path;
	NSBundle *thisBundle = [NSBundle mainBundle];
    
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]];
    wBrowseImg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]];
    
    
    
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
	{
        path = [thisBundle pathForResource:@"StandardInfo" ofType:@"html"];//
        
	}
	else
	{
		path = [thisBundle pathForResource:@"StandardInfo_iPhone" ofType:@"html"];
        
	}
    
    
	NSURL *instructionsURL = [[NSURL alloc] initFileURLWithPath:path];
    
    [self addSkipBackupAttributeToItemAtURL:instructionsURL];
    
	[wBrowseImg loadRequest:[NSURLRequest requestWithURL:instructionsURL]];
    backbtn.hidden = YES;
    
    wBrowseImg.delegate = self;
    [self.view addSubview:wBrowseImg];
   
           
    
    
    
    backbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 28)];
    backbtn.backgroundColor = [UIColor clearColor];
   
  

    backbtn.titleLabel.text =@"Back";
    static UIImage *backImg;
    
    backImg = [UIImage imageNamed:@"back.png"];

    [backbtn setBackgroundImage:backImg forState:UIControlStateNormal];

    [backbtn addTarget:self action:@selector(pushedBackButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButton =[[UIBarButtonItem alloc] initWithCustomView:backbtn];
    [self.navigationItem setLeftBarButtonItem:backButton animated:NO];
    backbtn.hidden = YES;

    
    
    wBrowseImg.scalesPageToFit = YES;
    
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark - WebView Delegate
//function is called when the url is loaded in webview
- (void)webViewDidFinishLoad:(UIWebView *)webView {    
   
   
    if (activityIndView != nil) 
    {
        if([activityIndView isAnimating])
        {
            [activityIndView stopAnimating];
            activityIndView.hidden = YES;
            activityIndView=nil;
            [activityIndView release];
        } 

    }
     
    if([webView canGoBack]){
        
        NSURL *theURL = webView.request.URL;
        NSString *url =  [theURL absoluteString];
        NSRange urlRange; 
        
        NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
        if (textRange.location != NSNotFound) 
        {
           urlRange = [url rangeOfString:@"StandardInfo" options:NSCaseInsensitiveSearch];
            
        }
        else
        {
           urlRange = [url rangeOfString:@"StandardInfo_iPhone" options:NSCaseInsensitiveSearch];
            
        }
        if (urlRange.location == NSNotFound)         
            backbtn.hidden = NO;
    }
    else
    {
        backbtn.hidden = YES;
       
    }

    
}

//function called when url request starts loading 
- (void)webViewDidStartLoad:(UIWebView *)webView {     
   
    
    [self createProgressionAlertWithMessage:@"Loading"];
  
}



- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if (activityIndView != nil) {
        if([activityIndView isAnimating]){
            activityIndView.hidden= TRUE;     
            [activityIndView stopAnimating];
        }
    } 
    

    if ([wBrowseImg isLoading])
        [wBrowseImg stopLoading];
    
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    
    NSURL *url = request.URL;
    NSString *urlString = url.absoluteString;
    NSRange urlRange; 
    
	if ([urlString isEqualToString:@"about:blank"]){
        
        
        NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
        if (textRange.location != NSNotFound) 
        {
            urlRange = [urlString rangeOfString:@"StandardInfo" options:NSCaseInsensitiveSearch];
            
        }
        else
        {
            urlRange = [urlString rangeOfString:@"StandardInfo_iPhone" options:NSCaseInsensitiveSearch];
            
        }
        if (urlRange.location == NSNotFound)         
            backbtn.hidden = NO;
        
        
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        //------
        
        Reachability *rchbility = [[Reachability reachabilityWithHostName: @"yeastgenome.org"] retain]; 
        NetworkStatus remoteHostStatus = [rchbility currentReachabilityStatus];
        [rchbility release];
        
        //CHECKING 'WAN' and Wi-Fi CONNECTION AVAILABILITY
        if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
        {
            
            if([urlString isEqualToString:@"mailto:%20SGD-helpdesk@lists.stanford.edu"])
            {
                
                
                Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
                if (mailClass != nil)
                {
                    // We must always check whether the current device is configured for sending emails
                    if ([mailClass canSendMail])
                    {
                        [self displayComposerSheet];
                    }
                    else
                    {
                        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Unable to send Email" message:@"Please check your Mail settings." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [myAlert show];
                        [myAlert release];
                    }
                }
                
                
            }else if([urlString isEqualToString:@"http://www.yeastgenome.org/"]){
                
                
                
            }
            
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
            
        }
    }
    
    if(activityIndView!=nil && [activityIndView isAnimating])
    {
        [activityIndView stopAnimating];
        activityIndView.hidden = YES;
        activityIndView=nil;
        [activityIndView release];
    } 
    
    return YES;
    
}


-(void)pushedBackButton:(id)sender{
    
    [wBrowseImg goBack];
    
    
    
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
#pragma mark Mail delegate

-(void)displayComposerSheet 
{
	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	mailController.mailComposeDelegate = self;
    
	
    NSString *subjecttxt = [[NSString alloc] initWithFormat:@"%@",@"SGD Helpdesk"];
	[mailController setToRecipients:[NSArray arrayWithObject:@"SGD-helpdesk@lists.stanford.edu"]];
	
	[mailController setSubject:subjecttxt];
	
	
	NSString *bodytext =[[NSString alloc] initWithFormat:@""];
	
	[mailController setMessageBody:bodytext isHTML:NO];
	
	[self presentModalViewController:mailController animated:YES];
	[bodytext release];
	[subjecttxt release];
	[mailController release];
}


- (void)mailComposeController:(MFMailComposeViewController*)mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	
	
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Result: canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Result: saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Result: sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Result: failed");
			break;
		default:
			NSLog(@"Result: not sent");
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
	
    if (MFMailComposeResultSent) {
        [self.navigationController popViewControllerAnimated:YES];
    }
	
}

//Called when 'Sync local database' button is clicked
-(IBAction)pushedSyncButton:(id)sender{

 
    if (manageVC != nil) 
    {
        [manageVC release];
        manageVC = nil;
    }
    
    
        manageVC = [[FeatManageData  alloc] initWithNibName:@"FeatManageData" bundle:[NSBundle mainBundle]];
    
    
 
    manageVC.managedObjectContext = managedObjectContext;
    [self.navigationController pushViewController:manageVC animated:YES];
    
    
   // [self downloadFileIfUpdated];

}


#pragma mark -
#pragma mark Memory Management 

- (void)dealloc
{
    [wBrowseImg setDelegate:nil];
    if ([wBrowseImg isLoading])
        [wBrowseImg stopLoading];
    
    [wBrowseImg release];
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Exclude backupUrl From Cloud

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL

{
    
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    
    
    const char* attrName = "com.apple.MobileBackup";
    
    u_int8_t attrValue = 1;
    
    
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    return result == 0;
    
}


@end
