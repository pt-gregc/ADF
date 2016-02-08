CKEDITOR.plugins.add( 'csimage', {
    icons: 'csimage',
    init: function( editor ) {
        editor.addCommand( 'insertCSImage', {
            exec: function( editor ) {
					logic_imageOnClick(editor);
				}
        });	 
	 
		  
			if ( editor.ui.addButton ) {
				editor.ui.addButton( 'CSimage', {
					label: 'Insert Image From CommonSpot Image Gallery',
					command: 'insertCSImage',
					toolbar: 'insert'
				} );
			}
					  
    }
});

logic_imageOnClick = function(editor)
{
	var sel = editor.getSelection(true);
	editor.lockSelection( sel );	
	var selType = sel.getType();
	var selText  = sel.getSelectedText();
	var selectedEle = sel.getSelectedElement();	
	var cs = editor.config.CommonSpot;	
	var callBack = 'insertImageCallback';
	var urlString = cs.jsDlgLoader + '?csModule=controls/imagecommon/image-summary&counter=0' + '&checklock=0&callback=' + callBack + '&pageid=' + cs.jspageid + '&controlid=0' + '&ktmlFrameName=' + editor.name + '&isDHTMLControl=1&customElementID=0&linkToElement=0';
	var curTag = '';
	if (selectedEle)
	{
		curTag = selectedEle.$;
		if (curTag.tagName == "IMG")
		{
			var attribs = new Array('align', 'height', 'hspace', 'src', 'vspace', 'width');
			var value;
			for (var i = 0; i < attribs.length; i++)
			{
				var value = selectedEle.getAttribute(attribs[i]);
				if (value)
					urlString += '&' + attribs[i] + '=' + value;
				else
					urlString += '&' + attribs[i] + '=0';
			}
			value = selectedEle.getAttribute('border');
			if (value)
				urlString += '&bordersize=' + value;
			else
				urlString += '&bordersize=0';
				
			value = selectedEle.getAttribute('alt');
			if (value)
			{
				var p = value;
				var q = '';
				for (i = 0; i < p.length; i++)
				{
					var j = p.charCodeAt(i);
					q += (j == 38) ? '&amp;' : (j < 128) ? p.charAt(i) : '&#' + j + ';';
				}
				urlString += '&flyover=' + escape(q);
			}
			else
				urlString += '&flyover=';

			var styleString = '';
			var styleTotal = 0;
			var styleCurrent = 0;
			
			value = selectedEle.getAttribute('className');
			if (value) 
				urlString += '&className=' + value;
			else urlString += '&className=';
			value = selectedEle.getAttribute('style');
			if (value)
			{
				styleTotal = value.length;
				for (var styleName in value)
				{
					styleCurrent++;
					if (styleCurrent > styleTotal)
						break;
					styleString += value[styleName] + ': ' + value.getPropertyValue(value[styleName]) + ';';
				}
				urlString += '&style=' + styleString;
			}
			else
				urlString += '&style=0';
			linkURL = 0;
			linkMouseover = '';
			mainImageURL = '';
			sizeID = 0;
			rollImageURL = '';
			value = selectedEle.getAttribute('id');
			if (value)
			{
				idValues = value.split('|');
				linkURL = idValues[0];
				if (linkURL == '') linkURL = 0;
				linkMouseover = idValues[1];
				mainImageURL = idValues[2];
				sizeID = idValues[3];
				rollImageURL = idValues[4];
			}
			urlString += '&MainImageURL=' + mainImageURL + '&sizeID=' + sizeID + '&RollImageURL=' + rollImageURL + '&LinkURL=' + escape(linkURL) + '&linkMouseover=' + linkMouseover;
		}
	}
	newWindow('selectimage', urlString);
};

CKEDITOR.editor.prototype.insertImageCallback = function(bOK, data, editorName)
{
	if (bOK == 0 || !data) return;
	var editor = CKEDITOR.instances[editorName];
	editor.unlockSelection(true);
	var sel = editor.getSelection(true);

	var selType = sel.getType();
	var selText  = sel.getSelectedText();
	var selectedEle = sel.getSelectedElement();
	var cs = editor.config.CommonSpot;	
	var foo = "";
	// dec_mouseover is the deciphered mouseover property value
	if (data["LinkURL"] != "" || data['dec_mouseover'] != '')
	{
		var mouseout = '';
		var attr = ' href="javascript:';
		var mouseover = '';
		if (data['dec_mouseover'] == '')
		{
			if (data["LinkDisplayURL"]) 
				mouseover = ' onmouseover="return window.status=' + "'" + data['LinkDisplayURL'] + "'" + '" ';
			else 
				mouseover = ' onmouseover="return window.status=' + "'" + data['LinkURL'] + "'" + '" ';
		}
		else
		{
			mouseover = ' onmouseover="' + data['dec_mouseover'] + 'return true"';
			if (data["LinkDisplayURL"] != '' && data["LinkURL"] != '') 
				attr = ' href="javascript:';
			else attr = '';
		}
		if (data['mouseout'] != '') 
			mouseout = ' onmouseout="' + data['mouseout'] + '"';
		// if we are linking to a (1) pop-up menu, (2) new window or (3) scheduled element
		// then call through HandleLink, otherwise put out href directly
		if (data["normallink"] == 1 && data["LinkDisplayURL"] != "")
		{
			// #8578 -- NA 4/15/04
			// Special case for custom element.  The LinkDisplayURL containes the URL unless popup,newwindow, scheduled element and custom element.  
			// Its usage is incorrect for custom element.  The real URL is in the 'LinkURL'.  The other cases are handled in the case below where data['normalLink'] != 1
			if (data["LinkDisplayURL"].toLowerCase() == "custom element data") 
				data["LinkDisplayURL"] = data["LinkURL"];
			foo += '<a' + mouseover + mouseout + ' href="' + data["LinkDisplayURL"] + '" style="cursor:hand" ';
		}
		else if (data["normallink"] == 1 && data["LinkDisplayURL"] == "")
		{
			thisHref = '';
			foo += '<a' + mouseover + mouseout + ' ';
		}
		else
		{
			foo += '<a' + mouseover + mouseout + attr + 'HandleLink(' + "'cpe_" + jspageid + "_0','" + data["LinkURL"] + "', '" + data["LinkDisplayURL"] + "');" + '" style="cursor:hand" ';
		}
		foo += 'id="' + data["LinkURL"] + '">';
	}
	foo += '<img src="' + data["csModule"] + '"';
	// store urls and such in ID using pipe delimited list.  Order of elements is:
	// linkURL
	// linkMouseover
	// mainImageURL
	// RollImageURL
	var thisID = data["LinkURL"] + '|' + data["linkMouseover"] + '|' + data["MainImageURL"] + '|' + data["sizeID"] + '|' + data["RollImageURL"];
	foo += ' id="' + thisID + '"';
	if (data["align"] != "" && data["align"] != "default") 
		foo += ' align=' + data["align"];
	if (data["width"] != "" && data["width"] != "0") 
		foo += ' width=' + data["width"];
	if (data["height"] != "" && data["height"] != "0") 
		foo += ' height=' + data["height"];
	if (data["bordersize"] != "") 
		foo += ' border=' + data["bordersize"];
	if (data["vspace"] != "") 
		foo += ' vspace=' + data["vspace"];
	if (data["hspace"] != "") 
		foo += ' hspace=' + data["hspace"];
	foo += ' alt="' + data["flyover"] + '"';
	if (data["className"] != "") 
		foo += ' class=' + data["className"];
	//  NEEDSWORK - we need to have a way to configure the title attribute in the RTE properties Inspector
	foo += ' title="' + data["flyover"] + '"';
	foo += '>';
	if (data["LinkURL"] != "" || data['dec_mouseover'] != '') 
		foo += '</a>';
	editor.insertHtml(foo);
};