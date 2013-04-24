//
//  FeatPhenoTypeDetails.m
//  SGD_2
//
//  Created by Vivek Bhutra on 14/06/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*
 Class to implement the Phenotype details of Feature.
 */
#import "FeatPhenoTypeDetails.h"
#import "EmailViewController.h"
#import "staticFunctionClass.h"
#import "SBJSON.h"
#import "webServiceHelper.h"
#import "Phenotypes.h"
#import "Reachability.h"

@implementation FeatPhenoTypeDetails

@synthesize managedObjectContext;
@synthesize progAlertView;
@synthesize activityIndView;
@synthesize selectedFeatures;

@synthesize onlyReference;

NSString *pubMedID;


#pragma mark -
#pragma mark Orientation Support
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

//IOS6
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
		        
        [self setLabelSizeFor:observableTitle detailview:observableLabel];
        [self setLabelSizeFor:mutantInfoTitle detailview:mutantInfoLabel];
        [self setLabelSizeFor:expTypeTitle detailview:expTypeLabel];
        [self setLabelSizeFor:qualifierTitle detailview:qualifierLabel];
        [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
        [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesLabel];
        
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
            [self setLabelWidthFor:observableLabel newWidth:320];
            [self setLabelWidthFor:expTypeLabel newWidth:320];
            [self setLabelWidthFor:mutantInfoLabel newWidth:320];
            [self setLabelWidthFor:qualifierLabel newWidth:320];
            [self setLabelWidthFor:referencesLabel newWidth:320];
            [self setButtonWidthFor:referenceBtn newWidth:450];
        }
        else			
        {            
            [self setLabelWidthFor:observableLabel newWidth:180];
            [self setLabelWidthFor:expTypeLabel newWidth:180];
            [self setLabelWidthFor:mutantInfoLabel newWidth:180];
            [self setLabelWidthFor:qualifierLabel newWidth:180];
            [self setLabelWidthFor:referencesLabel newWidth:165];
            [self setButtonWidthFor:referenceBtn newWidth:308];
        }
        
        [self setViewYOriginFor:mutantInfoTitle previousView:observableLabel];
        [self setViewYOriginFor:mutantInfoLabel previousView:observableLabel];
        
        if (mutantInfoLabel.text == @"") {
            [self setViewYOriginFor:expTypeTitle previousView:observableLabel];
            [self setViewYOriginFor:expTypeLabel previousView:observableLabel];            
        }
        else {
            [self setViewYOriginFor:expTypeTitle previousView:mutantInfoLabel];
            [self setViewYOriginFor:expTypeLabel previousView:mutantInfoLabel];
        }
        
        
        [self setViewYOriginFor:qualifierTitle previousView:expTypeLabel];
        
        qualifierLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        [self setLabelSizeFor:qualifierLabel labelText:qualifierLabel.text];
        [self setViewYOriginFor:qualifierLabel previousView:expTypeLabel];
        [qualifierLabel sizeToFit];
        
        [self setLabelSizeFor:referencesLabel labelText:referencesLabel.text];
        if (qualifierLabel.text == @"") {
            [self setViewYOriginFor:referencesTitle previousView:expTypeLabel];
            [self setViewYOriginFor:referencesLabel previousView:expTypeLabel];
            [self setViewYOriginFor:referenceBtn previousView:expTypeLabel];
        }
        else {
            [self setViewYOriginFor:referencesTitle previousView:qualifierLabel];
            [self setViewYOriginFor:referencesLabel previousView:qualifierLabel];            
            [self setViewYOriginFor:referenceBtn previousView:qualifierLabel];
        }
        referencesLabel.lineBreakMode = UILineBreakModeWordWrap;
        [referencesLabel sizeToFit];
        
        [self setLabelSizeFor:observableTitle detailview:observableLabel];
        [self setLabelSizeFor:mutantInfoTitle detailview:mutantInfoLabel];
        [self setLabelSizeFor:expTypeTitle detailview:expTypeLabel];
        [self setLabelSizeFor:qualifierTitle detailview:qualifierLabel];
        [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
        [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesLabel];
        
    
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
        
    }
}

#pragma mark -
#pragma mark View Life Cycle
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	UIInterfaceOrientation orientation = self.interfaceOrientation;
	
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
	{
        
        [self setLabelSizeFor:observableTitle detailview:observableLabel];
        [self setLabelSizeFor:mutantInfoTitle detailview:mutantInfoLabel];
        [self setLabelSizeFor:expTypeTitle detailview:expTypeLabel];
        [self setLabelSizeFor:qualifierTitle detailview:qualifierLabel];
        [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
        [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesLabel];
        
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
            [self setLabelWidthFor:observableLabel newWidth:320];
            [self setLabelWidthFor:expTypeLabel newWidth:320];
            [self setLabelWidthFor:mutantInfoLabel newWidth:320];
            [self setLabelWidthFor:qualifierLabel newWidth:320];
            [self setLabelWidthFor:referencesLabel newWidth:320];
            [self setButtonWidthFor:referenceBtn newWidth:450];
        }
        else			
        {
            [self setLabelWidthFor:observableLabel newWidth:180];
            [self setLabelWidthFor:expTypeLabel newWidth:180];
            [self setLabelWidthFor:mutantInfoLabel newWidth:180];
            [self setLabelWidthFor:qualifierLabel newWidth:180];
            [self setLabelWidthFor:referencesLabel newWidth:165];
            [self setButtonWidthFor:referenceBtn newWidth:308];
        }
        
        
        [self setViewYOriginFor:mutantInfoTitle previousView:observableLabel];
        [self setViewYOriginFor:mutantInfoLabel previousView:observableLabel];
        
        if (mutantInfoLabel.text == @"") {
            [self setViewYOriginFor:expTypeTitle previousView:observableLabel];
            [self setViewYOriginFor:expTypeLabel previousView:observableLabel];            
        }
        else {
            [self setViewYOriginFor:expTypeTitle previousView:mutantInfoLabel];
            [self setViewYOriginFor:expTypeLabel previousView:mutantInfoLabel];
        }
        
        
        
        [self setViewYOriginFor:qualifierTitle previousView:expTypeLabel];
        
        qualifierLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        [self setLabelSizeFor:qualifierLabel labelText:qualifierLabel.text];
        [self setViewYOriginFor:qualifierLabel previousView:expTypeLabel];
        [qualifierLabel sizeToFit];
        
        [self setLabelSizeFor:referencesLabel labelText:referencesLabel.text];
        
        if (qualifierLabel.text == @"") {
            [self setViewYOriginFor:referencesTitle previousView:expTypeLabel];
            [self setViewYOriginFor:referencesLabel previousView:expTypeLabel];
            [self setViewYOriginFor:referenceBtn previousView:expTypeLabel];
        }
        else {
            [self setViewYOriginFor:referencesTitle previousView:qualifierLabel];
            [self setViewYOriginFor:referencesLabel previousView:qualifierLabel];     
            [self setViewYOriginFor:referenceBtn previousView:qualifierLabel];
        }
        referencesLabel.lineBreakMode = UILineBreakModeWordWrap;
        [referencesLabel sizeToFit];
        
        [self setLabelSizeFor:observableTitle detailview:observableLabel];
        [self setLabelSizeFor:mutantInfoTitle detailview:mutantInfoLabel];
        [self setLabelSizeFor:expTypeTitle detailview:expTypeLabel];
        [self setLabelSizeFor:qualifierTitle detailview:qualifierLabel];
        [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
        [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesLabel];
        
        
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
          
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    //NSLog(@"here..");
    [super viewDidLoad];
	
    onlyReference = NO;
    
    //---------
    [lblTitle setHidden:YES];

    [observableTitle setHidden:YES];
    [expTypeTitle setHidden:YES];
    [qualifierTitle setHidden:YES];
    [mutantInfoTitle setHidden:YES];
    [referencesTitle setHidden:YES];
    [referenceBtn setHidden:YES];
    [indicator1 setHidden:YES];
    
    //---------
    
	CGRect frame = self.view.frame; //frame of scroll view
	frame.size.height = 400;
	frame.origin.y = 20;
	self.view.frame = frame;
	
	frame = contentView.frame;
	[(UIScrollView*)self.view setContentSize:frame.size];
	
	
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
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSString *featName = [staticFunctionClass getGeneName];
	NSDictionary *dict = [staticFunctionClass getPhenoDict];
	NSArray *display = [featName componentsSeparatedByString: @"/"];
	
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text= [NSString stringWithFormat:@"%@ %@", featName, @"Phenotype Details"];
    tlabel.textColor=[UIColor blackColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    
    
    lblTitle.text = featName;
    
	if (display.count > 1) {
		featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:1]];
	} else {
		featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
	}
	
	NSPredicate *fetchByFeatureName = [NSPredicate predicateWithFormat:@"featureName = %@", featName];
	
	[request setPredicate:fetchByFeatureName];
	
	NSError *error;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:request error:&error];
	
	selectedFeatures = [fetchedObjects objectAtIndex:0];
	
	[request release];
    
    
    
    observableTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]];
    mutantInfoTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]];
    expTypeTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]];
    qualifierTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]];
    referencesTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]];
	
	
	Reachability *rchbility = [[Reachability reachabilityWithHostName: @"yeastgenome.org"] retain];;
	NetworkStatus remoteHostStatus = [rchbility currentReachabilityStatus];
	[rchbility release];
	
	NSSet *phenotypeSet = selectedFeatures.phenotype;
    
	if ([phenotypeSet count] != 0)
	{
		for (Phenotypes *phenotypeObj in [phenotypeSet allObjects]) 
		{
            
			NSString *strChemical = [dict objectForKey:@"Chemical"];
			
            if ([strChemical length] != 0) 
			{
				strChemical = [NSString stringWithFormat:@"(%@)",strChemical];
			}
			else 
            {
				strChemical = @"";
			}
            
			NSString *tmpStr = [NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"Qualifier"], strChemical];
			
			if ([[phenotypeObj observable] isEqualToString:[dict objectForKey:@"Observable"]] && 
				[[phenotypeObj phenoQualifier] isEqualToString:tmpStr] && 
				[[phenotypeObj phenoReferences] isEqualToString:[dict objectForKey:@"Citation"]] && 
				[[phenotypeObj phenoExpType] isEqualToString:[dict objectForKey:@"ExpType"]]) 
			{
                
                //---------
                [lblTitle setHidden:NO];
                [observableTitle setHidden:NO];
                [expTypeTitle setHidden:NO];
                [qualifierTitle setHidden:NO];
                [mutantInfoTitle setHidden:NO];
                [referencesTitle setHidden:NO];
                [referenceBtn setHidden:NO];
                
                [indicator1 setHidden:NO];

                //--------
                
                pubMedID = [phenotypeObj pubMedId];
                observableLabel.text = [phenotypeObj observable];
				[observableLabel sizeToFit];
                
                if ([[phenotypeObj phenoQualifier] isEqualToString:@"none "])
                    mutantInfoLabel.text = @"";
                else
                    mutantInfoLabel.text = [phenotypeObj phenoQualifier];
                
                [mutantInfoLabel sizeToFit];
				[self setViewYOriginFor:mutantInfoLabel previousView:observableLabel];
				[self setViewYOriginFor:mutantInfoTitle previousView:observableLabel];
                
				expTypeLabel.text = [phenotypeObj phenoExpType];
				[expTypeLabel sizeToFit];
                
                [self setViewYOriginFor:expTypeLabel previousView:mutantInfoLabel];
				[self setViewYOriginFor:expTypeTitle previousView:mutantInfoLabel];
                
                //if ([[phenotypeObj mutantinfo] isEqualToString:@"null"])
                //    qualifierLabel.text = @"";
                //else
                
                qualifierLabel.text = [phenotypeObj mutantinfo];
                
				qualifierLabel.lineBreakMode = UILineBreakModeWordWrap;
				[self setLabelSizeFor:qualifierLabel labelText:qualifierLabel.text];
				[qualifierLabel sizeToFit];
				[self setViewYOriginFor:qualifierLabel previousView:expTypeLabel];
				[self setViewYOriginFor:qualifierTitle previousView:expTypeLabel];
				
				referencesLabel.text = [phenotypeObj phenoReferences];
				referencesLabel.lineBreakMode = UILineBreakModeWordWrap;
				[self setLabelSizeFor:referencesLabel labelText:referencesLabel.text];
				[referencesLabel sizeToFit];
				
				[self setViewYOriginFor:referencesLabel previousView:qualifierLabel];
				[self setViewYOriginFor:referencesTitle previousView:qualifierLabel];
                [self setViewYOriginFor:referenceBtn previousView:qualifierLabel];
                
			}
		}
        
		if ([observableLabel.text isEqualToString:@""]) 
		{ 
            
			if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
			{
				//CALLING WEB-SERVICE HELPER CLASS OBJECT FOR CHECKING CONNECTIVITY TO SGD SERVER
				[self createProgressionAlertWithMessage:@"Retrieving from SGD"];
				
				NSString *str;
                
				if ([[dict objectForKey:@"Chemical"] length] != 0) {
                    
                    
                    NSString *strChemical = [[dict objectForKey:@"Chemical"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                    NSString *strQualifier = [[dict objectForKey:@"Qualifier"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                    NSString *strObservable = [[dict objectForKey:@"Observable"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                    
                    
                    str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.phenotypes.observable+Gene.phenotypes.qualifier+Gene.phenotypes.chemical+Gene.phenotypes.experimentType+Gene.phenotypes.mutantType+Gene.phenotypes.publications.pubMedId+Gene.phenotypes.publications.citation\"+sortOrder=\"Gene.phenotypes.observable+asc\"+constraintLogic=\"A+and+B+and+C+and+D\"><constraint+path=\"Gene.secondaryIdentifier\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.observable\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.qualifier\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.chemical\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName, strObservable, strQualifier, strChemical];
                    
                }
				else if ([[dict objectForKey:@"Qualifier"] length] != 0)
                {
                    NSString *strQualifier = [[dict objectForKey:@"Qualifier"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                    NSString *strObservable = [[dict objectForKey:@"Observable"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                    
					str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.phenotypes.observable+Gene.phenotypes.qualifier+Gene.phenotypes.chemical+Gene.phenotypes.experimentType+Gene.phenotypes.mutantType+Gene.phenotypes.publications.pubMedId+Gene.phenotypes.publications.citation\"+sortOrder=\"Gene.phenotypes.observable+asc\"+constraintLogic=\"A+and+B+and+C\"><constraint+path=\"Gene.secondaryIdentifier\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.observable\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.qualifier\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName, strObservable, strQualifier];
                }
                else
                {
                    NSString *strExpType = [[dict objectForKey:@"ExpType"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                    NSString *strObservable = [[dict objectForKey:@"Observable"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                    
                    str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.phenotypes.observable+Gene.phenotypes.qualifier+Gene.phenotypes.chemical+Gene.phenotypes.experimentType+Gene.phenotypes.mutantType+Gene.phenotypes.publications.pubMedId+Gene.phenotypes.publications.citation\"+sortOrder=\"Gene.phenotypes.observable+asc\"+constraintLogic=\"A+and+B+and+C\"><constraint+path=\"Gene.secondaryIdentifier\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.observable\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.experimentType\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName, strObservable, strExpType];
                }
                
				
				[self webServiceCall:str];
			}
			
			//IF NOT REACHABLE THEN GIVING ALERT MESSAGE OF CONNECTION NOT AVAILABLE
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
	}
	else
	{
        
		if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
		{
			//CALLING WEB-SERVICE HELPER CLASS OBJECT FOR CHECKING CONNECTIVITY TO SGD SERVER
			[self createProgressionAlertWithMessage:@"Retrieving from SGD"];
			
			NSString *str;
            
			if ([[dict objectForKey:@"Chemical"] length] != 0) {
                
                
                NSString *strChemical = [[dict objectForKey:@"Chemical"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                NSString *strQualifier = [[dict objectForKey:@"Qualifier"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                NSString *strObservable = [[dict objectForKey:@"Observable"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                
                
                str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.phenotypes.observable+Gene.phenotypes.qualifier+Gene.phenotypes.chemical+Gene.phenotypes.experimentType+Gene.phenotypes.mutantType+Gene.phenotypes.publications.pubMedId+Gene.phenotypes.publications.citation\"+sortOrder=\"Gene.phenotypes.observable+asc\"+constraintLogic=\"A+and+B+and+C+and+D\"><constraint+path=\"Gene.secondaryIdentifier\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.observable\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.qualifier\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.chemical\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName, strObservable, strQualifier, strChemical];
                
            }
            else if ([[dict objectForKey:@"Qualifier"] length] != 0)
            {
                NSString *strQualifier = [[dict objectForKey:@"Qualifier"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                NSString *strObservable = [[dict objectForKey:@"Observable"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                
                str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.phenotypes.observable+Gene.phenotypes.qualifier+Gene.phenotypes.chemical+Gene.phenotypes.experimentType+Gene.phenotypes.mutantType+Gene.phenotypes.publications.pubMedId+Gene.phenotypes.publications.citation\"+sortOrder=\"Gene.phenotypes.observable+asc\"+constraintLogic=\"A+and+B+and+C\"><constraint+path=\"Gene.secondaryIdentifier\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.observable\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.qualifier\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName, strObservable, strQualifier];
            }
            else
            {
                NSString *strExpType = [[dict objectForKey:@"ExpType"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                NSString *strObservable = [[dict objectForKey:@"Observable"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                
                str = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/service/query/results?query=<query+name=\"\"+model=\"genomic\"+view=\"Gene.phenotypes.observable+Gene.phenotypes.qualifier+Gene.phenotypes.chemical+Gene.phenotypes.experimentType+Gene.phenotypes.mutantType+Gene.phenotypes.publications.pubMedId+Gene.phenotypes.publications.citation\"+sortOrder=\"Gene.phenotypes.observable+asc\"+constraintLogic=\"A+and+B+and+C\"><constraint+path=\"Gene.secondaryIdentifier\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.observable\"+op=\"=\"+value=\"%@\"/><constraint+path=\"Gene.phenotypes.experimentType\"+op=\"=\"+value=\"%@\"/></query>&format=jsonobjects&source=YeastGenomeapp",featName, strObservable, strExpType];
            }
            
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
			return;
		}
	}
	
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark Label Method

- (void)setViewYOriginFor: (UIView *)viewToSet previousView:(UIView *)previousView {
	CGRect newFrame = viewToSet.frame;
	int newYStart = previousView.frame.size.height + previousView.frame.origin.y+5;
	int xStart = viewToSet.frame.origin.x;
	newFrame.origin = CGPointMake(xStart,newYStart);
	viewToSet.frame = newFrame;
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

- (void)setLabelSizeFor: (UILabel *)labelToSet detailview:(UILabel *)detailview
{    
    CGRect newFrame = labelToSet.frame;
    int newHeight = detailview.frame.size.height;
    newFrame.size = CGSizeMake(labelToSet.frame.size.width, newHeight);
    labelToSet.frame = newFrame;
}
-(void) setLabelWidthFor: (UIView *)labelToSet newWidth: (int) newWidth
{
	CGRect newFrame = labelToSet.frame;
	int oldHeight = labelToSet.frame.size.height;
	newFrame.size = CGSizeMake(newWidth, oldHeight);
	labelToSet.frame = newFrame;
	[labelToSet sizeToFit];
}
-(void) setButtonWidthFor: (UIView *)labelToSet newWidth: (int) newWidth
{
	CGRect newFrame = labelToSet.frame;
	int oldHeight = labelToSet.frame.size.height;
	newFrame.size = CGSizeMake(newWidth, oldHeight);
	labelToSet.frame = newFrame;
}


#pragma mark -
#pragma mark Web Service Call 

- (void)webServiceCall:(NSString *)webserviceName
{
    //NSLog(@"webservice call");
	@try
	{
		webServiceHelper *webhelper = [[webServiceHelper alloc]init];
		[webhelper startConnectionwithoutEncoding:webserviceName];
		[webhelper setDelegate:self];
		
	}
	@catch (NSException *e) {
		NSLog(@"%@",[e description]);
	}
}

// implement the download delegate method

- (void)finishedDownloading:(NSString *)strJSONResponse
{
    //NSLog(@"Result is::%@",strJSONResponse);
	@try 
	{
        
		if ([activityIndView isAnimating]) 
			[activityIndView stopAnimating];
		
		@synchronized(self)
		{
			if ([strJSONResponse length] != 0) 
			{
				strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\n" withString:@""];
				strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\r" withString:@""];
				strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                strJSONResponse = [strJSONResponse stringByReplacingOccurrencesOfString:@"\\\"" withString:@""];
				
				NSRange   arange = [strJSONResponse rangeOfString:@"phenotypes\":["];
				if (arange.length != 0) 
				{
					NSString *strtest = [strJSONResponse substringFromIndex:arange.location+13];
					NSRange   brange = [strtest rangeOfString:@"],\"objectId"];
					NSString *strAllGene = [[NSString alloc] initWithString:[strtest substringToIndex:brange.location]];
					
					if ([strAllGene length] != 0)
					{
						NSArray *jsonObjects = [strAllGene componentsSeparatedByString:@"},{"];
						
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
								[self getResultsAndInsert:dictionary];
                            }
						}
					}
					else
					{
						UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
						[dialog setDelegate:self];
						[dialog setTitle:@"Phenotype details not found"];
						//[dialog setMessage:@"No match found,please try another query."];
						[dialog addButtonWithTitle:@"OK"];
						[dialog show];	
						[dialog release];
					}
				}
				else 
                {
					UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
					[dialog setDelegate:self];
					[dialog setTitle:@"Phenotype details not found"];
					//[dialog setMessage:@"No match found,please try another query."];
					[dialog addButtonWithTitle:@"OK"];
					[dialog show];	
					[dialog release];
				}
                
			}
			else
			{
				UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
				[dialog setDelegate:self];
				[dialog setTitle:@"Phenotype details not found"];
				//[dialog setMessage:@"No match found,please try another query."];
				[dialog addButtonWithTitle:@"OK"];
				[dialog show];	
				[dialog release];
			}
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
	
	NSArray *allValues = [resultSet allValues];
	NSArray *allKeys = [resultSet allKeys];
	for (int i=0; i<[allValues count]; i++) 
	{
		if ([[allValues objectAtIndex:i] isEqual:[NSNull null] ]) 
			[resultSet setValue:@"" forKey:[allKeys objectAtIndex:i]];
	}
	
	
	NSArray *allPublItem = [resultSet valueForKeyPath:@"publications"];
    
	NSString *strChemical = [resultSet objectForKey:@"chemical"];
	if ([strChemical length] != 0) 
	{
		strChemical = [NSString stringWithFormat:@"(%@)",strChemical];
	}
	else {
		strChemical = @"";
	}
	NSString *qualifierStr = [NSString stringWithFormat:@"%@ %@",[resultSet objectForKey:@"qualifier"],strChemical];
	
    
	
	@try
	{	
		NSManagedObjectContext *phenotypeMOC = [NSEntityDescription insertNewObjectForEntityForName:@"Phenotypes" inManagedObjectContext:managedObjectContext];
		[phenotypeMOC setValue:[resultSet objectForKey:@"experimentType"] forKey:@"phenoExpType"];//
		[phenotypeMOC setValue:[resultSet objectForKey:@"mutantType"] forKey:@"mutantinfo"];//
		[phenotypeMOC setValue:[resultSet objectForKey:@"observable"] forKey:@"observable"];//
		[phenotypeMOC setValue:qualifierStr forKey:@"phenoQualifier"];//
		[phenotypeMOC setValue:[[allPublItem objectAtIndex:0] objectForKey:@"citation"] forKey:@"phenoReferences"];
        //------
        [phenotypeMOC setValue:[[allPublItem objectAtIndex:0] objectForKey:@"pubMedId"] forKey:@"pubMedId"];
        //------
		[phenotypeMOC setValue:selectedFeatures forKey:@"phenotofeat"];
		        
		NSMutableSet *phenoTypeSet = [NSMutableSet set];
		[phenoTypeSet addObject:phenotypeMOC];
		[selectedFeatures addPhenotype:phenoTypeSet];
        
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
        
        [lblTitle setHidden:NO];
        [observableTitle setHidden:NO];
        [expTypeTitle setHidden:NO];
        [qualifierTitle setHidden:NO];
        [mutantInfoTitle setHidden:NO];
        [referencesTitle setHidden:NO];
        [referenceBtn setHidden:NO];
        [indicator1 setHidden:NO];
        //-------
        observableLabel.text = [resultSet objectForKey:@"observable"];
        [observableLabel sizeToFit];
        
        expTypeLabel.text = [resultSet objectForKey:@"experimentType"];
        [expTypeLabel sizeToFit];
        
        if ([qualifierStr isEqualToString:@"none "])
            mutantInfoLabel.text = @"";
        else
            mutantInfoLabel.text = qualifierStr;
        
        [mutantInfoLabel sizeToFit];
        
//        if ([[resultSet objectForKey:@"mutantType"] isEqualToString:@"null"])
//            qualifierLabel.text = @"";
//        else
        
        qualifierLabel.text = [resultSet objectForKey:@"mutantType"];
        
        [qualifierLabel sizeToFit];
        
        referencesLabel.text = [[allPublItem objectAtIndex:0] objectForKey:@"citation"];
        [referencesLabel sizeToFit];
        //-------  
        pubMedID = [[allPublItem objectAtIndex:0] objectForKey:@"pubMedId"];
        
        //---------
        UIInterfaceOrientation orientation = self.interfaceOrientation;
        
        NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
        if (textRange.location != NSNotFound) 
        {
                        
            [self setLabelWidthFor:observableLabel newWidth:500];
            [self setLabelWidthFor:expTypeLabel newWidth:500];
            [self setLabelWidthFor:mutantInfoLabel newWidth:500];
            [self setLabelWidthFor:qualifierLabel newWidth:500];
            [self setLabelWidthFor:referencesLabel newWidth:500];
            
            [self setViewYOriginFor:mutantInfoTitle previousView:observableLabel];
            [self setViewYOriginFor:mutantInfoLabel previousView:observableLabel];
            
            if (mutantInfoLabel.text == @"") {
                [self setViewYOriginFor:expTypeTitle previousView:observableLabel];
                [self setViewYOriginFor:expTypeLabel previousView:observableLabel];            
            }
            else {
                [self setViewYOriginFor:expTypeTitle previousView:mutantInfoLabel];
                [self setViewYOriginFor:expTypeLabel previousView:mutantInfoLabel];
            }
            
            [self setViewYOriginFor:qualifierTitle previousView:expTypeLabel];
            
            qualifierLabel.lineBreakMode = UILineBreakModeWordWrap;
            
            [self setLabelSizeFor:qualifierLabel labelText:qualifierLabel.text];
            [self setViewYOriginFor:qualifierLabel previousView:expTypeLabel];
            
            [qualifierLabel sizeToFit];
            
            [self setLabelSizeFor:referencesLabel labelText:referencesLabel.text];
            if (qualifierLabel.text == @"") {
                [self setViewYOriginFor:referencesTitle previousView:expTypeLabel];
                [self setViewYOriginFor:referencesLabel previousView:expTypeLabel];
                [self setViewYOriginFor:referenceBtn previousView:expTypeLabel];
            }
            else {
                [self setViewYOriginFor:referencesTitle previousView:qualifierLabel];
                [self setViewYOriginFor:referencesLabel previousView:qualifierLabel];       
                [self setViewYOriginFor:referenceBtn previousView:qualifierLabel];
            }
            referencesLabel.lineBreakMode = UILineBreakModeWordWrap;
            [referencesLabel sizeToFit];
            
            [self setLabelSizeFor:observableTitle detailview:observableLabel];
            [self setLabelSizeFor:mutantInfoTitle detailview:mutantInfoLabel];
            [self setLabelSizeFor:expTypeTitle detailview:expTypeLabel];
            [self setLabelSizeFor:qualifierTitle detailview:qualifierLabel];
            [self setLabelSizeFor:referencesTitle detailview:referencesLabel];    
            [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesLabel];
            
            float  f1 = referencesTitle.frame.origin.y+referencesTitle.frame.size.height+20;     

            if(orientation == UIInterfaceOrientationLandscapeLeft || 
               orientation == UIInterfaceOrientationLandscapeRight) 
            {
                [contentView setFrame:CGRectMake(128, 10, 768, f1)];
                contentView.layer.borderWidth = 1;
                contentView.layer.cornerRadius = 5;
                contentView.layer.borderColor = [[UIColor blackColor] CGColor];
                
                [self setLabelWidthFor:observableLabel newWidth:500];
                [self setLabelWidthFor:expTypeLabel newWidth:500];
                [self setLabelWidthFor:mutantInfoLabel newWidth:500];
                [self setLabelWidthFor:qualifierLabel newWidth:500];
                [self setLabelWidthFor:referencesLabel newWidth:500];
                
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
                
                [self setLabelWidthFor:observableLabel newWidth:320];
                [self setLabelWidthFor:expTypeLabel newWidth:320];
                [self setLabelWidthFor:mutantInfoLabel newWidth:320];
                [self setLabelWidthFor:qualifierLabel newWidth:320];
                [self setLabelWidthFor:referencesLabel newWidth:320];
                [self setButtonWidthFor:referenceBtn newWidth:450];
            }
            else			
            {
                
                [self setLabelWidthFor:observableLabel newWidth:180];
                [self setLabelWidthFor:expTypeLabel newWidth:180];
                [self setLabelWidthFor:mutantInfoLabel newWidth:180];
                [self setLabelWidthFor:qualifierLabel newWidth:180];
                [self setLabelWidthFor:referencesLabel newWidth:165];
                [self setButtonWidthFor:referenceBtn newWidth:308];
                
            }
            
            
            [self setViewYOriginFor:mutantInfoTitle previousView:observableLabel];
            [self setViewYOriginFor:mutantInfoLabel previousView:observableLabel];
            
            [self setViewYOriginFor:expTypeTitle previousView:mutantInfoLabel];
            [self setViewYOriginFor:expTypeLabel previousView:mutantInfoLabel];
            
            
            
            [self setViewYOriginFor:qualifierTitle previousView:expTypeLabel];
            
            qualifierLabel.lineBreakMode = UILineBreakModeWordWrap;
            
            [self setLabelSizeFor:qualifierLabel labelText:qualifierLabel.text];
            [self setViewYOriginFor:qualifierLabel previousView:expTypeLabel];
            [qualifierLabel sizeToFit];
            
            [self setLabelSizeFor:referencesLabel labelText:referencesLabel.text];
            [self setViewYOriginFor:referencesTitle previousView:qualifierLabel];
            [self setViewYOriginFor:referencesLabel previousView:qualifierLabel];
            
            [self setViewYOriginFor:referenceBtn previousView:qualifierLabel];
            referencesLabel.lineBreakMode = UILineBreakModeWordWrap;
            [referencesLabel sizeToFit];
            
            [self setLabelSizeFor:observableTitle detailview:observableLabel];
            [self setLabelSizeFor:mutantInfoTitle detailview:mutantInfoLabel];
            [self setLabelSizeFor:expTypeTitle detailview:expTypeLabel];
            [self setLabelSizeFor:qualifierTitle detailview:qualifierLabel];
            [self setLabelSizeFor:referencesTitle detailview:referencesLabel];
            [self setLabelSizeFor:(UILabel*)referenceBtn detailview:referencesLabel];
            
            
            //-----
            
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
        }
        
        onlyReference = NO;
		
	}
	@catch (NSException * e)
	{
		NSLog(@"%@",[e description]);
	}
	
}

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
#pragma mark Action Method 

//Function called when email icon is pressed and mail is composed with feature details

-(IBAction)pushedEmailButton:(id)sender 
{
	NSString *featName = [staticFunctionClass getGeneName];
	NSArray *display = [featName componentsSeparatedByString:@"/"];
	NSString *sysName = [display objectAtIndex:1];
	NSString *SubjectLine = [NSString stringWithFormat:@"%@, Phenotype Details", featName];
    
    [staticFunctionClass setSubjectLine:SubjectLine];
    NSMutableArray *arrRec = [[NSMutableArray alloc] init];
    
    EmailViewController *emailView = [[EmailViewController alloc]initWithNibName:@"EmailViewController" bundle:[NSBundle mainBundle]];
    
    NSString *eMailBody = @"";
	
	eMailBody = [eMailBody stringByAppendingFormat:@"<div><a href=\"http://www.yeastgenome.org/cgi-bin/phenotype/phenotype.fpl?locus=%@\">%@ Phenotype Details</a><br><br></div>",sysName, featName];
	
    if (qualifierLabel.text == @"") {
        if (mutantInfoLabel.text == @"")
            
            eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b>Observable:</b>%@<br><b>Experiment Type:</b>%@<br><b>Reference:</b>%@</td></tr><br><br>", observableLabel.text, expTypeLabel.text, referencesLabel.text];
        
        else
            
            eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b>Observable:</b>%@<br><b>Qualifier (chemical):</b>%@<br><b>Experiment Type:</b>%@<br><b>Reference:</b>%@</td></tr><br><br>", observableLabel.text, mutantInfoLabel.text, expTypeLabel.text, referencesLabel.text];
    }
    
    else {
        if (mutantInfoLabel.text == @"")
            
            eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b>Observable:</b>%@<br><b>Experiment Type:</b>%@<br><b>Mutant Info:</b>%@<br><b>Reference:</b>%@</td></tr><br><br>", observableLabel.text, expTypeLabel.text, qualifierLabel.text, referencesLabel.text];
        
        else
            
            eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b>Observable:</b>%@<br><b>Qualifier (chemical:)</b>%@<br><b>Experiment Type:</b>%@<br><b>Mutant Info:</b>%@<br><b>Reference:</b>%@</td></tr><br><br>", observableLabel.text, mutantInfoLabel.text, expTypeLabel.text, qualifierLabel.text, referencesLabel.text];
    }
    
    [staticFunctionClass setMessageBody:eMailBody];

// NSLog(@"FeatPhenotypeDetails: %@", eMailBody);

    [arrRec release];
    
    [self.navigationController pushViewController:emailView animated:YES];
	
}

//Function called when reference text is clicked and respective url is open in webview
-(void)pushedReferenceButton:(id)sender{
    
    onlyReference = YES;
    
   
    @try
	{
                
        
        if([pubMedID length]!=0)
        {
            
            NSString *urlAddress =[NSString stringWithFormat:@"http://www.yeastgenome.org/cgi-bin/reference/reference.pl?pmid=%@",pubMedID];//@"http://yeastmine.yeastgenome.org/yeastmine/portal.do?externalids=%@"
            
            
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
#pragma mark Actionsheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	@try {
		NSString *featName = [staticFunctionClass getGeneName];
		NSString *SubjectLine = [NSString stringWithFormat:@"%@, Phenotype Details", featName];
		
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




- (void)dealloc 
{
  	
    [super dealloc];
}


@end
