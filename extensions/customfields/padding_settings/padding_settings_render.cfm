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
	PaperThin Inc.
Name:
	date_time_builder_render.cfm
Summary:
	Custom field to build the Date/Time records.
	This field generates a collection of Date and Times for the field.
Version:
	1.0.0
History:
	2014-09-15 - Created
	2014-09-29 - GAC - Added Padding Value normalization to remove the label from the default values
--->

<cfscript>
	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";
	
	
	// Create a script obj
	application.ADF.scripts.loadJQuery();
	
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];

	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
 	// WriteDump(var=xparams, expand='no');

	// Validate if the property field has been defined
	if ( NOT StructKeyExists(xparams, "fldID") OR LEN(xparams.fldID) LTE 0 )
		xparams.fldID = fqFieldName;
	if ( NOT StructKeyExists(xparams, "fieldID") )
		xparams.fieldID = fqFieldName;
	if ( (NOT StructKeyExists(xparams, "fieldClass")) OR ( LEN(TRIM(xparams.fieldClass)) LTE 0) )
		xparams.fieldClass = "";
	
	// Remove any labels from the possibleValues String
	if ( StructKeyExists(xparams, "possibleValues") AND LEN(TRIM(xparams.possibleValues)) )
		xparams.possibleValues = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=xparams.possibleValues);
	else
		xparams.possibleValues = "";
		
	if( CurrentValue eq '' )
	{
		top = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=xparams.top);	
		right = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=xparams.right);	
		bottom = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=xparams.bottom);	
		left = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=xparams.left);	
	}		
	else
	{
		//top = ListGetAt( currentValue, 1, ' ' );
		//right = ListGetAt( currentValue, 2, ' ' );
		//bottom = ListGetAt( currentValue, 3, ' ' );
		//left = ListGetAt( currentValue, 4, ' ' );
		
		top = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=ListGetAt( currentValue, 1, ' ' ) );	
		right = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=ListGetAt( currentValue, 2, ' ' ) );	
		bottom = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=ListGetAt( currentValue, 3, ' ' ) );	
		left = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=ListGetAt( currentValue, 4, ' ' ) );	
	}
	
	currentValue = top & 'px ' & right & 'px ' & bottom & 'px ' & left & 'px';
	
	if( NOT StructKeyExists( xparams, 'ShowTop' ) )
		xparams.ShowTop = 0;
	if( NOT StructKeyExists( xparams, 'ShowRight' ) )
		xparams.ShowRight = 0;
	if( NOT StructKeyExists( xparams, 'ShowBottom' ) )
		xparams.ShowBottom = 0;
	if( NOT StructKeyExists( xparams, 'ShowLeft' ) )
		xparams.ShowLeft = 0;
		
	// TODO: add a function that strips the px off of each value in the possible values string
	// TODO: make sure each value int the possible values string is numeric
	// TODO: strip the px of of the current value string before converting to individual values
</cfscript>

<cfsavecontent variable="inputHTML">
	<cfoutput>
		<div>
		<cfif LEN(TRIM(xparams.possibleValues))>
			#application.ADF.paddingSettings.renderSelectionList(xparams.showTop,'Top:',xparams.FieldID,'Top',top,xparams.possibleValues)#
			#application.ADF.paddingSettings.renderSelectionList(xparams.showRight,'Right:',xparams.FieldID,'Right',right,xparams.possibleValues)#
			#application.ADF.paddingSettings.renderSelectionList(xparams.showBottom,'Bottom:',xparams.FieldID,'Bottom',bottom,xparams.possibleValues)#
			#application.ADF.paddingSettings.renderSelectionList(xparams.showLeft,'Left:',xparams.FieldID,'Left',left,xparams.possibleValues)#
		<cfelse>
			#application.ADF.paddingSettings.renderTextInput(xparams.showTop,'Top:',xparams.FieldID,'Top',top)#
			#application.ADF.paddingSettings.renderTextInput(xparams.showRight,'Right:',xparams.FieldID,'Right',right)#
			#application.ADF.paddingSettings.renderTextInput(xparams.showBottom,'Bottom:',xparams.FieldID,'Bottom',bottom)#
			#application.ADF.paddingSettings.renderTextInput(xparams.showLeft,'Left:',xparams.FieldID,'Left',left)#
		</cfif>
			<!--- // hidden field to store the value --->
			<input type="hidden" name="#fqFieldName#" value="#currentValue#" id="#xparams.fieldID#" class="#xparams.fieldClass#">
		</div>	
		<script>
			function onChange_#xparams.fieldID#()
			{
				var t = jQuery('###xparams.fieldID#_Top').val();
				var r = jQuery('###xparams.fieldID#_Right').val();
				var b = jQuery('###xparams.fieldID#_Bottom').val();
				var l = jQuery('###xparams.fieldID#_Left').val();
				
				<!--- // TODO: Add a JS function to parse the input values and build the valid padding string --->
				
				jQuery('###xparams.fieldID#').val(t + 'px ' + r + 'px ' + b + 'px ' + l + 'px'); 
			}
		</script>
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
<cfoutput>#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#</cfoutput>

