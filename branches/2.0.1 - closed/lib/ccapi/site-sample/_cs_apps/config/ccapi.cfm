<cfprocessingdirective suppresswhitespace="Yes">
<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->
<!--- // Add XML data to this file between the CFOUTPUT tags to prevent browser reading --->
<cfxml variable="configXML">
<cfoutput>
<?xml version="1.0" encoding="utf-8"?>
<settings>
	<logging>
		<enabled>1</enabled>
	</logging>
	<elements>
		<UniqueElementName>
			<pageID>1000</pageID>
			<subsiteID>1</subsiteID>
			<elementType>custom</elementType>
			<controlName>Unnamed</controlName>
		</UniqueElementName>
	</elements>
	<wsVars>
		<webserviceURL>#request.site.url#commonspot/webservice/cs_remote.cfc?wsdl</webserviceURL>
		<csuserid>webmaster</csuserid>
		<cspassword>password</cspassword>
		<site>#request.site.name#</site>
		<siteURL>#request.site.url#</siteURL>
		<subsiteID>1</subsiteID>
		<cssites>#request.cp.sitesDatasource#</cssites>
	</wsVars>
</settings>
</cfoutput>
</cfxml>
</cfprocessingdirective>