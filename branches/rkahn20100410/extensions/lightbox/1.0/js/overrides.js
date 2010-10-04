/* 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
*/
/* *************************************************************** */
/*
Author: 	
	PaperThin Inc.
	M. Carroll
Name:
	overrides.js
Summary:
	ADF Lightbox Framework JavaScript
Version:
	1.0.0
History:
	2010-02-19 - MFC - Created
	2010-04-19 - MFC - Commented out some functions that conflict with CS 5.x styles.
*/


/* 
 * overrides.js   Copyright PaperThin, Inc.
 */
if (typeof BrowserCheck != 'undefined')
	var is = BrowserCheck();
if ((typeof top.commonspot != 'undefined') && (typeof top.commonspot.lightbox != 'undefined'))
{ 
	checkDlg = function()
	{
		ResizeWindow();
	}

	CloseWindow = function()
	{
		top.commonspot.lightbox.closeCurrent();
	}

	cs_OpenURLinOpener = function(workUrl)
	{
		OpenURLInOpener(workUrl);
	}

	doCPOpenInOpener = function(workUrl)
	{
		OpenURLInOpener(workUrl);
	}

	DoFocus = function(){};

	handleLoad = function()
	{
		ResizeWindow();
	}
	
	
	
	
	/* 
	 *	ADF Update
	 */
	/*
	newWindow = function(name, url, customOverlayMsg)
	{
		var customOverlayMsg = customOverlayMsg ? customOverlayMsg : null;	
		if (url.indexOf('/commonspot/dashboard/') == 0 || url.indexOf('controls/imagecommon/add-image') > 0)
		{
			if (!is.valid)
			{
				alert('This functionality requires Internet Explorer 7/Firefox 2 or later.');
				return;
			}
			var setupComplete = checkDashboardSetup();
			if (!setupComplete)
			{
				setTimeout(function(){
					newWindow(name, url, customOverlayMsg);
				},100);
				return;
			}	
		}	

		if (top.commonspot && top.commonspot.lightbox)
	      top.commonspot.lightbox.openDialog(url, null, name, customOverlayMsg, null, window);
	}
	*/




	OpenURLandClose = function(workUrl)
	{
		var openerWin = top.commonspot.lightbox.getOpenerWindow();
		openerWin.location.href = workUrl;
		if (document.getElementById("leavewindowopen").checked == false)
		{
			setTimeout('window.close()', 250);
		}
	}

	OpenURLInOpener = function(workUrl)
	{
		var openWin = top.commonspot.lightbox.getOpenerWindow();
		if (openWin)
		{
			openWin.location.href = workUrl;
		}	
	}

	RefreshAndCloseWindow = function()
	{
		var openWin = top.commonspot.lightbox.getOpenerWindow();
		openWin.location.reload();
      CloseWindow();
	}

	RefreshParentWindow = function()
	{
		var openerWin = top.commonspot.lightbox.getOpenerWindow();
		pageid = openerWin.js_gvPageID;
		if (pageid > 0)
		{
			openerWin.document.cookie = "scrollPage=" + pageid;
			openerWin.document.cookie = "scrollX=" + cd_scrollLeft;
			openerWin.document.cookie = "scrollY=" + cd_scrollTop;
		}
		openerWin.location.reload();
		DoFocus(self);
		DoFocusDone=1;	// not done, but we don't want the focus
	}




	/* 
	 *	ADF Update
	 */
	/*
	ResizeWindow = function(doRecalc, curTab)
	{
		if (typeof ResizeWindowSafe != 'undefined')		// this variable is set in dlgcommon-head for legacy dialogs (initially set to 0, then to 1 upon calling dlgcommon-foot)
		{ 
			if (ResizeWindowSafe == 1)
				ResizeWindow_Meat(doRecalc, curTab);  // this function is defined in over-rides.js
			else
				ResizeWindowCalledCount = ResizeWindowCalledCount + 1;
		}
		else
			ResizeWindow_Meat(doRecalc, curTab);  // this function is defined in over-rides.js
	}
	

	ResizeWindow_Meat = function(doRecalc, currentTab)
	{
		var maintable = document.getElementById('MainTable');
		if (maintable)
		{
         if (doRecalc)
			{
				if (top.commonspot)
				{
            	top.commonspot.lightbox.initCurrentServerDialog(currentTab);
					ResizeWindow_Meat();
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
	*/




	setthefocus = function(){};

	/* Overwrite native window's methods */

	self.close = function()
	{
		CloseWindow();
	}

	//self.focus = function(){};
	
	
	
	
	/* 
	 *	ADF Update
	 */
	/*
	top.window.resizeTo = function(w, h)
	{
		top.commonspot.lightbox.initCurrent(w, h);
	}
	*/

	window.close = function()
	{
		CloseWindow();
	}

	// window.focus = function(){};
	
	
	
	
	/* 
	 *	ADF Update
	 */
	/*
	window.resizeTo = function(w, h)
	{
		top.commonspot.lightbox.initCurrent(w, h);
	}
	*/	




	checkDashboardSetup = function()
	{
		if (top.commonspot.clientUI)
			return true;

		if (!parent.window.document.getElementById("hiddenframeDiv"))
			doDashboardSetup();

		return false;
	}
	
	doDashboardSetup = function()
	{
		var iframeDiv = document.createElement('div');
		iframeDiv.id = 'hiddenframeDiv';
		iframeDiv.style.left = '-1000px';
		iframeDiv.style.top = '-1000px';
		
		var iframeHTML = '<iframe src="/commonspot/dashboard/hidden_iframe.html" name="hidden_frame" id="hidden_frame" width="1" height="1" scrolling="no" frameborder="0"></iframe>';
		iframeDiv.innerHTML = iframeHTML;
		var hiddenFrame = iframeDiv.childNodes[0];
		parent.window.document.body.appendChild(iframeDiv);
	}
	// Overwrite opener window object
	// This works in IE but fails in FF
	try 
	{
		if (top.commonspot && top.commonspot.lightbox)
			self.opener = top.commonspot.lightbox.getOpenerWindow();
	} catch (err){}
}

if (typeof(onLightboxLoad) == "undefined")
{
	/**
	* Hook that gets called by lightbox whenever the dialog gets loaded
	*/
	onLightboxLoad = function() 
	{	
		try{
			var rootDiv = document.getElementById('cs_commondlg')
		}catch(e){ 
			// $ function is not defined when there is an error. 
			// in that case, just return so we can show the error msg.
			return; 
		}	
		if (rootDiv)
		{	 
			// Check if we have buttons
			var outerDiv = document.getElementById('clsPushButtonsDiv');
			var tableEle = document.getElementById('clsPushButtonsTable');
			var otherBtns = document.getElementsByClassName('clsDialogButton');
			if (tableEle || otherBtns.length)
			{
				// Remove existing "proxy" buttons first
				var btnHolder = document.getElementById('clsProxyButtonHolder');
				if (btnHolder)
				{
					btnHolder.parentNode.removeChild(btnHolder);
				}
				
				// check if cf debug is on
				var arr = document.getElementsByClassName('cfdebug');
				// Append a new <div> that will contain the "proxy" buttons
				var dom = document.createElement('div');
				dom.id = "clsProxyButtonHolder";
				dom.innerHTML = '<table><tr><td id="clsProxySpellCheckCell"></td><td id="clsProxyButtonCell"></td></tr></table>';				
				if (arr.length > 0) 	// stick in after root div and before CF debug table
				{
					/*
						IE has problem with appending node before a script node. to get around it we add a div node around
						the script tags we have after rootDiv (dlgcommon-foot.cfm) and manipulate its innerHTML
						however, non-ie browsers has problem with manipulating innerHTML so doing it ol'way
					*/
					if (is.ie)
					{
						var inHTML = dom.outerHTML + rootDiv.nextSibling.innerHTML;
						rootDiv.nextSibling.innerHTML = inHTML;
					}
					else
						rootDiv.parentNode.insertBefore(dom, rootDiv.nextSibling);
				}	
				else
					rootDiv.parentNode.appendChild(dom);

				proxySpellChecker($('clsProxySpellCheckCell'));
				proxyPushButtons($('clsProxyButtonCell'));
				// Hide the "real" buttons
				if (outerDiv)
					outerDiv.style.display='none';
				if (tableEle)
					tableEle.style.display='none';
			}
		}
	}
}	

proxyPushButtons = function(targetNode)
{
	var cellNode = $('clsProxyButtonCell');
	var buttons = $$('#clsPushButtonsTable input[type="submit"]', '#clsPushButtonsTable input[type="button"]');
	var moreButtons = document.getElementsByClassName('clsDialogButton', null, 'INPUT');
	var addClose = 0;
	if ((buttons.length == 1 && buttons[0].value == 'Help') || buttons.length == 0)
		addClose = 1;
	for (var i=0; i<moreButtons.length; i++)
	{
		// lame! but FF is not happy with concat arrays feature;
		buttons.push(moreButtons[i]);
	}
	cleanRadioAndCheckBoxes($$('#MainTable input[type="checkbox"]', '#MainTable input[type="radio"]'));
	var doneButtons = [];
	var buttonString = [];
	for(var i=0; i<buttons.length; i++)
	{
		buttons[i].style.display = 'none';
		var buttonText = buttons[i].value.replace(/^\s+|\s+$/g, '');
		buttonString[i] = buttonText.toLowerCase();
	}  
	// show prev button
	var indexButton = arrayIndexOf(buttonString,'prev');
	var proxyIndex = 1;
	if (indexButton != -1 && arrayIndexOf(doneButtons,'prev') == -1)    
	{
	  cellNode.appendChild(createProxyButton(buttons[indexButton],proxyIndex++));
	  doneButtons.push('prev');
	}

	// show next button
	indexButton = arrayIndexOf(buttonString,'next');
	if (indexButton != -1 && arrayIndexOf(doneButtons,'next') == -1)    
	{
	  cellNode.appendChild(createProxyButton(buttons[indexButton],proxyIndex++));
	  doneButtons.push('next');
	}      
    // show all misc. buttons that are not submit and not cancel or close
	for(var i=0; i<buttons.length; i++)
	{
		buttonText = buttons[i].value.replace(/^\s+|\s+$/g, '');
		if (buttonText != 'Help' && 
		      buttonText != 'Close' &&
				buttonText != 'No' &&
		      buttonText != 'Cancel' &&
		      buttons[i].type == 'button' &&
				arrayIndexOf(doneButtons,buttonText) == -1)
		{
			cellNode.appendChild(createProxyButton(buttons[i],proxyIndex++));
			doneButtons.push(buttonText);
		}
	}
     
     
	// show all submit buttons that are not cancel or close
	for(var i=0; i<buttons.length; i++)
	{
		buttonText = buttons[i].value.replace(/^\s+|\s+$/g, '');
		if (buttonText != 'Help' && 
					buttonText != 'Close' &&
					buttonText != 'No' &&
					buttonText != 'Cancel' &&
					buttons[i].type == 'submit' &&
					arrayIndexOf(doneButtons,buttonText) == -1)
		{
			cellNode.appendChild(createProxyButton(buttons[i],proxyIndex++));
			doneButtons.push(buttonText);
		}
	}     

	// show cancel and close buttons
	for(var i=0; i<buttons.length; i++)
	{
		buttonText = buttons[i].value.replace(/^\s+|\s+$/g, '');
		if (buttonText != 'Help' && arrayIndexOf(doneButtons,buttonText) == -1)
		{
			cellNode.appendChild(createProxyButton(buttons[i],proxyIndex++));
			doneButtons.push(buttonText);
		}   
	}  

	if (arrayIndexOf(doneButtons, 'cancel') != -1 || arrayIndexOf(doneButtons, 'close') != -1)
		addClose = 0;
	
	// show close button if there are no buttons in the lighbox
	if (addClose && cellNode)
	{
		var closeNode = {
			value: 'Close',
			className: 'clsCloseButton',
			type: 'button',
			name: 'Close'
		};
		cellNode.appendChild(createProxyButton(closeNode,proxyIndex++));
	} 
}

cleanRadioAndCheckBoxes = function(buttons)
{
   var cName = "";
   for (var i=0; i<buttons.length; i++)
   {
      cName = buttons[i].className;
      if (cName.indexOf('clsNoBorderInput')==-1)
      {
         buttons[i].className = cName+' clsNoBorderInput';
      }
   }
}
proxySpellChecker = function(targetNode)
{
	var boxNode = $('OldSpellCheckOn');
	// Proxy the node only if it's visible (it could be hidden)
	if (boxNode && (boxNode.type == 'checkbox'))
	{
		var proxyLabel = document.createElement('label');
		var proxyBox = document.createElement('input');
		proxyBox.setAttribute('id', 'SpellCheckOn');
		proxyBox.setAttribute('name', 'SpellCheckOn');
		proxyBox.setAttribute('type', 'checkbox');
		proxyBox.setAttribute('value', 1);
		proxyBox.className = 'clsNoBorderInput';
		proxyBox.onclick = function()
		{
			$('OldSpellCheckOn').click();
		}
		proxyLabel.appendChild(proxyBox);
		proxyLabel.appendChild(document.createTextNode('Check Spelling'));
		targetNode.appendChild(proxyLabel);
		// Reflect original's status
		proxyBox.checked = boxNode.checked;
	}
}
			
/**
 * Helper method. Generate a proxy DOM node out of an original button
 * @param buttonNode   (node). Required. The original button DOM node
 * @return node
 */
createProxyButton = function(buttonNode,index)
{

	/*
	 Buttons must be styled to look as links. 
	 Since this can be tricky accross browsers, we wrap a <span> around the buttons 
	*/
	
	// Use trimmed value for text
	var buttonText = buttonNode.value.replace(/^\s+|\s+$/g, '');
	var newButtonText = buttonText;
	if (buttonText == 'OK' || buttonText == 'Finish')
		newButtonText = 'Save';    

	var proxyContainer = document.createElement('span');
	proxyContainer.id = 'proxyButton' + index; 
	if (buttonNode.title)
		proxyContainer.title = buttonNode.title;
	proxyContainer.className = buttonNode.className;  
	if ((buttonText == 'Cancel' || buttonText == 'Close') && 
				(buttonNode.className.indexOf('clsPushButton') >= 0 || buttonNode.className.indexOf('clsCancelButton') >= 0 || buttonNode.className.indexOf('clsCloseButton') >= 0)){
	  proxyContainer.className = 'cls'+buttonText+'Button';
	}

	var proxyBox = document.createElement('input');
	if (buttonNode.type == 'submit' && typeof buttonNode.click == 'function'){
	  proxyBox.setAttribute('type', 'button');
	}
	else{
		proxyBox.setAttribute('type', buttonNode.type);
	}   
	proxyBox.setAttribute('name', buttonNode.name);
	proxyBox.setAttribute('value', newButtonText);
	proxyBox.setAttribute('id', buttonText);

	if (newButtonText=='Cancel' || newButtonText=='Close')
	{
	  proxyContainer.onclick = function()
	  {
		if (typeof buttonNode.click == 'function' || typeof buttonNode.click == 'object')
		{
			buttonNode.click();
		}
		else
	      top.commonspot.lightbox.closeCurrent();
	  }
	}   
	else   
	{
		proxyContainer.onclick = function()
		{
			if (typeof buttonNode.click == 'function' || typeof buttonNode.click == 'object')
			{
				buttonNode.click();
			}	
			return false;
		}
	}		
	proxyBox.onmouseover = function()
	{
		this.style.textDecoration = 'underline';
		return false;
	}
	proxyBox.onmouseout = function()
	{
		this.style.textDecoration = 'none';
		return false;
	}	
	proxyContainer.appendChild(proxyBox);
	return proxyContainer;
}
/**
* Helper method.    Return index of an element in an array NOT case-sensitive.
* @param _this      Required. Array
 * @param x          Required. key
* @return index      
*/
arrayIndexOf = function(_this,x) 
{
   for(var i=0;i<_this.length;i++) 
   {
   	if (_this[i].toLowerCase()==x.toLowerCase()) 
   		return i;
   }
   return-1;
}   	
		

if (typeof(onLightboxResize) == "undefined")
{
	
	/**
	 * Hook that gets called by lightbox whenever the dialog gets resized
	 * @param w         (int). Required. Width
	 * @param h         (int). Required. Height
	 */
	onLightboxResize = function(w, h)
	{
		// Remove margins from the dialog's body
		document.body.style.margin = 0;
		document.body.style.padding = 0;
		var rootDiv = document.getElementById('cs_commondlg');
		if (rootDiv)
		{
			main_table = document.getElementById('MainTable');
			if (main_table && main_table.style)
			{
				main_table.style.height = (h -45) + 'px';
				main_table.style.marginTop = 0;
				rootDiv.style.marginTop = '10px';
				rootDiv.style.height = (h -37) + 'px';
			}	
				
			// Add scrollbars to the main box
			rootDiv.style.overflow = 'auto';
		}
	}

}
