<!---
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
--->

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	Michael Carroll 
Custom Field Type:
	general_chooser_props.cfm
Name:
	general_chooser_props.cfm
Summary:
	General Chooser field type.
	Allows for selection of the custom element records.
ADF Requirements:
	lib/scripts/ceData_1_0
	lib/scripts/SCRIPTS_1_0
History:
	2009-10-16 - MFC - Created
	2009-11-13 - MFC - Updated the Ajax calls to the CFC to call the controller 
						function.  This allows only the "controller" function to 
						listed in the proxy white list XML file.
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	// overwrite the field ID to be unique
	xParams.fieldID = #fqFieldName#;
	
	// Set the defaults
	if( StructKeyExists(xParams, "forceScripts") AND (xParams.forceScripts EQ "1") )
		xParams.forceScripts = true;
	else
		xParams.forceScripts = false;
	
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;
</cfscript>

<cfoutput>
	
	<cfscript>
		// Load the scripts
		scriptsObj = server.ADF.objectFactory.getBean("scripts_1_0");
		scriptsObj.loadJQuery("1.3.2", xParams.forceScripts);
		scriptsObj.loadJQueryUI("1.7.2", "ui-lightness", xParams.forceScripts);
		//scriptsObj.loadThickbox("3.1", xParams.forceScripts);
		//scriptsObj.loadJQueryTools();
		scriptsObj.loadADFLightbox();
	</cfscript>
	
	<script type="text/javascript">
		var #xParams.fieldID#_ajaxProxyURL = "#application.ADF.ajaxProxy#";
		var #xParams.fieldID#currentValue = "#currentValue#";
		var #xParams.fieldID#searchValues = "";
		var #xParams.fieldID#queryType = "all";
		
		jQuery(document).ready(function() {
			
			// Load the form sections
			#xParams.fieldID#_initChooser();
			#xParams.fieldID#_loadSection1();
		    #xParams.fieldID#_loadSection2();
		    #xParams.fieldID#_loadSection3();
			
			// JQuery use the LIVE event b/c we are adding links/content dynamically		    
		    // click for show all not-selected items
		    jQuery('###fqFieldName#-showAllItems').live("click", function(event){
			  	//#xParams.fieldID#queryType = 'notselected';
				#xParams.fieldID#_loadTopics('notselected');
			});
		    
		    // JQuery use the LIVE event b/c we are adding links/content dynamically
		    jQuery('###fqFieldName#-searchBtn').live("click", function(event){
			  	//#xParams.fieldID#queryType = "search";
				//load the search field into currentItems
				#xParams.fieldID#searchValues = jQuery('input###fqFieldName#-searchFld').val();
				#xParams.fieldID#currentValue = jQuery('input###fqFieldName#').val();
				#xParams.fieldID#_loadTopics('search')
			});
			
		});
		function #xParams.fieldID#_initChooser() {
			// load the initial list items based on the top terms from the chosen facet
			jQuery.get( #xParams.fieldID#_ajaxProxyURL,
			{ 	
				bean: '#xParams.chooserCFCName#',
				method: 'controller',
				chooserMethod: 'initChooser',
				fieldName: '#fqFieldName#',
				item: #xParams.fieldID#currentValue,
				queryType: #xParams.fieldID#queryType,
				searchValues: #xParams.fieldID#searchValues
			},
			function(msg){
				jQuery("###xParams.fieldID#-gc-init-styles").html(msg);
			});
		
		}
		
		function #xParams.fieldID#_loadSection1(){
			// load the initial list items based on the top terms from the chosen facet
			jQuery.get( #xParams.fieldID#_ajaxProxyURL,
			{ 	
				bean: '#xParams.chooserCFCName#',
				method: 'controller',
				chooserMethod: 'loadSection1',
				fieldName: '#fqFieldName#'
			},
			function(msg){
				jQuery("###xParams.fieldID#-gc-section1").html(msg);
			});
		}
		
		function #xParams.fieldID#_loadSection2(){
			// load the initial list items based on the top terms from the chosen facet
			jQuery.get( #xParams.fieldID#_ajaxProxyURL,
			{ 	
				bean: '#xParams.chooserCFCName#',
				method: 'controller',
				chooserMethod: 'loadSection2',
				fieldName: '#fqFieldName#'
			},
			function(msg){
				jQuery("###xParams.fieldID#-gc-section2").html(msg);
				// reinitialize the ADFLightbox				
				initADFLB();
			});
		}
		
		function #xParams.fieldID#_loadSection3(){
			// load the initial list items based on the top terms from the chosen facet
			jQuery.get( #xParams.fieldID#_ajaxProxyURL,
			{ 	
				bean: '#xParams.chooserCFCName#',
				method: 'controller',
				chooserMethod: 'loadSection3',
				fieldName: '#fqFieldName#'
			},
			function(msg){
				jQuery("###xParams.fieldID#-gc-section3").html(msg);
				if ( jQuery('input###fqFieldName#').val() != "")
				{
					// Load the selected terms on initial load
					#xParams.fieldID#_loadTopics('selected');
				}
				
				// Check the SHOW ALL LINKS flag status
				jQuery.get( #xParams.fieldID#_ajaxProxyURL,
				{ 	
					bean: '#xParams.chooserCFCName#',
					method: 'controller',
					chooserMethod: 'getShowAllLinksFlag'
				},
				function(msg){
					// SHOW ALL LINKS flag is not displayed so auto file the selections.
					if ( jQuery.trim(msg) == 'false'){
						//#xParams.fieldID#queryType = 'notselected';
						#xParams.fieldID#_loadTopics('notselected');
					}
				});
			});
		}
		
		function #xParams.fieldID#_loadTopics(queryType) {
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
				item: #xParams.fieldID#currentValue,
				queryType: queryType,
				searchValues: #xParams.fieldID#searchValues,
				csPageID: '#request.page.id#'
			},
			function(msg){
				if (queryType == "selected")
					jQuery("###xParams.fieldID#-sortable2").html(jQuery.trim(msg));
				else
					jQuery("###xParams.fieldID#-sortable1").html(jQuery.trim(msg));
					
				#xParams.fieldID#currentValue = "#currentValue#";
				#xParams.fieldID#_loadEffects();
			});
			
		}
		
		function #xParams.fieldID#_loadEffects() {
			jQuery("###xParams.fieldID#-sortable1, ###xParams.fieldID#-sortable2").sortable({
				connectWith: '.connectedSortable',
				stop: function(event, ui) { #xParams.fieldID#_serialize(); }
			}).disableSelection();
		}
		
		// serialize the selections
		function #xParams.fieldID#_serialize() {
			// get the serialized list
			var serialList = jQuery('###xParams.fieldID#-sortable2').sortable( 'toArray' );
			// load serial list into current values
			#xParams.fieldID#currentValue = serialList;
			// load current values into the form field
			jQuery("input###fqFieldName#").val(#xParams.fieldID#currentValue);
		}
	</script>
	<tr>
		<td class="cs_dlgLabelSmall" colspan="2">
			<br />
			<div>
				#xparams.label#:
			</div>
			<div id="#xParams.fieldID#-gc-init-styles"></div>
			<div id="#xParams.fieldID#-gc-main-area">
				<div id="#xParams.fieldID#-gc-top-area">
					<div id="#xParams.fieldID#-gc-section1">
					</div>
					<div id="#xParams.fieldID#-gc-section2">
					</div>
				</div>
				<div id="#xParams.fieldID#-gc-section3">
				</div>
			</div>	
			<input type="hidden" id="#fqFieldName#" name="#fqFieldName#" value="#currentValue#">
		</td>
	</tr>
	
	<script type="text/javascript">
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
	</script>
	
	<!--- // include hidden field for simple form processing --->
	<cfif renderSimpleFormField>
		<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'fic_','')#">
	</cfif>
</cfoutput>