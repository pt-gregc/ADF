<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
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
	uniqueID_render.cfc
Version:
	1.1
History:
	2014-01-07 - GAC - Converted the CFT to the ADF standard CFT format using the forms.wrapFieldHTML method
	2015-04-30 - DJM - Converted to CFC
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
--->
<cfcomponent displayName="UniqueID Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderLabel" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);
		if (inputParameters.renderField EQ "yes")
			super.renderLabel(argumentCollection=arguments);
	</cfscript>
</cffunction>

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		// Set the Input Field Type
		var cftInputType = "hidden";
		var cftInputSize = 0;
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);	
	
		if ( NOT LEN(currentValue) ) {
			// Set the Unique ID value the first time the field is rendered
			if ( inputParameters.uniqueIDtype EQ "csid" )
				currentValue = Request.Site.IDMaster.getID();
			else
				currentValue = createUUID();
		}
		
		if (inputParameters.renderField EQ "yes") {
			cftInputType = "text";
			cftInputSize = 40;
		}

		// set this into request scope so other objects can use this
		request[inputParameters.varName] = currentValue;
	</cfscript>

	<cfoutput>
		<cfif inputParameters.renderField EQ "no" AND inputParameters.renderRequestVar EQ "no">
			<style type="text/css">
				div###arguments.fieldName#_container {
					visibility: collapse;
				}
			</style>
		</cfif>
		<cfif inputParameters.renderField EQ "no" AND arguments.isRequired>
			<style type="text/css">
				div###arguments.fieldName#_label {
					visibility: collapse;
				}
			</style>
		</cfif>
		
		<input type="#cftInputType#" name="#arguments.fieldName#" value="#currentValue#"<cfif inputParameters.renderField EQ "yes"> size="#cftInputSize#"</cfif>/>
		<cfif inputParameters.renderRequestVar>
			<div>request.#inputParameters.varName#: #request[inputParameters.varName]#</div>
		</cfif>
	</cfoutput>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		
		if ( NOT StructKeyExists(inputParameters,"uniqueIDtype") OR LEN(TRIM(inputParameters.uniqueIDtype)) EQ 0 ) 
			inputParameters.uniqueIDtype = "cfuuid"; // cfuuid or csid
			
		if ( NOT StructKeyExists(inputParameters,"varName") OR LEN(TRIM(inputParameters.varName)) EQ 0 ) 
			inputParameters.varName = "uniqueID"; 
		
		if ( NOT StructKeyExists(inputParameters,"renderField") OR inputParameters.renderField NEQ "yes" ) 
			inputParameters.renderField = "no"; 
		
		if ( NOT StructKeyExists(inputParameters,"renderRequestVar") OR !IsBoolean(inputParameters.renderRequestVar) ) 
			inputParameters.renderRequestVar = "no"; 
		
		return inputParameters;
	</cfscript>
</cffunction>

</cfcomponent>