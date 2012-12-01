//
//  FavoritesListViewController.h
//  SGD_2
//
//  Created by Vivek on 08/07/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeatureDetails.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class FeatureDetails;

@interface FavoritesListViewController : UITableViewController <UIAlertViewDelegate,MFMailComposeViewControllerDelegate >{
    
	NSMutableArray              *favFeatsList;
	NSMutableArray				*selectedArray;
    
	NSManagedObjectContext      *managedObjectContext;
	
	FeatureDetails              *favFeatureDetailsVC;
    
    BOOL						inPseudoEditMode;
    UIImage						*selectedImage;
	UIImage						*unselectedImage;
    UIButton                    *EditButton;
    UIButton                    *CancelButton;
    UIButton                    *EmailButton; 
    
	 MFMailComposeViewController *controller;
}

@property (nonatomic, retain) NSMutableArray         *favFeatsList;
@property (nonatomic, retain) NSMutableArray         *selectedArray;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) FeatureDetails         *favFeatureDetailsVC;

@property BOOL inPseudoEditMode;

@property (nonatomic, retain) UIImage  *selectedImage;
@property (nonatomic, retain) UIImage  *unselectedImage;
@property (nonatomic, retain) UIButton *CancelButton;
@property (nonatomic, retain) UIButton *EditButton;


-(void)LoadFavList;
-(void)pushedExFavoritesButton:(id)sender;
-(void)pushedSelectedButton:(id)sender;
-(void)pushedEditButton:(id)sender;
-(void)pushedCancelButton:(id)sender;

-(void)deletefavorite;

-(void)doFavoriteExp;
-(void)populateSelectedArray;



@end
