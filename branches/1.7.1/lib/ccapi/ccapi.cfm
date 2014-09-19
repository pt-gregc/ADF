<cfprocessingdirective suppresswhitespace="Yes">
<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
		<UniqueCEConfigName>
			<pageID>1000</pageID>
			<subsiteID>1</subsiteID>
			<elementType>custom</elementType>
			<controlName>Unnamed</controlName>
		</UniqueCEConfigName>
		<UnqiueGlobalCEConfigName> 
			<elementType>custom</elementType>
			<gceConduitConfig>
				<timeout>60</timeout> <!-- // optional -->
				<customElementName>Another GCE Name</customElementName>
			</gceConduitConfig>
		</UnqiueGlobalCEConfigName>
	</elements>
	<!-- // Global Custom Element Conduit Page Pool -->
	<gceConduitPagePool>
		<globalTimeout>30</globalTimeout><!-- // seconds -->
		<requestWaitTime>200</requestWaitTime><!-- // milliseconds -->
		<logging>1</logging>
		<conduitPages>
			<page1>
				<pageid>1000</pageid>
				<csuserid>ccapiUser1</csuserid>
				<cspassword>password</cspassword>
			</page1>
			<page2>
				<pageid>1001</pageid>
				<csuserid>ccapiUser2</csuserid>
				<cspassword>password</cspassword>
			</page2>
		</conduitPages>
	</gceConduitPagePool>
	<wsVars>
		<webserviceURL>#request.site.url#commonspot/webservice/cs_service.cfc?wsdl</webserviceURL>
		<!-- // For CS 7.0.1+, 8.0.1+ and 9+ use the cs_remote.cfc -  uncomment webserviceURL below and delete the one above  -->
		<!-- <webserviceURL>#request.site.url#commonspot/webservice/cs_remote.cfc?wsdl</webserviceURL> -->
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