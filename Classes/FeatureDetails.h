//
//  FeatureDetails.h
//  SGD_2
//
//  Created by Vivek on 04/08/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Features.h"

#import "BrowseImgView.h"
#import "FeatGoDetails.h"
#import "FeatInteractionList.h"
#import "FeatPhenoType.h"
#import "FeatReferencesDetails.h"


@class FeatGoDetails;
@class FeatInteractionList;
@class FeatPhenoType;
@class FeatReferencesDetails;

@interface FeatureDetails : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> 
{
    
    IBOutlet UILabel		*standardLabel;
    IBOutlet UILabel		*systLabel;
	IBOutlet UILabel		*descLabel;
	IBOutlet UILabel		*aliasLabel;
	IBOutlet UILabel		*locLabel;
	IBOutlet UILabel		*typeLabel;
	
	IBOutlet UILabel		*featDescLabel;
	IBOutlet UILabel		*featAliasesLabel;
	IBOutlet UILabel		*featLocInfoLabel;
	IBOutlet UILabel		*featTypeLabel;
    
	IBOutlet UIView			*contentView;
	IBOutlet UIView			*moreInfoLinks;
    
	IBOutlet UILabel		*standardDetail;
    IBOutlet UILabel		*systDetail;

	IBOutlet UILabel		*primaryIdentifer;
	IBOutlet UILabel		*featPrimaryIdLabel;
	IBOutlet UILabel		*nameDescription;
	IBOutlet UILabel		*featNameDetails;
	IBOutlet UIImageView	*gBrowseImage;
    IBOutlet UIButton       *browseBtn;
	IBOutlet UILabel		*gBrowseLabel;
	IBOutlet UITableView	*tblMoreDetails;
	
    IBOutlet UILabel		*viewAtSGD;

    IBOutlet UIButton		*sequenceButton;
    IBOutlet UIButton		*yeastmineButton;
    IBOutlet UIButton		*spellButton;
    IBOutlet UIButton		*locusButton;


	Features				*selectedFeature;
	BrowseImgView           *browseImgVC;
    
	UIButton				*favoriteButton;
	UIButton				*EmailButton;

	NSString				*featName;
	
    // set up delegate to notifiy view controller when favorites change
	NSManagedObjectContext	*managedObjectContext;
    
    UIActivityIndicatorView	*activityIndView;
    
    UIActivityIndicatorView *av;
    
  
}

@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) UIView                 *contentView;
@property(nonatomic, retain) UIView                 *moreInfoLinks;
@property(nonatomic, retain) NSString               *featName;


@property(nonatomic, retain) Features				*selectedFeature;
@property(nonatomic, retain) BrowseImgView          *browseImgVC;

//Buttons actions declare
-(IBAction)pushedViewSGDButton:(id)sender;

-(IBAction)pushedFavsButton:(id)sender;
-(IBAction)pushedEmailButton:(id)sender;
-(IBAction)pushedBrowseButton:(id)sender;

//Declare Setting label size and position
-(void)setLabelSizeFor:(UILabel *)labelToSet labelText:(NSString *)labelText;
-(void)setViewYOriginFor:(UIView *)viewToSet previousView:(UIView *)previousViewName;
-(void)setViewXOriginFor:(UIView *)viewToSet previousView:(UIView *)previousViewName;
-(void)setViewYOriginFor: (UIView *)viewToSet previousView:(UIView *)previousLabelView previousDetailView:(UIView *)detailView;
-(void)setViewYOriginForViewAtSGD:(UIView *)viewToSet previousView:(UIView *)previousViewName;

-(void)setLabelSizeFor: (UILabel *)labelToSet detailview:(UILabel *)detailview;
-(void)setLabelSizeFor: (UILabel *)labelToSet gbrowseview:(UIImageView *)browseview;

-(void)setViewYOriginFor: (UIView *)viewToSet labelView:(UIView *)previousView;
-(void)setViewXButtonOriginFor: (UIButton *)buttonToSet previousView:(UIView *)previousView;

-(void) imageChangeForOtherObj;
-(void) setLabelWidthFor: (UIView *)labelToSet newWidth: (int) newWidth;
-(void) updateUsedMoreInfoDate;
-(NSString *)contentTypeForImageData:(NSData *)data;

@end




