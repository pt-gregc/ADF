/* 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	cs5-overrides.js
Summary:
	ADF Lightbox Framework JavaScript
Version:
	1.0.0
History:
    2010-02-19 - MFC - Created
	2014-01-03 - GAC - Added Comment Headers
					 - Added missing semi-colons to the ends of variablized functions
*/

lbResizeWindow = function()
{
	doRecalc = false;
	curTab = commonspot.lightbox.stack.length;

	if (typeof ResizeWindowSafe != 'undefined')		// this variable is set in dlgcommon-head for legacy dialogs (initially set to 0, then to 1 upon calling dlgcommon-foot)
	{ 
		if (ResizeWindowSafe == 1)
			lbResizeWindow_Meat(doRecalc, curTab);  // this function is defined in over-rides.js
		else
			ResizeWindowCalledCount = ResizeWindowCalledCount + 1;
	}
	else
		lbResizeWindow_Meat(doRecalc, curTab);  // this function is defined in over-rides.js
};

lbResizeWindow_Meat = function(doRecalc, currentTab)
{
	var maintable = document.getElementById('MainTable');
	if (maintable)
	{
     if (doRecalc)
		{
			if (top.commonspot)
			{
        	top.commonspot.lightbox.initCurrentServerDialog(currentTab);
				lbResizeWindow_Meat();
			}	
		}
     else
		{
			if (maintable.offsetHeight < 80)
				maintable.style.height = '80px';
			else
				maintable.style.height = '';
			
			if (top.commonspot)
        		top.commonspot.lightbox.initCurrent( maintable.offsetWidth, maintable.offsetHeight + 40);
		}	
	}	
};