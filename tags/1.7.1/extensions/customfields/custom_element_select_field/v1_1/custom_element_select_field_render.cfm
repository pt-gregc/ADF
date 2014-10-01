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
	M. Carroll 
Custom Field Type:
	Custom Element Select Field
Name:
	custom_element_select_field_render.cfm
Summary:
	Custom Element select field to select the custom element fields for the
		option id and name values.
	Added Properties to set the field name value, default field value, and field visibility.
ADF Requirements:
	csData_2_0
	scripts_1_2
	forms_1_1
History:
	2009-10-28 - MFC - Created
	2009-12-23 - MFC - Resolved error with loading the current value selected.
	2010-03-10 - MFC - Updated function call to ADF lib to reference application.ADF.
						Updated cedata statement to remove filter and get all records.
	2010-06-10 - MFC - Update to sort the CEDataArray at the start.
	2010-09-17 - MFC - Updated the Default Value field to add [] to the value 
						to make it evaluate a CF expression.
	2010-11-22 - MFC - Updated the loadJQuery call to remove the jquery version param.
						Removed commented out cfdump.
	2010-12-06 - RAK - Added the ability to define an active flag
						Added ability to dynamically build the display field - <firstName> <lastName>:At <email>
	2011-01-06 - RAK - Added error catching on evaluate failure.
	2011-02-08 - RAK - Added the class to the select from the props file for javascript interaction.
	2011-04-20 - RAK - Added the ability to have a multiple select field
	2011-06-23 - RAK - Added sortField option
	2011-06-23 - GAC - Added the the conditional logic for the sortField option 
					- Modified the "Other" option  from the displayFieldBuilder to be "--Other--" to make more visible and to avoid CE field name conflicts 
					- Added code to display the Description text 
	2013-02-20 - MFC - Replaced Jquery "$" references.
	2013-09-27 - GAC - Added a renderSelectOption to allow the 'SELECT' text to be added or removed from the selection list
	2013-11-14 - DJM - Added the fieldpermission variable for read only field 
    				 - Moved the Field to Data Mask code out to an new ADF from_1_1 function
	2013-11-14 - GAC - Updated the selected value to be an empty string if the stored value or the default value does not match available records from the bound element
	2013-11-15 - GAC - Converted the CFT to the ADF standard CFT format using the forms.wrapFieldHTML method
	2014-01-17 - TP  - Added the ability to render checkboxes, radio buttons as well as a selection list
	2014-01-30 - DJM - Removed Active Field and Value fields and replaced with a filter criteria option
	2014-01-30 - GAC - Moved into a v1_1 version subfolder
	2014-02-27 - GAC - Added backwards compatibility logic to allow field use the prior version of the CFT if installed on a pre-CS9 site
	2014-03-07 - JTP - Fixed issue if duplicate items in list. Caused selected value to be duplicated. Also limit results if read-only.
	2014-03-07 - DJM - Created Custom_Element_Select_Field_base.cfc for CFT specific methods
	2014-03-23 - JTP - Changed to have 'Select All' / 'Deselect All' links
	2014-03-24 - JTP - Added logic to sort selection list by display value if specified in props
	
To Do:
	2014-04-08 - JTP - Currently we are NOT sorting the list if displayed as checkboxes/radio buttons and user choose sort by display value
--->
<cfscript>
	requiredCSversion = 9;
	csVersion = ListFirst(ListLast(request.cp.productversion," "),".");
</cfscript>
<cfif csVersion LT requiredCSversion>
	<cfset useCFTversion = "v1_0">
	<cfinclude template="/ADF/extensions/customfields/custom_element_select_field/#useCFTversion#/custom_element_select_field_render.cfm">
	<cfexit>
</cfif>

<!---// CommonSpot 9 Required for the new element data filter criteria --->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	// the current row from the fieldQuery
	currentRow = fieldQuery.currentRow;

	// Set the Current Selected Value for the HIDDEN field that is passes the data to be stored
	// - This variable will only be populated if the value (default or stored) exists in the bound custom element  
	currentSelectedValue = "";
	
	// Set the defaults
	if ( StructKeyExists(xParams, "forceScripts") AND (xParams.forceScripts EQ "1") )
		xParams.forceScripts = true;
	else
		xParams.forceScripts = false;
		
	if ( NOT StructKeyExists(xparams,"multipleSelect") OR !IsBoolean(xParams.multipleSelect) )
		xParams.multipleSelect = false;
		
	if( NOT StructKeyExists(xparams,"widthValue") OR NOT IsNumeric(xParams.widthValue) )
		xParams.widthValue = "200";
	if( NOT StructKeyExists(xparams,"heightValue") OR NOT IsNumeric(xParams.heightValue) )
		xParams.heightValue = "150";	
		
	cType = application.ADF.customElementSelect.getFieldType(xparams);
	if( cType eq 'select' )		
	{
		SELECTION_LIST = 1;
	}
	else	
	{
		SELECTION_LIST = 0;	
	}	

	// For backwards compatiblity: 
	// - when using a Single Select the render Select Option must be explicity TURNED OFF to be disabled
	// - but for a Multi Select the render Select Option must be explicity TURNED ON to be enabled 
	// - and we must leave this as an available option Multi Select dropdowns
	if ( !StructKeyExists(xParams,"renderSelectOption") OR !IsBoolean(xParams.renderSelectOption) ) 
	{
		xParams.renderSelectOption = true;
		if ( xParams.multipleSelect )
			xParams.renderSelectOption = false;
	}
	
	if ( !StructKeyExists(xParams,"renderClearSelectionLink") OR !IsBoolean(xParams.renderClearSelectionLink) ) 
			xParams.renderClearSelectionLink = 0; 
	
	if ( NOT StructKeyExists(xparams, "fldName") OR (LEN(xparams.fldName) LTE 0) )
		xparams.fldName = fqFieldName;
	
	if ( NOT StructKeyExists(xparams,"addButton") OR !IsBoolean(xparams.addButton) )
		xparams.addButton = 0;
	
	ceFormID = 0;
	if (StructKeyExists(xparams,"customElement") and Len(xparams.customElement))
		ceFormID = application.ADF.cedata.getFormIDByCEName(xparams.customElement);
	
	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check with the cs6 fieldPermission parameter --
	//-- Also check to see if this field is FORCED to be READ ONLY for CS 9+ by looking for attributes.currentValues[fqFieldName_doReadonly] variable --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission, fqFieldName, attributes.currentValues);	
		
	// Check if we do not have a current value then set to the default
	if ( (LEN(currentValue) LTE 0) OR (currentValue EQ "") ) 
	{
		if ( (TRIM(LEFT(xparams.defaultVal,1)) EQ "[") AND (TRIM(RIGHT(xparams.defaultVal,1)) EQ "]") ) 
		{
			// Trim the [] from the expression
			xparams.defaultVal = MID(xparams.defaultVal, 2, LEN(xparams.defaultVal)-2);
			//2011-01-06 - RAK - Added error catching on eval failure.
			try{
				currentValue = Evaluate(xparams.defaultVal);
			}
			catch(Any e){
				currentValue = "";
			}
		}
		else
			currentValue = xparams.defaultVal;
	}
	
	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true;
	
	// Load JQuery to the script
	application.ADF.scripts.loadJQuery(force=xParams.forceScripts);
	if( SELECTION_LIST AND StructKeyExists(xparams, 'SortOption') AND xParams.SortOption eq 'useDisplay' )
		application.ADF.scripts.loadJQuerySelectboxes();
</cfscript>

<cfoutput>
	<script type="text/javascript">
		// javascript validation to make sure they have text to be converted
		#fqFieldName# = new Object();
		#fqFieldName#.id = '#fqFieldName#';
		//#fqFieldName#.tid = #rendertabindex#;
		#fqFieldName#.validator = "validate_#fqFieldName#()";
		#fqFieldName#.msg = "Please select a value for the #xparams.label# field.";
		// Check if the field is required
		if ( '#xparams.req#' == 'Yes' )
		{
			// push on to validation array
			vobjects_#attributes.formname#.push(#fqFieldName#);
		}
		
		function validate_#fqFieldName#()
		{
			if (jQuery("input[name=#fqFieldName#]").val() != '') 
				return true;
			else 
			{
				return false;
			}
		}
		
		// Set a global disable field flag 
		var setDisableFlag = false;
		
		function #fqFieldName#_loadSelection()
		{
			// Selected value
			var selectedVal = "";
			<cfif SELECTION_LIST>
			jQuery("select###fqFieldName#_select").find(':selected').each(function(index,item){
			<cfelse>
			jQuery("###fqFieldName#_div").find(':checked').each(function(index,item){			
			</cfif>
				if(selectedVal.length)
					selectedVal += ","
				selectedVal += jQuery(item).val();
			});
			// put the selected value into the
			jQuery("input[name=#fqFieldName#]").val(selectedVal);
		}
		
		// Function to set the field as disabled
		function #xparams.fldName#_disableFld()
		{
			// Set a global disable field flag 
			setDisableFlag = true;
			jQuery(".cls#fqFieldName#").attr('disabled', true);
		}
		
		// Function to set the field as enabled
		function #xparams.fldName#_enableFld()
		{
			// Set a global disable field flag 
			setDisableFlag = false;
			jQuery(".cls#fqFieldName#").attr('disabled', false);
		}
		
		jQuery(document).ready(function()
		{ 
			// Check if the field is hidden
			if( '#xparams.renderField#' == 'no' ) 
				jQuery("###fqFieldName#_fieldRow").hide();

			<!--- determine whether to use JS to sort items in list --->
			<cfif SELECTION_LIST eq 1>
				<cfif StructKeyExists(xparams, 'SortOption') AND xParams.SortOption eq 'useDisplay'>
					var obj = jQuery("###fqFieldName#_select");
					if( obj && typeof obj.sortOptions == 'function')
						obj.sortOptions();
				<cfelseif xparams.displayField eq "--Other--">
					var obj = jQuery("###fqFieldName#_select");
					if( obj && typeof obj.sortOptions == 'function' ) 
						obj.sortOptions();
				</cfif>	
			</cfif>
			
			<cfif xParams.renderClearSelectionLink>
				jQuery("###fqFieldName#_SelectAll").click(function(){

					<cfif cType EQ 'radio'>
						jQuery("input:radio[name=#fqFieldName#_select]").each(function(){
								jQuery(this).prop('checked',true);
						});
					<cfelse>
						//jQuery("input:checkbox[name=#fqFieldName#_select]").unCheckCheckboxes();
						jQuery("input:checkbox[name=#fqFieldName#_select]").each(function(){
								jQuery(this).prop('checked',true);	
						});
					</cfif>
					#fqFieldName#_loadSelection();
					});

				
				jQuery("###fqFieldName#_DeselectAll").click(function(){
					
				<cfif cType EQ 'radio'>
					jQuery("input:radio[name=#fqFieldName#_select]").each(function(){
							jQuery(this).prop('checked',false);	
					});
				<cfelse>
					//jQuery("input:checkbox[name=#fqFieldName#_select]").unCheckCheckboxes();
					jQuery("input:checkbox[name=#fqFieldName#_select]").each(function(){
							jQuery(this).prop('checked',false);	
					});
				</cfif>
				jQuery("input[name=#fqFieldName#]").val('');
				});
				
			</cfif>
		});
		
		function #fqFieldName#_reloadSelection()
		{
			var dataToBeSent_#fqFieldName# = 
				{ 
					bean: 'customElementSelect_1_0',
					method: 'renderCustomElementSelect',
					query2array: 0,
					returnformat: 'json',
					propertiesStruct: JSON.stringify(<cfoutput>#SerializeJSON(xparams)#</cfoutput>),
					formID: #ceFormID#,
					fqFieldName: '#fqFieldName#',
					fieldCurrentValue: '#currentValue#',
					isReadOnly: #readOnly#						
			 	};
	
			jQuery.post( '#application.ADF.ajaxProxy#', 
								dataToBeSent_#fqFieldName#,
								onSuccess_#fqFieldName#,
								"json");
		}
		
		function onSuccess_#fqFieldName#(data)
		{
			document.getElementById('#fqFieldName#_renderSelect').innerHTML = data;
			CloseWindow();
		}
	</script>
</cfoutput>
	
<cfsavecontent variable="inputHTML">
	<cfoutput>
		<table border=0 cellspacing="0" cellpadding="0"><tr><td>
		
			<div id="#fqFieldName#_renderSelect">#application.ADF.customElementSelect.renderCustomElementSelect(xparams,ceFormID,fqFieldName,currentValue,readOnly)#</div></cfoutput>
			
	 		<cfif xparams.addButton EQ "1">
				<cfoutput>
					</td><td valign="top" nowrap="nowrap">
				
					#application.ADF.scripts.loadJQuery()#
					#application.ADF.scripts.loadJQueryUI()#
					#application.ADF.scripts.loadADFLightbox()#
					<style type="text/css">
						a###fqFieldName#_addNewLink{
							font-size: 10px;
   							padding: 2px 4px;
							text-decoration:none;
							margin-left: 6px;
						}
						a###fqFieldName#_addNewLink:hover{
							cursor:pointer;
						}
					</style>
					<script type="text/javascript">
						jQuery(document).ready(function(){
							// Hover states on the static widgets
							jQuery("##addNew").hover(
								function() {
									jQuery(this).addClass('ui-state-hover');
								},
								function() {
									jQuery(this).removeClass('ui-state-hover');
								}
							);
						});
					</script>
				</cfoutput>
				
				<cfset buttonLabel = "New #xParams.label#">
				
				<cfoutput><a href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=Forms_1_1&method=renderAddEditForm&formid=#ceFormID#&datapageid=0&lbAction=norefresh&title=#buttonLabel#&callback=#fqFieldName#_reloadSelection" id="#fqFieldName#_addNewLink" class="ADFLightbox add-button ui-state-default ui-corner-all">#buttonLabel#</a></cfoutput>
	 		</cfif>
			
		<cfoutput></td></tr></table></cfoutput>		
</cfsavecontent>

<!---
	This CFT is using the forms lib wrapFieldHTML functionality. The wrapFieldHTML takes
	the Form Field HTML that you want to put into the TD of the right section of the CFT 
	table row and helps with display formatting, adds the hidden simple form fields (if needed) 
	and handles field permissions (other than read-only).
	Optionally you can disable the field label and the field discription by setting 
	the includeLabel and/or the includeDescription variables (found above) to false.  
--->
<cfoutput>	
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
</cfoutput>
