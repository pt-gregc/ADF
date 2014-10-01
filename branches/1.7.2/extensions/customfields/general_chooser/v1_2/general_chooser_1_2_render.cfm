<!---
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
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M Carroll 
Custom Field Type:
	general chooser v1.2
Name:
	general_chooser_1_2_render.cfm
Summary:
	General Chooser field type.
	Allows for selection of the custom element records.
Version:
	1.2
History:
	2009-10-16 - MFC - Created
	2009-11-13 - MFC - Updated the Ajax calls to the CFC to call the controller 
						function.  This allows only the "controller" function to 
						listed in the proxy white list XML file.
	2010-11-09 - MFC - Updated the Scripts loading methods to dynamically load the latest 
						script versions from the Scripts Object.
	2011-03-20 - MFC - Updated component to simplify the customizations process and performance.
						Removed Ajax loading process.
	2011-03-27 - MFC - Updated for Add/Edit/Delete callback.
	2011-09-21 - RAK - Added max/min selections
	2011-10-20 - GAC - Added defualt value check for the minSelections and maxSelections xParams varaibles
	2012-01-04 - SS - The field now honors the "required" setting in Standard Options.
	2012-03-19 - MFC - Added "loadAvailable" option to set if the available selections load
						when the form loads.
					   Added the new records will load into the "selected" area when saved.
	2012-07-31 - MFC - Replaced the CFJS function for "ListLen" and "ListFindNoCase".
	2013-01-10 - MFC - Fixed issue with the to add the new records into the "selected" area when saved.
	2013-12-02 - GAC - Added a new callback function for the the edit/delete to reload the selected items after an edit or a delete
					 - Updated to allow 'ADD NEW' to be used multiple times before submit
	2014-03-20 - GAC - Force the keys in the formData object from the 'ADD NEW' callback to lowercase so it is sure to match js_fieldName_CE_FIELD  value 
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	// overwrite the field ID to be unique
	xParams.fieldID = fqFieldName;
	
	// Set the defaults
	if( StructKeyExists(xParams, "forceScripts") AND (xParams.forceScripts EQ "1") )
		xParams.forceScripts = true;
	else
		xParams.forceScripts = false;
		
	if( NOT StructKeyExists(xParams, "minSelections") )
		xParams.minSelections = "0"; //	0 = selections are optional
	if( NOT StructKeyExists(xParams, "maxSelections") )
		xParams.maxSelections = "0"; //	0 = infinite selections are possible
	if( NOT StructKeyExists(xParams, "loadAvailable") )
		xParams.loadAvailable = "0"; //	0 = infinite selections are possible
	
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;
	
	// Set the label start and end tags
	labelStart = attributes.itemBaselineParamStart;
	labelEnd = attributes.itemBaseLineParamEnd;	
	//If the fields are required change the label start and end
	if ( xparams.req eq "Yes" ) {
		labelStart = attributes.reqItemBaselineParamStart;
		labelEnd = attributes.reqItemBaseLineParamEnd;
	}

	// Set defaults for the label and description 
	includeLabel = false;
	includeDescription = false; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check with the cs6 fieldPermission parameter --
	//-- Also check to see if this field is FORCED to be READ ONLY for CS 9+ by looking for attributes.currentValues[fqFieldName_doReadonly] variable --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission,fqFieldName,attributes.currentValues);
	//readOnly = true;
	
	if ( readOnly ) 
		xParams.loadAvailable = 0;
</cfscript>

<cfoutput>
	<cfscript>
		// Load the scripts
		application.ADF.scripts.loadJQuery(force=xParams.forceScripts);
		application.ADF.scripts.loadJQueryUI(force=xParams.forceScripts);
		application.ADF.scripts.loadADFLightbox();
		application.ADF.scripts.loadCFJS();
		
		// init Arg struct
		initArgs = StructNew();
		initArgs.fieldName = fqFieldName;
		initArgs.readOnly = readOnly;
		
		// Build the argument structure to pass into the Run Command
		selectionsArg = StructNew();
		selectionsArg.item = currentValue;
		selectionsArg.queryType = "selected";
		selectionsArg.csPageID = request.page.id;
		selectionsArg.fieldID = xParams.fieldID;
		selectionsArg.readOnly = readOnly;
	</cfscript>
	
	<script type="text/javascript">
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		#fqFieldName#.validator = "#xParams.fieldID#_validate()";
		vobjects_#attributes.formname#.push(#fqFieldName#);
		
		var #xParams.fieldID#_ajaxProxyURL = "#application.ADF.ajaxProxy#";
		var #xParams.fieldID#currentValue = "#currentValue#";
		var #xParams.fieldID#searchValues = "";
		var #xParams.fieldID#queryType = "all";
		
		jQuery(document).ready(function(){
			
			// Resize the window on the page load
			checkResizeWindow();
			
			// JQuery use the LIVE event b/c we are adding links/content dynamically		    
		    // click for show all not-selected items
		    jQuery('###fqFieldName#-showAllItems').live("click", function(event){
			  	// Load all the not-selected options
			  	#xParams.fieldID#_loadTopics('notselected');
			});
		    
		    // JQuery use the LIVE event b/c we are adding links/content dynamically
		    jQuery('###fqFieldName#-searchBtn').live("click", function(event){
		  		//load the search field into currentItems
				#xParams.fieldID#searchValues = jQuery('input###fqFieldName#-searchFld').val();
				#xParams.fieldID#currentValue = jQuery('input###fqFieldName#').val();
				#xParams.fieldID#_loadTopics('search')
			});
			
			<cfif !readOnly>
			// Load the effects and lightbox - this is b/c we are auto loading the selections
			#xParams.fieldID#_loadEffects();
			</cfif>
			
			// Re-init the ADF Lightbox
			initADFLB();
		});
		
		// 2013-12-02 - GAC - Updated to allow 'ADD NEW' to be used multiple times before submit
		function #xParams.fieldID#_loadTopics(queryType) 
		{
			var cValue = jQuery("input###fqFieldName#").val();		
				
			// Put up the loading message
			if (queryType == "selected")
				jQuery("###xParams.fieldID#-sortable2").html("Loading ... <img src='/ADF/extensions/customfields/general_chooser/ajax-loader-arrows.gif'>");
			else
				jQuery("###xParams.fieldID#-sortable1").html("Loading ... <img src='/ADF/extensions/customfields/general_chooser/ajax-loader-arrows.gif'>");
			
			// load the initial list items based on the top terms from the chosen facet
			jQuery.get( #xParams.fieldID#_ajaxProxyURL,
			{ 	
				bean: '#xParams.chooserCFCName#',
				method: 'controller',
				chooserMethod: 'getSelections',
				// item: #xParams.fieldID#currentValue, // removed since this value was not dynamically updating after 'ADD NEW'
				item: cValue,
				queryType: queryType,
				searchValues: #xParams.fieldID#searchValues,
				csPageID: '#request.page.id#',
				fieldID: '#xParams.fieldID#'
			},
			function(msg)
			{
				if (queryType == "selected")
					jQuery("###xParams.fieldID#-sortable2").html(jQuery.trim(msg));
				else
					jQuery("###xParams.fieldID#-sortable1").html(jQuery.trim(msg));
					
				#xParams.fieldID#_loadEffects();
				
				// Re-init the ADF Lightbox
				initADFLB();
			});
		}
		
		function #xParams.fieldID#_loadEffects() 
		{
			<cfif !readOnly>
			jQuery("###xParams.fieldID#-sortable1, ###xParams.fieldID#-sortable2").sortable({
				connectWith: '.connectedSortable',
				stop: function(event, ui) { #xParams.fieldID#_serialize(); }
			}).disableSelection();
			</cfif>
		}
		
		// serialize the selections
		function #xParams.fieldID#_serialize() 
		{
			// get the serialized list
			var serialList = jQuery('###xParams.fieldID#-sortable2').sortable( 'toArray' );
			// Check if the serialList is Array
			if ( jQuery.isArray(serialList) )
			{
				serialList = jQuery.ArrayToList(serialList);
			}
			
			// load serial list into current values
			#xParams.fieldID#currentValue = serialList;
			// load current values into the form field
			jQuery("input###fqFieldName#").val(#xParams.fieldID#currentValue);
		}
		
		// Resize the window function
		function checkResizeWindow()
		{
			// Check if we are in a loader.cfm page
			if ( '#ListLast(cgi.SCRIPT_NAME,"/")#' == 'loader.cfm' ) 
			{
				ResizeWindow();
			}
		}
		
		// 2013-12-02 - GAC - Updated to allow 'ADD NEW' to be used multiple times before submit
		function #xParams.fieldID#_formCallback(formData)
		{
			formData = typeof formData !== 'undefined' ? formData : {};
			var cValue = jQuery("input###fqFieldName#").val();

			// Call the utility function to make sure the JS object keys are all lowercase 
			formData = #xParams.fieldID#_ConvertCaseOfDataObjKeys(formData,'lower');

			// Load the newest item onto the selected values
			// 2012-07-31 - MFC - Replaced the CFJS function for "ListLen" and "ListFindNoCase".
			if ( cValue.length > 0 )
			{
				// Check that the record does not exist in the list already
				tempValue = cValue.search(formData[js_#xParams.fieldID#_CE_FIELD]); 
				if ( tempValue <= 0 ) 
					cValue = jQuery.ListAppend(formData[js_#xParams.fieldID#_CE_FIELD], cValue);
			}
			else 
				cValue = formData[js_#xParams.fieldID#_CE_FIELD];

			// load current values into the form field
			jQuery("input###fqFieldName#").val(cValue);
			
			// Reload the selected Values
			#xParams.fieldID#_loadTopics("selected");
			
			// Close the lightbox
			closeLB();
		}
		
		// 2013-11-26 - Fix for duplicate items on edit issue
		function #xParams.fieldID#_formEditCallback()
		{
			// Reload the selected Values
			#xParams.fieldID#_loadTopics("selected");
			// Reload the non-selected Values
			#xParams.fieldID#_loadTopics("notselected");
			// Close the lightbox
			closeLB();
		}

		// Validation function to validate required field and max/min selections
		function #xParams.fieldID#_validate()
		{
			//Get the list of selected items
			var selections = jQuery("###fqFieldName#").val();
			var lengthOfSelections = 0;
			//.split will return an array with 1 item if there is an empty string. Get around that.
			if(selections.length){
				var arraySelections = selections.split(",");
				lengthOfSelections = arraySelections.length;
			}
			<cfif xparams.req EQ 'Yes'>
				// If the field is required, check that a select has been made.
				if (lengthOfSelections <= 0) {
					alert("Please make a selection from the available items list.");
					return false;
				}
			</cfif>
			<cfif isNumeric(xParams.minSelections) and xParams.minSelections gt 0>
				if(lengthOfSelections < #xParams.minSelections#){
					alert("Minimum number of selections is #xParams.minSelections# you have only selected "+lengthOfSelections+" items");
					return false;
				}
			</cfif>
			<cfif isNumeric(xParams.maxSelections) and xParams.maxSelections gt 0>
				if(lengthOfSelections > #xParams.maxSelections#){
					alert("Maximum number of selections is #xParams.maxSelections# you have selected "+lengthOfSelections+" items");
					return false;
				}
			</cfif>
			return true;
		}
		
		// A Utility function convert the case of keys of a JS Data Object
		function #xParams.fieldID#_ConvertCaseOfDataObjKeys(dataobj,keycase)
		{
			dataobj = typeof dataobj !== 'undefined' ? dataobj : {};
			keycase = typeof keycase !== 'undefined' ? keycase : "lower"; //lower OR upper
			var key, keys = Object.keys(dataobj);
			var n = keys.length;
			var newobj={}
			while (n--) {
			  key = keys[n];
			  if ( keycase == 'lower' )
			  	newobj[key.toLowerCase()] = dataobj[key];
			  else if ( keycase == 'upper' ) 
			  	newobj[key.toUpperCase()] = dataobj[key];
			  else
			  	newobj[key] = dataobj[key]; // NOT upper or lower... pass the data back with keys unchanged
			}
			return newobj;
		}
	</script>
	<!--- //Load the General Chooser Styles --->
	#application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
											methodName="loadStyles",
											args=initArgs)#
	<!--- <tr>
		<td class="cs_dlgLabelSmall" colspan="2">
			
		</td>
	</tr> --->
	
	<!--- // include hidden field for simple form processing --->
	<!--- <cfif renderSimpleFormField>
		<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'fic_','')#">
	</cfif> --->
	
	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<!--- <div id="#xParams.fieldID#-gc-init-styles"></div> --->
			
			<!--- // Build Label --->
			<div id="#xParams.fieldID#-gc-main-label" class="cs_dlgLabelBoldNoAlign">
				#labelStart#
				<label for="#fqFieldName#" id="#fqFieldName#_LABEL">#TRIM(xParams.label)#:</label>
				#labelEnd#
			</div>
			
			<!--- // Instructions --->
			<div id="#xParams.fieldID#-gc-top-area-instructions" class="cs_dlgLabelSmall">
				#TRIM(application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
															methodName="loadChooserInstructions",
															args=initArgs))#
			</div>
			
			<div id="#xParams.fieldID#-gc-main-area" class="cs_dlgLabelSmall">
			
				<div id="#xParams.fieldID#-gc-top-area">
					<!--- SECTION 1 - TOP LEFT --->
					<div id="#xParams.fieldID#-gc-section1">
						<!--- Load the Search Box --->
						#application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
															methodName="loadSearchBox",
															args=initArgs)#
					</div>									
					<!--- SECTION 2 - TOP RIGHT --->
					<div id="#xParams.fieldID#-gc-section2">
						<!--- Load the Add New Link --->
						#application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
															methodName="loadAddNewLink",
															args=initArgs)#
					</div>
				</div>
				
				<!--- SECTION 3 --->
				<div id="#xParams.fieldID#-gc-section3">
					
					<!--- // Instructions --->
					<!--- <div id="#xParams.fieldID#-gc-top-area-instructions">
						#TRIM(application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
															methodName="loadChooserInstructions",
															args=initArgs))#
						<!--- Select the records you want to include in the selections by dragging 
							items into or out of the 'Available Items' list. Order the columns 
							within the datasheet by dragging items within the 'Selected Items' field. --->
					</div> --->
				
					<!--- Select Boxes --->
					<div id="#xParams.fieldID#-gc-select-left-box-label">
						#TRIM(application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
															methodName="loadAvailableLabel",
															args=initArgs))#
					</div>
					<div id="#xParams.fieldID#-gc-select-right-box-label">
						#TRIM(application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
															methodName="loadSelectedLabel",
															args=initArgs))#
					</div>
					<div id="#xParams.fieldID#-gc-select-left-box">
						<ul id="#xParams.fieldID#-sortable1" class="connectedSortable">
							<!--- Auto load the available selections --->
							<cfscript>
								// Set the query type flag before running the command
								selectionsArg.queryType = "notselected";
							</cfscript>
							<cfif xParams.loadAvailable>
								#application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
																methodName="getSelections",
																args=selectionsArg)#
							</cfif>
						</ul>
					</div>
					
					<div id="#xParams.fieldID#-gc-select-right-box">
						<ul id="#xParams.fieldID#-sortable2" class="connectedSortable">
							<!--- Check if we have current values and load the selected data --->
							<cfif LEN(currentValue)>
								<cfscript>
									// Set the query type flag before running the command
									selectionsArg.queryType = "selected";
								</cfscript>
								#application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
																methodName="getSelections",
																args=selectionsArg)#
							</cfif>
						</ul>
					</div>
				</div>
			</div>	
			<input type="hidden" id="#fqFieldName#" name="#fqFieldName#" value="#currentValue#">
		</cfoutput>
	</cfsavecontent>
	
	<!---
		This CFT is using the forms lib wrapFieldHTML functionality. The wrapFieldHTML takes
		the Form Field HTML that you want to put into the TD of the right section of the CFT 
		table row and helps with display formatting, adds the hidden simple form fields (if needed) 
		and handles field permissions (other than read-only).
		Optionally you can disable the field label and the field discription by setting 
		the includeLabel and/or the includeDescription variables (found above) to false.  
	--->
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
</cfoutput>