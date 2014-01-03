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
	same-records-cache.cfm
Summary:
	This modules handles caching of custom elements where the custom element render handler expects the same records returned all the time. 
	
	Requires the following custom script parameters:
		ElementType - for example 'PageIndex' 
		ElementName - the unique name of the element
		CacheName - Optional, the name of the cache. Defauls to ElementName if not passed
		MinutesToCache - the number of minutes to cache the content for.
		ShowClearLink - If set to 1 will display a link to clear the cache in author/edit/approve mode
		Debug - If set to 1 will show debug info in read mode 
		
	URL or Post Parameters:
		clearmemcache - clear all memory caches for this element
		ForceRender - causes element to render and then cache.
Version:
	1.0
History:
	2013-12-09 - TP - Created
--->

<cfscript>
	// this element should always be dynamic	
	request.element.isStatic = 0;
	
	// Check if any missing attributes
	missingAttr = getMissingAttributes();
	
	pageIDControlID = '#request.page.id#_#request.element.id#';
</cfscript>

<cfif missingAttr neq ''>
	<cfoutput><br><strong>Same Records Cache</strong><br>Error: Missing custom script parameters: #Replace( missingAttr, ",", ", ", "ALL")#</cfoutput>
	<cfexit>
</cfif>
		
<cfscript>
	// Create Memory Structures if they don't exist
	CreateMemStructures(attributes.elementType);

	// default cacheName to element Name if not specified	
	if( NOT StructKeyExists(attributes,'CacheName') )
		attributes.cacheName = attributes.elementName;	

	// default forceRender to 0 if not specified		
	if( NOT StructKeyExists(request.params,"ForceRender") )
		request.params.ForceRender = 0;
</cfscript>

<!--- if not in read mode, display link to clear the mem cache & render element normally --->
<cfif request.renderstate.RenderMode neq 'Read'>
		<!--- Render extra break so element icon does not hide --->
		<cfoutput><br></cfoutput>
		
		<!--- Display Cache Info --->
		<cfif attributes.ShowClearLink eq 1>
			<cfoutput>
			<div style="font-size: 12px; padding-left: 25px; background-color: ##FFFFC0; border: 1px solid ##c0c0c0; padding: 5px; margin: 10px;">
				<strong>Same Records Cache:</strong> CacheName:#attributes.cacheName# [<a href="#cgi.script_name#?ForceRender=1" title="Clicking this link will rebuild the memory cache for this element.">Rebuild Memory Cache</a>]
				&nbsp; Cache Duration: [#attributes.MinutesToCache# minutes] 
			</div>
			</cfoutput> 
		</cfif>
		
		<!--- invoke the element ---->
		<CFMODULE TEMPLATE="/commonspot/utilities/ct-render-named-element.cfm"
				ElementName="#attributes.ElementName#" ElementType="#attributes.ElementType#">
	<cfexit>
</cfif>


<!--- READ Mode Handling --------------->
<cfscript>
	bMakeCache = 1;
</cfscript>

<cfif attributes.debug eq 1>
	<cfoutput>
			<div style="font-size: 12px; padding-left: 25px; background-color: ##FFFFC0; border: 1px solid ##c0c0c0; padding: 5px; margin: 10px;">
				<strong>Same Records Cache:</strong> CacheName:#attributes.cacheName# [<a href="#cgi.script_name#?ForceRender=1" title="Clicking this link will rebuild the memory cache for this element.">Rebuild Memory Cache</a>]
				&nbsp; Cache Duration: [#attributes.MinutesToCache# minutes] 
			</div>
	</cfoutput>
</cfif>

<cfif StructKeyExists(application.CS_SameRecordsCache[attributes.ElementType],attributes.cacheName)>

	<cfif attributes.debug eq 1>
		<cfoutput><br>Expires: #application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].expires#</cfoutput>
	</cfif>

	<cfif StructKeyExists( application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName], '#pageIDControlID#' )
				AND DateCompare( now(), application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].expires) eq -1 
				AND isStruct(application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].elementInfo) 
				AND Request.Params.ForceRender neq 1>
			
			<cfif attributes.debug eq 1>
				<cfoutput><br><strong>Rendered from cache.</strong> Expires in #DateDiff( 's', now(), application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].expires)# seconds at #application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].expires# 
				<br><strong>Render Handler:</strong> #application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID].renderhandler#</cfoutput>
				<cfset tc = GetTickcount()>
			</cfif>

			<!--- render div to simulate the div that the element would have rendered, as we are bypassing calling the real element --->
			<cfoutput><div></cfoutput>			
			
			<!--- Call render handler and pass it the cached data --->
			<cfmodule template="#application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][PageIDControlID].renderhandler#"
						elementInfo = "#application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].elementInfo#">
						
			<cfoutput></div></cfoutput>						
			
			<cfif attributes.debug eq 1>
				<cfoutput><br>#GetTickcount() - tc#ms to render element from cached data.</cfoutput>
			</cfif>
					
			
			<!--- increment hit count & last use --->
			<cfscript>
				application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].hitCount = application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].hitCount + 1;
				application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].lastuse = now();
			</cfscript>	
			
			<!--- Stop further Processing --->
			<cfexit>
	</cfif>
</cfif>

<cfif attributes.debug eq 1>
	<cfoutput><br>==== RENDERED ELEMENT ===<br></cfoutput>
</cfif>

<cfscript>
	pushed = 0;
	// check if nested invocations, if so clone
	if( StructKeyExists(request,"CS_SameRecordsInfo") )
	{
		pushed_CS_SameRecordsInfo = Duplicate(request.CS_SameRecordsInfo);
		pushed = 1;
	}	
	request.CS_SameRecordsInfo = StructNew();
	request.CS_SameRecordsInfo.elementInfo = '';
	request.CS_SameRecordsInfo.renderhandler = '';

	tc = GetTickcount();
</cfscript>

<!--- 
	Invoke the element.  It will set the following variables:
		request.CS_SameRecordsInfo.elementInfo 
		request.CS_SameRecordsInfo.RenderHandler
--->
<cftry>
	<CFMODULE TEMPLATE="/commonspot/utilities/ct-render-named-element.cfm"
			ElementName="#attributes.ElementName#" ElementType="#attributes.ElementType#">
	<cfcatch>
		<cfset bMakeCache = 0>
		<cfrethrow>
		<cfexit>
	</cfcatch>
</cftry>

<cfif attributes.debug eq 1>
	<cfoutput>
	<br>Element Execution Time: #GetTickcount() - tc# ms &nbsp;
	renderHandler:#request.CS_SameRecordsInfo.renderhandler# &nbsp;
	Items: 
	<cfif isStruct(request.CS_SameRecordsInfo.elementInfo) and structKeyExists(request.CS_SameRecordsInfo.elementInfo,"elementdata")>
		#arraylen(request.CS_SameRecordsInfo.elementInfo.elementdata.PropertyValues)#
	</cfif>
	</cfoutput>
</cfif>


<cfscript>
	if( isStruct(request.CS_SameRecordsInfo.elementInfo) AND request.CS_SameRecordsInfo.renderhandler neq '' )
	{
		if( FindNoCase( 'loader.cfm', cgi.script_name ) eq 0 )
		{
			if( NOT StructKeyExists( application.CS_SameRecordsCache[attributes.ElementType], attributes.cacheName ) )
				application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName] = StructNew();
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].elementInfo = Duplicate(request.CS_SameRecordsInfo.elementInfo);
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID] = StructNew();
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID].renderhandler = request.CS_SameRecordsInfo.renderHandler;
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].hitCount = 0;
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].created = now();
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].lastuse = now();			
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].minutesToCache = attributes.MinutesToCache;
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].expires = DateAdd( "n", attributes.MinutesToCache, now() );
					
			if( cgi.QUERY_STRING neq '' )				
			{
				tmp = ReplaceNoCase( cgi.QUERY_STRING, "ForceRender=", "f_r=", "ALL" );
				application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].pageurl = cgi.script_name & "?" & tmp;
			}	
			else
				application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].pageurl = cgi.script_name;
		}	
	}
</cfscript>

<cfscript>
	// pop the pushed back off the stack
	if( pushed )
		request.CS_SameRecordsInfo =  Duplicate(pushed_CS_SameRecordsInfo);
</cfscript>


<!------ // FUNCTIONS // ------------------------------->


<!----------------------------------
	getMissingAttributes() - returns a string of missing attributes
------------------------------------>
<cffunction name="getMissingAttributes" access="private" output="No" returntype="string">
	<cfscript>
		missingAttr = '';
		if( NOT StructKeyExists(attributes,"ElementType") )
			missingAttr = ListAppend(missingAttr,"ElementType");
		if( NOT StructKeyExists(attributes,"ElementName") )
			missingAttr = ListAppend(missingAttr,"ElementName");
		if( NOT StructKeyExists(attributes,"MinutesToCache") )
			missingAttr = ListAppend(missingAttr,"MinutesToCache");
	
		if( NOT StructKeyExists(attributes,"ShowClearLink") )
			attributes.ShowClearLink = 0;
		if( NOT StructKeyExists(attributes,"Debug") )
			attributes.Debug = 0;
	</cfscript>
	<cfreturn missingAttr>
</cffunction>

<!----------------------------------
	CreateMemStructures	
------------------------------------>
<cffunction name="CreateMemStructures" access="private" output="No">
	<cfargument name="elementType" required="Yes" type="string">
	
	<cfscript>
		// Create the base memory structure if it does not exist.
		if( NOT StructKeyExists(application,"CS_SameRecordsCache") )
			application.CS_SameRecordsCache = StructNew();
			
		if( NOT StructKeyExists(application.CS_SameRecordsCache, arguments.elementType) )
			application.CS_SameRecordsCache[arguments.elementType] = StructNew();
	</cfscript>
</cffunction>

