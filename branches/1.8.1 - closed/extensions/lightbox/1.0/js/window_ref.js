/* 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
*/

/* *************************************************************** */
/*
Author: 	
	PaperThin Inc.
Name:
	windows_ref.js
Summary:
	ADF Lightbox Framework JavaScript
Version:
	1.0.0
History:
	2010-02-19 - MFC - Created
	2014-01-03 - GAC - Added Comment Headers
*/

/*
JavaScript routines to resolve references for windows inside lightbox
*/

function getOpener(ignoreOpenerProperty)
{
	if(top && (self != top) && (typeof(top.commonspot.lightbox)!= 'undefined'))
	{
		return top.commonspot.lightbox.getOpenerWindow(ignoreOpenerProperty);
	}
	else
	{
		return self.opener;
	}
}

function getRTEopener(FrameName)
{
	// Grab the window object out of the RTE's iframe
	if (!FrameName)
		FrameName = 'WebEdit';
	var fr = null;
	for (var i=top.commonspot.lightbox.stack.length-1; i>=0; i--)
	{
		if(top.commonspot.lightbox.stack.length == 1)
			fr = top.commonspot.lightbox.getOpenerWindow().document.getElementById(FrameName);
		else
			fr = top.commonspot.lightbox.stack[i].getWindow().document.getElementById(FrameName);
		if (fr)
			return fr.contentWindow;
	}
	return fr;
}

function hasLightbox()
{
	return ((top != self) && (typeof(top.commonspot.lightbox)!= 'undefined'));
}

var cleanHTMLWnd;
var spellcheckerWnd;
function getCleanHTMLTarget()
{
	if((self != top) && (typeof(top.commonspot.lightbox)!= 'undefined'))
	{
		var frName;
		for (var i=0; i<top.commonspot.lightbox.stack.length; i++)
		{
			frName = top.commonspot.lightbox.stack[i].getFrameName();
			if (frName == 'cleanHTML')
				return frName;
		}	
		var lightboxTarget = openEmptyLightBox('/commonspot/dhtmledit/clean_dhtml_stub.cfm', null, 'cleanHTML');
		return top.commonspot.lightbox.getFrameName();
	}
	else
	{
		if (!cleanHTMLWnd || cleanHTMLWnd.closed)
			cleanHTMLWnd = newWindow( 'cleanHTML', '/commonspot/dhtmledit/clean_dhtml_stub.cfm' );
		return 'cleanHTML';	
	}
	
}

function getSpellCheckTarget()
{
	if((self != top) && (typeof(top.commonspot.lightbox)!= 'undefined'))
	{
		// Open an empty lightbox
		var frName;
		for (var i=0; i<top.commonspot.lightbox.stack.length; i++)
		{
			frName = top.commonspot.lightbox.stack[i].getFrameName();
			if (frName == 'spellchecker')
				return frName;
		}	
		var lightboxTarget = openEmptyLightBox('/commonspot/spellchk/introscreen.cfm', null, 'spellchecker');
		return top.commonspot.lightbox.getFrameName();
	}
	else
	{
		if (!spellcheckerWnd || spellcheckerWnd.closed)
			spellcheckerWnd = newWindow( 'spellchecker', '/commonspot/spellchk/introscreen.cfm' );
		return 'spellchecker';	
	}
	
}

function closeCleanHTMLWindows()
{
	if((typeof(top.commonspot.lightbox)!= 'undefined'))
	{
		var win;
		for (var i=0; i<top.commonspot.lightbox.stack.length; i++)
		{
			win = top.commonspot.lightbox.stack[i];
			frName = win.getFrameName();
			if(frName == 'cleanHTML')
				win.close();
		}
	}
	else
	{
		if (self.children)
		{
			for(i=0;i<self.children.length;i++)
				self.children[i].close();
		}
	}
}

function openEmptyLightBox(url, hideClose, name, customOverlayMsg)
{
	var lightboxTarget;	
	var url = url ? url : null;
	var hideClose = hideClose ? hideClose : null;
	var name = name ? name : null;
	var customOverlayMsg = customOverlayMsg ? customOverlayMsg : null;
	// If we are inside a lightbox
	if (typeof(top.commonspot.lightbox)!= "undefined")
	{
		// Open an empty lightbox
		top.commonspot.lightbox.openDialog(url, hideClose, name, customOverlayMsg, null, null, true);
		
		lightboxTarget = top.commonspot.lightbox.getFrameName();
		// Form's target now must be the lightbox, not a new window
		return lightboxTarget;
	}
	else
		return;
}

// returns contentWindow of admin-frame
function getAdminWindow()
{
	var win = null;
	if (typeof(top.commonspot.lightbox) != 'undefined')
		win = top.commonspot.lightbox.getAdminWindow();
	return win;	
}
