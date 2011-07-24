//
//  StandardOutputRedirector.m
//  Redirector
//
//  Created by Zacharias Pasternack on 7/7/11.
//  Copyright 2011 Fat Apps, LLC. All rights reserved.
//

#import "StandardOutputRedirector.h"


enum { READ, WRITE };


@implementation StandardOutputRedirector


#pragma mark - Memory Management


- (id) init
{
    if( (self = [super init]) ) {
		redirectedOutput = [[NSMutableString alloc] init];
		
		if( pipe( redirectionPipe ) != -1 ) {
			oldStandardOutput = dup( fileno(stdout) );
			oldStandardError = dup( fileno(stderr) );
		}
		setbuf( stdout, NULL );
		setbuf( stderr, NULL );
    }
    
    return self;
}


- (void) dealloc
{
	if( redirecting ) {
		[self stopRedirecting];
	}
	
	if( oldStandardOutput > 0 ) {
		close( oldStandardOutput );
	}
	if( oldStandardError > 0 ) {
		close( oldStandardError );
	}
	if( redirectionPipe[READ] > 0 ) {
		close( redirectionPipe[READ] );
	}
	if( redirectionPipe[WRITE] > 0 ) {
		close( redirectionPipe[WRITE] );
	}
	
	[redirectedOutput release];
	
    [super dealloc];
}


#pragma mark - Public methods


- (void) startRedirecting
{
	if( redirecting ) return;
	
	dup2( redirectionPipe[WRITE], fileno(stdout) );
	dup2( redirectionPipe[WRITE], fileno(stderr) );
	redirecting = true;
}


- (void) stopRedirecting
{
	if( !redirecting ) return;
	
	dup2( oldStandardOutput, fileno(stdout) );
	dup2( oldStandardError, fileno(stderr) );
	redirecting = false;
}


- (NSString*) output
{
	const size_t bufferSize = 4096;
	char buffer[bufferSize];
	fcntl( redirectionPipe[READ], F_SETFL, O_NONBLOCK );	
	ssize_t bytesRead = read( redirectionPipe[READ], buffer, bufferSize - 1 );
	while( bytesRead > 0 ) {
		buffer[bytesRead] = 0;
		NSString* tempString = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
		[redirectedOutput appendString:tempString];
		bytesRead = read( redirectionPipe[READ], buffer, bufferSize );
	}
	
	return [NSString stringWithFormat:@"%@", redirectedOutput];
}


- (void) clearOutput
{
	[redirectedOutput setString:@""];
}


@end
