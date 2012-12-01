//
//  CustomURLConnection.h
//  bioGPS
//
//  Created by Vishwanath Deshmukh on 2/20/12. 
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomURLConnection : NSURLConnection {
    NSString *tag;
}

@property (nonatomic, retain) NSString *tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)tag;

@end