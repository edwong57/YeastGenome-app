//
//  EmailViewController.m
//  SGD_Vivek
//
//  Created by Vivek on 12/05/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "EmailViewController.h"
#import "SGD_2AppDelegate.h"
#import "staticFunctionClass.h"

@implementation EmailViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

-(id)init {
	if ((self=[super initWithNibName:@"EmailViewController" bundle:nil])) {
		self.title = @"Email";
		
		NSString* buttonImg = [[NSBundle mainBundle] pathForResource:@"email" ofType:@"png"];
		UIImage* browseImg = [[UIImage alloc] initWithContentsOfFile:buttonImg];
		
		
		UITabBarItem *browseItem = [[UITabBarItem alloc] initWithTitle:@"Email" image:browseImg tag:0];
		self.tabBarItem = browseItem;
		
		[browseItem release];
        [browseImg release];
		
	}
	
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	
}


-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	
	NSString *subjectLine =	[staticFunctionClass getSubjectLine];
	NSString *messageBody = [staticFunctionClass getMessageBody];
	
	NSMutableArray *arrRec = [[NSMutableArray alloc] init];
	arrRec   = [staticFunctionClass getRecipient];
	
	
	@try{
		
		MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    
		[controller setToRecipients:arrRec];
		[controller setSubject:subjectLine];
		[controller setTitle:@"Email Composer"];
		[controller setMessageBody:messageBody isHTML:YES];
        controller.mailComposeDelegate = self;
		
		[self presentModalViewController:controller animated:NO];

		[controller release];
	}
	@catch (NSException *ex) {
		return;
	}
	
	
	
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	[controller dismissModalViewControllerAnimated:YES];
	
	[self.navigationController popViewControllerAnimated:YES];
	

}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

//for iOS6

- (BOOL)shouldAutorotate {
return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
