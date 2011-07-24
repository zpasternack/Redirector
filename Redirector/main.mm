//
//  main.cpp
//  Redirector
//
//  Created by Zacharias Pasternack on 7/2/11.
//  Copyright 2011 Fat Apps, LLC. All rights reserved.
//

#include "OutputRedirector.h"

#import <Foundation/Foundation.h>
#import "StandardOutputRedirector.h"

#include <iostream>

#include <stdio.h>
#include <assert.h>

void RunStdoutRedirectorTest()
{
	CStdoutRedirector theRedirector;
	printf( "This is not redirected" );
	
	theRedirector.StartRedirecting();
	printf( "This is redirected" );
	assert( theRedirector.GetOutput() == "This is redirected" 
		   && "stdout not redirected!" );
	theRedirector.ClearOutput();
	assert( theRedirector.GetOutput().length() == 0 
		   && "redirector not cleared" );
	
	fprintf( stderr, "Redirected Error" );
	assert( theRedirector.GetOutput() == "Redirected Error" 
		   && "stderr not redirected" );
	theRedirector.ClearOutput();
	assert( theRedirector.GetOutput().length() == 0 
		   && "redirector not cleared" );
	
	theRedirector.StopRedirecting();	
	std::cout << "This is also not redirected";
	assert( theRedirector.GetOutput().length() == 0
		   && "redirection not stopped!" );
	
	theRedirector.StartRedirecting();
	fprintf( stdout, "stdout" );
	fprintf( stderr, "stderr" );
	printf( "stdout again" );
	assert( theRedirector.GetOutput() == "stdoutstderrstdout again" 
		   && "stdout, stderr not properly interleaved" );
}

void RunStdoutRedirectorTestWithSize( size_t outputSize )
{
	CStdoutRedirector theRedirector;
	theRedirector.StartRedirecting();
	int bytesWritten = 0;
	while( bytesWritten < outputSize ) {
		bytesWritten += printf( "This is a test - %d\n", bytesWritten );
	}
	theRedirector.StopRedirecting();
	
	std::string result = theRedirector.GetOutput();
	std::cout << result << std::endl;
}

void RunObjcRedirectorTest()
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	StandardOutputRedirector* theRedirector = [[StandardOutputRedirector alloc] init];
	printf( "This is not redirected" );
	
	[theRedirector startRedirecting];
	printf( "This is redirected" );
	assert( [[theRedirector output] isEqualToString:@"This is redirected"] 
		   && "stdout not redirected!" );
	[theRedirector clearOutput];
	assert( [[theRedirector output] length] == 0 
		   && "redirector not cleared" );
	
	fprintf( stderr, "Redirected Error" );
	assert( [[theRedirector output] isEqualToString:@"Redirected Error"]
		   && "stderr not redirected" );
	[theRedirector clearOutput];
	assert( [[theRedirector output] length] == 0 
		   && "redirector not cleared" );
	
	[theRedirector stopRedirecting];
	std::cout << "This is also not redirected";
	assert( [[theRedirector output] length] == 0
		   && "redirection not stopped!" );
	
	[theRedirector startRedirecting];
	fprintf( stdout, "stdout" );
	fprintf( stderr, "stderr" );
	printf( "stdout again" );
	assert( [[theRedirector output] isEqualToString:@"stdoutstderrstdout again"]
		   && "stdout, stderr not properly interleaved" );
	
	[pool drain];
}

int main (int argc, const char * argv[])
{
	RunStdoutRedirectorTest();
	
	// If this is any larger than 16kB, the stdout
	// internal buffer will fill up, and subsequent
	// calls to printf() et. al. will block.
	RunStdoutRedirectorTestWithSize( 16000 );
	
	RunObjcRedirectorTest();
	
	return 0;
}
