//
//  FeatGoTypeDetails.m
//  SGD_2
//
//  Created by Vivek on 7/6/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*Class to implement the details of Gene Ontology,
 data is fetch from core data and displayed for ipad/iphone */

#import "FeatGoTypeDetails.h"

#import "SGD_2AppDelegate.h"
#import "staticFunctionClass.h"
#import "EmailViewController.h"
#import "FeatGoDetails.h"
#import "GODetails.h"

#import "SBJSON.h"
#import "webServiceHelper.h"
#import "Reachability.h"

@implementation FeatGoTypeDetails

@synthesize contentView;

@synthesize SelectedGODetails;
@synthesize managedObjectContext;
@synthesize finalListArr;
@synthesize progAlertView;
@synthesize activityIndView;

NSString * strType;
NSString *featName;
NSString *PubMedID;

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

/*Function is called when device is rotated and implements 
 the orientation/alignment of the labels*/

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
    
	UIInterfaceOrientation orientation = self.interfaceOrientation;
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            float  f1 = assignedByDetails.frame.origin.y+assignedByDetails.frame.size.height+20; 
            [contentView setFrame:CGRectMake(128, 10, 768,f1)];
			contentView.layer.borderWidth = 1;
			contentView.layer.cornerRadius = 5;
			contentView.layer.borderColor = [[UIColor blackColor] CGColor];
            
		}
		else			
		{
            float  f1 = assignedByDetails.frame.origin.y+assignedByDetails.frame.size.height+20; 
            [contentView setFrame:CGRectMake(10, 10, 748, f1)];
			contentView.layer.borderWidth = 1;
			contentView.layer.cornerRadius = 5;
			contentView.layer.borderColor = [[UIColor blackColor] CGColor];
		}
        
        
        
        
        
        CGRect lblFrame = CGRectMake(contentView.frame.size.width-15,DefinitionDetails.frame.origin.y, 25, DefinitionDetails.frame.size.height);
        
        indicator1.frame = lblFrame;
        
       
        
     
              
        
        CGRect lblFrame2 = CGRectMake(contentView.frame.size.width-15,referencesDetails.frame.origin.y, 25, referencesDetails.frame.size.height);
        
        indicator2.frame = lblFrame2;
        
        
 
	}
	else
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
			[self setLabelWidthFor:annotationsDetails newWidth:350];
			[self setLabelWidthFor:evidenceDetails newWidth:350];
            [self setLabelWidthFor:DefinitionDetails newWidth:350];
            [self setButtonWidthFor:definitionBtn newWidth:471];

			[self setLabelWidthFor:referencesDetails newWidth:350];
            [self setButtonWidthFor:referenceBtn newWidth:471];

			[self setLabelWidthFor:assignedByDetails newWidth:350];
            
            [self setLabelSizeFor:lblEvidence detailview:evidenceDetails];
            [self setLabelSizeFor:lblDefinition detailview:DefinitionDetails];
            [self setLabelSizeFor:(UILabel*)definitionBtn detailview:DefinitionDetails];

            [self setLabelSizeFor:lblReferences detailview:referencesDetails];
            [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesDetails];

            [self setLabelSizeFor:lblAssignedBy detailview:assignedByDetails];
            
            //------Goid label and details
            [self setViewYOriginFor:lblGoId previousView:lblAnnotations previousDetailView:annotationsDetails];
            [self setViewYOriginFor:goIdDetails previousView:lblAnnotations previousDetailView:annotationsDetails];
            [self setViewXOriginFor:goIdDetails previousView:lblGoId];
            
            //---------
                        
          
            [self setViewYOriginFor:lblEvidence previousView:lblGoId previousDetailView:goIdDetails];
            [self setViewYOriginFor:evidenceDetails previousView:lblGoId previousDetailView:goIdDetails];
            [self setViewXOriginFor:evidenceDetails previousView:lblEvidence];
            
            
            
            //---------
            [self setViewYOriginFor:lblDefinition previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewYOriginFor:DefinitionDetails previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewXOriginFor:DefinitionDetails previousView:lblDefinition];
            [self setViewYOriginFor:definitionBtn previousView:lblEvidence previousDetailView:evidenceDetails];
            //---------
            
            
            
            [self setViewYOriginFor:lblReferences previousView:lblDefinition previousDetailView:DefinitionDetails];
            
            [self setViewYOriginFor:referencesDetails previousView:lblDefinition previousDetailView:DefinitionDetails];
            
         
            [self setViewXOriginFor:referencesDetails previousView:lblReferences];
            
               [self setViewYOriginFor:referenceBtn previousView:lblDefinition previousDetailView:DefinitionDetails];
            [self setViewYOriginFor:lblAssignedBy previousView:lblReferences previousDetailView:referencesDetails];
            [self setViewYOriginFor:assignedByDetails previousView:lblReferences previousDetailView:referencesDetails];
            [self setViewXOriginFor:assignedByDetails previousView:lblAssignedBy];
            
            float  f1 = assignedByDetails.frame.origin.y+assignedByDetails.frame.size.height+20; 
            [contentView setFrame:CGRectMake(0, 0, 480, f1)];
            [(UIScrollView*)self.view setContentSize:contentView.frame.size];
                        
            
            CGRect lblFrame = CGRectMake(contentView.frame.size.width-15,DefinitionDetails.frame.origin.y, 25, DefinitionDetails.frame.size.height);
            
            indicator1.frame = lblFrame;
            
            
            
            
            CGRect lblFrame2 = CGRectMake(contentView.frame.size.width-15,referencesDetails.frame.origin.y, 25, referencesDetails.frame.size.height);
            
            indicator2.frame = lblFrame2;
            

            
		}
		else			
		{
			[self setLabelWidthFor:annotationsDetails newWidth:210];
			[self setLabelWidthFor:evidenceDetails newWidth:210];
            [self setLabelWidthFor:DefinitionDetails newWidth:200];
            [self setButtonWidthFor:definitionBtn newWidth:312];

			[self setLabelWidthFor:referencesDetails newWidth:200];
            [self setButtonWidthFor:referenceBtn newWidth:312];

			[self setLabelWidthFor:assignedByDetails newWidth:210];
            
            [self setLabelSizeFor:lblEvidence detailview:evidenceDetails];
            [self setLabelSizeFor:lblDefinition detailview:DefinitionDetails];
            [self setLabelSizeFor:(UILabel*)definitionBtn detailview:DefinitionDetails];

            [self setLabelSizeFor:lblReferences detailview:referencesDetails];
            [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesDetails];

            [self setLabelSizeFor:lblAssignedBy detailview:assignedByDetails];
            
            
            //------Goid label and details
            [self setViewYOriginFor:lblGoId previousView:lblAnnotations previousDetailView:annotationsDetails];
            [self setViewYOriginFor:goIdDetails previousView:lblAnnotations previousDetailView:annotationsDetails];
            [self setViewXOriginFor:goIdDetails previousView:lblGoId];
            
            //---------
            
           
            [self setViewYOriginFor:lblEvidence previousView:lblGoId previousDetailView:goIdDetails];
            [self setViewYOriginFor:evidenceDetails previousView:lblGoId previousDetailView:goIdDetails];
            [self setViewXOriginFor:evidenceDetails previousView:lblEvidence];
            
            
            //---------
            [self setViewYOriginFor:lblDefinition previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewYOriginFor:DefinitionDetails previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewXOriginFor:DefinitionDetails previousView:lblDefinition];
            [self setViewYOriginFor:definitionBtn previousView:lblEvidence previousDetailView:evidenceDetails];
            //---------
            
           [self setViewYOriginFor:lblReferences previousView:lblDefinition previousDetailView:DefinitionDetails];
                   
            [self setViewYOriginFor:referencesDetails previousView:lblDefinition previousDetailView:DefinitionDetails];
            [self setViewXOriginFor:referencesDetails previousView:lblReferences];
            
            [self setViewYOriginFor:referenceBtn previousView:lblDefinition previousDetailView:DefinitionDetails];
            [self setViewYOriginFor:lblAssignedBy previousView:lblReferences previousDetailView:referencesDetails];
            [self setViewYOriginFor:assignedByDetails previousView:lblReferences previousDetailView:referencesDetails];
            [self setViewXOriginFor:assignedByDetails previousView:lblAssignedBy];
            float  f1 = assignedByDetails.frame.origin.y+assignedByDetails.frame.size.height+20; 
            [contentView setFrame:CGRectMake(0, 0, 320, f1)];
            [(UIScrollView*)self.view setContentSize:contentView.frame.size];
            
            
            
            
            CGRect lblFrame = CGRectMake(contentView.frame.size.width-15,DefinitionDetails.frame.origin.y, 25, DefinitionDetails.frame.size.height);
            
            indicator1.frame = lblFrame;
            
                        
            
            CGRect lblFrame2 = CGRectMake(contentView.frame.size.width-15,referencesDetails.frame.origin.y, 25, referencesDetails.frame.size.height);
            
            indicator2.frame = lblFrame2;
            


		}
	}
	
}


#pragma mark -
#pragma mark View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	UIInterfaceOrientation orientation = self.interfaceOrientation;
	
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
			contentView.layer.borderWidth = 1;
			contentView.layer.cornerRadius = 5;
			contentView.layer.borderColor = [[UIColor blackColor] CGColor];
            
            [lblAnnotations setFrame:CGRectMake(5, lblAnnotations.frame.origin.y, lblAnnotations.frame.size.width, lblAnnotations.frame.size.height)];
            [self setViewXOriginFor:annotationsDetails previousView:lblAnnotations];
            
            [self setLabelSizeFor:lblEvidence detailview:evidenceDetails];
            [self setLabelSizeFor:lblReferences detailview:referencesDetails];
            [self setLabelSizeFor:lblAssignedBy detailview:assignedByDetails];
            
            [self setLabelSizeFor:(UILabel*)definitionBtn detailview:DefinitionDetails];
            [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesDetails];
            //------Goid label and details
            [self setViewYOriginFor:lblGoId previousView:lblAnnotations previousDetailView:annotationsDetails];
            [self setViewYOriginFor:goIdDetails previousView:lblAnnotations previousDetailView:annotationsDetails];
            [self setViewXOriginFor:goIdDetails previousView:lblGoId];
            
            //---------
            
           
            [self setViewYOriginFor:lblEvidence previousView:lblGoId previousDetailView:goIdDetails];
            [self setViewYOriginFor:evidenceDetails previousView:lblGoId previousDetailView:goIdDetails];
            [self setViewXOriginFor:evidenceDetails previousView:lblEvidence];
            
            //-------
            [self setViewYOriginFor:lblDefinition previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewYOriginFor:DefinitionDetails previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewXOriginFor:DefinitionDetails previousView:lblDefinition];
            
            [self setViewYOriginFor:definitionBtn previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewYOriginFor:lblReferences previousView:lblDefinition previousDetailView:DefinitionDetails];
            
            [self setViewYOriginFor:referencesDetails previousView:lblDefinition previousDetailView:DefinitionDetails];
            //------------
            
            
        
            [self setViewXOriginFor:referencesDetails previousView:lblReferences];
            
            [self setViewYOriginFor:referenceBtn previousView:lblDefinition previousDetailView:DefinitionDetails];
            
            [self setViewYOriginFor:lblAssignedBy previousView:lblReferences previousDetailView:referencesDetails];
            [self setViewYOriginFor:assignedByDetails previousView:lblReferences previousDetailView:referencesDetails];
            [self setViewXOriginFor:assignedByDetails previousView:lblAssignedBy];
            
            
            float  f1 = assignedByDetails.frame.origin.y+assignedByDetails.frame.size.height+20; 
            [contentView setFrame:CGRectMake(128, 10, 768,f1)];
            [(UIScrollView*)self.view setContentSize:contentView.frame.size];
            
            
            
            CGRect lblFrame = CGRectMake(contentView.frame.size.width-15,DefinitionDetails.frame.origin.y, 25, DefinitionDetails.frame.size.height);
            
            indicator1.frame = lblFrame;
            
            
            
            CGRect lblFrame2 = CGRectMake(contentView.frame.size.width-15,referencesDetails.frame.origin.y, 25, referencesDetails.frame.size.height);
            
            indicator2.frame = lblFrame2;
            

		}
		else			
		{
           
			contentView.layer.borderWidth = 1;
			contentView.layer.cornerRadius = 5;
			contentView.layer.borderColor = [[UIColor blackColor] CGColor];
            
            
            [lblAnnotations setFrame:CGRectMake(5, lblAnnotations.frame.origin.y, lblAnnotations.frame.size.width, lblAnnotations.frame.size.height)];
            [self setViewXOriginFor:annotationsDetails previousView:lblAnnotations];
            
            [self setLabelSizeFor:lblEvidence detailview:evidenceDetails];
            [self setLabelSizeFor:lblReferences detailview:referencesDetails];
            [self setLabelSizeFor:lblAssignedBy detailview:assignedByDetails];
            [self setLabelSizeFor:(UILabel*)definitionBtn detailview:DefinitionDetails];
            [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesDetails];
            
            //------Goid label and details
            [self setViewYOriginFor:lblGoId previousView:lblAnnotations previousDetailView:annotationsDetails];
            [self setViewYOriginFor:goIdDetails previousView:lblAnnotations previousDetailView:annotationsDetails];
            [self setViewXOriginFor:goIdDetails previousView:lblGoId];
            
            //---------
            
         
            
            [self setViewYOriginFor:lblEvidence previousView:lblGoId previousDetailView:goIdDetails];
            [self setViewYOriginFor:evidenceDetails previousView:lblGoId previousDetailView:goIdDetails];
            [self setViewXOriginFor:evidenceDetails previousView:lblEvidence];
            
            
            //-------
            [self setViewYOriginFor:lblDefinition previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewYOriginFor:DefinitionDetails previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewXOriginFor:DefinitionDetails previousView:lblDefinition];
            [self setViewYOriginFor:definitionBtn previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewYOriginFor:lblReferences previousView:lblDefinition previousDetailView:DefinitionDetails];
            
              [self setViewYOriginFor:referencesDetails previousView:lblDefinition previousDetailView:DefinitionDetails];
            //------------
            
            
           
            [self setViewXOriginFor:referencesDetails previousView:lblReferences];
            
            [self setViewYOriginFor:referenceBtn previousView:lblDefinition previousDetailView:DefinitionDetails];
            [self setViewYOriginFor:lblAssignedBy previousView:lblReferences previousDetailView:referencesDetails];
            [self setViewYOriginFor:assignedByDetails previousView:lblReferences previousDetailView:referencesDetails];
            [self setViewXOriginFor:assignedByDetails previousView:lblAssignedBy];
            
            float  f1 = assignedByDetails.frame.origin.y+assignedByDetails.frame.size.height+20; 
            [contentView setFrame:CGRectMake(10, 10, 748, f1)];
            [(UIScrollView*)self.view setContentSize:contentView.frame.size];
            
            
            
            
            CGRect lblFrame = CGRectMake(contentView.frame.size.width-15,DefinitionDetails.frame.origin.y, 25, DefinitionDetails.frame.size.height);
            
            indicator1.frame = lblFrame;
            
            
            
            CGRect lblFrame2 = CGRectMake(contentView.frame.size.width-15,referencesDetails.frame.origin.y, 25, referencesDetails.frame.size.height);
            
            indicator2.frame = lblFrame2;
            

		}
        
        
       
	}
	else
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
			[self setLabelWidthFor:annotationsDetails newWidth:350];
            [self setLabelWidthFor:goIdDetails newWidth:350];

			[self setLabelWidthFor:evidenceDetails newWidth:350];
            [self setLabelWidthFor:DefinitionDetails newWidth:350];
            [self setButtonWidthFor:definitionBtn newWidth:471];

			[self setLabelWidthFor:referencesDetails newWidth:350];
            [self setButtonWidthFor:referenceBtn newWidth:471];

			[self setLabelWidthFor:assignedByDetails newWidth:350];
            
            [self setLabelSizeFor:lblEvidence detailview:evidenceDetails];
            [self setLabelSizeFor:lblReferences detailview:referencesDetails];
            [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesDetails];

            [self setLabelSizeFor:lblDefinition detailview:DefinitionDetails];
            [self setLabelSizeFor:(UILabel*)definitionBtn detailview:DefinitionDetails];

            [self setLabelSizeFor:lblAssignedBy detailview:assignedByDetails];
            
            
            //------Goid label and details
            [self setViewYOriginFor:lblGoId previousView:lblAnnotations previousDetailView:annotationsDetails];
            [self setViewYOriginFor:goIdDetails previousView:lblAnnotations previousDetailView:annotationsDetails];
            [self setViewXOriginFor:goIdDetails previousView:lblGoId];
            
            //---------
            
            [self setViewYOriginFor:lblEvidence previousView:lblGoId previousDetailView:goIdDetails];
            [self setViewYOriginFor:evidenceDetails previousView:lblGoId previousDetailView:goIdDetails];
            [self setViewXOriginFor:evidenceDetails previousView:lblEvidence];
            
         
            
            //---------
            [self setViewYOriginFor:lblDefinition previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewYOriginFor:DefinitionDetails previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewXOriginFor:DefinitionDetails previousView:lblDefinition];
            [self setViewYOriginFor:definitionBtn previousView:lblEvidence previousDetailView:evidenceDetails];
            //---------
           
            [self setViewYOriginFor:lblReferences previousView:lblDefinition previousDetailView:DefinitionDetails];
            [self setViewYOriginFor:referencesDetails previousView:lblDefinition previousDetailView:DefinitionDetails];
            [self setViewXOriginFor:referencesDetails previousView:lblReferences];
            [self setViewYOriginFor:referenceBtn previousView:lblDefinition previousDetailView:DefinitionDetails];
            
            [self setViewYOriginFor:lblAssignedBy previousView:lblReferences previousDetailView:referencesDetails];
            [self setViewYOriginFor:assignedByDetails previousView:lblReferences previousDetailView:referencesDetails];
            [self setViewXOriginFor:assignedByDetails previousView:lblAssignedBy];
            
            
            float  f1 = assignedByDetails.frame.origin.y+assignedByDetails.frame.size.height+20; 
            [contentView setFrame:CGRectMake(0, 0, 480, f1)];
            [(UIScrollView*)self.view setContentSize:contentView.frame.size];

            
            
            
            CGRect lblFrame = CGRectMake(contentView.frame.size.width-15,DefinitionDetails.frame.origin.y, 25, DefinitionDetails.frame.size.height);
            
            indicator1.frame = lblFrame;
            

            
            
            CGRect lblFrame2 = CGRectMake(contentView.frame.size.width-15,referencesDetails.frame.origin.y, 25, referencesDetails.frame.size.height);
            
            indicator2.frame = lblFrame2;
            
            //---------

		}
		else			
		{
			[self setLabelWidthFor:annotationsDetails newWidth:210];
            [self setLabelWidthFor:goIdDetails newWidth:210];
			[self setLabelWidthFor:evidenceDetails newWidth:210];
            [self setLabelWidthFor:DefinitionDetails newWidth:200];
            [self setButtonWidthFor:definitionBtn newWidth:312];

			[self setLabelWidthFor:referencesDetails newWidth:200];
            [self setButtonWidthFor:referenceBtn newWidth:312];

			[self setLabelWidthFor:assignedByDetails newWidth:210];
            
            [self setLabelSizeFor:lblEvidence detailview:evidenceDetails];
            [self setLabelSizeFor:lblReferences detailview:referencesDetails];
            [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesDetails];

            [self setLabelSizeFor:lblDefinition detailview:DefinitionDetails];
            [self setLabelSizeFor:(UILabel*)definitionBtn detailview:DefinitionDetails];

            [self setLabelSizeFor:lblAssignedBy detailview:assignedByDetails];
            
            
            //------Goid label and details
            [self setViewYOriginFor:lblGoId previousView:lblAnnotations previousDetailView:annotationsDetails];
            [self setViewYOriginFor:goIdDetails previousView:lblAnnotations previousDetailView:annotationsDetails];
            [self setViewXOriginFor:goIdDetails previousView:lblGoId];
            
            //---------
            [self setViewYOriginFor:lblEvidence previousView:lblGoId previousDetailView:goIdDetails];
            [self setViewYOriginFor:evidenceDetails previousView:lblGoId previousDetailView:goIdDetails];
            [self setViewXOriginFor:evidenceDetails previousView:lblEvidence];
            
            
            //---------
            [self setViewYOriginFor:lblDefinition previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewYOriginFor:DefinitionDetails previousView:lblEvidence previousDetailView:evidenceDetails];
            [self setViewXOriginFor:DefinitionDetails previousView:lblDefinition];
            [self setViewYOriginFor:definitionBtn previousView:lblEvidence previousDetailView:evidenceDetails];
            //---------
            
            [self setViewYOriginFor:lblReferences previousView:lblDefinition previousDetailView:DefinitionDetails];
            [self setViewYOriginFor:referencesDetails previousView:lblDefinition previousDetailView:DefinitionDetails];
            [self setViewXOriginFor:referencesDetails previousView:lblReferences];
            
            [self setViewYOriginFor:referenceBtn previousView:lblDefinition previousDetailView:DefinitionDetails];
            [self setViewYOriginFor:lblAssignedBy previousView:lblReferences previousDetailView:referencesDetails];
            [self setViewYOriginFor:assignedByDetails previousView:lblReferences previousDetailView:referencesDetails];
            [self setViewXOriginFor:assignedByDetails previousView:lblAssignedBy];
            
            float  f1 = assignedByDetails.frame.origin.y+assignedByDetails.frame.size.height+20; 
            [contentView setFrame:CGRectMake(0, 0, 320, f1)];
            [(UIScrollView*)self.view setContentSize:contentView.frame.size];

            
            
            CGRect lblFrame = CGRectMake(contentView.frame.size.width-15,DefinitionDetails.frame.origin.y, 25, DefinitionDetails.frame.size.height);
            
            indicator1.frame = lblFrame;
            
            
            
            CGRect lblFrame2 = CGRectMake(contentView.frame.size.width-15,referencesDetails.frame.origin.y, 25, referencesDetails.frame.size.height);
            
            indicator2.frame = lblFrame2;
            

            
		}
	}
    
}




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	if (finalListArr != nil) 
	{
		[finalListArr release];
		finalListArr = nil;
	}
	finalListArr = [[NSMutableArray alloc] init];
    
    strType =  [staticFunctionClass getFeatGOTypeStr];
    
    
    
    NSArray *display = [[staticFunctionClass getGeneName] componentsSeparatedByString: @"/"];
    
    if (display.count > 1) {
        featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:1]];
    } else {
        featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
    }
    
    
    
    NSString *featName = [staticFunctionClass getGeneName];
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text=[NSString stringWithFormat:@"%@ %@",featName,self.navigationItem.title];
    
    tlabel.textColor=[UIColor blackColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    functiontype.text = featName;
    
	// setting view size -- increasing the length
	
	CGRect frame = self.view.frame; //frame of scroll view
	frame.size.height = 1000;
	frame.origin.y = 20;
	self.view.frame = frame;
	
	frame = contentView.frame;
	
	[(UIScrollView*)self.view setContentSize:frame.size];
	
	
	
	
	// Get Predicate String 
	NSString *PredicateString  = [staticFunctionClass getPredicateStr];

	NSArray *arrPredicates = [PredicateString componentsSeparatedByString:@"#"];
	
		
	// get selected GO Details
	
	
	@try
	{
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"GODetails" inManagedObjectContext:managedObjectContext];
		
		[request setEntity:entity];
		
		
		// setting the predicate 		
		NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:4];
		
//		NSPredicate *fetchByFeat = [NSPredicate predicateWithFormat:@"
		
		NSPredicate *fetchByAnnotation = [NSPredicate predicateWithFormat:@"annotation = %@",[arrPredicates objectAtIndex:0]];
		[predicates addObject:fetchByAnnotation];
		
		NSPredicate *fetchByEvidence = [NSPredicate predicateWithFormat:@"evidence = %@",[arrPredicates objectAtIndex:1]];
		[predicates addObject:fetchByEvidence];		
		
		NSPredicate *fetchByReferences = [NSPredicate predicateWithFormat:@"goReferences = %@",[arrPredicates objectAtIndex:2]];
		[predicates addObject:fetchByReferences];
		
		NSPredicate *fetchByGOType = [NSPredicate predicateWithFormat:@"goType = %@",[arrPredicates objectAtIndex:3]];
		[predicates addObject:fetchByGOType];
		// build the compound predicate
		NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
		
//		NSLog(@"BUILT: %@", predicate);
			
		[request setPredicate:predicate];
		
		[request setFetchLimit:1];  // limit to 1 request returned
		
		NSError *error;
		NSArray *fetchedObjects = [[managedObjectContext executeFetchRequest:request error:&error] retain];

		SelectedGODetails = [fetchedObjects objectAtIndex:0];  //gets the feature object
		
		[request release];
						
//		NSLog(@"GOID: %@", SelectedGODetails.goId);
		
        annotationsDetails.text = [NSString stringWithFormat:@"%@", SelectedGODetails.annotation];
		
		NSString *strPlistName = [[NSBundle mainBundle] pathForResource:@"goEvidenceCodes" ofType:@"plist"];
		NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:strPlistName];
		NSString *strEvidence = [plistDictionary objectForKey:SelectedGODetails.evidence];
        
        [functiontype setFrame:CGRectMake(5, functiontype.frame.origin.y, functiontype.frame.size.width, functiontype.frame.size.height)];        
		//Display Annotation detail and set label size
		annotationsDetails.text = [NSString stringWithFormat:@"%@", SelectedGODetails.annotation];
        [self setViewXOriginFor:annotationsDetails previousView:lblAnnotations];
		[self setLabelSizeFor:annotationsDetails labelText:annotationsDetails.text];
        [annotationsDetails sizeToFit];
        [lblAnnotations setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        
        //Display GOID label and detail and set label size
        [self setViewYOriginFor:lblGoId previousView:lblAnnotations previousDetailView:annotationsDetails];
        
        goIdDetails.text = SelectedGODetails.goId;
        [self setViewYOriginFor:goIdDetails previousView:lblAnnotations previousDetailView:annotationsDetails];
        [self setViewXOriginFor:goIdDetails previousView:lblGoId];
		[self setLabelSizeFor:goIdDetails labelText:goIdDetails.text];
        [goIdDetails sizeToFit];
        [lblGoId setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        [self setLabelSizeFor:lblGoId detailview:goIdDetails];
        
        //Display label and Evidence detail and set label size
        [self setViewYOriginFor:lblEvidence previousView:lblGoId previousDetailView:goIdDetails];
		evidenceDetails.text = strEvidence;
		[self setViewYOriginFor:evidenceDetails previousView:lblGoId previousDetailView:goIdDetails];
        [self setViewXOriginFor:evidenceDetails previousView:lblEvidence];
		[self setLabelSizeFor:evidenceDetails labelText:evidenceDetails.text];
        [evidenceDetails sizeToFit];
        [lblEvidence setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        [self setLabelSizeFor:lblEvidence detailview:evidenceDetails];
        
		[plistDictionary release];
		
        //-------Definition display-----
        [self setViewYOriginFor:lblDefinition previousView:lblEvidence previousDetailView:evidenceDetails];
        DefinitionDetails.text = [NSString stringWithFormat:@"%@", SelectedGODetails.definition];
        [self setViewXOriginFor:DefinitionDetails previousView:lblDefinition];
		[self setLabelSizeFor:DefinitionDetails labelText:DefinitionDetails.text];
        [DefinitionDetails sizeToFit];
        [lblDefinition setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        [self setLabelSizeFor:lblDefinition detailview:DefinitionDetails];

        
        //Display Refernce detail and set label size	
		
		[self setViewYOriginFor:lblReferences previousView:lblDefinition previousDetailView:DefinitionDetails];
        
		referencesDetails.text = [NSString stringWithFormat:@"%@", SelectedGODetails.goReferences];
		[self setViewYOriginFor:referencesDetails previousView:lblDefinition previousDetailView:DefinitionDetails];
        [self setViewXOriginFor:referencesDetails previousView:lblReferences];
		[self setLabelSizeFor:referencesDetails labelText:referencesDetails.text];
		[referencesDetails sizeToFit];
        [lblReferences setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        [self setLabelSizeFor:lblReferences detailview:referencesDetails];
               
		
//		if (referencesDetails) {
				[self setViewYOriginFor:lblAssignedBy previousView:referencesDetails];
  
			
		assignedByDetails.text = [NSString stringWithFormat:@"%@", SelectedGODetails.assignedBy];
		[self setViewYOriginFor:assignedByDetails previousView:referencesDetails];
		[self setLabelSizeFor:assignedByDetails labelText:assignedByDetails.text];
        [lblAssignedBy setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];   
        [self setLabelSizeFor:lblAssignedBy detailview:assignedByDetails];
        
        

		
		//Display navigation bar buttons at top
		
		UIView *EmailFavView = [[UIView alloc] initWithFrame:CGRectMake(0,0,35,35)];
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
		[EmailFavView release];
		[rightButton release];
		[EmailButton release];
		
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@",[e description]);
	}
	
//	NSLog(@"end view did load GOID: %@", SelectedGODetails.goId);


}


- (void)viewDidUnload {
	
//	NSLog(@"View did unload %@", SelectedGODetails.goId);
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Label Method

//Set Label Width according to the label text length

-(void) setLabelWidthFor: (UIView *)labelToSet newWidth: (int) newWidth
{
	CGRect newFrame = labelToSet.frame;
	int oldHeight = labelToSet.frame.size.height;
	newFrame.size = CGSizeMake(newWidth, oldHeight);
	labelToSet.frame = newFrame;
	[labelToSet sizeToFit];
}

//Set Label Size according to the label text length

- (void)setLabelSizeFor: (UILabel *)labelToSet labelText:(NSString *)labelText {
	
	CGSize maxLabelSize = CGSizeMake(2960, 99999);
	
	CGSize expectedLabelSize = [labelText sizeWithFont:labelToSet.font 
									 constrainedToSize:maxLabelSize
										 lineBreakMode:labelToSet.lineBreakMode];
	CGRect newFrame = labelToSet.frame;
	newFrame.size.height = expectedLabelSize.height;	
	labelToSet.frame = newFrame;
	
	
}

//Setting the Y Origin of label depending on label at top

- (void)setViewYOriginFor: (UIView *)viewToSet previousView:(UIView *)previousView {
	CGRect newFrame = viewToSet.frame;
	int newYStart = previousView.frame.size.height + previousView.frame.origin.y + 5;
	int xStart = viewToSet.frame.origin.x;
	newFrame.origin = CGPointMake(xStart,newYStart);
	viewToSet.frame = newFrame;
}

//Setting the X Origin of label depending on label on left

- (void)setViewXOriginFor: (UIView *)viewToSet previousView:(UIView *)previousView {
	CGRect newFrame = viewToSet.frame;
	int newXStart = previousView.frame.size.width + previousView.frame.origin.x +05;
	int yStart = viewToSet.frame.origin.y;
	newFrame.origin = CGPointMake(newXStart,yStart);
	viewToSet.frame = newFrame;
}


//Setting the Y Origin of label depending on label at top
- (void)setViewYOriginFor: (UIView *)viewToSet previousView:(UIView *)previousLabelView previousDetailView:(UIView *)detailView  {
    
    float ft1 = previousLabelView.frame.origin.y+previousLabelView.frame.size.height;
    float ft2 = detailView.frame.origin.y+detailView.frame.size.height;
    
    if(ft1>ft2){
        viewToSet.frame = CGRectMake(05, ft1+10, viewToSet.frame.size.width, viewToSet.frame.size.height);
    }else{
        viewToSet.frame = CGRectMake(05, ft2+10, viewToSet.frame.size.width, viewToSet.frame.size.height);
        
    }
}

- (void)setLabelSizeFor: (UILabel *)labelToSet detailview:(UILabel *)detailview {
    
    CGRect newFrame = labelToSet.frame;
    int newHeight = detailview.frame.size.height;
    newFrame.size = CGSizeMake(labelToSet.frame.size.width, newHeight);
        
	labelToSet.frame = newFrame;
   
    
}

-(void) setButtonWidthFor: (UIView *)labelToSet newWidth: (int) newWidth
{
	CGRect newFrame = labelToSet.frame;
	int oldHeight = labelToSet.frame.size.height;
	newFrame.size = CGSizeMake(newWidth, oldHeight);
	labelToSet.frame = newFrame;
    
    

}


#pragma mark -
#pragma mark Action Method

//Called when email icon is pressed and mail is composed
-(IBAction)pushedEmailButton:(id)sender 
{
    NSString *featName = [staticFunctionClass getGeneName];
	NSArray *names = [featName componentsSeparatedByString:@"/"]; //split featName into standard and systematic names
	NSString *sysName = [names lastObject];
    
    NSString *SubjectLine = [NSString stringWithFormat:@"%@, %@",featName,self.title]; 
    
    
    [staticFunctionClass setSubjectLine:SubjectLine];
    NSMutableArray *arrRec = [[NSMutableArray alloc] init];
    
    EmailViewController *emailView = [[EmailViewController alloc]initWithNibName:@"EmailViewController" bundle:[NSBundle mainBundle]];
    
    NSString *eMailBody = @"";
    
    eMailBody = [eMailBody stringByAppendingFormat:@"<div><b><a href=\"http://www.yeastgenome.org/cgi-bin/GO/goAnnotation.pl?locus=%@\">%@ GO Annotations<br><br></a></div><table><tr><td><b>Gene Ontology Term:</b>%@<br> <b>GOID:</b>%@<br><b>Evidence:</b>%@<br><b>Definition:</b>%@<br><b>Reference:</b>%@<br><b>Assigned By:</b>%@</td></tr></table><br><br>",sysName, featName, annotationsDetails.text,goIdDetails.text,evidenceDetails.text, DefinitionDetails.text, referencesDetails.text, assignedByDetails.text];
	
    [staticFunctionClass setMessageBody:eMailBody];
    
    [arrRec release];
    
    [self.navigationController pushViewController:emailView animated:YES];
    
    [emailView release];
}
	
/*Function called when reference text is pressed 
 and the respective url is loaded in webview*/
-(void)pushedReferenceButton:(id)sender{
    
//	NSLog(@"ref button GOID: %@", SelectedGODetails.goId);

    
    @try
	{
        
        PubMedID = [NSString stringWithFormat:@"%@", SelectedGODetails.pubMedId];        
        if([PubMedID length]!=0)
        {
            
            NSString *urlAddress =[NSString stringWithFormat:@"http://www.yeastgenome.org/cgi-bin/reference/reference.pl?pmid=%@",PubMedID];//@"http://yeastmine.yeastgenome.org/yeastmine/portal.do?externalids=%@"
            
            
            
            
            [staticFunctionClass setBrowseImg:urlAddress];
            
            BrowseImgView * browseImgVC = [[BrowseImgView alloc] initWithNibName:@"BrowseImgView_iPhone" bundle:[NSBundle mainBundle]];
            
            
            browseImgVC.title = @"Reference";  
            
            [self.navigationController pushViewController:browseImgVC animated:YES];
            
            [browseImgVC release];
            
            
        }
        
  
        
    
    }
	@catch (NSException * e)
	{
		NSLog(@"%@", [e description]);
	}
   
    
}

/*Function called when definition text is pressed 
 and the respective url is loaded in webview*/
-(IBAction)pushedDefinitionButton:(id)sender {
	
    @try {
		
			NSString *urlAddress =[NSString stringWithFormat:@"http://www.yeastgenome.org/cgi-bin/GO/goTerm.pl?goid=%@",SelectedGODetails.goId];//@"http://yeastmine.yeastgenome.org/yeastmine/portal.do?externalids=%@"
            
            [staticFunctionClass setBrowseImg:urlAddress];
            
            BrowseImgView * browseImgVC = [[BrowseImgView alloc] initWithNibName:@"BrowseImgView_iPhone" bundle:[NSBundle mainBundle]];
            
            
            browseImgVC.title = @"GO Term"; 
            
            [self.navigationController pushViewController:browseImgVC animated:YES];
            
            [browseImgVC release];
       
        
    }   
    @catch (NSException * e)
    {
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
#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}




- (void)dealloc {
	
	[SelectedGODetails release];
    [super dealloc];
}


@end
