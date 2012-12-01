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

@synthesize webData,delegate;

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
    
	if( theConnection )
	{
		
		if (webData != nil) {
			webData = nil;
		}
        
        bytesCount = 0;
		webData = [[NSMutableData data] retain];
	}
	else
	{
		[delegate finishedDownloading:[NSString stringWithFormat:@""]];
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
	}
	else
	{
		[delegate finishedDownloading:[NSString stringWithFormat:@""]];
	}
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	
	if ([httpResponse statusCode] >= 400)
	{
		// do error handling here
		[delegate finishedDownloading:[NSString stringWithFormat:@""]];
	} 
	else {
	}
	
	// Check for webdata and init webdata
	if (webData != nil) {
		webData = nil;
		
	}
	webData = [[NSMutableData data] retain];
}	

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	bytesCount = bytesCount + [data length];

	[webData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	@try
	{
        
        
		[delegate finishedDownloading:[NSString stringWithFormat:@""]];
        
	}
	@catch (NSException *e) {
		NSLog(@"%@",[e description]);
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	@try
	{
               
		if ([webData length] != 0)
		{
			NSString *jsonResponse = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];

			[delegate finishedDownloading:jsonResponse]; // notify delegate download finished
		}
		else
		{
			//ERROR HANDLING
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
