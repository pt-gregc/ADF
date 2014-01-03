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
Name:
	fields_1_0.cfc
Summary:
	CFT Fields functions for the ADF Library
Version:
	1.0
History:
	2013-12-09 - MFC - Created
--->
<cfcomponent displayname="fields_1_0" extends="ADF.core.Base" hint="CFT Fields functions for the ADF Library">

<cfproperty name="version" value="1_0_0">
<cfproperty name="type" value="transient">
<!--- <cfproperty name="ceData" injectedBean="ceData_1_0" type="dependency">
<cfproperty name="scripts" injectedBean="scripts_1_0" type="dependency"> --->
<cfproperty name="wikiTitle" value="Fields_1_0">

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$renderDataValueStringfromFieldMask
Summary:
	Returns the string of data values from field mask. 
	Used with the Custom Element Field Select CFT
Returns:
	string
Arguments:
	Struct - fieldDataStruct
	string - fieldMaskStr
History:
 	2010-12-06 - RAK - Created
	2013-11-14 - DJM - Pulled out from the Custom Element Select Field render file and converted to its own method
	2013-11-14 - GAC - Moved from the Custom Element Select Field to the Forms_1_1 lib
--->
<cffunction name="renderDataValueStringfromFieldMask" hint="Returns the string of data values from field mask" access="public" returntype="string">
	<cfargument name="fieldDataStruct" type="struct" required="true" hint="Struct with the field key/value pair">
	<cfargument name="fieldMaskStr" type="string" required="true" hint="String mask of <fieldNames> used build the field value display">
	<cfscript>
		var displayField = arguments.fieldMaskStr;
		var startChar = chr(171);
		var endChar = chr(187);
		var value = '';
		var foundIndex = 0;
		var foundEndIndex = 0;
		
		// While we still detect the upper ascii start character loop through
		while ( Find(startChar,displayField) ) {
			foundIndex = Find(startChar,displayField);
			foundEndIndex = Find(endChar,displayField);
			//Grab the content in between the start and end character
			value = mid(displayField,foundIndex+1,foundEndIndex-foundIndex-1);
			if ( StructKeyExists(arguments.fieldDataStruct,value) ) {
				// We found it. Replace the <value> with the actual value
				displayField = Replace(displayField,"#startChar##value##endChar#", arguments.fieldDataStruct[value],"ALL");
			}
			else {
				// Something is messed up... tell them so in the field!
				displayField = Replace(displayField,"#startChar##value##endChar#", "Field '#value#' does not exist!");
			}
		}
		
		return displayField;
	</cfscript>
</cffunction>

</cfcomponent>