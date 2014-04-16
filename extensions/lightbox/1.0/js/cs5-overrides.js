
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
}

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
}