//
//  StandardOutputRedirector.h
//  Redirector
//
//  Created by Zacharias Pasternack on 7/7/11.
//  Copyright 2011 Fat Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StandardOutputRedirector : NSObject
{
    int	redirectionPipe[2];
    int	oldStandardOutput;
    int	oldStandardError;
    BOOL redirecting;
	NSMutableString* redirectedOutput;
}
- (void) startRedirecting;
- (void) stopRedirecting;
- (NSString*) output;
- (void) clearOutput;
@end
