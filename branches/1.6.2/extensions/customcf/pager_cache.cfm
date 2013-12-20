<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2013.
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
	pager-cache.cfm
Summary:
	This modules handles caching of paged results for a pageIndex or custom element
	
	Requires the following custom element parameters:
		ElementType - for example 'PageIndex' 
		ElementName - the unique name of the element
		URLParam - the name of the URL parameter that defines the current page
		MinutesToCache - the number of miutes to cache the content for.
		
	This module will store the data in a structure in application space named application.ADF.cache.pagerCache.  The name of the key
	to the cache will be made from cgi.script_name and the url specified parameter
History:
	2012-07-28 - TP - Created
--->
<cfscript>
	missingAttr = "";
	if( NOT StructKeyExists(attributes,"ElementType") )
		missingAttr = ListAppend(missingAttr,"ElementType");
	if( NOT StructKeyExists(attributes,"ElementName") )
		missingAttr = ListAppend(missingAttr,"ElementName");
	if( NOT StructKeyExists(attributes,"URLParam") )
		missingAttr = ListAppend(missingAttr,"URLParam");	
	if( NOT StructKeyExists(attributes,"MinutesToCache") )
		missingAttr = ListAppend(missingAttr,"MinutesToCache");					
</cfscript>
<cfif missingAttr neq ''>
	<cfoutput>You must specify the following Custom Element parameters: #Replace( missingAttr, ",", ", ", "ALL")#</cfoutput>
	<cfset request.element.isStatic = 0>
	<cfexit>
</cfif>

<!--- <cfoutput>RenderMode: #request.renderstate.RenderMode#</cfoutput> --->
<cfif request.renderstate.RenderMode neq 'Read'>
		<cfoutput><br></cfoutput> <!--- add extra space so element icons don't overlap --->
		<CFMODULE TEMPLATE="/commonspot/utilities/ct-render-named-element.cfm"
				ElementName="#attributes.ElementName#" ElementType="#attributes.ElementType#">
	<cfexit>
</cfif>

<cfscript>
	// Assume Page if not defined
	if( NOT StructKeyExists(url,"#attributes.URLParam#") )
		url[attributes.URLParam] = 1;
</cfscript>

<cfscript>
	name = Replace( cgi.script_name, "\", "_", "ALL" );
	name = Replace( name, "/", "_", "ALL" );
	name = "#name#_#url[attributes.UrlParam]#";
	bMakeCache = 1;
	bExit = 0;
	
	if( NOT StructKeyExists(application.ADF.cache,"pagerCache") )
		application.ADF.cache.pagerCache = StructNew();
</cfscript>


<cfif StructKeyExists(application.ADF.cache.pagerCache,name)>
	<cfif DateCompare( now(), application.ADF.cache.pagerCache[name].expires) lt 0 AND application.ADF.cache.pagerCache[name].data neq ''>
			<!--- <cfoutput><br>---Rendered from cache [#application.ADF.cache.pagerCache[name].expires#]----</cfoutput> --->
			<cfoutput>#application.ADF.cache.pagerCache[name].data#</cfoutput>
			<cfexit>
	</cfif>
</cfif>

<!--- <cfoutput><br>==== RENDER ELEMENT ===<br></cfoutput> --->
<cfsavecontent variable="theOutput">
	<cftry>
		<CFMODULE TEMPLATE="/commonspot/utilities/ct-render-named-element.cfm"
				ElementName="#attributes.ElementName#" ElementType="#attributes.ElementType#">
		<cfcatch>
			<cfset bMakeCache = 0>
			<cfrethrow>
			<cfexit>
		</cfcatch>
	</cftry>
</cfsavecontent>			
<cfoutput>#theOutput#</cfoutput>

<cfscript>
	if( bMakeCache )
	{
		application.ADF.cache.pagerCache[name] = StructNew();
		application.ADF.cache.pagerCache[name].expires = DateAdd( "n", attributes.MinutesToCache, now() );
		application.ADF.cache.pagerCache[name].data = theOutput;
	}
</cfscript>
