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
	padding_settings_base.cfc
Summary:
	Common functions for the padding settings custom field
Version:
	1.0
History:
	2014-09-15 - Created
	2014-09-29 - GAC - Added a Padding Value normalization method to remove the label from the default values
--->
<cfcomponent displayname="padding_settings_base" extends="ADF.core.Base" output="false" hint="Common functions for the padding settings custom field">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	$renderSelectionList
Summary:
	Renders a selection list of possible padding values.
Returns:
	Void
Arguments:
	Boolean - Show
	String - Label
	String - FieldID
	String - Name
	String - Value
	String - possibleValues
History:
	2014-09-15 - Created
--->
<cffunction name="renderSelectionList" access="public" output="Yes" returntype="void" hint="renders a selection list of possible padding values.">
	<cfargument name="Show" type="Boolean" required="Yes">
	<cfargument name="Label" type="String" required="Yes">
	<cfargument name="FieldID" type="string" required="Yes">
	<cfargument name="name" type="string" required="Yes">
	<cfargument name="value" type="string" required="Yes">
	<cfargument name="possibleValues" type="string" required="Yes">
	
	<cfset var index="">
	
	<cfif arguments.show>
		<cfoutput>
			#arguments.label#
			<select id="#arguments.FieldID#_#arguments.Name#" name="#arguments.FieldID#_#arguments.Name#" onchange="onChange_#FieldID#();">
				<cfloop index="index" list="#arguments.possibleValues#">
					<option<cfif TRIM(arguments.value) eq TRIM(index)> selected="selected"</cfif>>#TRIM(index)#</option>
				</cfloop>
			</select>px&nbsp;&nbsp;
		</cfoutput>	
	<cfelse>
		<cfoutput><input type="hidden" id="#arguments.FieldID#_#arguments.Name#" name="#arguments.FieldID#_#arguments.Name#" value="#TRIM(arguments.value)#"></cfoutput>
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	$renderInputField
Summary:
	Renders an generic input field 
Returns:
	Void
Arguments:
	Boolean - Show
	String - Label
	String - FieldID
	String - Name
	String - Value
History:
	2014-09-15 - Created
--->
<cffunction name="renderTextInput" access="public" output="Yes" returntype="void" hint="renders a selection list of possible padding values.">
	<cfargument name="Show" type="Boolean" required="Yes">
	<cfargument name="Label" type="String" required="Yes">
	<cfargument name="FieldID" type="string" required="Yes">
	<cfargument name="name" type="string" required="Yes">
	<cfargument name="value" type="string" required="Yes">
	
	<cfif arguments.show>
		<cfoutput>
			#arguments.label#
			<input type="text" id="#arguments.FieldID#_#arguments.Name#" name="#arguments.FieldID#_#arguments.Name#" value="#TRIM(arguments.value)#" size="4" onKeyUp="onChange_#FieldID#();" style="text-align:right;">px&nbsp;&nbsp;
		</cfoutput>	
	<cfelse>
		<cfoutput><input type="hidden" id="#arguments.FieldID#_#arguments.Name#" name="#arguments.FieldID#_#arguments.Name#" value="#TRIM(arguments.value)#"></cfoutput>
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	$normalizePaddingValues
Summary:
	Removes the labels from the padding strings added via the CFT props
Returns:
	Void
Arguments:
	String - PaddingValues
	String - Delimiter
History:
	2014-09-29 - Created
--->
<cffunction name="normalizePaddingValues" access="public" output="false" returntype="string" hint="">
	<cfargument name="PaddingValues" type="string" required="false" default="">
	<cfargument name="delimiter" type="string" required="false" default=",">
	
	<cfscript>
		var retStr = "";
		var item = "";
		
		for ( i=1; i LTE ListLen(arguments.PaddingValues,arguments.delimiter); i=i+1 )
		{
			item = ListGetAt(arguments.PaddingValues,i,arguments.delimiter);	
			if ( FindNoCase("px",item) )
				item = TRIM(ReplaceNoCase(item,"px",""));
				
			retStr = ListAppend(retStr,item,arguments.delimiter);
		}
		
		return retStr;
	</cfscript>
</cffunction>


</cfcomponent>