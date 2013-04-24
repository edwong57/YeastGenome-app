//
//  webServiceHelper.m
//  SGD_Vivek
//
//  Created by Vivek on 11/05/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "webServiceHelper.h"
#import "SBJSON.h"
#import "SGD_2AppDelegate.h"

@implementation webServiceHelper

@synthesize webData, delegate, httpR;

int bytesCount;
#pragma mark -
#pragma mark Web Service Call 

-(void)startConnection:(NSString*)urlrequest
{
	urlrequest = [urlrequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
	NSURL *myWebserverURL = [[NSURL alloc] initWithString:urlrequest];
    
    [self addSkipBackupAttributeToItemAtURL:myWebserverURL];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myWebserverURL];
	//NSLog(@"URL--%@",urlrequest);

	NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	[myWebserverURL release];
    
	if( theConnection ) {
		
		if (webData != nil) {
			webData = nil;
		}
        
        bytesCount = 0;
            
        webData = [[NSMutableData data] retain];
        NSLog(@"connection made");
         
 	} else {
        NSLog(@"No data returned");
    
        UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
        [dialog setDelegate:self];
        [dialog setTitle:@"YeastMine is temporarily unavailable."];
        [dialog setMessage:@"Please try your search again shortly. If the problem persists, please contact SGD at sgd-  helpdesk@lists.stanford.edu"];
        [dialog addButtonWithTitle:@"Ok"];
        [dialog show];
        [dialog release];
//[delegate finishedDownloading:[NSString stringWithFormat:@""]];
	}
	
}


-(void)startConnectionwithoutEncoding:(NSString*)urlrequest
{
    urlrequest = [urlrequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    urlrequest = [urlrequest stringByReplacingOccurrencesOfString:@"%252B" withString:@"%2B"];
    
	NSURL *myWebserverURL = [[NSURL alloc] initWithString:urlrequest];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myWebserverURL];
	//NSLog(@"URL--%@",urlrequest);
    
	NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	[myWebserverURL release];
    
	if( theConnection )
	{
		
		if (webData != nil) {
			webData = nil;
		}
        
        bytesCount = 0;
		webData = [[NSMutableData data] retain];
        
        NSLog(@"webData: %@", webData);
        
      
       // [delegate finishedDownloading:[NSString stringWithFormat:@""]];

 	}
else
{ NSLog(@"Err in startconnectionwithoutencoding");
    
//		[delegate finishedDownloading:[NSString stringWithFormat:@""]];
	}
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    httpR = [httpResponse statusCode];
   
	if (httpR >= 400) {
 		// do error handling here // add something to go back
        
        NSLog(@"Response error: %d", httpR);
        [delegate alternateResponse:httpR];
 
        
	} else {
        NSLog(@"Response: %d", [httpResponse statusCode]);

	// Check for webdata and init webdata
	if (webData != nil) {
		webData = nil;
		
        bytesCount = 0;

	}
	webData = [[NSMutableData data] retain];
    
    }
}	

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//	NSLog(@"pre bytes count: %d", bytesCount);
  //  NSLog(@" data: %@", temp);
    bytesCount = bytesCount + [data length];

	[webData appendData:data];
//    NSLog(@"got data %d", bytesCount);
}



-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	@try
	{
        NSLog(@"connection failed: %@", error);
        
        [delegate quitWebServices:[NSString stringWithFormat:@""]];
        
		//[delegate finishedDownloading:[NSString stringWithFormat:@""]];
        
	}
	@catch (NSException *e) {
		NSLog(@"%@",[e description]);
   //     return [NSString stringWithFormat:(@"%@", e)];
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	@try
	{
        NSLog(@"connection done retrieving data, %d", [webData length]);
               
		if ([webData length] != 0)
		{

                if (httpR > 200) {
   
                    [delegate alternateResponse:httpR];
      
                } else {
                    NSString *jsonResponse = [[NSString alloc] initWithBytes:
                                     [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];

                    [delegate finishedDownloading:jsonResponse]; // notify delegate download finished
                }
      }
		else
		{
			//ERROR HANDLING
            NSLog(@"finished loading err");
            
			[delegate finishedDownloading:@""];
		}
		
	}
	@catch (NSException *e) 
	{
		NSLog(@"%@",[e description]);
	}
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    
    
    const char* attrName = "com.apple.MobileBackup";
    
    u_int8_t attrValue = 1;
    
    
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    return result == 0;
    
}

@end
