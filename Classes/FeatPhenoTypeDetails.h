//
//  FeatPhenoTypeDetails.h
//  SGD_2
//
//  Created by Vivek on 14/06/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "webServiceHelper.h"
#import "Features.h"
#import <QuartzCore/QuartzCore.h>
#import "webServiceHelper.h"
#import "BrowseImgView.h"


@class Features;
@interface FeatPhenoTypeDetails : UIViewController <UIActionSheetDelegate,UIAlertViewDelegate, DownloadCompleteDelegate>
{
	IBOutlet UILabel            *lblTitle;
	IBOutlet UILabel			*observableLabel;
	IBOutlet UILabel			*qualifierLabel;
	IBOutlet UILabel			*expTypeLabel;
	IBOutlet UILabel			*mutantInfoLabel;
	IBOutlet UILabel			*referencesLabel;
	
	IBOutlet UILabel			*observableTitle;
	IBOutlet UILabel			*expTypeTitle;
	IBOutlet UILabel			*qualifierTitle;
	IBOutlet UILabel			*mutantInfoTitle;
	IBOutlet UILabel			*referencesTitle;
    IBOutlet UIButton           *referenceBtn;
	
    IBOutlet UILabel            *indicator1;

	IBOutlet UIView				*contentView;
	
	UIAlertView					*progAlertView;
	UIActivityIndicatorView		*activityIndView;
	
	NSManagedObjectContext		*managedObjectContext;	
	UIButton					*EmailButton;
	Features					*selectedFeatures;
    BOOL                        onlyReference;
}
@property (nonatomic, retain) NSManagedObjectContext		*managedObjectContext;	
@property (nonatomic, retain) Features                      *selectedFeatures;
@property (nonatomic, retain) UIAlertView                   *progAlertView;
@property (nonatomic, retain) UIActivityIndicatorView       *activityIndView;


@property BOOL onlyReference;

- (void)createProgressionAlertWithMessage:(NSString *)message;
- (void)webServiceCall:(NSString *)webserviceName;
- (void)getResultsAndInsert:(NSDictionary *)resultSet;

//Declare Setting label size and position
- (void)setLabelSizeFor: (UILabel *)labelToSet labelText:(NSString *)labelText;
- (void)setLabelWidthFor: (UIView *)labelToSet newWidth: (int) newWidth;
- (void)setButtonWidthFor: (UIView *)labelToSet newWidth: (int) newWidth;
- (void)setViewYOriginFor: (UIView *)viewToSet previousView:(UIView *)previousView;
- (void)setLabelSizeFor: (UILabel *)labelToSet detailview:(UILabel *)detailview ;


-(IBAction)pushedEmailButton:(id)sender;
-(IBAction)pushedReferenceButton:(id)sender;

@end
