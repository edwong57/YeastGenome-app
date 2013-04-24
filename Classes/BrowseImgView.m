//
//  BrowseImgView.m
//  SGD_2
//
//  Created by Vivek on 8/10/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*
 Class implements the webview,where it is loaded with url  
 in application itself. 
 
 */
#import "BrowseImgView.h"
#import "Reachability.h"
#import "staticFunctionClass.h"


@implementation BrowseImgView


@synthesize wBrowseImg;
@synthesize m_activity;
//@synthesize gBrowseImg;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



#pragma mark -
#pragma mark Orientation Support 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
// for IOS6
- (BOOL)shouldAutorotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

/*
 Function is called when device is rotated and implements 
 the orientation/alignment of the webview
 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
    
	UIInterfaceOrientation orientation = self.interfaceOrientation;
    
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            m_activity.frame = CGRectMake(470, 350, 30, 30);

		}
		else			
		{
            m_activity.frame = CGRectMake(360, 350, 30, 30);

		}
	}
	else
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            m_activity.frame = CGRectMake(220, 110, 30, 30);

        }
		else			
		{
            m_activity.frame = CGRectMake(130, 150, 30, 30);

		}
	}
	
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  
    wBrowseImg.scalesPageToFit = YES;
	// gBrowseImg.scalesPageToFit = YES;
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
	tlabel.text=self.title;
    tlabel.textColor=[UIColor blackColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    
    [tlabel release];
    
   }


// viewWillAppear loads every time you open up this View

- (void)viewWillAppear:(BOOL)animated {
 
    
	[wBrowseImg setBackgroundColor:[UIColor clearColor]];
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            m_activity.frame = CGRectMake(470, 350, 30, 30);

		}
		else			
		{
            m_activity.frame = CGRectMake(360, 350, 30, 30);

		}
	}
	else
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            m_activity.frame = CGRectMake(220, 110, 30, 30);
            
        }
		else			
		{
            m_activity.frame = CGRectMake(145, 150, 30, 30);
            
		}
	}
    
    Reachability *rchbility = [[Reachability reachabilityWithHostName: @"yeastgenome.org"] retain];;
    NetworkStatus remoteHostStatus = [rchbility currentReachabilityStatus];
    [rchbility release];
    
    //CHECKING 'WAN' CONNECTION AVAILABILITY
    if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
    {
        
        NSString *urlAddress = [staticFunctionClass getBrowseImg];
        
        //NSLog(@"URL address BRowse -->%@",urlAddress);
        //Create a URL object.
        NSURL *url = [NSURL URLWithString:urlAddress];
        
        [self addSkipBackupAttributeToItemAtURL:url];
        
        //URL Requst Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        //NSLog(@"URL---> %@",requestObj);
        //Load the request in the UIWebView.
        [wBrowseImg loadRequest:requestObj];
        
        
        
    }//IF NOT REACHABLE THEN GIVING ALERT MESSAGE OF CONNECTION NOT AVAILABLE
    else if(remoteHostStatus == NotReachable)
    {
        
        UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
        [dialog setDelegate:self];
        [dialog setTitle:@"No network"];
        [dialog setMessage:@"Please check your network connection"];
        [dialog addButtonWithTitle:@"OK"];
        [dialog show];	
        [dialog release];
        return;
    }

    
}


- (void)viewWillDisappear:(BOOL)animated {
    if([m_activity isAnimating]){
     m_activity.hidden= TRUE;     
    [m_activity stopAnimating];
    }
    
    if ([wBrowseImg isLoading])
        [wBrowseImg stopLoading];

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - WebView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {     
    m_activity.hidden= FALSE;    
    [m_activity startAnimating];  
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {    
    m_activity.hidden= TRUE;     
    [m_activity stopAnimating];  
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    if([m_activity isAnimating]){
        m_activity.hidden= TRUE;     
        [m_activity stopAnimating];
    }
    if ([wBrowseImg isLoading])
        [wBrowseImg stopLoading];
    
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
#pragma mark Memory Management 
- (void)dealloc
{
    wBrowseImg.delegate = nil;
    
    [wBrowseImg release],
    wBrowseImg = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
