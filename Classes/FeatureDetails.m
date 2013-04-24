//
//  FeatureDetails.m
//  SGD_2
//
//  Created by Vivek on 04/08/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

/*
 Class to display the detail information of the gene/feature.
 eg: Standard name, systematic name ,aliases, description etc
 for the selected feature. 
 
 */
#import "SGD_2AppDelegate.h"
#import "FeatureDetails.h"
#import "FavoritesListViewController.h"
#import "FeatGoDetails.h"
#import "FeatInteractionList.h"
#import "FeatPhenoType.h"
#import "FeatReferencesDetails.h"
#import "EmailViewController.h"
#import "BrowseImgView.h"

#import "Features.h"
#import "Alias.h"
#import "FeatLocation.h"
#import "FeatAnnotation.h"
#import "staticFunctionClass.h"
#import "Reachability.h"



@implementation FeatureDetails

@synthesize selectedFeature;
@synthesize managedObjectContext;
@synthesize contentView;
@synthesize moreInfoLinks;
@synthesize featName;
@synthesize browseImgVC;

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
   
    
	UIInterfaceOrientation orientation = self.interfaceOrientation;

	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            float  f1 = sequenceButton.frame.origin.y+sequenceButton.frame.size.height+20; 
			[contentView setFrame:CGRectMake(128, 5, 768, f1)];

			contentView.layer.borderWidth = 1;
			contentView.layer.cornerRadius = 5;
			contentView.layer.borderColor = [[UIColor blackColor] CGColor];
 
		}
		else			
		{
            float  f1 = sequenceButton.frame.origin.y+sequenceButton.frame.size.height+20; 
			[contentView setFrame:CGRectMake(0, 0, 768, f1)];

			contentView.layer.borderWidth = 0;
			contentView.layer.cornerRadius = 0;
			contentView.layer.borderColor = [[UIColor blackColor] CGColor];
 
		}
        
        [self setLabelSizeFor:descLabel detailview:featDescLabel];

        [self setLabelSizeFor:descLabel detailview:featDescLabel];
        [self setLabelSizeFor:locLabel detailview:featLocInfoLabel];
        
        //--
        [self setLabelSizeFor:aliasLabel detailview:featAliasesLabel];

        //--
        [self setLabelWidthFor:standardLabel newWidth:200];
        [self setLabelWidthFor:standardDetail newWidth:200];
        [self setLabelWidthFor:systLabel newWidth:200];
        [self setLabelWidthFor:systDetail newWidth:200];
       

        [self setLabelSizeFor:locLabel gbrowseview:gBrowseImage];
        
        if (gBrowseImage.hidden)
            [self setLabelSizeFor:locLabel detailview:featLocInfoLabel];
	}
	else
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{   
           

			[self setLabelWidthFor:featNameDetails newWidth:300];//350
			[self setLabelSizeFor:featNameDetails labelText:featNameDetails.text];
			[self setLabelWidthFor:featDescLabel newWidth:300];
			[self setLabelSizeFor:featDescLabel labelText:featDescLabel.text];
			[self setLabelWidthFor:featAliasesLabel newWidth:230];
			[self setLabelSizeFor:featAliasesLabel labelText:featAliasesLabel.text];
			[self setLabelWidthFor:featTypeLabel newWidth:250];
			[self setLabelSizeFor:featTypeLabel labelText:featTypeLabel.text];
			[self setLabelWidthFor:featPrimaryIdLabel newWidth:150];
			[self setLabelSizeFor:featPrimaryIdLabel labelText:featPrimaryIdLabel.text];
            //***
            [self setLabelWidthFor:featLocInfoLabel newWidth:310];
            [self setLabelSizeFor:featLocInfoLabel labelText:featLocInfoLabel.text];
            //*****
			[self setLabelWidthFor:moreInfoLinks newWidth:450];//450
            
			[self setLabelWidthFor:gBrowseImage newWidth:307];
            
            [self setLabelWidthFor:browseBtn newWidth:307];
            
            gBrowseImage.frame = CGRectMake(140, 419, 307, 75);            
		

            [featDescLabel sizeToFit];
            [self setLabelSizeFor:descLabel detailview:featDescLabel];
            [self setLabelSizeFor:locLabel detailview:featLocInfoLabel];
            float  f1 = sequenceButton.frame.origin.y+sequenceButton.frame.size.height+20;            [contentView setFrame:CGRectMake(0, 0, 480, f1)];
            

		}
		else			
		{
            
			[self setLabelWidthFor:featNameDetails newWidth:160];
			[self setLabelSizeFor:featNameDetails labelText:featNameDetails.text];
			[self setLabelWidthFor:featDescLabel newWidth:127];
			[self setLabelSizeFor:featDescLabel labelText:featDescLabel.text];
			[self setLabelWidthFor:featAliasesLabel newWidth:180];
			[self setLabelSizeFor:featAliasesLabel labelText:featAliasesLabel.text];
			[self setLabelWidthFor:featTypeLabel newWidth:150];
			[self setLabelSizeFor:featTypeLabel labelText:featTypeLabel.text];
			[self setLabelWidthFor:featPrimaryIdLabel newWidth:210];
			[self setLabelSizeFor:featPrimaryIdLabel labelText:featPrimaryIdLabel.text];
            //***
            [self setLabelWidthFor:featLocInfoLabel newWidth:190];
            [self setLabelSizeFor:featLocInfoLabel labelText:featLocInfoLabel.text];
            //featLocInfoLabel.backgroundColor = [UIColor greenColor];

            //*****
			[self setLabelWidthFor:moreInfoLinks newWidth:307];
			[self setLabelWidthFor:gBrowseImage newWidth:307];
            
            [featDescLabel sizeToFit];
            [self setLabelSizeFor:descLabel detailview:featDescLabel];
            [self setLabelSizeFor:locLabel detailview:featLocInfoLabel];

             float  f1 = sequenceButton.frame.origin.y+sequenceButton.frame.size.height+20;            [contentView setFrame:CGRectMake(0, 0, 320, f1)];

            
		}
        
        [featLocInfoLabel sizeToFit];
        [featTypeLabel sizeToFit];
        [featNameDetails sizeToFit];
        //***
        
        [self setLabelSizeFor:locLabel detailview:featLocInfoLabel];
        //[self setLabelSizeFor:locLabel gbrowseview:gBrowseImage];
        //*****
        if([selectedFeature.geneName length]>0) {
            [self setViewYOriginFor:systLabel previousView:standardLabel previousDetailView:standardDetail];
            [self setViewYOriginFor:systDetail previousView:standardLabel previousDetailView:standardDetail];
            [self setViewXOriginFor:systDetail previousView:systLabel];
        }else{

        }
        
       // [self setViewYOriginFor:aliasLabel previousView:systLabel previousDetailView:systDetail];
       // [self setViewYOriginFor:featAliasesLabel previousView:systLabel previousDetailView:systDetail];
       // [self setViewXOriginFor:featAliasesLabel previousView:aliasLabel];
        
        if ([aliasLabel.text length] > 0) {
            //-----
            //----
            [self setViewYOriginFor:aliasLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewYOriginFor:featAliasesLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewXOriginFor:featAliasesLabel previousView:aliasLabel];
            [featAliasesLabel sizeToFit];
            [self setLabelSizeFor:aliasLabel detailview:featAliasesLabel];
            
            
            //----------
            //----
            [self setViewYOriginFor:typeLabel previousView:aliasLabel previousDetailView:featAliasesLabel];
            [self setViewYOriginFor:featTypeLabel previousView:aliasLabel previousDetailView:featAliasesLabel];
            [self setViewXOriginFor:featTypeLabel previousView:typeLabel];
            [self setLabelSizeFor:typeLabel detailview:featTypeLabel];

            
        }else{
            [self setViewYOriginFor:typeLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewYOriginFor:featTypeLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewXOriginFor:featTypeLabel previousView:typeLabel];
            [self setLabelSizeFor:typeLabel detailview:featTypeLabel];

        }
        
        [self setViewYOriginFor:descLabel previousView:typeLabel previousDetailView:featTypeLabel];
        [self setViewYOriginFor:featDescLabel previousView:typeLabel previousDetailView:featTypeLabel];
        [self setViewXOriginFor:featDescLabel previousView:descLabel];
        
        [self setViewYOriginFor:nameDescription previousView:descLabel previousDetailView:featDescLabel];
        [self setViewYOriginFor:featNameDetails previousView:descLabel previousDetailView:featDescLabel];
        [self setViewXOriginFor:featNameDetails previousView:nameDescription];
        
        if ([nameDescription.text  length] > 0) {
            
           
            [self setLabelSizeFor:nameDescription detailview:featNameDetails];

            [self setViewYOriginFor:primaryIdentifer previousView:nameDescription previousDetailView:featNameDetails];
            [self setViewYOriginFor:featPrimaryIdLabel previousView:nameDescription previousDetailView:featNameDetails];
            [self setViewXOriginFor:featPrimaryIdLabel previousView:primaryIdentifer];
            
        }else{
            [self setViewYOriginFor:primaryIdentifer previousView:descLabel previousDetailView:featDescLabel];
            [self setViewYOriginFor:featPrimaryIdLabel previousView:descLabel previousDetailView:featDescLabel];
            [self setViewXOriginFor:featPrimaryIdLabel previousView:primaryIdentifer];
            
        }
                
        [self setViewYOriginFor:locLabel previousView:primaryIdentifer previousDetailView:featPrimaryIdLabel];
        [self setViewYOriginFor:featLocInfoLabel previousView:primaryIdentifer previousDetailView:featPrimaryIdLabel];
        [self setViewXOriginFor:featLocInfoLabel previousView:locLabel];
        
        if (textRange.location == NSNotFound)
        {
            if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
            {
                [self setLabelSizeFor:locLabel detailview:(UILabel *)gBrowseImage];
                [self setViewYOriginFor:browseBtn previousView:featLocInfoLabel];
                [self setViewYOriginFor:gBrowseImage previousView:featLocInfoLabel];
                [self setViewXOriginFor:gBrowseImage previousView:locLabel];
                [self setViewXOriginFor:browseBtn previousView:locLabel];
            }
            else
            {
                [self setViewYOriginFor:browseBtn previousView:locLabel previousDetailView:featLocInfoLabel];
                [self setViewYOriginFor:gBrowseImage previousView:locLabel previousDetailView:featLocInfoLabel]; 
            }
        }
        
        [self setViewYOriginFor:moreInfoLinks previousView:gBrowseImage];
        
        if (moreInfoLinks.hidden) {
            if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
                [self setViewYOriginForViewAtSGD:viewAtSGD previousView:locLabel];
            else
                [self setViewYOriginForViewAtSGD:viewAtSGD previousView:gBrowseImage];
        }
        else {
            [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];
        }
        
        [self setViewYOriginFor:sequenceButton previousView:viewAtSGD];
        [self setViewYOriginFor:yeastmineButton previousView:viewAtSGD];
        [self setViewYOriginFor:spellButton previousView:viewAtSGD];
        [self setViewYOriginFor:locusButton previousView:viewAtSGD];
        
        if (gBrowseImage.hidden) {
            
            [self setLabelSizeFor:locLabel detailview:featLocInfoLabel];
            [self setViewYOriginFor:moreInfoLinks previousView:featLocInfoLabel];
            [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];
            
            [self setViewYOriginFor:sequenceButton previousView:viewAtSGD];
            [self setViewYOriginFor:yeastmineButton previousView:viewAtSGD];
            [self setViewYOriginFor:spellButton previousView:viewAtSGD];
            [self setViewYOriginFor:locusButton previousView:viewAtSGD];
        }
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            float  f1 = sequenceButton.frame.origin.y+sequenceButton.frame.size.height+20;            [contentView setFrame:CGRectMake(0, 0, 480, f1)];
        }
        else {
            float  f1 = sequenceButton.frame.origin.y+sequenceButton.frame.size.height+20; 
            [contentView setFrame:CGRectMake(0, 0, 320, f1)];
        } 
	}

	[featDescLabel sizeToFit];	
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
		
        
    
        [self setLabelSizeFor:descLabel detailview:featDescLabel];
       
        [self setLabelSizeFor:locLabel gbrowseview:gBrowseImage];
        ///////////
        [self setLabelWidthFor:featNameDetails newWidth:400];
        [self setLabelSizeFor:featNameDetails labelText:featNameDetails.text];
        [self setLabelWidthFor:featDescLabel newWidth:450];
        [self setLabelSizeFor:featDescLabel labelText:featDescLabel.text];
        [self setLabelWidthFor:featAliasesLabel newWidth:400];
        [self setLabelSizeFor:featAliasesLabel labelText:featAliasesLabel.text];
        [self setLabelWidthFor:featTypeLabel newWidth:400];
        [self setLabelSizeFor:featTypeLabel labelText:featTypeLabel.text];
        [self setLabelWidthFor:featPrimaryIdLabel newWidth:150];
        [self setLabelSizeFor:featPrimaryIdLabel labelText:featPrimaryIdLabel.text];
        //***
        [self setLabelWidthFor:featLocInfoLabel newWidth:400];
        [self setLabelSizeFor:featLocInfoLabel labelText:featLocInfoLabel.text];
        //featLocInfoLabel.backgroundColor = [UIColor greenColor];
        //*****
        [self setLabelWidthFor:moreInfoLinks newWidth:725];
        
        
        [self setLabelWidthFor:browseBtn newWidth:493];
        
        
        
        
        if([selectedFeature.geneName length]>0) {
            [self setViewYOriginFor:systLabel previousView:standardLabel previousDetailView:standardDetail];
            [self setViewYOriginFor:systDetail previousView:standardLabel previousDetailView:standardDetail];
            [self setViewXOriginFor:systDetail previousView:systLabel];
        }else{
            
        }
        
        
        
        if ([aliasLabel.text length] > 0) {
            /*
            [self setViewYOriginFor:aliasLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewYOriginFor:featAliasesLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewXOriginFor:featAliasesLabel previousView:aliasLabel];
            */
            //----
            [self setViewYOriginFor:aliasLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewYOriginFor:featAliasesLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewXOriginFor:featAliasesLabel previousView:aliasLabel];
            [featAliasesLabel sizeToFit];
            [self setLabelSizeFor:aliasLabel detailview:featAliasesLabel];
            
            

            
            [self setViewYOriginFor:typeLabel previousView:aliasLabel previousDetailView:featAliasesLabel];
            [self setViewYOriginFor:featTypeLabel previousView:aliasLabel previousDetailView:featAliasesLabel];
            [self setViewXOriginFor:featTypeLabel previousView:typeLabel];
            
            
        }else{
            [self setViewYOriginFor:typeLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewYOriginFor:featTypeLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewXOriginFor:featTypeLabel previousView:typeLabel];
        }
        
        
        
        [self setViewYOriginFor:descLabel previousView:typeLabel previousDetailView:featTypeLabel];
        [self setViewYOriginFor:featDescLabel previousView:typeLabel previousDetailView:featTypeLabel];
        [self setViewXOriginFor:featDescLabel previousView:descLabel];
        
       
        [self setLabelSizeFor:featDescLabel labelText:featDescLabel.text];
        [featDescLabel sizeToFit];
        
        
        
        [self setLabelSizeFor:descLabel detailview:featDescLabel];
        
        if ([nameDescription.text  length] > 0) {
            
            [self setLabelSizeFor:nameDescription labelText:nameDescription.text];
            [self setViewYOriginFor:nameDescription previousView:descLabel previousDetailView:featDescLabel];
            [self setViewYOriginFor:featNameDetails previousView:descLabel previousDetailView:featDescLabel];
            [self setViewXOriginFor:featNameDetails previousView:nameDescription];
            [featNameDetails sizeToFit];
            [self setLabelSizeFor:nameDescription detailview:featNameDetails];


            [self setViewYOriginFor:primaryIdentifer previousView:nameDescription previousDetailView:featNameDetails];
            [self setViewYOriginFor:featPrimaryIdLabel previousView:nameDescription previousDetailView:featNameDetails];
           
        }else{
            [self setViewYOriginFor:primaryIdentifer previousView:descLabel previousDetailView:featDescLabel];
            [self setViewYOriginFor:featPrimaryIdLabel previousView:descLabel previousDetailView:featDescLabel];
            
        }
        
        [self setLabelSizeFor:featPrimaryIdLabel labelText:featPrimaryIdLabel.text];
        [self setViewXOriginFor:featPrimaryIdLabel previousView:primaryIdentifer];

       
         

        [self setViewYOriginFor:locLabel previousView:primaryIdentifer previousDetailView:featPrimaryIdLabel];
        [self setViewYOriginFor:featLocInfoLabel previousView:primaryIdentifer previousDetailView:featPrimaryIdLabel];
        [self setViewXOriginFor:featLocInfoLabel previousView:locLabel];
        
        
        
        
        if (gBrowseImage.hidden){
            
            [self setLabelSizeFor:locLabel detailview:featLocInfoLabel];
            [self setViewYOriginFor:moreInfoLinks previousView:locLabel previousDetailView:featLocInfoLabel];
            
        }
        else{
            //NSLog(@"Label size gbrowse");
            [self setLabelSizeFor:locLabel gbrowseview:gBrowseImage];
            [self setViewYOriginFor:gBrowseImage previousView:featLocInfoLabel];
            [self setViewYOriginFor:browseBtn previousView:featLocInfoLabel];
            
            
            
        }

        if (moreInfoLinks.hidden) {
            if (gBrowseImage.hidden){
                [self setViewYOriginForViewAtSGD:viewAtSGD previousView:featLocInfoLabel];
                [self setViewYOriginFor:sequenceButton previousView:featLocInfoLabel];
                [self setViewYOriginFor:yeastmineButton previousView:featLocInfoLabel];
                [self setViewYOriginFor:spellButton previousView:featLocInfoLabel];
                [self setViewYOriginFor:locusButton previousView:featLocInfoLabel];
            }else{
            [self setViewYOriginForViewAtSGD:viewAtSGD previousView:gBrowseImage];
            
            
            
            [self setViewYOriginFor:sequenceButton previousView:gBrowseImage];
            [self setViewYOriginFor:yeastmineButton previousView:gBrowseImage];
            [self setViewYOriginFor:spellButton previousView:gBrowseImage];
            [self setViewYOriginFor:locusButton previousView:gBrowseImage];
            }
        }
        else {
            if (!gBrowseImage.hidden){
            [self setViewYOriginFor:moreInfoLinks previousView:gBrowseImage];
            [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];
            
           
            }else{
            
                [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];
            
            }
            
            [self setViewYOriginFor:sequenceButton previousView:moreInfoLinks];
            [self setViewYOriginFor:yeastmineButton previousView:moreInfoLinks];
            [self setViewYOriginFor:spellButton previousView:moreInfoLinks];
            [self setViewYOriginFor:locusButton previousView:moreInfoLinks];
        }
        

       
              
               
        if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
            float  f1 = sequenceButton.frame.origin.y+sequenceButton.frame.size.height+20;         
            [contentView setFrame:CGRectMake(128, 5, 768, f1)];
            
            
			contentView.layer.borderWidth = 1;
			contentView.layer.cornerRadius = 5;
			contentView.layer.borderColor = [[UIColor blackColor] CGColor];
            
		}
		else			
		{
            float  f1 = sequenceButton.frame.origin.y+sequenceButton.frame.size.height+20; 
            [contentView setFrame:CGRectMake(0, 0, 768, f1)];
            
			contentView.layer.borderWidth = 0;
			contentView.layer.cornerRadius = 0;
			contentView.layer.borderColor = [[UIColor blackColor] CGColor];
            
		}
       
        [(UIScrollView*)self.view setContentSize:contentView.frame.size];
	}
	else
	{
		if(orientation == UIInterfaceOrientationLandscapeLeft || 
		   orientation == UIInterfaceOrientationLandscapeRight) 
		{
         
            
			[self setLabelWidthFor:featNameDetails newWidth:300];
			[self setLabelSizeFor:featNameDetails labelText:featNameDetails.text];
			[self setLabelWidthFor:featDescLabel newWidth:300];
			[self setLabelSizeFor:featDescLabel labelText:featDescLabel.text];
			[self setLabelWidthFor:featAliasesLabel newWidth:230];
			[self setLabelSizeFor:featAliasesLabel labelText:featAliasesLabel.text];
			[self setLabelWidthFor:featTypeLabel newWidth:250];
			[self setLabelSizeFor:featTypeLabel labelText:featTypeLabel.text];
			[self setLabelWidthFor:featPrimaryIdLabel newWidth:150];
			[self setLabelSizeFor:featPrimaryIdLabel labelText:featPrimaryIdLabel.text];
            
            //*****
            [self setLabelWidthFor:featLocInfoLabel newWidth:310];
            [self setLabelSizeFor:featLocInfoLabel labelText:featLocInfoLabel.text];
            
            //*****
			[self setLabelWidthFor:moreInfoLinks newWidth:450];         
         
            [self setLabelWidthFor:browseBtn newWidth:307];
            
            
            gBrowseImage.frame = CGRectMake(140, 419, 307, 75);            
            [featDescLabel sizeToFit];
            [self setLabelSizeFor:descLabel detailview:featDescLabel];
            [self setLabelSizeFor:locLabel detailview:featLocInfoLabel];
            float  f1 = sequenceButton.frame.origin.y+sequenceButton.frame.size.height+20;            
            [contentView setFrame:CGRectMake(0, 0, 480, f1)];
		}
		else			
		{
            
			[self setLabelWidthFor:featNameDetails newWidth:160];
			[self setLabelSizeFor:featNameDetails labelText:featNameDetails.text];
            [self setLabelWidthFor:featDescLabel newWidth:127];
			[self setLabelSizeFor:featDescLabel labelText:featDescLabel.text];
			[self setLabelWidthFor:featAliasesLabel newWidth:180];
			[self setLabelSizeFor:featAliasesLabel labelText:featAliasesLabel.text];
			[self setLabelWidthFor:featTypeLabel newWidth:150];
			[self setLabelSizeFor:featTypeLabel labelText:featTypeLabel.text];
			[self setLabelWidthFor:featPrimaryIdLabel newWidth:210];
			[self setLabelSizeFor:featPrimaryIdLabel labelText:featPrimaryIdLabel.text];
            //***
            [self setLabelWidthFor:featLocInfoLabel newWidth:190];
            [self setLabelSizeFor:featLocInfoLabel labelText:featLocInfoLabel.text];
            //featLocInfoLabel.backgroundColor = [UIColor greenColor];
            //*****
			[self setLabelWidthFor:moreInfoLinks newWidth:307];
			[self setLabelWidthFor:gBrowseImage newWidth:307];
            
            
            [featDescLabel sizeToFit];
            [self setLabelSizeFor:descLabel detailview:featDescLabel];
            
            
            float  f1 = sequenceButton.frame.origin.y+sequenceButton.frame.size.height+20; 
            [contentView setFrame:CGRectMake(0, 0, 320, f1)];
		}
        
        [featLocInfoLabel sizeToFit];
        [featTypeLabel sizeToFit];
        [featNameDetails sizeToFit];
        //*****
        //NSLog(@"WillAppear");
        [self setLabelSizeFor:locLabel labelText:featLocInfoLabel.text];

        [self setLabelSizeFor:locLabel detailview:featLocInfoLabel];
        //[self setLabelSizeFor:locLabel gbrowseview:gBrowseImage];
        //*******
        if([selectedFeature.geneName length]>0) {
            [self setViewYOriginFor:systLabel previousView:standardLabel previousDetailView:standardDetail];
            [self setViewYOriginFor:systDetail previousView:standardLabel previousDetailView:standardDetail];
            [self setViewXOriginFor:systDetail previousView:systLabel];
          }else{

        }
        
        /*[self setViewYOriginFor:aliasLabel previousView:systLabel previousDetailView:systDetail];
        [self setViewYOriginFor:featAliasesLabel previousView:systLabel previousDetailView:systDetail];
        [self setViewXOriginFor:featAliasesLabel previousView:aliasLabel];*/
        
        if ([aliasLabel.text length] > 0) {
            //----
            [self setViewYOriginFor:aliasLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewYOriginFor:featAliasesLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewXOriginFor:featAliasesLabel previousView:aliasLabel];
            [featAliasesLabel sizeToFit];
            [self setLabelSizeFor:aliasLabel detailview:featAliasesLabel];

            
            //----------
            [self setViewYOriginFor:typeLabel previousView:aliasLabel previousDetailView:featAliasesLabel];
            [self setViewYOriginFor:featTypeLabel previousView:aliasLabel previousDetailView:featAliasesLabel];
            [self setViewXOriginFor:featTypeLabel previousView:typeLabel];
            [self setLabelSizeFor:typeLabel detailview:featTypeLabel];

            
        }else{
            [self setViewYOriginFor:typeLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewYOriginFor:featTypeLabel previousView:systLabel previousDetailView:systDetail];
            [self setViewXOriginFor:featTypeLabel previousView:typeLabel];
            [self setLabelSizeFor:typeLabel detailview:featTypeLabel];

        }
        
        [self setViewYOriginFor:descLabel previousView:typeLabel previousDetailView:featTypeLabel];
        [self setViewYOriginFor:featDescLabel previousView:typeLabel previousDetailView:featTypeLabel];
        [self setViewXOriginFor:featDescLabel previousView:descLabel];
        
        [self setViewYOriginFor:nameDescription previousView:descLabel previousDetailView:featDescLabel];
        [self setViewYOriginFor:featNameDetails previousView:descLabel previousDetailView:featDescLabel];
        [self setViewXOriginFor:featNameDetails previousView:nameDescription];
        
        if ([nameDescription.text  length] > 0) {
            
            [self setViewYOriginFor:primaryIdentifer previousView:nameDescription previousDetailView:featNameDetails];
            [self setViewYOriginFor:featPrimaryIdLabel previousView:nameDescription previousDetailView:featNameDetails];
            [self setLabelSizeFor:nameDescription detailview:featNameDetails];

            [self setViewXOriginFor:featPrimaryIdLabel previousView:primaryIdentifer];
            
        }else{
            [self setViewYOriginFor:primaryIdentifer previousView:descLabel previousDetailView:featDescLabel];
            [self setViewYOriginFor:featPrimaryIdLabel previousView:descLabel previousDetailView:featDescLabel];
            [self setViewXOriginFor:featPrimaryIdLabel previousView:primaryIdentifer];
            
        }
                
        [self setViewYOriginFor:locLabel previousView:primaryIdentifer previousDetailView:featPrimaryIdLabel];
        [self setViewYOriginFor:featLocInfoLabel previousView:primaryIdentifer previousDetailView:featPrimaryIdLabel];
        [self setViewXOriginFor:featLocInfoLabel previousView:locLabel];
        
        if (textRange.location == NSNotFound)
        {
            if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
            {
                [self setLabelSizeFor:locLabel detailview:(UILabel *)gBrowseImage];
                [self setViewYOriginFor:browseBtn previousView:featLocInfoLabel];
                [self setViewYOriginFor:gBrowseImage previousView:featLocInfoLabel];
                [self setViewXOriginFor:gBrowseImage previousView:locLabel];
                [self setViewXOriginFor:browseBtn previousView:locLabel];
            }
            else
            {
                [self setViewYOriginFor:browseBtn previousView:locLabel previousDetailView:featLocInfoLabel];
                [self setViewYOriginFor:gBrowseImage previousView:locLabel previousDetailView:featLocInfoLabel]; 
            }
        }
        
        [self setViewYOriginFor:moreInfoLinks previousView:gBrowseImage];
        if (moreInfoLinks.hidden) {
            [self setViewYOriginForViewAtSGD:viewAtSGD previousView:gBrowseImage];
        }
        else {
            [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];
        }
        
        [self setViewYOriginFor:sequenceButton previousView:viewAtSGD];
        [self setViewYOriginFor:yeastmineButton previousView:viewAtSGD];
        [self setViewYOriginFor:spellButton previousView:viewAtSGD];
        [self setViewYOriginFor:locusButton previousView:viewAtSGD];
                
        if (gBrowseImage.hidden) {
            
            [self setLabelSizeFor:locLabel detailview:featLocInfoLabel];
            [self setViewYOriginFor:moreInfoLinks previousView:featLocInfoLabel];
            [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];
            
            [self setViewYOriginFor:sequenceButton previousView:viewAtSGD];
            [self setViewYOriginFor:yeastmineButton previousView:viewAtSGD];
            [self setViewYOriginFor:spellButton previousView:viewAtSGD];
            [self setViewYOriginFor:locusButton previousView:viewAtSGD];
            
        }
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            float  f1 = sequenceButton.frame.origin.y+sequenceButton.frame.size.height+20;            [contentView setFrame:CGRectMake(0, 0, 480, f1)];
        }
        else {
            float  f1 = sequenceButton.frame.origin.y+sequenceButton.frame.size.height+20; 
            [contentView setFrame:CGRectMake(0, 0, 320, f1)];
        }
        
        
	}
    
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)viewDidLoad 
{

    [super viewDidLoad];
   
    [moreInfoLinks setHidden:YES];
    
    [standardLabel setHidden:YES];
    [systLabel setHidden:YES];
    [descLabel setHidden:YES];
    [aliasLabel setHidden:YES];
    [locLabel setHidden:YES];
    [typeLabel setHidden:YES];
    [primaryIdentifer setHidden:YES];
    [viewAtSGD setHidden:YES];
    [sequenceButton setHidden:YES];
    [yeastmineButton setHidden:YES];
    [spellButton setHidden:YES];
    [locusButton setHidden:YES];

    
    
  
        
    av = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    
    
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

    
   
    
    
    av.frame = activityFrame;
    [self.view addSubview:av];
    [av startAnimating];
    
    [staticFunctionClass initBrowseImg];
	[staticFunctionClass setGeneName:[NSString stringWithFormat:@"%@",self.title]];
	
	tblMoreDetails.dataSource = self;
	tblMoreDetails.delegate = self;
	
	tblMoreDetails.layer.borderWidth = 1;
	tblMoreDetails.layer.borderColor = [[UIColor grayColor] CGColor];
	tblMoreDetails.layer.cornerRadius = 5;
	
	
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	
    if (textRange.location != NSNotFound) 
	{
		// setting view size -- increasing the length
		CGRect frame = self.view.frame; //frame of scroll view
		frame.size.height = 1500;
		frame.origin.y = 20;
		self.view.frame = frame;
        
		//finally set the scroll view's contentSize property to the size of the content view's frame; always needed
        
        [(UIScrollView*)self.view setContentSize:frame.size];
        
	}
	else
	{
		CGRect frame = self.view.frame; //frame of scroll view
		frame.size.height = 1000;
		frame.origin.y = 20;
		
        [self.view setFrame:frame];
        
		//finally set the scroll view's contentSize property to the size of the content view's frame; always needed
		
        [(UIScrollView*)self.view setContentSize:frame.size];
        
	}
    
}

//Fetch the details of the feature and display it
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	
	UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
	tlabel.text=self.navigationItem.title;
    tlabel.textColor=[UIColor blackColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
	
	// get details of the selected feature
	@try
	{
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features" inManagedObjectContext:managedObjectContext];
		
		[request setEntity:entity];
		
		featName = [[NSString alloc] init];
		
		NSArray *display = [self.title componentsSeparatedByString: @"/"];
		
		if (display.count > 1) 
        {
			featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:1]];
		} 
        else 
        {
			featName = [NSString stringWithFormat:@"%@", [display objectAtIndex:0]];
		}
		
		// setting the predicate
		NSPredicate *fetchByFeatureName = [NSPredicate predicateWithFormat:@"featureName = %@", featName];
		
		[request setPredicate:fetchByFeatureName];
		
		NSError *error;
		NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:request error:&error];
		
		selectedFeature = [fetchedObjects objectAtIndex:0];  //gets the feature object
		[request release];
		
        
        [standardLabel setHidden:NO];
        [systLabel setHidden:NO];
        [descLabel setHidden:NO];
        [aliasLabel setHidden:NO];
        [locLabel setHidden:NO];
        [typeLabel setHidden:NO];        
        [primaryIdentifer setHidden:NO];
        [viewAtSGD setHidden:NO];
        [sequenceButton setHidden:NO];
        [yeastmineButton setHidden:NO];
        [spellButton setHidden:NO];
        [locusButton setHidden:NO];
        

        
        if([selectedFeature.geneName length]>0)
        {
            
            standardLabel.text = @"Standard Name";	
        
            standardDetail.text = selectedFeature.geneName;
          
        
            [self setViewYOriginFor:standardDetail labelView:standardLabel];
            [self setViewXOriginFor:standardDetail previousView:standardLabel]; 
            [standardLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
           
        }
        else
        {
            standardLabel.text = @"";	
            standardDetail.text = @"";
        }
       
        
        systLabel.text = @"Systematic Name";
     

        systDetail.text = selectedFeature.featureName;
        [self setViewXOriginFor:systDetail previousView:systLabel];
        [self setViewYOriginFor:systDetail labelView:systLabel];

        [systLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        
        // set Alias info
		NSSet *featAlias = selectedFeature.aliases;
        
		NSMutableString *displayAliases = [[NSMutableString alloc] init];
		
		for (Alias *alias in [featAlias allObjects]) 
		{
            
			if ([displayAliases length] > 0) {
				[displayAliases appendString:@", "];
			}
			
			[displayAliases appendString:[alias aliasName]];
		}
		if ([displayAliases length] > 0) {
			aliasLabel.text = @"Alias";
            [aliasLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
           
        [self setViewYOriginFor:aliasLabel previousView:systLabel previousDetailView:systDetail];
            
			
		} else 
			aliasLabel.text = @"";
      		
		
		featAliasesLabel.text = [NSString stringWithFormat:@"%@", displayAliases];
        
		[displayAliases release];
		[self setViewXOriginFor:featAliasesLabel previousView:aliasLabel];
        [self setViewYOriginFor:featAliasesLabel labelView:aliasLabel];
		[featAliasesLabel sizeToFit];

        
		// set feature type label
		typeLabel.text = @"Feature type ";
        [typeLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
		
        if ([aliasLabel.text length] > 0) {
        
        [self setViewYOriginFor:typeLabel previousView:aliasLabel previousDetailView:featAliasesLabel];
        
        }else{
            [self setViewYOriginFor:typeLabel previousView:systLabel previousDetailView:systDetail];

        }
		
		
		featTypeLabel.text = [NSString stringWithFormat:@"%@", selectedFeature.featType];
        
        [self setViewXOriginFor:featTypeLabel previousView:typeLabel];

		[self setLabelSizeFor:featTypeLabel labelText:featTypeLabel.text];
        [self setViewYOriginFor:featTypeLabel labelView:typeLabel];
		[featTypeLabel sizeToFit];
		

        
		//description
		descLabel.text = @"Description";
        [self setViewYOriginFor:descLabel previousView:typeLabel previousDetailView:featTypeLabel];
        
        
        [descLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        
		NSString *featDesc = [NSString stringWithFormat:@"%@", selectedFeature.annotation.descriptions];
		
		featDescLabel.lineBreakMode = UILineBreakModeWordWrap;
		
		[self setViewXOriginFor:featDescLabel previousView:descLabel];
		[self setLabelSizeFor:featDescLabel labelText:featDesc];
        [self setViewYOriginFor:featDescLabel labelView:descLabel];
        
		featDescLabel.text = featDesc;
		[featDescLabel sizeToFit];

              
        
		nameDescription.text = @"Name Description";
       
		
		featNameDetails.text = [NSString stringWithFormat:@"%@", selectedFeature.annotation.nameDescription];
		if ([featNameDetails.text isEqualToString:@" "]) 
		{
			featNameDetails.text = @"";
		}
		if ([featNameDetails.text length] > 0 ) {
			nameDescription.text = @"Name Description";
         
            [self setViewYOriginFor:nameDescription previousView:descLabel previousDetailView:featDescLabel];

          

            [nameDescription setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];

		} else {
			nameDescription.text = @"";
		}
		
		[self setViewXOriginFor:featNameDetails previousView:nameDescription];
        [self setViewYOriginFor:featNameDetails labelView:nameDescription];

		[self setLabelSizeFor:featNameDetails labelText:featNameDetails.text];
		[featNameDetails sizeToFit];
		
        //set primary identifier
		primaryIdentifer.text = @"SGDID";
        [primaryIdentifer setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];
        
        if ([nameDescription.text  length] > 0) {
            
            [self setViewYOriginFor:primaryIdentifer previousView:nameDescription previousDetailView:featNameDetails];
            
        }else{
            [self setViewYOriginFor:primaryIdentifer previousView:descLabel previousDetailView:featDescLabel];
            
        }

		featPrimaryIdLabel.text = [NSString stringWithFormat:@"%@", selectedFeature.dbxrefId];
        
		[self setLabelSizeFor:featPrimaryIdLabel labelText:featPrimaryIdLabel.text];
		[self setViewXOriginFor:featPrimaryIdLabel previousView:primaryIdentifer];
        [self setViewYOriginFor:featPrimaryIdLabel labelView:primaryIdentifer];

		[featPrimaryIdLabel sizeToFit];
		
		// setting sequence info
		
		locLabel.text = @"Chromosomal Location";
        [locLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Square.png"]]];

		[self setViewYOriginFor:locLabel previousView:primaryIdentifer previousDetailView:featPrimaryIdLabel];
		
		
		featLocInfoLabel.lineBreakMode = UILineBreakModeWordWrap;
		featLocInfoLabel.text = selectedFeature.sequenceInformation; 
        
        //NSLog(@"sequence----->%@",selectedFeature.sequenceInformation); 
        
        [self setViewXOriginFor:featLocInfoLabel previousView:locLabel];

        [self setViewYOriginFor:featLocInfoLabel labelView:locLabel];
		
        //NSLog(@"View Did Appear----->"); 

        [self setLabelSizeFor:locLabel labelText:featLocInfoLabel.text];

		static UIImage *favImage;
		
		if ([[NSString stringWithFormat:@"%d",selectedFeature.favorite] isEqualToString:@"1"]) {		
			favImage = [UIImage imageNamed:@"starFilledYellow.png"];
			
		} else {
			favImage = [UIImage imageNamed:@"starOpen.png"];
		}
		
		
		//Displaying the navigation bar buttons
		UIView *EmailFavView = [[UIView alloc]initWithFrame:CGRectMake(0,0,117,35)];
		EmailFavView.backgroundColor = [UIColor clearColor];
    
		
		static UIImage *EmailImage;
		CGRect EmailFrame = CGRectMake(40,1, 35,35);
		EmailButton = [[UIButton alloc]initWithFrame:EmailFrame];
		EmailImage = [UIImage imageNamed:@"email.png"];
		[EmailButton setBackgroundImage:EmailImage forState:UIControlStateNormal];
		EmailButton.backgroundColor = [UIColor clearColor];
		
		[EmailButton addTarget:self action:@selector(pushedEmailButton:) forControlEvents:UIControlEventTouchUpInside];
		
		CGRect favFrame = CGRectMake(80,0,35, 35);
		favoriteButton = [[UIButton alloc] initWithFrame:favFrame];
		[favoriteButton setBackgroundImage:favImage forState:UIControlStateNormal];
		[favoriteButton addTarget:self action:@selector(pushedFavsButton:) forControlEvents:UIControlEventTouchUpInside]; 
		
		[EmailFavView addSubview:EmailButton];
		[EmailFavView addSubview:favoriteButton];
		
		
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:EmailFavView];
		self.navigationItem.rightBarButtonItem = rightButton;
		[rightButton release];
		[EmailButton release];
		[favoriteButton release];
		
		
		
        if ([activityIndView isAnimating]) 
			[activityIndView stopAnimating];
        
		//Set GBrowse Image Button Postion
		Reachability *rchbility = [[Reachability reachabilityWithHostName: @"yeastgenome.org"] retain];;
		NetworkStatus remoteHostStatus = [rchbility currentReachabilityStatus];
		[rchbility release];
        
    
		//CHECKING 'WAN' CONNECTION AVAILABILITY
		if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
		{
            @try{
                
            
			//GETTING IMAGE
                NSString *gbrowseURL = [NSString stringWithFormat:@"http://yeastgenome.org/cache/gbrowse_images/%@-seqimage.jpg",selectedFeature.featureName];
                //NSLog(@"Image Path--> %@",gbrowseURL);
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:gbrowseURL]];
                
                NSString *imgext = [self contentTypeForImageData:imageData]; 

            //	if ([imageData length] >=1000) 
                if (imgext!=nil) 
                {
                    //[self setViewYOriginFor:gBrowseLabel previousView:featLocInfoLabel];
                    browseBtn.backgroundColor = [UIColor clearColor];
                    [browseBtn addTarget:self action:@selector(pushedBrowseButton:) forControlEvents:UIControlEventTouchUpInside];
                    
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    gBrowseImage.image = image; 
                    gBrowseImage.layer.borderColor = [[UIColor grayColor] CGColor];
                    gBrowseImage.layer.borderWidth = 1;
                    gBrowseImage.layer.cornerRadius = 5;
                    [imageData release];
                    
                    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
                   
                    if (textRange.location != NSNotFound) {

                        [self setViewXOriginFor:browseBtn previousView:descLabel];
                        [self setViewXOriginFor:gBrowseImage previousView:descLabel];
                        [self setViewYOriginFor:browseBtn previousView:locLabel];
                        [self setViewYOriginFor:gBrowseImage previousView:locLabel];
                        [self setViewYOriginFor:sequenceButton labelView:viewAtSGD];
                        [self setViewYOriginFor:yeastmineButton labelView:viewAtSGD];
                        [self setViewYOriginFor:spellButton labelView:viewAtSGD];
                        [self setViewYOriginFor:locusButton labelView:viewAtSGD];
                    
                    }
                    else
                    {
                        [self setViewYOriginFor:browseBtn previousView:locLabel previousDetailView:featLocInfoLabel];
                        [self setViewYOriginFor:gBrowseImage previousView:locLabel previousDetailView:featLocInfoLabel];
                        [self setViewYOriginFor:sequenceButton previousView:viewAtSGD];
                        [self setViewYOriginFor:yeastmineButton previousView:viewAtSGD];
                        [self setViewYOriginFor:spellButton previousView:viewAtSGD];
                        [self setViewYOriginFor:locusButton previousView:viewAtSGD];

                    }
                    
                    [self setViewYOriginFor:moreInfoLinks previousView:gBrowseImage];
                    [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];

                }
                else
                {
                    gBrowseImage.hidden = YES;
                    gBrowseLabel.hidden = YES;
                    browseBtn.hidden = YES;
                    [self setViewYOriginFor:moreInfoLinks previousView:featLocInfoLabel];
                    [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];

                    if (textRange.location != NSNotFound) {
                        [self setViewYOriginFor:sequenceButton labelView:viewAtSGD];
                        [self setViewYOriginFor:yeastmineButton labelView:viewAtSGD];
                        [self setViewYOriginFor:spellButton labelView:viewAtSGD];
                        [self setViewYOriginFor:locusButton labelView:viewAtSGD];
                    }
                    else {
                        
                        [self setViewYOriginFor:sequenceButton previousView:viewAtSGD];
                        [self setViewYOriginFor:yeastmineButton previousView:viewAtSGD];
                        [self setViewYOriginFor:spellButton previousView:viewAtSGD];
                        [self setViewYOriginFor:locusButton previousView:viewAtSGD];
                        
                    }
                }
            }
            @catch (NSException *ex) {
                
            }
		}
		
		//IF NOT REACHABLE THEN GIVING ALERT MESSAGE OF CONNECTION NOT AVAILABLE
		else if(remoteHostStatus == NotReachable)
		{
            if(av != nil && [av isAnimating])
            {
                [av stopAnimating];
                [av removeFromSuperview];
                
                av = nil;
            }
            
            gBrowseImage.hidden = YES;
            gBrowseLabel.hidden = YES;
            browseBtn.hidden = YES;
            //========== IF no network hide gbrowseimage and align belo lable
            [self setViewYOriginFor:moreInfoLinks previousView:featLocInfoLabel];
            [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];
            
            if (textRange.location != NSNotFound) {
                [self setViewYOriginFor:sequenceButton labelView:viewAtSGD];
                [self setViewYOriginFor:yeastmineButton labelView:viewAtSGD];
                [self setViewYOriginFor:spellButton labelView:viewAtSGD];
                [self setViewYOriginFor:locusButton labelView:viewAtSGD];
            }
            else {
                
                [self setViewYOriginFor:sequenceButton previousView:viewAtSGD];
                [self setViewYOriginFor:yeastmineButton previousView:viewAtSGD];
                [self setViewYOriginFor:spellButton previousView:viewAtSGD];
                [self setViewYOriginFor:locusButton previousView:viewAtSGD];
                
            }

            
            //Set Position for More Info links
            
            
            NSRange arsRange = [featName rangeOfString:@"ars" options:NSCaseInsensitiveSearch];
            NSRange cenRange = [featName rangeOfString:@"cen" options:NSCaseInsensitiveSearch];
            NSRange tyRange = [featName rangeOfString:@"Ty" options:NSCaseInsensitiveSearch];
            NSRange ltrDRange = [featName rangeOfString:@"delta" options:NSCaseInsensitiveSearch];
            NSRange ltrORange = [featName rangeOfString:@"omega" options:NSCaseInsensitiveSearch];
            NSRange ltrTRange = [featName rangeOfString:@"tau" options:NSCaseInsensitiveSearch];
            NSRange ltrSRange = [featName rangeOfString:@"sigma" options:NSCaseInsensitiveSearch];
            NSRange telXCRange = [featName rangeOfString:@"-XC" options:NSCaseInsensitiveSearch];
            NSRange telXRRange = [featName rangeOfString:@"-XR" options:NSCaseInsensitiveSearch];
            NSRange telYPRange = [featName rangeOfString:@"-YP" options:NSCaseInsensitiveSearch];
            NSRange telTRRange = [featName rangeOfString:@"-TR" options:NSCaseInsensitiveSearch];
            
            if (arsRange.location != NSNotFound || cenRange.location != NSNotFound || tyRange.location != NSNotFound ||
                ltrDRange.location!= NSNotFound || ltrORange.location!= NSNotFound || ltrTRange.location!= NSNotFound || 
                ltrSRange.location!= NSNotFound || telXCRange.location!= NSNotFound || telXRRange.location!= NSNotFound ||
                telYPRange.location!= NSNotFound ||telTRRange.location!= NSNotFound) 
            {
                
                [moreInfoLinks setHidden:YES];
                
                if (textRange.location != NSNotFound) {
                    [self setViewYOriginForViewAtSGD:viewAtSGD previousView:gBrowseImage];
                    [self setViewYOriginFor:sequenceButton labelView:viewAtSGD];
                    [self setViewYOriginFor:yeastmineButton labelView:viewAtSGD];
                    [self setViewYOriginFor:spellButton labelView:viewAtSGD];
                    [self setViewYOriginFor:locusButton labelView:viewAtSGD];
                }
                else {
                    [self setViewYOriginForViewAtSGD:viewAtSGD previousView:gBrowseImage];
                    
                    [self setViewYOriginFor:sequenceButton previousView:viewAtSGD];
                    [self setViewYOriginFor:yeastmineButton previousView:viewAtSGD];
                    [self setViewYOriginFor:spellButton previousView:viewAtSGD];
                    [self setViewYOriginFor:locusButton previousView:viewAtSGD];
                }
            }
            else 
            {
                [moreInfoLinks setHidden:NO];
                if (textRange.location != NSNotFound) {
                    [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];
                    [self setViewYOriginFor:sequenceButton labelView:viewAtSGD];
                    [self setViewYOriginFor:yeastmineButton labelView:viewAtSGD];
                    [self setViewYOriginFor:spellButton labelView:viewAtSGD];
                    [self setViewYOriginFor:locusButton labelView:viewAtSGD];
                }
                else {
                    [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];
                    
                    [self setViewYOriginFor:sequenceButton previousView:viewAtSGD];
                    [self setViewYOriginFor:yeastmineButton previousView:viewAtSGD];
                    [self setViewYOriginFor:spellButton previousView:viewAtSGD];
                    [self setViewYOriginFor:locusButton previousView:viewAtSGD];
                    
                }
            }

          
            [self viewWillAppear:YES];
			return;
		}
         

        
        
        if(av != nil && [av isAnimating])
        {
            [av stopAnimating];
            [av removeFromSuperview];
            
            av = nil;
        }
	}
	@catch (NSException * e) 
	{
        if(av != nil && [av isAnimating])
        {
            [av stopAnimating];
            [av removeFromSuperview];
            
            av = nil;
        }
		
        NSLog(@"%@",[e description]);
        
        return;
	}
   
    //Set Position for More Info links
    
    
    NSRange arsRange = [featName rangeOfString:@"ars" options:NSCaseInsensitiveSearch];
    NSRange cenRange = [featName rangeOfString:@"cen" options:NSCaseInsensitiveSearch];
    NSRange tyRange = [featName rangeOfString:@"Ty" options:NSCaseInsensitiveSearch];
    NSRange ltrDRange = [featName rangeOfString:@"delta" options:NSCaseInsensitiveSearch];
    NSRange ltrORange = [featName rangeOfString:@"omega" options:NSCaseInsensitiveSearch];
    NSRange ltrTRange = [featName rangeOfString:@"tau" options:NSCaseInsensitiveSearch];
    NSRange ltrSRange = [featName rangeOfString:@"sigma" options:NSCaseInsensitiveSearch];
    NSRange telXCRange = [featName rangeOfString:@"-XC" options:NSCaseInsensitiveSearch];
    NSRange telXRRange = [featName rangeOfString:@"-XR" options:NSCaseInsensitiveSearch];
    NSRange telYPRange = [featName rangeOfString:@"-YP" options:NSCaseInsensitiveSearch];
    NSRange telTRRange = [featName rangeOfString:@"-TR" options:NSCaseInsensitiveSearch];
    
    if (arsRange.location != NSNotFound || cenRange.location != NSNotFound || tyRange.location != NSNotFound ||
        ltrDRange.location!= NSNotFound || ltrORange.location!= NSNotFound || ltrTRange.location!= NSNotFound || 
        ltrSRange.location!= NSNotFound || telXCRange.location!= NSNotFound || telXRRange.location!= NSNotFound ||
        telYPRange.location!= NSNotFound ||telTRRange.location!= NSNotFound) 
    {
        
        [moreInfoLinks setHidden:YES];
        
        if (textRange.location != NSNotFound) {
            [self setViewYOriginForViewAtSGD:viewAtSGD previousView:gBrowseImage];
            [self setViewYOriginFor:sequenceButton labelView:viewAtSGD];
            [self setViewYOriginFor:yeastmineButton labelView:viewAtSGD];
            [self setViewYOriginFor:spellButton labelView:viewAtSGD];
            [self setViewYOriginFor:locusButton labelView:viewAtSGD];
        }
        else {
            [self setViewYOriginForViewAtSGD:viewAtSGD previousView:gBrowseImage];
            
            [self setViewYOriginFor:sequenceButton previousView:viewAtSGD];
            [self setViewYOriginFor:yeastmineButton previousView:viewAtSGD];
            [self setViewYOriginFor:spellButton previousView:viewAtSGD];
            [self setViewYOriginFor:locusButton previousView:viewAtSGD];
        }
    }
    else 
    {
           [moreInfoLinks setHidden:NO];
        if (textRange.location != NSNotFound) {
            [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];
            [self setViewYOriginFor:sequenceButton labelView:viewAtSGD];
            [self setViewYOriginFor:yeastmineButton labelView:viewAtSGD];
            [self setViewYOriginFor:spellButton labelView:viewAtSGD];
            [self setViewYOriginFor:locusButton labelView:viewAtSGD];
        }
        else {
            [self setViewYOriginForViewAtSGD:viewAtSGD previousView:moreInfoLinks];
            
            [self setViewYOriginFor:sequenceButton previousView:viewAtSGD];
            [self setViewYOriginFor:yeastmineButton previousView:viewAtSGD];
            [self setViewYOriginFor:spellButton previousView:viewAtSGD];
            [self setViewYOriginFor:locusButton previousView:viewAtSGD];
            
        }
    }

    [self viewWillAppear:YES];
    
    [(UIScrollView*)self.view flashScrollIndicators];
    
}

- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
}

#pragma mark -
#pragma mark Label Methods  
//Set Label Width according to the label text length
-(void) setLabelWidthFor: (UIView *)labelToSet newWidth: (int) newWidth
{
	CGRect newFrame = labelToSet.frame;
	
	int oldHeight = labelToSet.frame.size.height;
	newFrame.size = CGSizeMake(newWidth, oldHeight);
    
	labelToSet.frame = newFrame;
    
  

}

//Set Label Size according to the label text length

- (void)setLabelSizeFor: (UILabel *)labelToSet labelText:(NSString *)labelText {
	
   // NSLog(@"Sequence INfo-->%@",labelText);
	CGSize maxLabelSize = CGSizeMake(2960, 99999);
	
	CGSize expectedLabelSize = [labelText sizeWithFont:labelToSet.font 
									 constrainedToSize:maxLabelSize
										 lineBreakMode:labelToSet.lineBreakMode];
	CGRect newFrame = labelToSet.frame;
	newFrame.size.height = expectedLabelSize.height;	
	labelToSet.frame = newFrame;
    
    //NSLog(@"labelnewFrame-->%@",newFrame);
    //NSLog(@"labelToSet-->%@",labelToSet);
}

//Set Label Size according to the label text length

- (void)setLabelSizeFor: (UILabel *)labelToSet detailview:(UILabel *)detailview {
		
    if (detailview == (UILabel *)gBrowseImage)
    {
        CGRect newFrame = labelToSet.frame;
        int newHeight = detailview.frame.size.height + 35;
        newFrame.size = CGSizeMake(labelToSet.frame.size.width, newHeight);
        labelToSet.frame = newFrame;
        
       // NSLog(@"In detail View....");
       // NSLog(@"gBrowseImage Size %@",labelToSet);
    }
    
    else
    {
        CGRect newFrame = labelToSet.frame;
        int newHeight = detailview.frame.size.height;
        newFrame.size = CGSizeMake(labelToSet.frame.size.width, newHeight);
        labelToSet.frame = newFrame;
        
       // NSLog(@"Chromosomal Size %@",labelToSet);
       // NSLog(@"CHROMO Text-->%@",detailview.text);
    }
}

//Set Label Size according to the label text length

- (void)setLabelSizeFor: (UILabel *)labelToSet gbrowseview:(UIImageView *)browseview {
    
    //NSLog(@"In gBrowse....");
    CGRect newFrame = labelToSet.frame;
    int newHeight = browseview.frame.size.height+ featLocInfoLabel.frame.size.height+20;
    newFrame.size = CGSizeMake(labelToSet.frame.size.width, newHeight);
    
	labelToSet.frame = newFrame;
    //NSLog(@"Chromosomal Size %@",labelToSet);
}

//Setting the Y Origin of label depending on label at top
- (void)setViewYOriginFor: (UIView *)viewToSet previousView:(UIView *)previousView {
	CGRect newFrame = viewToSet.frame;
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    int newYStart;
	if (textRange.location != NSNotFound)
        newYStart = previousView.frame.size.height + previousView.frame.origin.y + 20;
    else
        newYStart = previousView.frame.size.height + previousView.frame.origin.y + 2;
	int xStart = viewToSet.frame.origin.x;
	newFrame.origin = CGPointMake(xStart,newYStart);
	viewToSet.frame = newFrame;
}

- (void)setViewYOriginForViewAtSGD: (UIView *)viewToSet previousView:(UIView *)previousView {
	CGRect newFrame = viewToSet.frame;
    int newYStart;
    newYStart = previousView.frame.size.height + previousView.frame.origin.y + 20;
	int xStart = viewToSet.frame.origin.x;
	newFrame.origin = CGPointMake(xStart,newYStart);
	viewToSet.frame = newFrame;
}


//Setting the X Origin of label depending on label on left

- (void)setViewXOriginFor: (UIView *)viewToSet previousView:(UIView *)previousView {
	CGRect newFrame = viewToSet.frame;
	int newXStart = previousView.frame.size.width + previousView.frame.origin.x+10;
	int yStart = viewToSet.frame.origin.y;
	newFrame.origin = CGPointMake(newXStart,yStart);
	viewToSet.frame = newFrame;
}

//Setting the X Origin of button  depending on label on left

- (void)setViewXButtonOriginFor: (UIButton *)buttonToSet previousView:(UIView *)previousView {
	CGRect newFrame = buttonToSet.frame;
	int newXStart = previousView.frame.size.width + previousView.frame.origin.x+10;
	int yStart = buttonToSet.frame.origin.y;
	newFrame.origin = CGPointMake(newXStart,yStart);
	buttonToSet.frame = newFrame;
    
    

}
//Setting the Y Origin of label depending on label at top
- (void)setViewYOriginFor: (UIView *)viewToSet previousView:(UIView *)previousLabelView previousDetailView:(UIView *)detailView  {
    
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if (textRange.location != NSNotFound) {
    
        float ft1 = previousLabelView.frame.origin.y+previousLabelView.frame.size.height;
        float ft2 = detailView.frame.origin.y+detailView.frame.size.height;

        if(ft1>ft2){
            viewToSet.frame = CGRectMake(25, ft1+10, viewToSet.frame.size.width, viewToSet.frame.size.height);
        }else{
            viewToSet.frame = CGRectMake(25, ft2+10, viewToSet.frame.size.width, viewToSet.frame.size.height);
        }
    }
    else {
        
        float ft1 = previousLabelView.frame.origin.y+previousLabelView.frame.size.height;
        float ft2 = detailView.frame.origin.y+detailView.frame.size.height;
        
        if(ft1>ft2){
            viewToSet.frame = CGRectMake(05, ft1+10, viewToSet.frame.size.width, viewToSet.frame.size.height);
        }else{
            viewToSet.frame = CGRectMake(05, ft2+10, viewToSet.frame.size.width, viewToSet.frame.size.height);
        }        
    }
}

//Setting the Y Origin of details label depending on label at side
- (void)setViewYOriginFor: (UIView *)viewToSet labelView:(UIView *)previousView {
	CGRect newFrame = viewToSet.frame;
    int newYStart;
    NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if (textRange.location != NSNotFound)
        newYStart = previousView.frame.origin.y;
    else
        newYStart = previousView.frame.origin.y + 2;        
	int xStart = viewToSet.frame.origin.x;
	newFrame.origin = CGPointMake(xStart,newYStart);
	viewToSet.frame = newFrame;
}






#pragma mark -
#pragma mark Action Method

//Called when Browse Image is clicked

-(IBAction)pushedBrowseButton:(id)sender{

    Reachability *rchbility = [[Reachability reachabilityWithHostName: @"yeastgenome.org"] retain];;
    NetworkStatus remoteHostStatus = [rchbility currentReachabilityStatus];
    [rchbility release];
    
    //CHECKING 'WAN' CONNECTION AVAILABILITY
    if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
    {
        
        NSString *sequenceInfo; 
        
        NSString *chr = selectedFeature.location.chromosome;
        
        sequenceInfo = [NSString stringWithFormat:@"Chr%@:%@..%@", chr, selectedFeature.location.minCoord, selectedFeature.location.maxCoord];
        
        NSString *urlAddress = [NSString stringWithFormat: @"http://browse.yeastgenome.org/fgb2/gbrowse/scgenome/?name=%@;label=Landmarks:overview;label=SGD+Everything;label=Tachibana+Adr1+Cat8;label=MacIsaac+TFBSs",sequenceInfo];
        [staticFunctionClass setBrowseImg:urlAddress];
        
        
        if (browseImgVC != nil)
        {
            [browseImgVC release];
            browseImgVC = nil;
        }
        browseImgVC = [[BrowseImgView alloc] initWithNibName:@"BrowseImgView_iPhone" bundle:[NSBundle mainBundle]];
        
        browseImgVC.title = self.title; 
        [self.navigationController pushViewController:browseImgVC animated:YES];
        
        //[browseImgVC release];
        
        
        
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

//Called when View at SGD buttons are clicked

-(IBAction)pushedViewSGDButton:(id)sender{

   
    
    Reachability *rchbility = [[Reachability reachabilityWithHostName: @"yeastgenome.org"] retain];;
    NetworkStatus remoteHostStatus = [rchbility currentReachabilityStatus];
    [rchbility release];
    
    //CHECKING 'WAN' CONNECTION AVAILABILITY
    if (remoteHostStatus == ReachableViaWWAN || remoteHostStatus == ReachableViaWiFi) 
    {
        
        @try {
            
            UIButton *btn = (UIButton*)sender;
            int buttonTag = btn.tag; 
            NSString *urlAddress;
            
            switch (buttonTag) {
                    
                case 0:
                    
                    urlAddress = [NSString stringWithFormat:@"http://yeastgenome.org/cgi-bin/getSeq?query=%@&format=fasta",selectedFeature.featureName];
                                        
                    break;
                    
                case 1:
                    urlAddress = [NSString stringWithFormat:@"http://yeastmine.yeastgenome.org/yeastmine/portal.do?externalids=%@",selectedFeature.dbxrefId];
                    break;
                    
                case 2:
                    
                    if([selectedFeature.geneName length]== 0){
                        urlAddress = [NSString stringWithFormat:@"http://spell.yeastgenome.org/search/show_results?num_genes=20&search_string=%@",selectedFeature.featureName];
                    }else{
                        
                        urlAddress = [NSString stringWithFormat:@"http://spell.yeastgenome.org/search/show_results?num_genes=20&search_string=%@",selectedFeature.geneName];
                    }
                    
                    break;
                    
                case 3:
                    urlAddress = [NSString stringWithFormat:@"http://www.yeastgenome.org/cgi-bin/locus.fpl?dbid=%@",selectedFeature.dbxrefId];
                    break;
                    
                default:
                    break;
            }
            
            
            
            //NSLog(@"URL address-->%@",urlAddress);
            [staticFunctionClass setBrowseImg:urlAddress];
            
            if (browseImgVC != nil)
            {
                [browseImgVC release];
                browseImgVC = nil;
            }
            browseImgVC = [[BrowseImgView alloc] initWithNibName:@"BrowseImgView_iPhone" bundle:[NSBundle mainBundle]];
            
            browseImgVC.title = self.title; 
            
            [self.navigationController pushViewController:browseImgVC animated:YES];
            
            //[browseImgVC release];
            
        }
        @catch (NSException * e) 
        {
            NSLog(@"%@",[e description]);
        }
        
        
        
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


//Called when Email button is clicked
-(IBAction)pushedEmailButton:(id)sender
{
    
    NSString *SubjectLine = [NSString stringWithFormat:@"%@, %@", self.title,@"Feature Details"];
    
    
    [staticFunctionClass setSubjectLine:SubjectLine];
    NSMutableArray *arrRec = [[NSMutableArray alloc] init];
    
    EmailViewController *emailView = [[EmailViewController alloc]initWithNibName:@"EmailViewController" bundle:[NSBundle mainBundle]];	
    
    NSString *eMailBody = @"";
    if ([selectedFeature.geneName length] > 0) {
        if ([aliasLabel.text length] > 0) {
            
            
            eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b>Standard Name:</b>%@<br><b>Systematic Name: <a href=\"http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%@\">%@</a><br><b>Description:</b>%@<br><b>Alias:</b>%@<br><b>Feature Type:</b>%@<br><b>SGD ID:</b>%@<br><b>Chromosomal Location:</b>%@</td></tr><br><br>",selectedFeature.geneName,systDetail.text,systDetail.text, selectedFeature.annotation.descriptions, featAliasesLabel.text, featTypeLabel.text, featPrimaryIdLabel.text, featLocInfoLabel.text];
            
        } else {
            eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b>Standard Name:</b>%@<br><b>Systematic Name: <a href=\"http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%@\">%@</a><br><b>Description:</b>%@<br><b>Feature Type:</b>%@<br><b>SGD ID:</b>%@<br><b>Chromosomal Location:</b>%@</td></tr><br><br>",selectedFeature.geneName,systDetail.text,systDetail.text, selectedFeature.annotation.descriptions, featTypeLabel.text, featPrimaryIdLabel.text, featLocInfoLabel.text];
        }
    }
    
    else {
        if ([aliasLabel.text length] > 0) {
            
            
            eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b>Systematic Name: <a href=\"http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%@\">%@</a><br><b>Description:</b>%@<br><b>Alias:</b>%@<br><b>Feature Type:</b>%@<br><b>SGD ID:</b>%@<br><b>Chromosomal Location:</b>%@</td></tr><br><br>",systDetail.text,systDetail.text, selectedFeature.annotation.descriptions, featAliasesLabel.text, featTypeLabel.text, featPrimaryIdLabel.text, featLocInfoLabel.text];
                
        } else {
            
            eMailBody = [eMailBody stringByAppendingFormat:@"<tr><td><b>Systematic Name: <a href=\"http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%@\">%@</a><br><b>Description:</b>%@<br><b>Feature Type:</b>%@<br><b>SGD ID:</b>%@<br><b>Chromosomal Location:</b>%@</td></tr><br><br>",systDetail.text,systDetail.text,selectedFeature.annotation.descriptions, featTypeLabel.text, featPrimaryIdLabel.text, featLocInfoLabel.text];
        } 
    }
	NSLog(@"%@",eMailBody);
	
    [staticFunctionClass setMessageBody:eMailBody];
    [arrRec release];
    
    [self.navigationController pushViewController:emailView animated:YES];
}

/*Called when Favorite Star icon is clicked 
 It checks the favorite status and set the gene/feature 
 favorite status accordingly.
 */
-(IBAction)pushedFavsButton:(id)sender 
{
	@try
	{
		static NSString *isFav;
		static int boolFav;
		static UIImage *image;
		
		// change button image for favorite
		
		if ([[NSString stringWithFormat:@"%d",selectedFeature.favorite] isEqualToString:@"1"]) 
		{
			
			isFav = @"0";
			boolFav = 0;
			image = [UIImage imageNamed:@"starOpen.png"];
        
        } else {
			
			isFav = @"1";
			boolFav = 1;
			image = [UIImage imageNamed:@"starFilledYellow.png"];
		}
		
		[favoriteButton setBackgroundImage:image forState:UIControlStateNormal];
		
	
		[selectedFeature setFavorite:boolFav];	
		
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
		
		
		
		SGD_2AppDelegate *app = (SGD_2AppDelegate*)[[UIApplication sharedApplication] delegate];
		[app.favoritesListVC LoadFavList];
		
		
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@",[e description]);
	}
	
		
}


-(void) imageChangeForOtherObj
{
	@try
	{
		
		UIImage *favImage;
		
		if ([[NSString stringWithFormat:@"%d",selectedFeature.favorite] isEqualToString:@"1"])
			favImage = [UIImage imageNamed:@"starFilledYellow.png"];
		else
			favImage = [UIImage imageNamed:@"starOpen.png"];
		
		[favoriteButton setBackgroundImage:favImage forState:UIControlStateNormal];		
	}
	@catch (NSException * e) 
	{
		NSLog(@"%@",[e description]);
	}
	
}
	 
#pragma mark -
#pragma mark Actionsheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	@try {
		NSString *SubjectLine = [NSString stringWithFormat:@"%@, %@", self.title,@"Feature Details"];
		
		
		[staticFunctionClass setSubjectLine:SubjectLine];
		NSMutableArray *arrRec = [[NSMutableArray alloc] init];
		
		EmailViewController *emailView = [[EmailViewController alloc]initWithNibName:@"EmailViewController" bundle:[NSBundle mainBundle]];	
   
        NSString *textDataString; 
        if ([aliasLabel.text length] > 0) {
					
            textDataString = [NSString stringWithFormat:@"Name Details:%@\nDescription:%@\nAlias:%@\nFeature Type:%@\nSGD ID:%@\nSequence Information:%@\n",featNameDetails.text, selectedFeature.annotation.descriptions,featAliasesLabel.text,featTypeLabel.text,featPrimaryIdLabel.text,featLocInfoLabel.text];
			
		} else {
		 textDataString = [NSString stringWithFormat:@"Name Details:%@\nDescription:%@\nFeature Type:%@\nSGD ID:%@\nSequence Information:%@\n",featNameDetails.text, selectedFeature.annotation.descriptions,featTypeLabel.text,featPrimaryIdLabel.text,featLocInfoLabel.text];
        }
       
		switch (buttonIndex) {
				
			case 0:
				
			                
                [staticFunctionClass setMessageBody:textDataString];
				
				
				[arrRec addObject:@"yeast-curator@genome.standfor.edu"];	
				
				[staticFunctionClass setRecipient:arrRec];
				[arrRec release];
				
				[self.navigationController pushViewController:emailView animated:YES];
				
				break;
				
			case 1:
	
				[staticFunctionClass setMessageBody:textDataString];

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


// MoreDetails Table 
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1; 
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
 
	}
 
 // Configure the cell...
	NSRange textRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
	if (textRange.location != NSNotFound) 
	{
		cell.textLabel.font = [UIFont systemFontOfSize:18];
	}
	else {
		cell.textLabel.font = [UIFont systemFontOfSize:14];
	}

	
	if (indexPath.row == 0) 
		cell.textLabel.text = [NSString stringWithFormat:@"Gene Ontology"];
	else if (indexPath.row == 1)
		cell.textLabel.text = [NSString stringWithFormat:@"Interactions"];
	else if (indexPath.row == 2)
		cell.textLabel.text = [NSString stringWithFormat:@"Phenotypes"];
	else if (indexPath.row == 3)
		cell.textLabel.text = [NSString stringWithFormat:@"References"];

	
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

#pragma mark -
#pragma mark Table view delegate
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    //NSLog(@"featTypeLabel:%@",featTypeLabel.text);
    
// Navigation logic may go here. Create and push another view controller.
	@try
	{
		[self updateUsedMoreInfoDate];
		
		[tblMoreDetails deselectRowAtIndexPath:indexPath animated:NO];
		if (indexPath.row == 0) 
		{
			FeatGoDetails *featGOVC = [[FeatGoDetails alloc] initWithNibName:@"FeatGoDetails" bundle:[NSBundle mainBundle]];
			
			featGOVC.title = self.title; 
			featGOVC.managedObjectContext = managedObjectContext;
			[self.navigationController pushViewController:featGOVC animated:YES];
			
			[featGOVC release];
		}
		else if (indexPath.row == 1)
		{
			FeatInteractionList *featInteractionVC = [[FeatInteractionList alloc] initWithNibName:@"FeatInteractionList" bundle:[NSBundle mainBundle]];
			featInteractionVC.title = @"Interaction Details";
			featInteractionVC.managedObjectContext = managedObjectContext;
			[self.navigationController pushViewController:featInteractionVC animated:YES];
			
			[featInteractionVC release];
		}
		else if (indexPath.row == 2)
		{
            FeatPhenoType *featPhenoVC = [[FeatPhenoType alloc] initWithNibName:@"FeatPhenoType" bundle:[NSBundle mainBundle]];
			featPhenoVC.title = @"Phenotype Details";
            
			if([featTypeLabel.text isEqualToString:@"not physically mapped"])
                featPhenoVC.isPhysNotMapped = TRUE;
            else
                featPhenoVC.isPhysNotMapped = FALSE;
			
            featPhenoVC.managedObjectContext = managedObjectContext;
			[self.navigationController pushViewController:featPhenoVC animated:YES];
			//[featPhenoVC release];
		}
		else if (indexPath.row == 3)
		{
			FeatReferencesDetails *featReferencesVC = [[FeatReferencesDetails alloc] initWithNibName:@"FeatReferencesDetails" bundle:[NSBundle mainBundle]];
			featReferencesVC.title = @"References";
            if([featTypeLabel.text isEqualToString:@"not physically mapped"])
                featReferencesVC.isPhysNotMapped = TRUE;
            else
                featReferencesVC.isPhysNotMapped = FALSE;

			featReferencesVC.managedObjectContext = managedObjectContext;
			[self.navigationController pushViewController:featReferencesVC animated:YES];
			
			[featReferencesVC release];
		}
	}
	@catch (NSException * e)
	{
		NSLog(@"%@",[e description]);
	}

}
							 

-(void)updateUsedMoreInfoDate
{
	@try
	{
		[selectedFeature setValue:[NSDate date] forKey:@"usedDateMoreInfo"];	
		
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
			NSLog(@"Couldn't save update date to more info date\n");
		}		  
		
		[dnc removeObserver:self
					   name:NSManagedObjectContextDidSaveNotification
					 object:managedObjectContext];
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
    
    // Release any cached data, images, etc that aren't in use.
}




- (void)dealloc 
{
	
    [super dealloc];
}

@end
