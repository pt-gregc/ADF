<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the Starter App directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->
<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright 
Custom Field Type:
	Custom Section Label Field
Name:
	$custom_section_label_render.cfm
Summary:
	Label Custom Field
History:
 	2012-03-19 - GAC - Created
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];

	// Set the label ID from the field name
	if ( NOT StructKeyExists(xparams, "labelID") OR LEN(TRIM(xparams.labelID)) EQ 0 )
		xparams.labelID = TRIM(ReplaceNoCase(fqFieldName,'fic_','')) & "_LABEL";
	
	// Set the Label Class Name 
	if ( NOT StructKeyExists(xparams, "labelClass") )
		xparams.labelClass = "";
	
	// Set the decription DIV ID 
	if ( NOT StructKeyExists(xparams, "descptID") )
		xparams.descptID = "";
	
	// Set the decription DIV Class 
	if ( NOT StructKeyExists(xparams, "descptClass") )
		xparams.descptClass = "";

	// Set the hideLabelText flag 
	if ( NOT StructKeyExists(xparams, "hideLabelText") )
		xparams.hideLabelText = false;

	// Remove leading and trailing spaces
	xparams.labelID = TRIM(xparams.labelID);
	xparams.labelClass = TRIM(xparams.labelClass);
	xparams.descptID = TRIM(xparams.descptID);
	xparams.descptClass = TRIM(xparams.descptClass);

	// Get the Discription 
	description = "";
	if ( StructKeyExists(fieldQuery,"DESCRIPTION") )
		description = fieldQuery.DESCRIPTION[fieldQuery.currentRow];
	
	//If the fields are required change the label start and end
	labelStart = attributes.itemBaselineParamStart;
	labelEnd = attributes.itemBaseLineParamEnd;
	if ( xparams.req eq "Yes" )
	{
		labelStart = attributes.reqItemBaselineParamStart;
		labelEnd = attributes.reqItemBaseLineParamEnd;
	}
</cfscript>
<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
	</script>
	
	<tr id="#fqFieldName#_FIELD_ROW" colspan="2">
		<td valign="top">
		<cfif xparams.hideLabelText>
			<span id="#xparams.labelID#"<cfif LEN(xparams.labelClass)> class="#xparams.labelClass#"</cfif>></span>
		<cfelse>
			<cfif LEN(xparams.labelClass) EQ 0>#labelStart#</cfif>
			<label id="#xparams.labelID#"<cfif LEN(xparams.labelClass)> class="#xparams.labelClass#"</cfif>>#xParams.label#</label>
			<cfif LEN(xparams.labelClass) EQ 0>#labelEnd#</cfif>
		</cfif>
		</td>
	</tr>
	<cfif LEN(TRIM(description))>
	<!--- // If there is a description print out a new row and the description --->
	<tr id="#fqFieldName#_DESCRIPTION_ROW">
		<td colspan="2">
		<cfif LEN(xparams.descptID) OR LEN(xparams.descptClass)>
			<div<cfif LEN(xparams.descptID)> id="#xparams.descptID#"</cfif><cfif LEN(xparams.descptClass)> class="#xparams.descptClass#"</cfif>>
			#description#
			</div>
		<cfelse>
			#attributes.descParamStart#
			#description#
			<br/><br/>
			#attributes.descParamEnd#
		</cfif>
		</td>
	</tr>
	</cfif>
</cfoutput>