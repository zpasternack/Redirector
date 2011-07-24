//
//  OutputRedirector.cpp
//
//  Created by Zacharias Pasternack on 6/3/11.
//  Copyright 2011 Fat Apps, LLC. All rights reserved.
//

#include "OutputRedirector.h"

#include <fcntl.h>

using namespace std;

enum PIPES { READ, WRITE };


// -------------------------------------------------------------
// CStdoutRedirector (IOutputRedirector)
//
// Redirect stdout, stderr on demand.
// -------------------------------------------------------------

CStdoutRedirector::CStdoutRedirector()
: IOutputRedirector()
, _oldStdOut( 0 )
, _oldStdErr( 0 )
, _redirecting( false )
{
	_pipe[READ] = 0;
	_pipe[WRITE] = 0;
	if( pipe( _pipe ) != -1 ) {
		_oldStdOut = dup( fileno(stdout) );
		_oldStdErr = dup( fileno(stderr) );
	}
	
	setbuf( stdout, NULL );
	setbuf( stderr, NULL );
}


CStdoutRedirector::~CStdoutRedirector()
{
	if( _redirecting ) {
		StopRedirecting();
	}

	if( _oldStdOut > 0 ) {
		close( _oldStdOut );
	}
	if( _oldStdErr > 0 ) {
		close( _oldStdErr );
	}
	if( _pipe[READ] > 0 ) {
		close( _pipe[READ] );
	}
	if( _pipe[WRITE] > 0 ) {
		close( _pipe[WRITE] );
	}
}


void
CStdoutRedirector::StartRedirecting()
{
	if( _redirecting ) return;
	
	dup2( _pipe[WRITE], fileno(stdout) );
	dup2( _pipe[WRITE], fileno(stderr) );
	_redirecting = true;
}


void
CStdoutRedirector::StopRedirecting()
{
	if( !_redirecting ) return;

	dup2( _oldStdOut, fileno(stdout) );
	dup2( _oldStdErr, fileno(stderr) );
	_redirecting = false;
}


string
CStdoutRedirector::GetOutput()
{
	const size_t bufSize = 4096;
	char buf[bufSize];
	fcntl( _pipe[READ], F_SETFL, O_NONBLOCK );	
	ssize_t bytesRead = read( _pipe[READ], buf, bufSize - 1 );
	while( bytesRead > 0 ) {
		buf[bytesRead] = 0;
		_redirectedOutput += buf;
		bytesRead = read( _pipe[READ], buf, bufSize );
	}
	
	return _redirectedOutput;
}


void
CStdoutRedirector::ClearOutput()
{
	_redirectedOutput.clear();
}
