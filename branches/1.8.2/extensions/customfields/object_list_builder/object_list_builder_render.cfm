<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Custom Field Type:
	Object List Builder
Name:
	object_list_builder_render.cfm
Summary:
	This is the  render handler module for Object List Builderr field
ADF Requirements:
	scripts_1_2
History:
	2015-04-17 - SU/SFS - Created
--->
<cfscript>
	wraptag = 'div';
	
	// Path to component in the ADF
	componentOverridePath = "#request.site.csAppsURL#components";
	componentName = "objectListBuilder_1_0";
	
	// Ajax URL to the proxy component in the context of the site
	ajaxComURL = application.ADF.ajaxProxy;
	ajaxBeanName = 'objectListBuilder';
	inputParameters = attributes.parameters[fieldQuery.inputID];
	application.ADF.scripts.loadJQuery(noConflict=true);
	application.ADF.scripts.loadJQueryUI();	
	

	compOverridePath = "";
	if (StructKeyExists(inputParameters, "componentPath") AND inputParameters.componentPath neq "")
	{
		compOverridePath = inputParameters.componentPath;
		ext = ListLast(compOverridePath,'.');
		if (ext EQ 'cfc')
		{
			fileName = Mid(compOverridePath, 1, Len(compOverridePath)-Len(ext)-1);
			fileNamewithExt = compOverridePath;
		}
		else
		{
			fileName = compOverridePath;
			fileNamewithExt = compOverridePath & '.cfc';
		}
		
		try
		{
			if ( StructKeyExists(application.ADF,fileName) )
			{
				datamanagerObj = application.ADF[fileName];
				componentName = fileName;
				ajaxBeanName = fileName;
			}
			else if ( FileExists(ExpandPath('#componentOverridePath#/#fileNamewithExt#')) )
			{
				datamanagerObj = CreateObject("component", "#componentOverridePath#/#fileName#");
				componentName = fileName;
				ajaxBeanName = fileName;
			}
			else
			{
				datamanagerObj = application.ADF[ajaxBeanName];
			}
		}
		catch(Any e)
		{
			Server.CommonSpot.UDF.mx.doLog("DataManager: Could not load override component '#inputParameters.componentPath#'");
			datamanagerObj = application.ADF[ajaxBeanName];
		}		
	}
	else
	{
		datamanagerObj = application.ADF[ajaxBeanName];
	}
	
	formats = datamanagerObj.getFormats();
	formatsArr = deserializeJSON(formats);
	

	
	currentValue = attributes.currentValues[fqFieldName];	
	// Validate if the property field has been defined
	if ( NOT StructKeyExists(inputParameters, "fldID") OR LEN(inputParameters.fldID) LTE 0 )
		inputParameters.fldID = fqFieldName;
		
	parsedVal = datamanagerObj.parse(data=currentValue);	
	
	validationJS = "";
	msg = "Please select a #attributes.parameters[fieldQuery.inputID].label# value.";
	if (StructKeyExists(attributes.parameters[fieldQuery.inputID], 'msg') AND  Len(attributes.parameters[fieldQuery.inputID].msg) GT 0)
		msg = attributes.parameters[fieldQuery.inputID].msg;
	if (StructKeyExists(attributes, "pageID"))
		pageID = attributes.pageID;
	else
		pageID = 0;
	if (StructKeyExists(attributes, "controlID"))
		controlID = attributes.controlID;
	else
		controlID = 0;
		
	if (StructKeyExists(attributes.parameters[fieldQuery.inputID], 'ID'))
		formID = attributes.parameters[fieldQuery.inputID].ID;
	else
		formID = 0;	

	resultsJSONPath = datamanagerObj.getResultsJSONFilePath();
	resultsJSONFile = datamanagerObj.getResultsJSONFile();
	filePath = "#ExpandPath(resultsJSONPath)##resultsJSONFile#_#pageID#_#controlID#.json";
	if (NOT FileExists(filePath))
		datamanagerObj.writeJSONFile(pageID=pageID, controlID=controlID);
</cfscript>

<!---<cfoutput>
	<p>filepath: #filepath#</p>
</cfoutput>--->

<cffile action="read" file="#filePath#" variable="objectList">

<!---<cfset application.adf.utils.logappend(msg=objectList, logfile='debugOLB.html', label='objectList')>--->

<cfscript>
	colsArr = deserializeJSON(objectList);
	colsList = "";
	if (ArrayLen(colsArr) gt 0)
		colsList = StructkeyList(colsArr[1]);
</cfscript>

<!---<cfset application.adf.utils.logappend(msg=colsArr, logfile='debugOLB.html', label='colsArr')>--->

<cfif attributes.rendermode eq 'label'>
	<cfoutput>#fieldlabel#</cfoutput>
	<cfexit>
<cfelseif attributes.rendermode eq 'value'>
	<cfif fieldpermission gt 0>
		<cfoutput>#attributes.currentvalues[fqFieldName]#</cfoutput>
	</cfif>
	<cfexit>
<cfelseif attributes.rendermode eq 'description'>
	<cfoutput>#fieldQuery.description#</cfoutput>
	<cfexit>
</cfif>
<cfoutput>
	#datamanagerObj.renderJS()#
	#datamanagerObj.renderStyles()#
<tr><td colspan="2">
<table width="950" border="0" class="borderedTable" id="borderedTable" cellspacing="0" cellpadding="2" summary="">
	<!--- left bar --->
	<tr>
		<td valign="top">
			<table border="0" class="header" id="leftTD" cellspacing="0" cellpadding="0">
				<tr>
					<td valign="top">
						<table border="0" class="grayBg" cellpadding="0" cellspacing="2">
							<tr>
								<td class="cs_dlgLabelBold">Search: </td>
								<td><div id="custom-templates"><input type="text" size="50" class="typeahead rounded" name="searchString" id="searchString" placeholder="Type search string here"></div></td>
							</tr>
							<tr>
								<td class="cs_dlgLabelBold">Format: </td>
								<td>
									<select name="format" class="rounded" id="format" onchange="if (jQuery('##searchString').val().length){renderResults()}">
										<cfloop from="1" to="#arrayLen(formatsArr)#" index="index">
										<cfscript>
											curVal = formatsArr[index];
											isDefault = curVal['isDefault'];
										</cfscript>
										<option value="#curVal['formatName']#"<cfif isDefault> selected</cfif>>#curVal['displayName']#</option>
										</cfloop>
									</select>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="contentTR">
					<td class="whiteBg" id="containerTD">
					<div id="containerDIV">
					<p id="draggablesContainer"></p>
					<div id="rawDiv" style="display: none;"></div>
					</div>
					</td>
				</tr>
			</table> 
		</td>
		<!--- ckEditor --->
		<td width="560" valign="top" id="ckEditoTD">
			<div class="frameOverlay" id="frameOverlay">
			<textarea name="#fqFieldName#" id="#fqFieldName#">#parsedVal#</textarea>
			<script>
				CKEDITOR.replace( '#fqFieldName#',
				{
					width: '560',
					//height: '490',
					toolbar: [ { name: 'links', items: ['CSlink','Unlink','Anchor','CSimage'] }, { name: 'colors', items: ['TextColor','BGColor'] },  { name: 'clipboard', items: ['Cut','Copy','Paste','PasteText','PasteFromWord','Undo','Redo'] }, { name: 'editing', items: ['Find','Replace','Scayt','SelectAll'] }, { name: 'paragraph', items: ['BidiLtr','BidiRtl','Language','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','Blockquote','CreateDiv','NumberedList','BulletedList','Outdent','Indent'] }, { name: 'insert', items: ['Table','HorizontalRule','Smiley','SpecialChar','PageBreak'] }, { name: 'basicstyles', items: ['Bold','Italic','Strike','Subscript','Superscript','RemoveFormat'] }, { name: 'styles', items: ['Styles','Format','Font','FontSize'] }, { name: 'document', items: ['Source'] }, { name: 'tools', items: ['Maximize','ShowBlocks'] }, '/', { name: 'custom', items: ['listformat']} ],
					extraPlugins: 'listformat,cslink,csimage',
					allowedContent: true,
					enterMode: CKEDITOR.ENTER_BR,
					//removePlugins: 'magicline',
					//ignoreEmptyParagraph: true,
					autoParagraph: false,
					toolbarCanCollapse: true,
					resize_enabled: false,
					contentsCss: '/ADF/extensions/customfields/object_list_builder/object_list_builder_editor_styles.css',
					listBuilder: 
					{
						content: '#JSStringFormat(formats)#',
						ajaxBeanName: '#ajaxBeanName#',
						ajaxComURL: '#ajaxComURL#'
					},
					 CommonSpot: 
					 {
					 	jsUserID: #Session.User.ID#,
						jsDlgLoader: "#Request.SubSite.DlgLoader#",
						jslinkToElement: '0',
						jsitemid: '0',
						jscontrolid: '#controlid#',
						jspageid: '#pageID#',
						jselementType: '',
						jsSiteID: #Request.SiteID#,
						jsSiteURL: '#Request.SubSiteCache[1].url#',
						jsSubsiteURL: '#Request.SubSite.url#',
						jsSubSiteID: #Request.SubSiteID#,
						jsFrameName: '#fqFieldName#',
						jsformid: '#formID#',
						jscustomElementID: '#formID#'		
					 },					
					on: 
					{
						contentDom: function( evt ) 
						{
							var editor = CKEDITOR.instances['#fqFieldName#'];
							var editable = editor.editable();
							
							editable.attachListener( editable, 'click', function(e) 
							{
								editor.plugins.listformat.checkListFormat(e);
							});				
							//reSizeEditor();
							var leftTD = jQuery('##leftTD').height();
							var parsedH = parseInt(leftTD);
							//alert(parsedH);
							editor.resize( '100%', parsedH, false ,true );
						},
						instanceReady: function (evt)
						{	
						/*
							var writer = evt.editor.dataProcessor.writer;
							var tags = ['p','div','h1','h2','h3','h4','h5','h6']; // etc.
							// The character sequence to be used for line breaks.
							writer.lineBreakChars = '\n';
							// The character sequence to use for every indentation step.
							writer.indentationChars = '\t';		
												
							for (var key in tags) 
							{
								writer.setRules(tags[key],
								{
									indent : true,
									breakBeforeOpen : true,
									breakAfterOpen : true,
									breakBeforeClose : true,
									breakAfterClose : false
								});
							}
						*/
						}
					}
				});
				//CKEDITOR.config.allowedContent = 'h1(*) h2(*) h3(*) p(*) blockquote strong em div(*) span a';				

				CKEDITOR.plugins.addExternal( 'listformat', '/ADF/extensions/customfields/object_list_builder/plugins/listformat/' );
				CKEDITOR.plugins.addExternal( 'csimage', '/ADF/extensions/customfields/object_list_builder/plugins/csimage/' );
				CKEDITOR.plugins.addExternal( 'cslink', '/ADF/extensions/customfields/object_list_builder/plugins/cslink/' );
	
			</script>	
			</div> 
		</td>	
	</tr>
</table>
</td></tr>	
<script>
	var editor = null;
	jQuery.ajaxSetup({ cache: false, async: true, debug: 0 });	

	
	function drag(ev)
	{
		var data = ev.target;
		while(data)
		{
			if (data.className != 'ui-widget-content spacedDiv')
			{
				data = data.parentNode;
			}
			else
			{ 
				data = data.childNodes[0];
				break;
			}
		}
		if (data)
		{
			var format = document.getElementById('format').options[document.getElementById('format').selectedIndex].value;
			if (format == '')
			{
				alert('Please select a default format for this listing');
				return false;
			}
			
			var newHTML = data.innerHTML;
			newHTML = newHTML.replace('doNothingNow()', '');
			
			if( formatsAssocArr[format] )
				wraptag = formatsAssocArr[format];
			else
				wraptag = 'div';	
				
			var html = '<' + wraptag + ' contenteditable="false" class="placeholderWrapper" id="DIV_' + data.id + '" onfocus="editor.plugins.listformat.checkListFormat(\'' + format + '\');"><' + wraptag + ' class="placeholder" id="PL_' + data.id + '" data-format="' + format + '">' + newHTML + '</' + wraptag + '></' + wraptag + '>';
				html = html + '&nbsp;';
//console.log(html);
			ev.dataTransfer.setData("text/html", html);
		}
		else
			return false;
	}
	
	function doNothingNow(event)
	{
		var eventSource = event.srcElement;
		if(event)
		{
			event.stopPropagation();
			event.preventDefault();
		}
		else if(window.event)
		{
			window.event.cancelBubble = true;
			window.returnValue = false;
		}
		window.status = '';
		return false;
	}
	

	function setEventHooks(obj)
	{
		var aTags = 'input,a,img,div,span,td,th'.split(',');
		for(var i = 0; i < aTags.length; i++)
		{
			var aTagObjs = obj.getElementsByTagName(aTags[i]);
			for (j = 0; j < aTagObjs.length; j++)
			{
				if (aTags[i] == 'a')
				{
					aTagObjs[j].setAttribute('href', 'javascript:doNothingNow()');
				}
				killTagEvents(aTagObjs[j]);
			}	
		}
		return jQuery(obj).html();
	}

	function killTagEvents(obj, events)
	{
		if(!events)
			var events = 'onclick,ondblclick,onfocus,onmousedown,onmouseup,onmouseover,onmouseout,onchange,oncontextmenu,onkeypress';
		var aEvents = events.split(',')
		for(var i = 0; i < aEvents.length; i++)
			obj[aEvents[i]] = doNothingNow;
	}
			
	function renderResults()
	{
		var searchStr = jQuery('##searchString').val();
		
		var format = jQuery('##format').val();
		var ajaxData = '';
		var thisID = 0;
		var thisData = '';
		var curRecID = 0;
		var dataToBeSent = { 
				bean: '#ajaxBeanName#',
				method: 'getResultsList',
				searchString: searchStr,
				debug: 0,
				returnformat: 'html',
				async: true
		 };		
		 			
		jQuery.when
		(
			jQuery.post
			( 
					'#ajaxComURL#', 
					dataToBeSent, 
					null, 
					"json" 
			)

		).always(function(retData)
		{
			var res = retData.DATA;
			var htmlArr = [];
			curRecID = 0;
			for (var i=0; i < res.length; i++)
			{
				curRecID = res[i][0];
				dataToBeSent = 
				{ 
					bean: '#ajaxBeanName#',
					method: 'renderItem',
					format : format,
					id: curRecID,
					curIndex: i,
					returnformat: 'html',
					async: true
			 	};
				jQuery.when
				(					
					jQuery.post
					( 
						'#ajaxComURL#', 
						dataToBeSent, 
						null, 
						"json" 
					)

				).always(function(itemData)
				{			
					thisData = this.data;
					thisID = getValFromURL(thisData, 'id');
					thisIndex = getValFromURL(thisData, 'curIndex');
					var rawDiv = jQuery('##rawDiv');
					rawDiv = rawDiv[0];
					jQuery(rawDiv).html(itemData.responseText);
					var retHTML = setEventHooks(rawDiv);	
					var txtVal = jQuery(rawDiv).text();
					var dataName = thisID + ' ' + txtVal.replace(thisID,'');
					htmlArr[thisIndex] = '<div id="rec_' + thisID + '" class="ui-widget-content spacedDiv" draggable="true" ondragstart="drag(event)" data-name="' + dataName.toLowerCase() + '"><div id="' + thisID + '">' + retHTML + '</div></div>';
					checkResponsesState(htmlArr); // need this array to make it keep the order
				});		
			}			
			checkResponsesState(htmlArr);		
		})
	}		
		
						
	function checkResponsesState(arr)
	{
		jQuery('##draggablesContainer').html(arr.join(''));		
	}		

	// this is the function that slowing down the reactiveness of the searching
	// also change "keyup" to "blur" or something to change the event of running the search
	jQuery("##searchString").blur(function()
	{
		//var timerid;
		//clearTimeout(timerid);
		//timerid = setTimeout(function() { renderResults(); }, 2000);
		var currSearchStr = jQuery('##searchString').val();
		if (currSearchStr.length){
			renderResults();
		}
	});
	
	
	// javascript validation
	#fqFieldName#=new Object();
	#fqFieldName#.id='#fqFieldName#';
	#fqFieldName#.tid=#rendertabindex#;
	#fqFieldName#.validator = "validate_#fqFieldName#()";
	#fqFieldName#.msg = "Object list is empty.";
	vobjects_#attributes.formname#.push(#fqFieldName#);
	
	function validate_#fqFieldName#() 
	{
		parseEditorContent();
		return true;
	}
	
	function getValFromURL(urlStr, curKey)
	{
		var vars = [], hash;
		var hashes = urlStr.split('&');
		for(var i = 0; i < hashes.length; i++)
		{
			hash = hashes[i].split('=');
			if (curKey)
			{
				if (curKey == hash[0])
					return hash[1];
			}
			else
			{
				vars.push(hash[0]);
				vars[hash[0]] = hash[1];
			}
		}
		return vars;
		
	}
	
	var typeaheadData = [];
	thisTypeahead = function() 
	{
		typeaheadData = '#JSStringFormat(objectList)#';
		jsonData = jQuery.parseJSON(typeaheadData);
	<cfloop list="#lcase(colsList)#" index="curColumn">
		var col_#curColumn# = new Bloodhound({
			datumTokenizer: function (data) {
				return Bloodhound.tokenizers.whitespace(data['value']);
			},			
			queryTokenizer: Bloodhound.tokenizers.whitespace,
			local: jQuery.map(jsonData, function(record) {
				return {
					value: record.#curColumn# 
				}; 
			})
		});
		col_#curColumn#.initialize();
	</cfloop>
	
		jQuery('.typeahead').typeahead(
		{
			hint: true,
			highlight: true,
			minLength: 1
		}
		<cfloop list="#lcase(colsList)#" index="curColumn">
		,
		{
			name: 'col_#curColumn#',
			displayKey: 'value',
			source: col_#curColumn#.ttAdapter()
		}
		</cfloop>
		);			
	}	

	
	function parseEditorContent()
	{
		var html = editor.getData();
		var rawDiv = jQuery('##rawDiv');
		rawDiv = rawDiv[0];
		jQuery(rawDiv).html(html);
		var curDiv = null;
		var curParent = null;
		var curID = null;
		var newHTML = '';
		var curFormat = null;
		var divs = rawDiv.getElementsByClassName('placeholder');
		if (divs.length)
			curDiv = divs[0];
		while(curDiv)
		{
			curParent = curDiv.parentNode;
			curID = curDiv.getAttribute('id');
			curID = curID.replace('PL_','');
			curFormat = curDiv.getAttribute('data-format');
			newHTML = '<customObjectListBuilderTag customtagid="#inputParameters.fldID#" id="' + curID + '" format="' + curFormat + '">';
			curParent.outerHTML = newHTML;
			rawDiv = jQuery('##rawDiv');
			rawDiv = rawDiv[0];
			divs = rawDiv.getElementsByClassName('placeholder');
			if (divs.length)
				curDiv = divs[0];	
			else
				break;			
		}
		html = jQuery(rawDiv).html();
		
		editor.setData(html);
	}	
	var hasTabs = [];
	jQuery(document).ready(function()	
	{
		editor = CKEDITOR.instances['#fqFieldName#'];
		hasTabs = jQuery('.cs_tab_inactive');
		//getTypeAheadSetupReady();
		//renderResults();
		thisTypeahead();
		callEditorResize();
	});		
	
	function callEditorResize()
	{
		if (!editor)
			return;
		try
		{
			var leftTD = jQuery('##leftTD').height();
			var parsedH = parseInt(leftTD);

	//		if (hasTabs.length)
	//			parsedH -= 20;
			//alert(parsedH);
			editor.resize( '100%', parsedH, false ,true );
		}
		catch(e){}
	}
	reSizeLocal = function()
	{
		// executes when complete page is fully loaded, including all frames, objects and images
		var winWidth = jQuery(window).width();
		var winHeight = jQuery(top.window).height()
		//debugger;
		var parsedH = parseInt(winHeight);
		var parsedW = parseInt(winWidth);
		if (hasTabs.length)
			parsedH -= 40;		
		callEditorResize();
		//jQuery('##borderedTable').height(parseInt(parsedH-190));
		jQuery('##contentTR').height(parseInt(parsedH-260));
		jQuery('##containerTD').height(parseInt(parsedH-250));
		jQuery('##containerTD').width(parseInt(parsedW/2));
		jQuery('##containerDIV').css('overflowY','auto');
		jQuery('##containerDIV').css('maxHeight',parseInt(parsedH-250));
		jQuery('##cs_commondlg').css('overflow','hidden');
	}


	jQuery(window).resize(reSizeLocal);
</script>
</cfoutput>