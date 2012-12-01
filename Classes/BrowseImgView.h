//
//  BrowseImgView.h
//  SGD_2
//
//  Created by Vivek on 8/10/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sys/xattr.h>

@interface BrowseImgView : UIViewController<UIWebViewDelegate,UIAlertViewDelegate> {
    
    IBOutlet UIWebView               *wBrowseImg;
    IBOutlet UIActivityIndicatorView *m_activity; 
//	IBOutlet UIImageView *gBrowseImg;
    
}

@property (nonatomic, retain) UIWebView               *wBrowseImg;
@property (nonatomic, retain) UIActivityIndicatorView *m_activity;
//@property (nonatomic, retain) UIImageView *gbrowseImge;

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end
