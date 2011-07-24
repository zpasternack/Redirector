//
//  OutputRedirector.h
//
//  Created by Zacharias Pasternack on 6/3/11.
//  Copyright 2011 Fat Apps, LLC. All rights reserved.
//

#ifndef _OUTPUTREDIRECTOR_H_
#define _OUTPUTREDIRECTOR_H_

#include <string>


class IOutputRedirector
{
public:
			IOutputRedirector()	{}
	virtual	~IOutputRedirector(){}
	
	virtual void	StartRedirecting() = 0;
	virtual void	StopRedirecting() = 0;
	
	virtual std::string	GetOutput() = 0;
	virtual void		ClearOutput() = 0;
};


class CStdoutRedirector : public IOutputRedirector
{
public:
	CStdoutRedirector();
	virtual	~CStdoutRedirector();
	
	virtual void	StartRedirecting();
	virtual void	StopRedirecting();
	
	virtual std::string	GetOutput();
	virtual void		ClearOutput();
	
private:
    int		_pipe[2];
    int		_oldStdOut;
    int		_oldStdErr;
    bool	_redirecting;
	std::string _redirectedOutput;
};

#endif /* _OUTPUTREDIRECTOR_H_ */
