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
<cfif NOT StructKeyExists( request, 'cs_loaded_padding_functions' )>
	<cfset request.cs_loaded_padding_functions = 1>
	<cfinclude template="padding_functions.cfm">
</cfif>	

<!---
/* *************************************************************** */
Author: 	
	PaperThin Inc.
	M. Carroll
Name:
	date_time_builder_render.cfm
Summary:
	Custom field to build the Date/Time records.
	This field generates a collection of Date and Times for the field.
Version:
	1.0.0
History:
	2010-09-15 - MFC - Created
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
		
	
	if( CurrentValue eq '' )
	{
		top = xparams.top;	
		right = xparams.right;	
		bottom = xparams.bottom;	
		left = xparams.left;	
		CurrentValue = top & ' ' & right & ' ' & bottom & ' ' & left;
	}		
	else
	{
		top = ListGetAt( currentValue, 1, ' ' );
		right = ListGetAt( currentValue, 2, ' ' );
		bottom = ListGetAt( currentValue, 3, ' ' );
		left = ListGetAt( currentValue, 4, ' ' );
	}
	
	if( NOT StructKeyExists( xparams, 'ShowTop' ) )
		xparams.ShowTop = 0;
	if( NOT StructKeyExists( xparams, 'ShowRight' ) )
		xparams.ShowRight = 0;
	if( NOT StructKeyExists( xparams, 'ShowBottom' ) )
		xparams.ShowBottom = 0;
	if( NOT StructKeyExists( xparams, 'ShowLeft' ) )
		xparams.ShowLeft = 0;
</cfscript>

<cfsavecontent variable="inputHTML">
	<cfoutput>
		<div>
			#renderSelectionList(xparams.showLeft,'Left:',xparams.FieldID,'Left',left,xparams.possibleValues)#
			#renderSelectionList(xparams.showTop,'Top:',xparams.FieldID,'Top',top,xparams.possibleValues)#
			#renderSelectionList(xparams.showRight,'Right:',xparams.FieldID,'Right',right,xparams.possibleValues)#
			#renderSelectionList(xparams.showBottom,'Bottom:',xparams.FieldID,'Bottom',bottom,xparams.possibleValues)#

			<!--- hidden field to store the value --->
			<input type="hidden" name="#fqFieldName#" value="#currentValue#" id="#xparams.fieldID#" class="#xparams.fieldClass#">
		</div>	
		<script>
			function onChange_#xparams.fieldID#()
			{
				var t = jQuery('###xparams.fieldID#_Top').val();
				var r = jQuery('###xparams.fieldID#_Right').val();
				var b = jQuery('###xparams.fieldID#_Bottom').val();
				var l = jQuery('###xparams.fieldID#_Left').val();
			
				jQuery('###xparams.fieldID#').val(t + ' ' + r + ' ' + b + ' ' + l); 
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

