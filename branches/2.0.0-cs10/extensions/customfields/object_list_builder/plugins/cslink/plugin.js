CKEDITOR.plugins.add( 'cslink', {
	 requires: 'link,fakeobjects',
    icons: 'cslink',
    init: function( editor ) {
        editor.addCommand( 'insertCSLink', {
            exec: function( editor ) {
					logic_linkOnClick(editor);
				}
        });
			if ( editor.ui.addButton ) {
				editor.ui.addButton( 'CSlink', {
					label: 'Insert Link to a CommonSpot Object',
					command: 'insertCSLink',
					toolbar: 'insert'
				} );
			}			  
    }
});

logic_linkOnClick = function(editor)
{
	var sel = editor.getSelection(true);
	var selType = sel.getType();
	var selText  = sel.getSelectedText();
	var selectedObj = CKEDITOR.plugins.link.getSelectedLink( editor );
	var selectedEle;
	var cs = editor.config.CommonSpot;	
	var linkElements;
	var linkURL = '';
	var itemMouseover = '';
	var esctext = "";
	var displayopt = 1;
	var attr = null;
	var theHTMLText = '';
	editor.lockSelection( sel );	

	if (selText == '')
	{
		alert('Your selection contains empty paragraph tag. Please be sure to select some text content.');
		return;
	}	
	if (selectedObj)
		selectedEle = selectedObj.$;
	if (selectedEle)
	{
		if (selectedEle.tagName == 'IMG')
		{
			alert('Use link button in the properties inspector of this image or link section of image dialog to link this image');
			return;
		}
	
		if (selectedEle.tagName == 'A')
		{
			if (selectedEle.style.textDecoration == 'none')
			{
				displayopt = 2;
				if (selectedEle.onmouseover && selectedEle.onmouseover.toString().indexOf('textDecoration') != -1) displayopt = 3;
			}
			if (selectedEle.id != '')
			{
				attr = selectedEle.id.split('|');
				linkURL = attr[0];
				itemMouseover = attr[1];
			}
		}
		else
		{

			// check for cells in the selection
			var o = /<td.+>/gi;
			var c = /<\/td>/gi;
			var oh = /<th.+>/gi;
			var ch = /<\/th>/gi;
			if (holdForCallback.search(o) >= 0 || holdForCallback.search(c) >= 0 || holdForCallback.search(oh) >= 0 || holdForCallback.search(ch) >= 0)
			{
				alert("Your selection contains table cells and cannot be converted into a link. " + "Please be sure to restrict your selection to text only.");
				return;
			}
			theHTMLText = holdForCallback.toLowerCase();
		}	
	}


		// invoke CommonSpot common link dialog
		strurlstring = cs.jsDlgLoader + '?csModule=dhtmledit/webedit-link-loader&counter=0' + '&callback=setCommonSpotLinkCallback' + '&pageid=' + cs.jspageid + '&ktmlFrameName=' + editor.name + '&controlid=' + cs.jscontrolid + '&itemid=' + cs.jsitemid + '&finish=dhtmledit/link-finish' + '&what=link' + '&displayopt=' + displayopt + '&htmltext=' + esctext + '&linkURL=' + escape(linkURL) + '&itemMouseover=' + itemMouseover + '&customElementID=' + cs.jscustomElementID + '&linkToElement=' + cs.jslinkToElement;
		//alert( strurlstring.replace(/&/g, '\n  &') );
		newWindow('cplinkdlg', strurlstring);
};

CKEDITOR.editor.prototype.setCommonSpotLinkCallback = function(urlstring, controlid, itemid, LinkURL, LinkDisplayOpt, DisplayableLink, iMouseover, iMouseout, mouseOver, editorName)
{
	var editor = CKEDITOR.instances[editorName];
	editor.unlockSelection(true);
	var sel = editor.getSelection(true);
	var selType = sel.getType();
	var selText  = sel.getSelectedText();
	var selectedObj = CKEDITOR.plugins.link.getSelectedLink( editor );
	var selectedEle;
	var cs = editor.config.CommonSpot;	
	
	var hrefValue = '';
	var rText = '';
	var mouseOverValue = '';
	var mouseOutValue = '';
	var idValue = '';
	var styleValue = '';
	var urlstringValue = '';
	var linkPopup = '';
	var linkSched = '';
	var linkNewWindow = '';
	var setStatusBar = '';
	var hrefValue = '';
	var aTagString = '';

	if (selectedObj)
		selectedEle = selectedObj.$;	
	if (selectedEle)
	{
		if ((selectedEle.tagName.toLowerCase() == 'input' && 
						selectedEle.id && 
						selectedEle.id.indexOf('csfield^') == 0) ||
								(selectedEle.tagName.toLowerCase() == 'img'))
			rText = selectedEle.outerHTML;

	}
	else
		rText = selText;
	if (LinkURL != "" || iMouseover != '')
	{
		mouseOverValue = iMouseover;
		mouseOutValue = iMouseout;
		idValue = LinkURL + '|' + mouseOver;
		styleValue = '';
		urlstringValue = urlstring;
		linkPopup = false;
		if (mouseOver.indexOf("CPMENU") != -1) 
			linkPopup = true;
		linkSched = false;
		if (mouseOver.indexOf("CPSCHED") != -1) 
			linkSched = true;
		linkNewWindow = false;
		if (LinkURL.indexOf("CPNEWWIN") != -1) 
			linkNewWindow = true;
		setStatusBar = false;
		if (mouseOver.indexOf('setStatBar') != -1) 
			setStatusBar = true;
		if (iMouseover != '')
		{
			if (linkPopup) 
				mouseOverValue += " return window.status='Pop-Up Menu'; ";
			else if (setStatusBar) 
				mouseOverValue += " return true; ";
		}
		if (linkNewWindow)
		{
			urlstringValue = "javascript:HandleLink('cpe_" + controlid + "_" + itemid + "','" + LinkURL + "');"
			if (LinkDisplayOpt != 3 && !setStatusBar)
			{
				urlPos = 1 + LinkURL.indexOf("@");
				urlPart = LinkURL.substr(urlPos);
				urlPos = urlPart.indexOf("http://");
				if (urlPos > 0) 
					urlPart = urlPart.substr(urlPos);
				mouseOutValue += " return window.status=''; ";
				mouseOverValue += " return window.status='" + urlPart + "'; ";
			}
		}
		else if (linkPopup || linkSched)
			urlstringValue = "javascript:HandleLink('cpe_" + controlid + "_" + itemid + "','" + LinkURL + "','" + LinkURL + "');"
		hrefValue += urlstringValue;
		switch (LinkDisplayOpt)
		{
			case 1:
				// normal link
				if (iMouseover != '') 
					styleValue = 'cursor: hand;';
				break;
			case 2:
				// no underline
				styleValue = 'text-decoration:none; cursor:hand;';
				break;
			case 3:
				// underline on mouseover
				if (linkNewWindow)
				{
					mouseOverValue = "glblLinkHandler(this,'textDecoration','underline');" + mouseOverValue + " return self.status='" + DisplayableLink + "';";
					mouseOutValue = "glblLinkHandler(this,'textDecoration','none');" + mouseOutValue + " return self.status='';";
				}
				else
				{
					mouseOverValue = "glblLinkHandler(this,'textDecoration','underline');" + mouseOverValue;
					mouseOutValue = "glblLinkHandler(this,'textDecoration','none');" + mouseOutValue;
				}
				styleValue = 'text-decoration:none; cursor:hand;';
				break;
		}
		if (selectedEle)
		{
			selectedEle.setAttribute('id', idValue);
			selectedEle.setAttribute('style', styleValue);
			if (mouseOverValue.length != 0) 
				selectedEle.setAttribute('onmouseover', mouseOverValue);
			else 
				selectedEle.removeAttribute('onmouseover');
			if (mouseOutValue.length != 0) 
				selectedEle.setAttribute('onmouseout', mouseOutValue);
			else 
				selectedEle.removeAttribute('onmouseout');
			if (hrefValue.length != 0 && LinkDisplayOpt != 0) 
				selectedEle.setAttribute('href', hrefValue);
			else 
				selectedEle.removeAttribute('href');
		}
		else
		{
			if (hrefValue.indexOf('#') == 0) 
				aTagString = '<a ';
			else 
				aTagString = '<a id="' + idValue + '" ';
			if (mouseOverValue.length != 0) 	
				aTagString += 'onmouseover="' + mouseOverValue + '" ';
			if (mouseOutValue.length != 0) 
				aTagString += 'onmouseout="' + mouseOutValue + '" ';
			if (styleValue.length != 0) 
				aTagString += 'style="' + styleValue + '" ';
			if (hrefValue.length != 0 && LinkDisplayOpt != 0) 
				aTagString += 'href="' + hrefValue + '" ';
			aTagString += '>' + rText + '</a>';
			editor.insertHtml(aTagString);
		}
	}
	else // end: if (LinkURL != "" || iMouseover != '')
	{
		// call unlink here.
	}	
};
