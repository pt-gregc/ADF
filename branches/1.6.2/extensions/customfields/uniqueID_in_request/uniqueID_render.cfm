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
	PaperThin Inc.
Name:
	uniqueID_render.cfm
Version:
	1.1
History:
	2014-01-07 - GAC - Converted the CFT to the ADF standard CFT format using the forms.wrapFieldHTML method
--->

<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	if ( NOT StructKeyExists(xparams,"uniqueIDtype") OR LEN(TRIM(xparams.uniqueIDtype)) EQ 0 ) 
		xparams.uniqueIDtype = "cfuuid"; // cfuuid or csid
		
	if ( NOT StructKeyExists(xparams,"varName") OR LEN(TRIM(xparams.varName)) EQ 0 ) 
		xparams.varName = "uniqueID"; 
	
	if ( NOT StructKeyExists(xparams,"renderField") OR xparams.renderField NEQ "yes" ) 
		xparams.renderField = "no"; 
	
	if ( NOT StructKeyExists(xparams,"renderRequestVar") OR !IsBoolean(xparams.renderRequestVar) ) 
		xparams.renderRequestVar = "no"; 
	
	if ( NOT LEN(currentValue) ) {
		// Set the Unique ID value the first time the field is rendered
	    if ( xparams.uniqueIDtype EQ "csid" )
			currentValue = Request.Site.IDMaster.getID();
		else
			currentValue = createUUID();
	}
	
	// Set defaults for the label and description 
	includeLabel = false; 		// Set to false so label does not display
	includeDescription = false; // Set to false so description does not display
	
	// Set the Input Field Type
	cftInputType = "hidden";
	formInputSize = "";
	if ( xparams.renderField EQ "yes") {
		cftInputType = "text";
		cftInputSize = 40;
		includeLabel = true;
	}
	
	// Set the Display the Request Varaible and the Value
	//if ( xparams.renderRequestVar )
	//	includeLabel = true;

	// set this into request scope so other objects can use this
	request[xparams.varName] = currentValue;
</cfscript>

<cfoutput>
	<cfif xparams.renderField EQ "no" AND xparams.renderRequestVar EQ "no">
	<style type="text/css">
		tr###fqFieldName#_FIELD_ROW {
			visibility: collapse;
		}
	</style>
	</cfif>
	
	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<input type="#cftInputType#" name="#fqFieldName#" value="#currentValue#"<cfif xparams.renderField EQ "yes"> size="#cftInputSize#"</cfif>/>
			<cfif xparams.renderRequestVar>
			<div>request.#xparams.varName#: #request[xparams.varName]#</div>
			</cfif>
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
