//
//  webServiceHelper.h
//  SGD_Vivek
//
//  Created by Vivek on 11/05/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/xattr.h>

@protocol DownloadCompleteDelegate <NSObject>

@required
- (void)finishedDownloading:(NSString *)jsonResponse;
@end

@interface webServiceHelper : NSObject  
{
	NSMutableData				*webData;
	id <DownloadCompleteDelegate> delegate;		
}

@property(nonatomic, retain) NSMutableData *webData;
@property (nonatomic, assign) id <DownloadCompleteDelegate> delegate;

-(void)startConnection:(NSString*)urlrequest;
-(void)startConnectionwithoutEncoding:(NSString*)urlrequest;
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end

