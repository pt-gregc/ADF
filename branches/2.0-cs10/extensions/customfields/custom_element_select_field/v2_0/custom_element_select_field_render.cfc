<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
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
	custom_element_select_field_render.cfc
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
	2014-11-06 - GAC - Fixed the conditional logic around the xparams.defaultVal expression parsing
	2015-04-10 - DJM - Converted to CFC
	2015-04-24 - DJM - Added own CSS
	2015-05-13 - DRM - Add isMultiline()
	2015-05-26 - DJM - Added the 2.0 version
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 

To Do:
	2014-04-08 - JTP - Currently we are NOT sorting the list if displayed as checkboxes/radio buttons and user choose sort by display value
--->
<cfcomponent displayName="CustomElementSelectField Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var allAtrs = getAllAttributes();
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var ceFormID = 0;
		var cType = application.ADF.customElementSelect.getFieldType(inputParameters);
		var selection_list = (cType eq 'select') ? 1: 0;
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;	
		var ajaxComURL = application.ADF.ajaxProxy;
		var buttonLabel = "New #inputParameters.label#";
		var cftPath = "/ADF/extensions/customfields/custom_element_select_field/v2_0";
	
		inputParameters = setDefaultParameters(argumentCollection=arguments);
		
		if (StructKeyExists(inputParameters,"customElement") and Len(inputParameters.customElement))
			ceFormID = application.ADF.cedata.getFormIDByCEName(inputParameters.customElement);

		// Check if we do not have a current value then set to the default
		if ( LEN(TRIM(currentValue)) EQ 0 ) 
		{
			if ( (LEFT(TRIM(inputParameters.defaultVal),1) EQ "[") AND (RIGHT(TRIM(inputParameters.defaultVal),1) EQ "]") ) 
			{
				// Trim the [] from the expression
				inputParameters.defaultVal = MID(inputParameters.defaultVal, 2, LEN(inputParameters.defaultVal)-2);
				
				//2011-01-06 - RAK - Added error catching on eval failure.
				try{
					currentValue = Evaluate(inputParameters.defaultVal);
				}
				catch(Any e){
					currentValue = "";
				}
			}
			else
				currentValue = inputParameters.defaultVal;
		}
		
		// Load JQuery to the script
		application.ADF.scripts.loadJQuery(force=inputParameters.forceScripts);
		if( selection_list AND StructKeyExists(inputParameters, 'SortOption') AND inputParameters.SortOption eq 'useDisplay' )
			application.ADF.scripts.loadJQuerySelectboxes();
		
		renderJSFunctions(argumentCollection=arguments, fieldParameters=inputParameters, formID=ceFormID, isSelectionList=selection_list, controlType=cType, updatedValue=currentValue);
	</cfscript>
	
	<cfoutput><table border=0 cellspacing="0" cellpadding="0"><tr><td>
		<div id="#arguments.fieldName#_renderSelect">#application.ADF.customElementSelect.renderCustomElementSelect(inputParameters,ceFormID,arguments.fieldName,currentValue,readOnly)#</div></cfoutput>
		
		<cfif inputParameters.addButton EQ "1">
			<cfoutput>
				</td><td valign="top" nowrap="nowrap">
			
				#application.ADF.scripts.loadJQuery()#
				#application.ADF.scripts.loadJQueryUI()#
				#application.ADF.scripts.loadADFLightbox()#
				<cfif NOT StructKeyExists(Request, 'customSelectCSS')>
					<cfoutput>
						<link rel="stylesheet" type="text/css" href="#cftPath#/custom_element_select_field_styles.css" />
					</cfoutput>
					<cfset Request.customSelectCSS = 1>
				</cfif>
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
			
			<cfoutput><a href="javascript:;" rel="#ajaxComURL#?bean=Forms_1_1&method=renderAddEditForm&formid=#ceFormID#&datapageid=0&lbAction=norefresh&title=#buttonLabel#&callback=#arguments.fieldName#_reloadSelection" id="#arguments.fieldName#_addNewLink" class="ADFLightbox add-button ui-state-default ui-corner-all addNewButton">#buttonLabel#</a></cfoutput>
		</cfif>
	
	<cfoutput></td></tr></table></cfoutput>		
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="fieldParameters" type="struct" required="yes">
	<cfargument name="formID" type="numeric" required="yes">
	<cfargument name="isSelectionList" type="boolean" required="yes">
	<cfargument name="controlType" type="string" required="yes">
	<cfargument name="updatedValue" type="string" required="yes">
	
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.fieldParameters);
		var readOnly = (arguments.displayMode EQ 'readonly') ? true :false;	
		
		// Ajax URL to the proxy component in the context of the site
		var ajaxComURL = application.ADF.ajaxProxy;
		var ajaxBeanName = 'customElementSelect_1_0';
	</cfscript>

<cfoutput>
<script type="text/javascript">
<!--

// Set a global disable field flag 
var setDisableFlag = false;

function #arguments.fieldName#_loadSelection()
{
	// Selected value
	var selectedVal = "";
	<cfif arguments.isSelectionList>
	jQuery("select###arguments.fieldName#_select").find(':selected').each(function(index,item){
	<cfelse>
	jQuery("###arguments.fieldName#_div").find(':checked').each(function(index,item){			
	</cfif>
		if(selectedVal.length)
			selectedVal += ","
		selectedVal += jQuery(item).val();
	});
	// put the selected value into the
	jQuery("input[name=#arguments.fieldName#]").val(selectedVal);
}

// Function to set the field as disabled
function #inputParameters.fldName#_disableFld()
{
	// Set a global disable field flag 
	setDisableFlag = true;
	jQuery(".cls#arguments.fieldName#").attr('disabled', true);
}

// Function to set the field as enabled
function #inputParameters.fldName#_enableFld()
{
	// Set a global disable field flag 
	setDisableFlag = false;
	jQuery(".cls#arguments.fieldName#").attr('disabled', false);
}

jQuery(document).ready(function()
{ 
	// Check if the field is hidden
	if( '#inputParameters.renderField#' == 'no' ) 
		jQuery("###arguments.fieldName#_fieldRow").hide();

	<!--- determine whether to use JS to sort items in list --->
	<cfif arguments.isSelectionList eq 1>
		<cfif StructKeyExists(inputParameters, 'SortOption') AND inputParameters.SortOption eq 'useDisplay'>
			var obj = jQuery("###arguments.fieldName#_select");
			if( obj && typeof obj.sortOptions == 'function')
				obj.sortOptions();
		<cfelseif inputParameters.displayField eq "--Other--">
			var obj = jQuery("###arguments.fieldName#_select");
			if( obj && typeof obj.sortOptions == 'function' ) 
				obj.sortOptions();
		</cfif>	
	</cfif>
	
	<cfif inputParameters.renderClearSelectionLink>
		jQuery("###arguments.fieldName#_SelectAll").click(function(){

			<cfif arguments.controlType EQ 'radio'>
				jQuery("input:radio[name=#arguments.fieldName#_select]").each(function(){
						jQuery(this).prop('checked',true);
				});
			<cfelse>
				//jQuery("input:checkbox[name=#arguments.fieldName#_select]").unCheckCheckboxes();
				jQuery("input:checkbox[name=#arguments.fieldName#_select]").each(function(){
						jQuery(this).prop('checked',true);	
				});
			</cfif>
			#arguments.fieldName#_loadSelection();
			});

		
		jQuery("###arguments.fieldName#_DeselectAll").click(function(){
			
		<cfif arguments.controlType EQ 'radio'>
			jQuery("input:radio[name=#arguments.fieldName#_select]").each(function(){
					jQuery(this).prop('checked',false);	
			});
		<cfelse>
			//jQuery("input:checkbox[name=#arguments.fieldName#_select]").unCheckCheckboxes();
			jQuery("input:checkbox[name=#arguments.fieldName#_select]").each(function(){
					jQuery(this).prop('checked',false);	
			});
		</cfif>
		jQuery("input[name=#arguments.fieldName#]").val('');
		});
		
	</cfif>
});

function #arguments.fieldName#_reloadSelection()
{
	var dataToBeSent_#arguments.fieldName# = 
		{ 
			bean: '#ajaxBeanName#',
			method: 'renderCustomElementSelect',
			query2array: 0,
			returnformat: 'json',
			propertiesStruct: JSON.stringify(<cfoutput>#SerializeJSON(inputParameters)#</cfoutput>),
			formID: #arguments.formID#,
			fqFieldName: '#arguments.fieldName#',
			fieldCurrentValue: '#arguments.updatedValue#',
			isReadOnly: #readOnly#						
		};

	jQuery.post( '#ajaxComURL#', 
						dataToBeSent_#arguments.fieldName#,
						onSuccess_#arguments.fieldName#,
						"json");
}

function onSuccess_#arguments.fieldName#(data)
{
	document.getElementById('#arguments.fieldName#_renderSelect').innerHTML = data;
	CloseWindow();
}
//-->
</script></cfoutput>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		
		// Set the defaults
		if ( StructKeyExists(inputParameters, "forceScripts") AND (inputParameters.forceScripts EQ "1") )
			inputParameters.forceScripts = true;
		else
			inputParameters.forceScripts = false;
			
		if ( NOT StructKeyExists(inputParameters,"multipleSelect") OR !IsBoolean(inputParameters.multipleSelect) )
			inputParameters.multipleSelect = false;
			
		if( NOT StructKeyExists(inputParameters,"widthValue") OR NOT IsNumeric(inputParameters.widthValue) )
			inputParameters.widthValue = "200";
		
		if( NOT StructKeyExists(inputParameters,"heightValue") OR NOT IsNumeric(inputParameters.heightValue) )
			inputParameters.heightValue = "150";	

		// For backwards compatiblity: 
		// - when using a Single Select the render Select Option must be explicity TURNED OFF to be disabled
		// - but for a Multi Select the render Select Option must be explicity TURNED ON to be enabled 
		// - and we must leave this as an available option Multi Select dropdowns
		if ( !StructKeyExists(inputParameters,"renderSelectOption") OR !IsBoolean(inputParameters.renderSelectOption) ) 
		{
			inputParameters.renderSelectOption = true;
			if ( inputParameters.multipleSelect )
				inputParameters.renderSelectOption = false;
		}
		
		if ( !StructKeyExists(inputParameters,"renderClearSelectionLink") OR !IsBoolean(inputParameters.renderClearSelectionLink) ) 
				inputParameters.renderClearSelectionLink = 0; 
		
		if ( NOT StructKeyExists(inputParameters, "fldName") OR (LEN(inputParameters.fldName) LTE 0) )
			inputParameters.fldName = arguments.fieldName;
		
		if ( NOT StructKeyExists(inputParameters,"addButton") OR !IsBoolean(inputParameters.addButton) )
			inputParameters.addButton = 0;
		
		return inputParameters;
	</cfscript>
</cffunction>

<cfscript>
	private any function getValidationJS(required string formName, required string fieldName, required boolean isRequired)
	{
		if (arguments.isRequired)
			return 'hasValue(document.#arguments.formName#.#arguments.fieldName#, "TEXT")';
		return "";
	}
	
	private string function getValidationMsg()
	{
		return "Please select a value for the #arguments.label# field.";
	}

	private boolean function isMultiline()
	{
		return (structKeyExists(arguments.parameters, "multipleSelect") && arguments.parameters.multipleSelect == 1);
	}

	public string function getResourceDependencies()
	{
		return listAppend(super.getResourceDependencies(), "jQuery,jQueryUI,ADFLightbox,jQuerySelectboxes");
	}
</cfscript>

</cfcomponent>