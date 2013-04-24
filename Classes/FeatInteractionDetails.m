//
//  FeatInteractionDetails.m
//  SGD_2
//
//  Created by Vivek on 14/06/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*
 Class to implement the detail of Feature Interaction.
 */

#import "FeatInteractionDetails.h"
#import "staticFunctionClass.h"
#import "SBJSON.h"
#import "webServiceHelper.h"
#import "EmailViewController.h"
#import "BrowseImgView.h"
#import "Interactions.h"
#import "Reachability.h"

@implementation FeatInteractionDetails

@synthesize managedObjectContext;
@synthesize progAlertView, activityIndView;
@synthesize selectedFeature;
@synthesize allReferencesInteraction;



#pragma mark -
#pragma mark Orientation Support
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

//for IOS6
-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

/*Function is called when device is rotated and labels are align/oriented accordingly*/
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	UIInterfaceOrientation orientation = self.interfaceOrientation;
	
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
			[contentView setFrame:CGRectMake(128, 10, 768, 450)];
			contentView.layer.borderWidth = 1;
			contentView.layer.cornerRadius = 5;
			contentView.layer.borderColor = [[UIColor blackColor] CGColor];
		}
		else			
		{
			[contentView setFrame:CGRectMake(10, 10, 748, 450)];
			contentView.layer.borderWidth = 1;
			contentView.layer.cornerRadius = 5;
			contentView.layer.borderColor = [[UIColor blackColor] CGColor];
		}
        
        
        
        CGRect lblFrame = CGRectMake(contentView.frame.size.width-15,referencesLabel.frame.origin.y, 25, referencesLabel.frame.size.height);
        
        indicator1.frame = lblFrame;
        

	}
	else
    {
        if(orientation == UIInterfaceOrientationLandscapeLeft || 
           orientation == UIInterfaceOrientationLandscapeRight) 
        {
            
            
            [self setLabelWidthFor:geneNameLabel newWidth:330];
            [self setLabelWidthFor:featNameLabel newWidth:330];
            [self setLabelWidthFor:expTypeLabel newWidth:330];
            [self setLabelWidthFor:featTypeLabel newWidth:330];
            [self setLabelWidthFor:actionLabel newWidth:330];
            [self setLabelWidthFor:sourceLabel newWidth:330];
            
            [self setLabelWidthFor:intDescriptionLabel newWidth:330];
            [self setLabelWidthFor:referencesLabel newWidth:330];
            [self setButtonWidthFor:referenceBtn newWidth:471];

            
        }
        else			
        {
                        
            [self setLabelWidthFor:geneNameLabel newWidth:180];
            [self setLabelWidthFor:featNameLabel newWidth:180];
            [self setLabelWidthFor:expTypeLabel newWidth:180];
            [self setLabelWidthFor:featTypeLabel newWidth:180];
            [self setLabelWidthFor:actionLabel newWidth:180];
            [self setLabelWidthFor:sourceLabel newWidth:180];
            
            [self setLabelWidthFor:intDescriptionLabel newWidth:180];
            [self setLabelWidthFor:referencesLabel newWidth:170];
                  
        }
     
        
        //---------
        [self setViewYOriginFor:featNameTitle  previousView:geneNameTitle previousDetailView:geneNameLabel];
        [self setViewYOriginFor:featNameLabel previousView:geneNameTitle previousDetailView:geneNameLabel];
        [self setViewXOriginFor:featNameLabel previousView:featNameTitle];
        
        //---------
        [self setViewYOriginFor:expTypeTitle previousView:featNameTitle  previousDetailView:featNameLabel ];
        [self setViewYOriginFor:expTypeLabel previousView:featNameTitle previousDetailView:featNameLabel];
        [self setViewXOriginFor:expTypeLabel previousView:expTypeTitle];
        
        //---------
        [self setViewYOriginFor:featTypeTitle previousView:expTypeTitle  previousDetailView:expTypeLabel];
        [self setViewYOriginFor:featTypeLabel previousView:expTypeTitle previousDetailView:expTypeLabel];
        [self setViewXOriginFor:featTypeLabel previousView:featTypeTitle];
        
        [self setViewYOriginFor:actionTitle previousView:featTypeTitle  previousDetailView:featTypeLabel];
        [self setViewYOriginFor:actionLabel previousView:featTypeTitle previousDetailView:featTypeLabel];
        [self setViewXOriginFor:actionLabel  previousView:actionTitle];
        
        
        [self setViewYOriginFor:sourceTitle previousView:actionTitle  previousDetailView:actionLabel ];
        [self setViewYOriginFor:sourceLabel previousView:actionTitle previousDetailView:actionLabel];
        [self setViewXOriginFor:sourceLabel previousView:sourceTitle];
        
        
        [self setViewYOriginFor:intDescriptionTitle previousView:sourceTitle  previousDetailView:sourceLabel];
        [self setViewYOriginFor:intDescriptionLabel previousView:sourceTitle previousDetailView:sourceLabel];
        [self setViewXOriginFor:intDescriptionLabel previousView:intDescriptionTitle]; 
        [intDescriptionLabel sizeToFit];
        [self setLabelSizeFor:intDescriptionTitle detailview:intDescriptionLabel];

     
        [self setViewYOriginFor:referencesTitle previousView:intDescriptionTitle  previousDetailView:intDescriptionLabel];
        
        [self setViewYOriginFor:referencesLabel previousView:intDescriptionTitle previousDetailView:intDescriptionLabel];
      
        
        [self setViewXOriginFor:referencesLabel previousView:referencesTitle];
        
        [referencesLabel sizeToFit];
        [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
        [self setViewYOriginFor:referenceBtn previousView:intDescriptionTitle previousDetailView:intDescriptionLabel];
        [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesLabel];
        
        
        
        CGRect lblFrame = CGRectMake(contentView.frame.size.width-15,referencesLabel.frame.origin.y, 25, referencesLabel.frame.size.height);
        
        indicator1.frame = lblFrame;
        
        //---------

                     
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
       
  
        [self setLabelWidthFor:geneNameLabel newWidth:500];
        [self setLabelWidthFor:featNameLabel newWidth:500];
        [self setLabelWidthFor:expTypeLabel newWidth:500];
        [self setLabelWidthFor:featTypeLabel newWidth:500];
        [self setLabelWidthFor:actionLabel newWidth:500];
        [self setLabelWidthFor:sourceLabel newWidth:500];
        
        [self setLabelWidthFor:intDescriptionLabel newWidth:500];
        [self setLabelWidthFor:referencesLabel newWidth:500];
        
        
        
        //---------
        [self setViewYOriginFor:featNameTitle  previousView:geneNameTitle previousDetailView:geneNameLabel];
        [self setViewYOriginFor:featNameLabel previousView:geneNameTitle previousDetailView:geneNameLabel];
        [self setViewXOriginFor:featNameLabel previousView:featNameTitle];
        
        //---------
        [self setViewYOriginFor:expTypeTitle previousView:featNameTitle  previousDetailView:featNameLabel ];
        [self setViewYOriginFor:expTypeLabel previousView:featNameTitle previousDetailView:featNameLabel];
        [self setViewXOriginFor:expTypeLabel previousView:expTypeTitle];
        
        //---------
        [self setViewYOriginFor:featTypeTitle previousView:expTypeTitle  previousDetailView:expTypeLabel];
        [self setViewYOriginFor:featTypeLabel previousView:expTypeTitle previousDetailView:expTypeLabel];
        [self setViewXOriginFor:featTypeLabel previousView:featTypeTitle];
        
        [self setViewYOriginFor:actionTitle previousView:featTypeTitle  previousDetailView:featTypeLabel];
        [self setViewYOriginFor:actionLabel previousView:featTypeTitle previousDetailView:featTypeLabel];
        [self setViewXOriginFor:actionLabel  previousView:actionTitle];
        
        
        [self setViewYOriginFor:sourceTitle previousView:actionTitle  previousDetailView:actionLabel ];
        [self setViewYOriginFor:sourceLabel previousView:actionTitle previousDetailView:actionLabel];
        [self setViewXOriginFor:sourceLabel previousView:sourceTitle];
        
        
        [self setViewYOriginFor:intDescriptionTitle previousView:sourceTitle  previousDetailView:sourceLabel];
        [self setViewYOriginFor:intDescriptionLabel previousView:sourceTitle previousDetailView:sourceLabel];
        [self setViewXOriginFor:intDescriptionLabel previousView:intDescriptionTitle]; 
        [intDescriptionLabel sizeToFit];
        
        [self setViewYOriginFor:referencesTitle previousView:intDescriptionTitle  previousDetailView:intDescriptionLabel];
      
        [self setViewYOriginFor:referencesLabel previousView:intDescriptionTitle previousDetailView:intDescriptionLabel];
        [self setViewXOriginFor:referencesLabel previousView:referencesTitle]; 
        [referencesLabel sizeToFit];
        
       
        
        [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
        //----
        [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
        [self setViewYOriginFor:referenceBtn previousView:intDescriptionTitle previousDetailView:intDescriptionLabel];
        [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesLabel];
        //-----
        
        float  f1 = referencesTitle.frame.origin.y+referencesTitle.frame.size.height+20;            

		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            [contentView setFrame:CGRectMake(128, 10, 768, f1)];
			contentView.layer.borderWidth = 1;
			contentView.layer.cornerRadius = 5;
			contentView.layer.borderColor = [[UIColor blackColor] CGColor];
            
		}
		else			
		{
			[contentView setFrame:CGRectMake(10, 10, 748, f1)];
			contentView.layer.borderWidth = 1;
			contentView.layer.cornerRadius = 5;
			contentView.layer.borderColor = [[UIColor blackColor] CGColor];
            
		}    
        
        [(UIScrollView*)self.view setContentSize:contentView.frame.size];
        
        
        
        CGRect lblFrame = CGRectMake(contentView.frame.size.width-15,referencesLabel.frame.origin.y, 25, referencesLabel.frame.size.height);
        
        indicator1.frame = lblFrame;
        
       

    }
	else
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
			[self setLabelWidthFor:intDescriptionLabel newWidth:330];
			[self setLabelWidthFor:referencesLabel newWidth:330];
            [self setButtonWidthFor:referenceBtn newWidth:471];


		}
		else			
		{
			[self setLabelWidthFor:intDescriptionLabel newWidth:180];
			[self setLabelWidthFor:referencesLabel newWidth:170];
            [self setButtonWidthFor:referenceBtn newWidth:312];

		}
        
        
        //---------
        [self setViewYOriginFor:featNameTitle  previousView:geneNameTitle previousDetailView:geneNameLabel];
        [self setViewYOriginFor:featNameLabel previousView:geneNameTitle previousDetailView:geneNameLabel];
        [self setViewXOriginFor:featNameLabel previousView:featNameTitle];
     
        //---------
        [self setViewYOriginFor:expTypeTitle previousView:featNameTitle  previousDetailView:featNameLabel ];
        [self setViewYOriginFor:expTypeLabel previousView:featNameTitle previousDetailView:featNameLabel];
        [self setViewXOriginFor:expTypeLabel previousView:expTypeTitle];
        
        //---------
        [self setViewYOriginFor:featTypeTitle previousView:expTypeTitle  previousDetailView:expTypeLabel];
        [self setViewYOriginFor:featTypeLabel previousView:expTypeTitle previousDetailView:expTypeLabel];
        [self setViewXOriginFor:featTypeLabel previousView:featTypeTitle];
        
        [self setViewYOriginFor:actionTitle previousView:featTypeTitle  previousDetailView:featTypeLabel];
        [self setViewYOriginFor:actionLabel previousView:featTypeTitle previousDetailView:featTypeLabel];
        [self setViewXOriginFor:actionLabel  previousView:actionTitle];
        
        
        [self setViewYOriginFor:sourceTitle previousView:actionTitle  previousDetailView:actionLabel ];
        [self setViewYOriginFor:sourceLabel previousView:actionTitle previousDetailView:actionLabel];
        [self setViewXOriginFor:sourceLabel previousView:sourceTitle];
        
        
        [self setViewYOriginFor:intDescriptionTitle previousView:sourceTitle  previousDetailView:sourceLabel];
        [self setViewYOriginFor:intDescriptionLabel previousView:sourceTitle previousDetailView:sourceLabel];
        [self setViewXOriginFor:intDescriptionLabel previousView:intDescriptionTitle]; 
        [intDescriptionLabel sizeToFit];
        [self setLabelSizeFor:intDescriptionTitle detailview:intDescriptionLabel];

        [self setViewYOriginFor:referencesTitle previousView:intDescriptionTitle  previousDetailView:intDescriptionLabel];
        [self setViewYOriginFor:referencesLabel previousView:intDescriptionTitle previousDetailView:intDescriptionLabel];
      
        [self setViewXOriginFor:referencesLabel previousView:referencesTitle]; 
        [referencesLabel sizeToFit];
        [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
        
        //----
        [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesLabel];

        [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
        [self setViewYOriginFor:referenceBtn previousView:intDescriptionTitle previousDetailView:intDescriptionLabel];
        [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesLabel];
        //-----
        
        
	}
	
    
    float  f1 = referencesTitle.frame.origin.y+referencesTitle.frame.size.height+20;            
    
    UIInterfaceOrientation orientation1 = self.interfaceOrientation;
	
	NSRange textRange1 = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	
    if (textRange1.location != NSNotFound) 
	{
        
    }
    else
    {
        if(orientation1 == UIInterfaceOrientationLandscapeLeft || 
           orientation1 == UIInterfaceOrientationLandscapeRight) 
        {
            [contentView setFrame:CGRectMake(0, 0, 480, f1)];
        }
        else			
        {
            [contentView setFrame:CGRectMake(0, 0, 320, f1)];
        }    
        
        
    }
 
    [(UIScrollView*)self.view setContentSize:contentView.frame.size];

    
    
    CGRect lblFrame = CGRectMake(contentView.frame.size.width-15,referencesLabel.frame.origin.y, 25, referencesLabel.frame.size.height);
    
    indicator1.frame = lblFrame;
    
    //---------

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
    
	CGRect frame = self.view.frame; //frame of scroll view
	frame.size.height = 1000;
	frame.origin.y = 20;
	self.view.frame = frame;
	
	frame = contentView.frame;
	[(UIScrollView*)self.view setContentSize:frame.size];
	
	
    NSString *featName = [staticFunctionClass getGeneName];
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text= [NSString stringWithFormat:@"%@ %@", featName, @"Interaction Details"];
    tlabel.textColor=[UIColor blackColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    [tlabel release];
    
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
    [EmailFavView release];
      
    
    titleLabel.text = [staticFunctionClass getGeneName];

    
    
    
    NSDictionary *interFeatureName = [staticFunctionClass getInteractionDict];
    //---------
    allReferencesInteraction = [[NSMutableArray alloc] init];
    
    //----
   
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features" inManagedObjectContext:managedObjectContext];
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
    
    selectedFeature = [fetchedObjects objectAtIndex:0];  //gets the feature object		
    
    [request release];
    
     //--
    //Check if already in database
    
    NSSet *interactionSet = selectedFeature.interaction;
    BOOL isInter = NO;
    if ([interactionSet count] != 0)
    {
        for (Interactions *interObj in [interactionSet allObjects]) 
        {
            if ([[interObj featureName] isEqualToString:[interFeatureName objectForKey:@"featureName"]] &&
                [[interObj experimentType] isEqualToString:[interFeatureName objectForKey:@"experimentType"]] &&
                [[interObj featureType] isEqualToString:[interFeatureName objectForKey:@"featureType"]] &&
                [[interObj intDescription] isEqualToString:[interFeatureName objectForKey:@"intDescription"]] &&
                [[interObj intReferences] isEqualToString:[interFeatureName objectForKey:@"citation"]] &&
                [[interObj action] isEqualToString:[interFeatureName objectForKey:@"action"]]) 
            {
            
                //------
                //Display gene Name detail and set label size
                isInter = YES;
                geneNameLabel.text = [interFeatureName objectForKey:@"geneName"];
                
                [self setViewXOriginFor:geneNameLabel previousView:geneNameTitle];
                [self setLabelSizeFor:geneNameLabel labelText:geneNameLabel.text];
                [geneNameLabel sizeToFit];
                [geneNameTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
                [self setLabelSizeFor:geneNameTitle detailview:geneNameLabel];
                
                //Display Feature Name label and detail and set label size
                [self setViewYOriginFor:featNameTitle previousView:geneNameTitle previousDetailView:geneNameLabel];
                
                featNameLabel.text = [interFeatureName objectForKey:@"featureName"];
                [self setViewYOriginFor:featNameLabel previousView:geneNameTitle previousDetailView:geneNameLabel];
                [self setViewXOriginFor:featNameLabel previousView:featNameTitle];
                [self setLabelSizeFor:featNameLabel labelText:featNameLabel.text];
                [featNameLabel sizeToFit];
                [featNameTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
                [self setLabelSizeFor:featNameTitle detailview:featNameLabel];
                
                //Display label and Experiment type detail and set label size
                [self setViewYOriginFor:expTypeTitle previousView:featNameLabel previousDetailView:featNameTitle];
                expTypeLabel.text = [interFeatureName objectForKey:@"experimentType"];
                [self setViewYOriginFor:expTypeLabel previousView:featNameTitle previousDetailView:featNameLabel];
                [self setViewXOriginFor:expTypeLabel previousView:expTypeTitle];
                
                [self setLabelSizeFor:expTypeLabel labelText:expTypeLabel.text];
                [expTypeLabel sizeToFit];
                [expTypeTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
                [self setLabelSizeFor:expTypeTitle detailview:expTypeLabel];
                
                
                //-------Feature Type display-----
                [self setViewYOriginFor:featTypeTitle previousView:expTypeTitle previousDetailView:expTypeLabel];
                featTypeLabel.text = [interFeatureName objectForKey:@"featureType"];
                [self setViewXOriginFor:featTypeLabel previousView:featTypeTitle];
                [self setViewYOriginFor:featTypeLabel previousView:expTypeTitle previousDetailView:expTypeLabel];
                
                [self setLabelSizeFor:featTypeLabel labelText:featTypeLabel.text];
                [featTypeLabel sizeToFit];
                [featTypeTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
                [self setLabelSizeFor:featTypeTitle detailview:featTypeLabel];
                
                
                //Action Display
                [self setViewYOriginFor:actionTitle previousView:featTypeTitle previousDetailView:featTypeLabel];
                actionLabel.text = [interFeatureName objectForKey:@"action"];
                [self setViewYOriginFor:actionLabel previousView:featTypeTitle previousDetailView:featTypeLabel];
                [self setViewXOriginFor:actionLabel previousView:actionTitle];
                
                [self setLabelSizeFor:actionLabel labelText:actionLabel.text];
                [actionLabel sizeToFit];
                [actionTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
                [self setLabelSizeFor:actionTitle detailview:actionLabel];
                
                
                //Source Display
                
                [self setViewYOriginFor:sourceTitle previousView:actionTitle previousDetailView:actionLabel];
                sourceLabel.text = @"BioGRID";//[interFeatureName objectForKey:@"source"];
                [self setViewYOriginFor:sourceLabel previousView:actionTitle previousDetailView:actionLabel];
                [self setViewXOriginFor:sourceLabel previousView:sourceTitle];
                
                [self setLabelSizeFor:sourceLabel labelText:sourceLabel.text];
                [sourceLabel sizeToFit];
                [sourceTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
                [self setLabelSizeFor:sourceTitle detailview:sourceLabel];
                
                
                
                
                
                //Description display
                
                [self setViewYOriginFor:intDescriptionTitle previousView:sourceTitle previousDetailView:sourceLabel];
                intDescriptionLabel.text =  [interFeatureName objectForKey:@"intDescription"];
                [self setViewYOriginFor:intDescriptionLabel previousView:sourceTitle previousDetailView:sourceLabel];
                [self setViewXOriginFor:intDescriptionLabel previousView:intDescriptionTitle];
                
                [self setLabelSizeFor:intDescriptionLabel labelText:intDescriptionLabel.text];
                [intDescriptionLabel sizeToFit];
                [intDescriptionTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
                [self setLabelSizeFor:intDescriptionTitle detailview:intDescriptionLabel];
                
                
               
                
                referencesLabel.text = [interFeatureName objectForKey:@"citation"];
                
                [self setViewYOriginFor:referencesTitle previousView:intDescriptionTitle  previousDetailView:intDescriptionLabel];
                [self setViewYOriginFor:referencesLabel previousView:intDescriptionTitle previousDetailView:intDescriptionLabel];
                
                
                [self setViewXOriginFor:referencesLabel previousView:referencesTitle]; 
                
                [referencesLabel sizeToFit];//[referencesIndicator sizeToFit];
                [referencesTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
                [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
                
                //----
                [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
                [self setViewYOriginFor:referenceBtn previousView:intDescriptionTitle previousDetailView:intDescriptionLabel];
                [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesLabel];
                //-----
                
                break;
            }
             
            
        }
    
    
    }
    if (!isInter) {
        //-----
        isInter = NO;
        NSManagedObjectContext *interactionMOC = [NSEntityDescription insertNewObjectForEntityForName:@"Interactions" inManagedObjectContext:managedObjectContext];
        [interactionMOC setValue:[interFeatureName objectForKey:@"intDescription"] forKey:@"intDescription"];
        [interactionMOC setValue:[interFeatureName objectForKey:@"experimentType"] forKey:@"experimentType"];
        [interactionMOC setValue:[interFeatureName objectForKey:@"action"] forKey:@"action"];
        [interactionMOC setValue:[interFeatureName objectForKey:@"featureName"] forKey:@"featureName"];
        [interactionMOC setValue:[interFeatureName objectForKey:@"geneName"] forKey:@"geneName"];	
        [interactionMOC setValue:[interFeatureName objectForKey:@"featureType"] forKey:@"featureType"];
        [interactionMOC setValue: @"BioGRID" forKey:@"source"];
        [interactionMOC setValue:[interFeatureName objectForKey:@"citation"] forKey:@"intReferences"];
        [interactionMOC setValue:selectedFeature forKey:@"intertofeat"];
        
        
        NSMutableSet *interactionsSet = [NSMutableSet set];
        [interactionsSet addObject:interactionMOC];
        [selectedFeature addInteraction:interactionsSet];
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
        
       
        
        //------
        //Display gene Name detail and set label size
        
        geneNameLabel.text = [interFeatureName objectForKey:@"geneName"];
        
        [self setViewXOriginFor:geneNameLabel previousView:geneNameTitle];
        [self setLabelSizeFor:geneNameLabel labelText:geneNameLabel.text];
        [geneNameLabel sizeToFit];
        [geneNameTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        [self setLabelSizeFor:geneNameTitle detailview:geneNameLabel];
        
        //Display Feature Name label and detail and set label size
        [self setViewYOriginFor:featNameTitle previousView:geneNameTitle previousDetailView:geneNameLabel];
        
        featNameLabel.text = [interFeatureName objectForKey:@"featureName"];
        [self setViewYOriginFor:featNameLabel previousView:geneNameTitle previousDetailView:geneNameLabel];
        [self setViewXOriginFor:featNameLabel previousView:featNameTitle];
        [self setLabelSizeFor:featNameLabel labelText:featNameLabel.text];
        [featNameLabel sizeToFit];
        [featNameTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        [self setLabelSizeFor:featNameTitle detailview:featNameLabel];
        
        //Display label and Experiment type detail and set label size
        [self setViewYOriginFor:expTypeTitle previousView:featNameLabel previousDetailView:featNameTitle];
        expTypeLabel.text = [interFeatureName objectForKey:@"experimentType"];
        [self setViewYOriginFor:expTypeLabel previousView:featNameTitle previousDetailView:featNameLabel];
        [self setViewXOriginFor:expTypeLabel previousView:expTypeTitle];
        
        [self setLabelSizeFor:expTypeLabel labelText:expTypeLabel.text];
        [expTypeLabel sizeToFit];
        [expTypeTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        [self setLabelSizeFor:expTypeTitle detailview:expTypeLabel];
        
        
        //-------Feature Type display-----
        [self setViewYOriginFor:featTypeTitle previousView:expTypeTitle previousDetailView:expTypeLabel];
        featTypeLabel.text = [interFeatureName objectForKey:@"featureType"];
        [self setViewXOriginFor:featTypeLabel previousView:featTypeTitle];
        [self setViewYOriginFor:featTypeLabel previousView:expTypeTitle previousDetailView:expTypeLabel];
        
        [self setLabelSizeFor:featTypeLabel labelText:featTypeLabel.text];
        [featTypeLabel sizeToFit];
        [featTypeTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        [self setLabelSizeFor:featTypeTitle detailview:featTypeLabel];
        
        
        //Action Display
        [self setViewYOriginFor:actionTitle previousView:featTypeTitle previousDetailView:featTypeLabel];
        actionLabel.text = [interFeatureName objectForKey:@"action"];
        [self setViewYOriginFor:actionLabel previousView:featTypeTitle previousDetailView:featTypeLabel];
        [self setViewXOriginFor:actionLabel previousView:actionTitle];
        
        [self setLabelSizeFor:actionLabel labelText:actionLabel.text];
        [actionLabel sizeToFit];
        [actionTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        [self setLabelSizeFor:actionTitle detailview:actionLabel];
        
        
        //Source Display
        
        [self setViewYOriginFor:sourceTitle previousView:actionTitle previousDetailView:actionLabel];
        sourceLabel.text = @"BioGRID";//[interFeatureName objectForKey:@"source"];
        [self setViewYOriginFor:sourceLabel previousView:actionTitle previousDetailView:actionLabel];
        [self setViewXOriginFor:sourceLabel previousView:sourceTitle];
        
        [self setLabelSizeFor:sourceLabel labelText:sourceLabel.text];
        [sourceLabel sizeToFit];
        [sourceTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        [self setLabelSizeFor:sourceTitle detailview:sourceLabel];
        
        
        
        
        
        //Description display
        
        [self setViewYOriginFor:intDescriptionTitle previousView:sourceTitle previousDetailView:sourceLabel];
        intDescriptionLabel.text =  [interFeatureName objectForKey:@"intDescription"];
        [self setViewYOriginFor:intDescriptionLabel previousView:sourceTitle previousDetailView:sourceLabel];
        [self setViewXOriginFor:intDescriptionLabel previousView:intDescriptionTitle];
        
        [self setLabelSizeFor:intDescriptionLabel labelText:intDescriptionLabel.text];
        [intDescriptionLabel sizeToFit];
        [intDescriptionTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        [self setLabelSizeFor:intDescriptionTitle detailview:intDescriptionLabel];
        
        
        //Display Reference detail and set label size
        
        
        referencesLabel.text = [interFeatureName objectForKey:@"citation"];
        
        [self setViewYOriginFor:referencesTitle previousView:intDescriptionTitle  previousDetailView:intDescriptionLabel];
        [self setViewYOriginFor:referencesLabel previousView:intDescriptionTitle previousDetailView:intDescriptionLabel];
        [self setViewXOriginFor:referencesLabel previousView:referencesTitle]; 
        [referencesLabel sizeToFit];
        
       

        
        [referencesTitle setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
        
        
        //----
        [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
        [self setViewYOriginFor:referenceBtn previousView:intDescriptionTitle previousDetailView:intDescriptionLabel];
        [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesLabel];
        //-----
        

    }
        
}


#pragma mark -
#pragma mark - Label Method

-(void) setLabelWidthFor: (UIView *)labelToSet newWidth: (int) newWidth
{
	CGRect newFrame = labelToSet.frame;
	int oldHeight = labelToSet.frame.size.height;
	newFrame.size = CGSizeMake(newWidth, oldHeight);
	labelToSet.frame = newFrame;
}

- (void)setLabelSizeFor: (UILabel *)labelToSet labelText:(NSString *)labelText {
	
	CGSize maxLabelSize = CGSizeMake(219, 99999);
	CGSize expectedLabelSize = [labelText sizeWithFont:labelToSet.font 
									 constrainedToSize:maxLabelSize
										 lineBreakMode:labelToSet.lineBreakMode];
	CGRect newFrame = labelToSet.frame;
	newFrame.size.height = expectedLabelSize.height;	
	labelToSet.frame = newFrame;
}

- (void)setViewYOriginFor: (UIView *)viewToSet previousView:(UIView *)previousView {
	CGRect newFrame = viewToSet.frame;
	int newYStart = previousView.frame.size.height + previousView.frame.origin.y+5;
	int xStart = viewToSet.frame.origin.x;
	newFrame.origin = CGPointMake(xStart,newYStart);
	viewToSet.frame = newFrame;
}
- (void)setViewXOriginFor: (UIView *)viewToSet previousView:(UIView *)previousView {
	CGRect newFrame = viewToSet.frame;
	int newXStart = previousView.frame.size.width + previousView.frame.origin.x + 5;
	int yStart = viewToSet.frame.origin.y;
	newFrame.origin = CGPointMake(newXStart,yStart);
	viewToSet.frame = newFrame;
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



#pragma mark -
#pragma mark Web Service Method 

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

// implement the download delegate method

- (void)finishedDownloading:(NSString *)strJSONResponse
{
    

	@try 
	{
		if ([activityIndView isAnimating]) 
			[activityIndView stopAnimating];
		
		[progAlertView dismissWithClickedButtonIndex:(NSInteger)nil animated:YES];
		
              
		
			
			@synchronized(self)
			{
                
                //-----
        if ([strJSONResponse length] != 0)
                {
                NSError *error;
                SBJSON *json = [[SBJSON new] autorelease];
                
                strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                
                strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\\\"" withString:@""];
                
                NSDictionary *dictionary = [json objectWithString:strJSONResponse error:&error];
                               
                [self getResultsAndInsert:dictionary];

                NSArray *layOuts =  [dictionary objectForKey:@"results"]; 
                
            if ([layOuts count]!=0) {
                        
                    
                NSArray *Interactions = [layOuts objectAtIndex:0];
                NSArray *Interactions1 = [Interactions objectForKey:@"interactions"];
                NSArray *publications;
                for (int i=0; i<[Interactions1 count];i++)
                {
                    
                    
                    NSDictionary *InteractionsData =  [Interactions1 objectAtIndex:i];
                    
                    NSArray * interactions = [InteractionsData objectForKey:@"interactingGenes"];
                 //   if ([interactions])
                    NSDictionary *interactiongenes = [interactions objectAtIndex:0];
                    publications = [interactiongenes objectForKey:@"publications"];
                    
                }  
                
                }else
                    {
                        UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
                        [dialog setDelegate:self];
                        [dialog setTitle:@"Interaction details not found"];
                        //[dialog setMessage:@"No match found,please try another query."];
                        [dialog addButtonWithTitle:@"OK"];
                        [dialog show];	
                        [dialog release];
                    }
                }else
            {
                UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
                [dialog setDelegate:self];
                [dialog setTitle:@"Interaction details not found"];
                //[dialog setMessage:@"No match found,please try another query."];
                [dialog addButtonWithTitle:@"OK"];
                [dialog show];	
                [dialog release];
            }
                    //------
                
        }
	}
	// now we are sure the download is complete
	@catch (NSException *e) 
	{
		NSLog(@"%@",[e description]);
	}
	
}

-(void) getResultsAndInsert:(NSDictionary *)resultSet
{
	if ([activityIndView isAnimating]) 
		[activityIndView stopAnimating];
	
	
	NSError *error;
	
	NSMutableDictionary *allPublItem = [resultSet valueForKeyPath:@"publication"];
    
	NSArray *allValues = [resultSet allValues];
	NSArray *allKeys = [resultSet allKeys];
	for (int i=0; i<[allValues count]; i++) 
	{
		if ([[allValues objectAtIndex:i] isEqual:[NSNull null] ]) 
			[resultSet setValue:@"No Value" forKey:[allKeys objectAtIndex:i]];
	}
	
	@try
	{	
        
        //-------
        NSArray *layOuts =  [resultSet objectForKey:@"results"]; 
        if ([layOuts count]!=0) {
            
            
            
            NSArray *Interactions = [layOuts objectAtIndex:0];
            NSArray *Interactions1 = [Interactions objectForKey:@"interactions"];
            
            for (int i=0; i<[Interactions1 count];i++)
            {
                
                NSDictionary *InteractionsData =  [Interactions1 objectAtIndex:i];
                
                NSArray * interactions = [InteractionsData objectForKey:@"interactingGenes"];
                NSDictionary *interactiongenes = [interactions objectAtIndex:0];
                
                
                NSDictionary *Experiment = [InteractionsData objectForKey:@"experiment"];
                NSDictionary *publication = [Experiment objectForKey:@"publication"];
                NSString *citation = [publication objectForKey:@"citation"];
                NSString *pubID = [publication objectForKey:@"pubMedId"];
                
                
                
                NSString *gene = [interactiongenes objectForKey:@"symbol"];
                if (gene == (id)[NSNull null] || gene.length == 0 ) gene = @"";
                
                NSMutableDictionary *tmpInterDict = [[NSMutableDictionary alloc] init];
                
                [tmpInterDict setValue:[InteractionsData objectForKey:@"experimentType"] forKey:@"experimentType"];//
                [tmpInterDict setValue:[InteractionsData objectForKey:@"role"] forKey:@"action"];//
                [tmpInterDict setValue:[interactiongenes objectForKey:@"secondaryIdentifier"] forKey:@"featureName"];//
                [tmpInterDict setValue:gene forKey:@"geneName"];
                
                [tmpInterDict setValue:[InteractionsData objectForKey:@"interactionType"] forKey:@"featureType"];//
                [tmpInterDict setValue:[interactiongenes objectForKey:@"headline"] forKey:@"intDescription"];
                [tmpInterDict setValue:[InteractionsData objectForKey:@"role"] forKey:@"action"];
                [tmpInterDict setValue:citation forKey:@"citation"];
                [tmpInterDict setValue:pubID forKey:@"pubMedId"];
                
                
                [tmpInterDict release];
                
                
                
                
            }  
            
        }else
        {
            UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
            [dialog setDelegate:self];
            [dialog setTitle:@"Data not found"];
            //[dialog setMessage:@"No match found,please try another query."];
            [dialog addButtonWithTitle:@"OK"];
            [dialog show];	
            [dialog release];
        }

        //------
        
		NSManagedObjectContext *interactionMOC = [NSEntityDescription insertNewObjectForEntityForName:@"Interactions" inManagedObjectContext:managedObjectContext];
		[interactionMOC setValue:[resultSet objectForKey:@"description"] forKey:@"intDescription"];
		[interactionMOC setValue:[resultSet objectForKey:@"experimentType"] forKey:@"experimentType"];
		[interactionMOC setValue:[resultSet objectForKey:@"interactingGeneAction"] forKey:@"action"];
		[interactionMOC setValue:[resultSet objectForKey:@"interactingGeneFeatureName"] forKey:@"featureName"];
		[interactionMOC setValue:[resultSet objectForKey:@"interactingGeneName"] forKey:@"geneName"];	
		[interactionMOC setValue:[resultSet objectForKey:@"interactionType"] forKey:@"featureType"];
		[interactionMOC setValue:[resultSet objectForKey:@"source"] forKey:@"source"];
		[interactionMOC setValue:[allPublItem objectForKey:@"citation"] forKey:@"intReferences"];
		[interactionMOC setValue:selectedFeature forKey:@"intertofeat"];
        
		
		NSMutableSet *interactionsSet = [NSMutableSet set];
		[interactionsSet addObject:interactionMOC];
		[selectedFeature addInteraction:interactionsSet];
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
		
		UIInterfaceOrientation orientation = self.interfaceOrientation;
		
		NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
		if (textRange.location != NSNotFound) 
		{
			if(orientation == UIInterfaceOrientationLandscapeLeft || 
			   orientation == UIInterfaceOrientationLandscapeRight) 
			{
				[contentView setFrame:CGRectMake(128, 10, 768, 450)];
				contentView.layer.borderWidth = 1;
				contentView.layer.cornerRadius = 5;
				contentView.layer.borderColor = [[UIColor blackColor] CGColor];
                
			}
			else			
			{
				[contentView setFrame:CGRectMake(10, 10, 748, 450)];
				contentView.layer.borderWidth = 1;
				contentView.layer.cornerRadius = 5;
				contentView.layer.borderColor = [[UIColor blackColor] CGColor];
				
			}
			
		
            [self setLabelWidthFor:geneNameLabel newWidth:500];
            [self setLabelWidthFor:featNameLabel newWidth:500];
            [self setLabelWidthFor:expTypeLabel newWidth:500];
            [self setLabelWidthFor:featTypeLabel newWidth:500];
            [self setLabelWidthFor:actionLabel newWidth:500];
            [self setLabelWidthFor:sourceLabel newWidth:500];
            
            [self setLabelWidthFor:intDescriptionLabel newWidth:500];
            [self setLabelWidthFor:referencesLabel newWidth:500];
            
                   
            actionLabel.text = [resultSet objectForKey:@"interactingGeneAction"];
            [actionLabel sizeToFit];
            expTypeLabel.text = [resultSet objectForKey:@"experimentType"];
            [expTypeLabel sizeToFit];
            featNameLabel.text = [resultSet objectForKey:@"interactingGeneFeatureName"];
            [featNameLabel sizeToFit];
            featTypeLabel.text = [resultSet objectForKey:@"interactionType"];
            [featTypeLabel sizeToFit];
            geneNameLabel.text = [resultSet objectForKey:@"interactingGeneName"];		
            [geneNameLabel sizeToFit];
            sourceLabel.text = [resultSet objectForKey:@"source"];
            [sourceLabel sizeToFit];
            
            [self setViewYOriginFor:featNameTitle previousView:geneNameLabel];
            [self setViewYOriginFor:featNameLabel previousView:geneNameLabel];
            
            [self setViewYOriginFor:expTypeTitle previousView:featNameLabel];
            [self setViewYOriginFor:expTypeLabel previousView:featNameLabel];
            
            [self setViewYOriginFor:featTypeTitle previousView:expTypeLabel];
            [self setViewYOriginFor:featTypeLabel previousView:expTypeLabel];
            
            [self setViewYOriginFor:actionTitle previousView:featTypeLabel];
            [self setViewYOriginFor:actionLabel previousView:featTypeLabel];
            
            [self setViewYOriginFor:sourceTitle previousView:actionLabel];
            [self setViewYOriginFor:sourceLabel previousView:actionLabel];
            
            
            [self setViewYOriginFor:intDescriptionTitle previousView:sourceLabel];
            [self setViewYOriginFor:intDescriptionLabel previousView:sourceLabel];
            
            intDescriptionLabel.text = [resultSet objectForKey:@"description"];
            [self setLabelSizeFor:intDescriptionLabel labelText:intDescriptionLabel.text];
            [intDescriptionLabel sizeToFit];
            referencesLabel.text = [allPublItem objectForKey:@"citation"];
            [self setLabelSizeFor:referencesLabel labelText:referencesLabel.text];
            [referencesLabel sizeToFit];
            
             
            
            [self setViewYOriginFor:referencesLabel previousView:intDescriptionLabel];
            
            [self setViewYOriginFor:referencesTitle previousView:intDescriptionLabel];
       			
			
		}
		else
		{
			if(orientation == UIInterfaceOrientationLandscapeLeft || 
			   orientation == UIInterfaceOrientationLandscapeRight) 
			{
                
                [self setLabelWidthFor:geneNameLabel newWidth:330];
                [self setLabelWidthFor:featNameLabel newWidth:330];
                [self setLabelWidthFor:expTypeLabel newWidth:330];
                [self setLabelWidthFor:featTypeLabel newWidth:330];
                [self setLabelWidthFor:actionLabel newWidth:330];
                [self setLabelWidthFor:sourceLabel newWidth:330];
                
                [self setLabelWidthFor:intDescriptionLabel newWidth:330];
                [self setLabelWidthFor:referencesLabel newWidth:330];
                
                           
			}
			else			
			{
                               
                [self setLabelWidthFor:geneNameLabel newWidth:180];
                [self setLabelWidthFor:featNameLabel newWidth:180];
                [self setLabelWidthFor:expTypeLabel newWidth:180];
                [self setLabelWidthFor:featTypeLabel newWidth:180];
                [self setLabelWidthFor:actionLabel newWidth:180];
                [self setLabelWidthFor:sourceLabel newWidth:180];
                
                [self setLabelWidthFor:intDescriptionLabel newWidth:180];
				[self setLabelWidthFor:referencesLabel newWidth:180];
				
			}
			
        
			actionLabel.text = [resultSet objectForKey:@"interactingGeneAction"];
			expTypeLabel.text = [resultSet objectForKey:@"experimentType"];
			featNameLabel.text = [resultSet objectForKey:@"interactingGeneFeatureName"];
			featTypeLabel.text = [resultSet objectForKey:@"interactionType"];
			geneNameLabel.text = [resultSet objectForKey:@"interactingGeneName"];		
			sourceLabel.text = [resultSet objectForKey:@"source"];
                        
            
            [self setViewYOriginFor:featNameTitle previousView:geneNameLabel];
            [self setViewYOriginFor:featNameLabel previousView:geneNameLabel];
            
            [self setViewYOriginFor:expTypeTitle previousView:featNameLabel];
            [self setViewYOriginFor:expTypeLabel previousView:featNameLabel];
            
            [self setViewYOriginFor:featTypeTitle previousView:expTypeLabel];
            [self setViewYOriginFor:featTypeLabel previousView:expTypeLabel];
            
            [self setViewYOriginFor:actionTitle previousView:featTypeLabel];
            [self setViewYOriginFor:actionLabel previousView:featTypeLabel];
            
            [self setViewYOriginFor:sourceTitle previousView:actionLabel];
            [self setViewYOriginFor:sourceLabel previousView:actionLabel];
            
            
            [self setViewYOriginFor:intDescriptionTitle previousView:sourceLabel];
            [self setViewYOriginFor:intDescriptionLabel previousView:sourceLabel];
            
            intDescriptionLabel.text = [resultSet objectForKey:@"description"];
            [self setLabelSizeFor:intDescriptionLabel labelText:intDescriptionLabel.text];
            [intDescriptionLabel sizeToFit];
            
            
            referencesLabel.text = [allPublItem objectForKey:@"citation"];
            
            [self setViewYOriginFor:referencesLabel previousView:intDescriptionLabel];
            
            [self setViewYOriginFor:referencesTitle previousView:intDescriptionLabel];
            
            [self setLabelSizeFor:referencesLabel labelText:referencesLabel.text];
            [referencesLabel sizeToFit];

                      
			
		}
		
				
	}
	@catch (NSException * e)
	{
		NSLog(@"%@",[e description]);
	}
	
}


-(void) createProgressionAlertWithMessage:(NSString *)message
{
	if (progAlertView != nil) 
		progAlertView = nil;
	
	if (activityIndView != nil) 
		activityIndView = nil;
	
	progAlertView = [[UIAlertView alloc] initWithTitle: message
											   message: @"Please wait..."
											  delegate: self
									 cancelButtonTitle:  nil
									 otherButtonTitles: nil];
	
	activityIndView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndView.frame = CGRectMake(139.0f-18.0f, 80.0f, 37.0f, 37.0f);
	
	[progAlertView addSubview:activityIndView];
	[activityIndView startAnimating];
	
	[progAlertView show];
	[progAlertView release];
}


#pragma mark -
#pragma mark Action Method

//Function called when email icon is pressed and mail is composed with feature details
-(IBAction)pushedEmailButton:(id)sender 
{
	
    NSString *featName = [staticFunctionClass getGeneName];
	NSArray *display = [featName componentsSeparatedByString:@"/"];
	NSString *sysName = [display objectAtIndex:1];
	NSString *SubjectLine = [NSString stringWithFormat:@"%@, Interaction Details", featName];
    
    
    [staticFunctionClass setSubjectLine:SubjectLine];
    NSMutableArray *arrRec = [[NSMutableArray alloc] init];
    
    EmailViewController *emailView = [[EmailViewController alloc]initWithNibName:@"EmailViewController" bundle:[NSBundle mainBundle]];
    
    NSString *eMailBody = @"";
	
	eMailBody = [eMailBody stringByAppendingFormat:@"<div><a href=\"http://www.yeastgenome.org/cgi-bin/interactions.pl?locus=%@\">%@ Physical and Genetic Interactions</a></div>", sysName, featName];
    
    eMailBody = [eMailBody stringByAppendingFormat:@"<table><tr><td><b>Gene Name:</b>%@<br><b>Feature Name:</b>%@<br><b>Experiment Type:</b>%@<br><br>Feature Type:</b>%@<br><b>Action:</b>%@<br><b>Source:</b>%@<br><b>Description:</b>%@<br><b>Reference:</b>%@</td></tr></table><br><br>", geneNameLabel.text, featNameLabel.text, expTypeLabel.text, featTypeLabel.text, actionLabel.text, sourceLabel.text, intDescriptionLabel.text, referencesLabel.text];
	
    [staticFunctionClass setMessageBody:eMailBody];

 //   NSLog(@"FeatInteractionDetails: %@", eMailBody);
	
    [arrRec release];
    
    [self.navigationController pushViewController:emailView animated:YES];
	
}

//Called when reference text is clicked and respective url is opened in webview
-(void)pushedReferenceButton:(id)sender{

    
    // Navigation logic may go here. Create and push another view controller.
	
    @try 
	{
        NSDictionary *interFeatureName = [staticFunctionClass getInteractionDict];
        NSString *urlAddress =[NSString stringWithFormat:@"http://www.yeastgenome.org/cgi-bin/reference/reference.pl?pmid=%@",[interFeatureName objectForKey:@"pubMedId"]];
        
        [staticFunctionClass setBrowseImg:urlAddress];
        
        BrowseImgView *browseImgVC = [[BrowseImgView alloc] initWithNibName:@"BrowseImgView_iPhone" bundle:[NSBundle mainBundle]];
        
        browseImgVC.title = @"Reference"; 
        
        [self.navigationController pushViewController:browseImgVC animated:YES];
        
        [browseImgVC release];

        
       	}
	@catch (NSException * e) {
		NSLog(@"%@",[e description]);
	}
	

    


}

#pragma mark -
#pragma mark Actionsheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	@try
	{
		NSString *featName = [staticFunctionClass getGeneName];
		NSString *SubjectLine = [NSString stringWithFormat:@"%@, Interaction Details", featName];
		
		
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
	@catch (NSException * e) {
		
		NSLog(@"%@", [e description]);
	}
}

#pragma mark -
#pragma mark Memory Management
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


- (void)dealloc 
{
    [super dealloc];
}


@end
