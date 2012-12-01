//
//  SearchViewController.h
//  SGD_2
//
//  Created by Vishwanath on 08/07/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeatureDetails.h"
#import "sqlite3.h"
#import "JSON.h"
#import "webServiceHelper.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define CHARACTERS          @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-()[]"
#define CHARACTERS_NUMBERS  [CHARACTERS stringByAppendingString:@"1234567890"]

@class webServiceHelper;
@class FeatureDetails;
@interface SearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource,DownloadCompleteDelegate, MFMailComposeViewControllerDelegate>{
	NSString *URLAddress;
    
	UISearchBar					*sBar;
	UITableView					*searchResultsTable;
	UIAlertView					*progAlertView;
	UIActivityIndicatorView		*activityIndView;
	
	
	NSMutableArray				*featsList; //storing the data that is displayed in the table
    NSMutableArray				*selectedArray;
    
	
	BOOL						searching;
	BOOL						letUserSelectRow;
    BOOL                        gotsearchresult;
	
	NSManagedObjectContext		*managedObjectContext;
    
	webServiceHelper			*searchGeneRequest;
	FeatureDetails				*searchFeatureDetailsVC;
    
    BOOL						inPseudoEditMode;
    UIImage						*selectedImage;
	UIImage						*unselectedImage;
    UIButton                    *EditButton;
    UIButton                    *CancelButton;
    UIButton                    *EmailButton;
    
    NSMutableArray              *allFeatsToShow;
    
    int page;
    int tpages;
    int adjacents;
    NSMutableString             *geneSearchText;
    
    NSArray                     *array;
    
    UIActivityIndicatorView     *progressInd;
    UIActivityIndicatorView     *ProgressSearch;
	UIView                      *fadeView;
    int cntScroll;
    NSInteger                   firstScrollOffset;
    BOOL                        isAlias;
    
    BOOL                        isDescription;
    
    int                         currentLastCell;
    BOOL                        isScroll;
    
    int                         test;
    
    MFMailComposeViewController *controller;
}


@property (nonatomic, assign) int currentLastCell;
@property (nonatomic, retain) NSArray                   *array;
@property (nonatomic, retain) NSMutableString           *geneSearchText;
@property (nonatomic, retain) NSManagedObjectContext    *managedObjectContext;

@property (nonatomic, retain) webServiceHelper          *searchGeneRequest;

@property (nonatomic, retain) FeatureDetails            *searchFeatureDetailsVC;

@property (nonatomic, retain) UIAlertView               *progAlertView;
@property (nonatomic, retain) UIActivityIndicatorView   *activityIndView;
@property (nonatomic, retain) UIActivityIndicatorView   *ProgressSearch;

@property (nonatomic, retain) IBOutlet UISearchBar		*sBar;
@property (nonatomic, retain) IBOutlet UITableView		*searchResultsTable;
@property (nonatomic, retain) NSMutableArray			*featsList;
@property (nonatomic, retain) NSMutableArray            *selectedArray;

@property BOOL inPseudoEditMode;

@property (nonatomic, retain) UIImage  *selectedImage;
@property (nonatomic, retain) UIImage  *unselectedImage;
@property (nonatomic, retain) UIButton *CancelButton;
@property (nonatomic, retain) UIButton *EditButton;

@property(nonatomic, retain)NSString *URLAddress;

-(void)Pagination;
-(void)webServiceRequest:(NSString *)webserviceName;
-(void)getResultsAndInsert:(NSDictionary *)resultSet;
-(void)reloadTableWithNewData;
-(void)finishedDownloading:(NSString *)strJSONResponse;

-(void)populateSelectedArray;
-(void)pushedFavButton:(id)sender;
-(void)addToFavourite;


-(void)pushedCancelButton:(id)sender;
-(void)refreshTable;


@end

 

