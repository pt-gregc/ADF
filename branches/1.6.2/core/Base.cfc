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
	Base.cfc
Summary:
	Base component for Custom Application Common Framework
History:
	2009-05-11 - MFC - Created
	2011-01-21 - GAC - Added a getADFversion function
	2011-04-05 - MFC - Updated the version property.
					   Added a getCSVersion function.
	2011-07-11 - MFC - Updated INIT function to remove call to "super.init".
	2011-09-27 - GAC - Added a getADFminorVersion to only return first two version digits
	2013-10-21 - GAC - Added 'file-version' property for ADF core files
--->
<cfcomponent name="Base" hint="Base component for Custom Application Common Framework">

<cfproperty name="version" value="1_6_2">
<cfproperty name="file-version" value="1">
	
<cffunction name="init" output="true" returntype="any">
	<cfscript>
		StructAppend(variables, arguments, false);
		return this;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc. 	
	G. Cronkright
Name:
	getADFversion
Summary:
	Returns the ADF Version
Returns:
	String - ADF Version
Arguments:
	Void
History:
	2011-01-20 - GAC - Created
--->
<cffunction name="getADFversion" access="public" returntype="string">
	<cfscript>
		var ADFversion = "0.0.0";
		if ( StructKeyExists(server.ADF,"version") )
			ADFversion = server.ADF.version;
	 	return ADFversion;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.	
	G. Cronkright
Name:
	getDecimalADFVersion
Summary:
	Returns the the major and minor digits of the ADF Version in decimal format
		for comparing.
Returns:
	Numeric - ADF Decimal Version 
Arguments:
	Void
History:
	2011-09-27 - GAC/MFC - Created
	2011-09-28 - GAC - Updated to use the VAL function to remove the version numbers after the minor version
--->
<cffunction name="getDecimalADFVersion" access="public" returntype="numeric">
	<cfscript>
		var ADFversion = getADFversion();
		return Val(ADFversion);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.
	M. Carroll
Name:
	getCSversion
Summary:
	Returns the CS Version as based on the "server.ADF.csVersion" loaded
		in Core.cfc.
Returns:
	numeric - ADF Version
Arguments:
	Void
History:
	2011-04-05 - MFC - Created
--->
<cffunction name="getCSVersion" access="public" returntype="numeric">
	<cfscript>
		var csVersion = "5.1.0";
		if ( StructKeyExists(server.ADF,"csVersion") )
			csVersion = server.ADF.csVersion;
	 	return csVersion;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ron West
Name:
	$deserializeXML
Summary:
	Converts XML into CF struct
Returns:
	Struct rtnData
Arguments:
	String XMLString
History:
 	2011-03-20 - RLW - Created
--->
<cffunction name="deserializeXML" access="public" returnType="struct" hint="Converts XML into CF Struct">
	<cfargument name="XMLString" type="string" required="true" hint="XML String to be deserialized into CF">
	<cfscript>
		var rtnData = structNew();
		if( isXML(arguments.XMLString) )
			rtnData = server.CommonSpot.MapFactory.deserialize(arguments.XMLString);
	</cfscript>
	<cfreturn rtnData>
</cffunction>

</cfcomponent>
