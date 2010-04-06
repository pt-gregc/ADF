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

/* 
 * overrides.js   Copyright PaperThin, Inc.
 */
if((typeof top.commonspot != 'undefined') && (typeof top.commonspot.lightbox != 'undefined'))
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
	
	newWindow = function(name, url, customOverlayMsg)
	{
		var customOverlayMsg = customOverlayMsg ? customOverlayMsg : null;	
		if (url.indexOf('/commonspot/dashboard/') == 0 || url.indexOf('controls/imagecommon/add-image') > 0)
		{
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
		if(document.getElementById("leavewindowopen").checked == false)
		{
			setTimeout('window.close()', 250);
		}
	}

	OpenURLInOpener = function(workUrl)
	{
		var openWin = top.commonspot.lightbox.getOpenerWindow();
		if(openWin)
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

	ResizeWindow = function(doRecalc)
	{
		if( typeof ResizeWindowSafe != 'undefined' )		// this variable is set in dlgcommon-head for legacy dialogs (initially set to 0, then to 1 upon calling dlgcommon-foot)
		{ 
			if( ResizeWindowSafe == 1 )
				ResizeWindow_Meat(doRecalc);  // this function is defined in over-rides.js
			else
				ResizeWindowCalledCount = ResizeWindowCalledCount + 1;
		}
		else
		{
			ResizeWindow_Meat(doRecalc);  // this function is defined in over-rides.js
		}		
	}
	

	ResizeWindow_Meat = function(doRecalc)
	{
		var maintable = document.getElementById('MainTable');
		if(maintable)
		{
         if (doRecalc)
			{
				if( top.commonspot )
            	top.commonspot.lightbox.initCurrentServerDialog();
			}
         else
			{
				if (maintable.offsetHeight < 120)
					maintable.style.height = '120px';
				else
					maintable.style.height = '';
				
				if( top.commonspot )
            	top.commonspot.lightbox.initCurrent( maintable.offsetWidth, maintable.offsetHeight + 40);
			}	
		}	
	}	

	setthefocus = function(){};

	/* Overwrite native window's methods */

	self.close = function()
	{
		CloseWindow();
	}

	//self.focus = function(){};

	top.window.resizeTo = function(w, h)
	{
		top.commonspot.lightbox.initCurrent(w, h);
	}

	window.close = function()
	{
		CloseWindow();
	}

	// window.focus = function(){};

	window.resizeTo = function(w, h)
	{
		top.commonspot.lightbox.initCurrent(w, h);
	}
	
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

if(typeof(onLightboxLoad) == "undefined")
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
		if(rootDiv)
		{	 
			// Check if we have buttons
			var outerDiv = document.getElementById('clsPushButtonsDiv');
			var tableEle = document.getElementById('clsPushButtonsTable');
			var otherBtns = document.getElementsByClassName('clsDialogButton');
			if(tableEle || otherBtns.length)
			{
				// Remove existing "proxy" buttons first
				var btnHolder = document.getElementById('clsProxyButtonHolder');
				if(btnHolder)
				{
					btnHolder.parentNode.removeChild(btnHolder);
				}
				
				// check if cf debug is on
				var arr = document.getElementsByClassName('cfdebug');
				if( arr.length > 0 )
				{
					// stick in after root div and before CF debug table
					new Insertion.After(rootDiv, '<div id="clsProxyButtonHolder"><table><tr><td id="clsProxySpellCheckCell"></td><td id="clsProxyButtonCell"></td></tr></table></div>');
				}
				else
				{
					// Append a new <div> that will contain the "proxy" buttons
					var dom = document.createElement('div');
					dom.id = "clsProxyButtonHolder";
					dom.innerHTML = '<table><tr><td id="clsProxySpellCheckCell"></td><td id="clsProxyButtonCell"></td></tr></table>';
					rootDiv.parentNode.appendChild(dom);
				}				
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
	var buttonString = new Array();
	var buttonTypes = new Array();
	for(var i=0; i<buttons.length; i++)
	{
		buttons[i].style.display = 'none';
		if(buttons[i].value != 'Help')
		{
			var buttonText = buttons[i].value.replace(/^\s+|\s+$/g, '');
			buttonString[i] = buttonText.toLowerCase();
			buttonTypes[i] = (buttons[i].type).toLowerCase();
		}
	}  
	// show prev button
	var indexButton = arrayIndexOf(buttonString,'prev');
	var proxyIndex = 1;
	if(indexButton != -1)    
	{
	  cellNode.appendChild(createProxyButton(buttons[indexButton],proxyIndex++));
	  buttons.splice(indexButton,1);
	  buttonString.splice(indexButton,1);
	  buttonTypes.splice(indexButton,1);
	}

	// show next button
	indexButton = arrayIndexOf(buttonString,'next');
	if(indexButton != -1)    
	{
	  cellNode.appendChild(createProxyButton(buttons[indexButton],proxyIndex++));
	  buttons.splice(indexButton,1);
	  buttonString.splice(indexButton,1);
	  buttonTypes.splice(indexButton,1);
	}      
     
     // show all misc. buttons that are not submit and not cancel or close
	while(arrayIndexOf(buttonTypes,'button')!=-1)
	{
		for(var i=0; i<buttons.length; i++)
		{
			buttonText = buttons[i].value.replace(/^\s+|\s+$/g, '');
			if(buttonText != 'Help' && 
			      buttonText != 'Close' &&
			      buttonText != 'Cancel' &&
			      buttons[i].type == 'button')
			{
				cellNode.appendChild(createProxyButton(buttons[i],proxyIndex++));
				buttons.splice(i,1);
			}
			buttonString.splice(i,1);
			buttonTypes.splice(i,1);
		}
	}
     
	for(var i=0; i<buttons.length; i++)
	{
		if(buttons[i].value != 'Help')
		{
			buttonString[i] = buttonText.toLowerCase();
			buttonTypes[i] = (buttons[i].type).toLowerCase();
		}
	}        
     
     // show all submit buttons that are not cancel or close
	while(arrayIndexOf(buttonTypes,'submit')!=-1)
	{      
		for(var i=0; i<buttons.length; i++)
		{
			buttonText = buttons[i].value.replace(/^\s+|\s+$/g, '');
			if(buttonText != 'Help' && 
						buttonText != 'Close' &&
						buttonText != 'Cancel' &&
						buttons[i].type == 'submit')
			{
				cellNode.appendChild(createProxyButton(buttons[i],proxyIndex++));
				buttons.splice(i,1);
			}
			buttonString.splice(i,1);
			buttonTypes.splice(i,1);
		}     
	} 
	// show cancel and close buttons
	for(var i=0; i<buttons.length; i++)
	{
		buttonText = buttons[i].value.replace(/^\s+|\s+$/g, '');
		if(buttonText != 'Help')
		{
			cellNode.appendChild(createProxyButton(buttons[i],proxyIndex++));
			buttons.splice(i,1);
			if (buttonText == 'Cancel' || buttonText == 'Close')
				addClose = 0;
		}   
	}  
	// show close button if there are no buttons in the lighbox
	if(addClose)
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
	if(boxNode && (boxNode.type == 'checkbox'))
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
	if( buttonNode.title )
		proxyContainer.title = buttonNode.title;
	proxyContainer.className = buttonNode.className;  
	if ((buttonText == 'Cancel' || buttonText == 'Close') && 
				(buttonNode.className == 'clsPushButton' || buttonNode.className == 'clsCancelButton')){
	  proxyContainer.className = 'cls'+buttonText+'Button';
	}

	var proxyBox = document.createElement('input');
	if(buttonNode.type == 'submit' && typeof buttonNode.click == 'function'){
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
		if(typeof buttonNode.click == 'function' || typeof buttonNode.click == 'object')
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
			if(typeof buttonNode.click == 'function' || typeof buttonNode.click == 'object')
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
* Helper method.    Return index of an element in an array.
* @param _this      Required. Array
 * @param x          Required. key
* @return index      
*/
arrayIndexOf = function(_this,x) 
{
   for(var i=0;i<_this.length;i++) 
   {
   	if(_this[i]==x) 
   		return i;
   }
   return-1;
}   	
		

if(typeof(onLightboxResize) == "undefined")
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
		if(rootDiv)
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
