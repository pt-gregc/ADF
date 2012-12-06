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

<!--- // RLW - 2011-01-30 - this field type is designed to allow you to easily get the value/params from another
	field in the same custom element.  Currently only the csPageURL (CommonSpot Page URL) field type has 
	been implemented
		2011-12-28 - MFC - Force JQuery to "noconflict" mode to resolve issues with CS 6.2.
	 --->

<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	otherFields = arrayNew(1);
	tabIDList = "";
		
	application.ADF.scripts.loadJQuery(noConflict=true);
	// get the list of tabs for this element
	tabAry = application.ADF.ceData.getTabsFromFormID(request.params.formID);
	// convert to list
	for(itm=1; itm lte arrayLen(tabAry); itm=itm+1 ){
		tabIDList=listAppend(tabIDList, tabAry[itm].ID);
	}
	// retrieve the fields
	otherFields = application.ADF.ceData.getFieldsFromTabID(tabIDList);
</cfscript>
<cfif not arrayLen(otherFields)>
	<cfoutput><p>Error reading fields from element. Make sure there are fields for this tab and/or check your CommonSpot Error Logs</p></cfoutput>
	<cfexit>
</cfif>
<cfparam name="currentValues.formField" default="">

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#formField';
		// allows this field to support the orange icon (copy down to label from field name)
		fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
		// allows this field to have a common onSubmit Validator
		fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
		// handling the copy label function
		function #prefix#doLabel(str)
		{
			document.#formname#.#prefix#label.value = str;
		}
		function #prefix#doValidate()
		{
			if( jQuery("###prefix#formField").val().length == 0 )
			{
				alert('Please select a valid field on this form');
				jQuery("###prefix#formField").focus();
				return false;
			}
			return true;
		}
	
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall">CS Page Field Name:</td>
			<td class="cs_dlgLabelSmall">
				<select name="#prefix#formField" id="#prefix#formField">
					<option value="">--Select--</option>
					<cfloop from="1" to="#arrayLen(otherFields)#" index="itm">
						<cfset jsFieldID = "fic_#request.params.formID#_#otherFields[itm].fieldID#">
						<option value="#jsFieldID#"<cfif currentValues.formField eq jsFieldID> selected="selected"</cfif>>#otherFields[itm].defaultValues.label# [#otherFields[itm].defaultValues.fieldName#]</option>
					</cfloop>
				</select>
				<p>Select the CS Element to bind to</p>
			</td>
		</tr>
	</table>
</cfoutput>