<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
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
		
	Optional parameters:		
		CacheName - Optional, the name of the cache. Defauls to ElementName if not passed
		MinutesToCache - the number of minutes to cache the content for - defaults to 10.
		ShowClearLink - If set to 1 will display a link to clear the cache in author/edit/approve mode - defaults to 0
		Debug - If set to 1 will show debug info in read mode - defaults to 0		
		RenderHandler - The path to the render handle to invoke when cache exists and is current. Recommended that this is passed, 
								otherwise the elemnt needed to be loaded to get the render handler path.
		ClassNames - One or more class names to apply to the surrounding div						
		
	URL or Post Parameters:
		clearmemcache - clear all memory caches for this element
		ForceRender - causes element to render and then cache.
		ClearType - causes cache clear of all instances for this element type
		ClearALL - causes cache clear of all instances		
		
	The render handler for the custom element that is being called MUST include code like the following:
		<cfscript>
			request.element.isStatic = 0;		// the element need to be dynamic			
		   if( StructKeyExists(request,"CS_SameRecordsInfo") )
		   {
		   	request.CS_SameRecordsInfo.ElementInfo = attributes.ElementInfo;
		      request.CS_SameRecordsInfo.renderhandler = '{renderhandler path}';	// i.e. /rendrhandlers/profile.cfm
				request.CS_SameRecordsInfo.ClassNames = '{class names}';
		   }
		</cfscript>		
	
		
Version:
	1.0.1
History:
	2013-12-09 - JTP - Created
	2014-02-18 - JTP - Added ClearType and ClearAll url parameters
	2014-03-05 - JTP - Var declarations
	2014-03-19 - JTP - Added optional renderhandler & classNames attributes as an optimization.
	2015-09-10 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
--->

<cfscript>
	stc = GetTickCount();
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

		
	// Clear memory cache for this type of element is specified		
	if( StructKeyExists(request.params,"ClearType") AND request.params.ClearType eq 1 )		
	{
		if( StructKeyExists( application.CS_SameRecordsCache, attributes.ElementType ) )
			StructDelete( application.CS_SameRecordsCache, attributes.ElementType );
	}	
	// Clear memory cache for All types if specified		
	if( StructKeyExists(request.params,"ClearAll") AND request.params.ClearAll eq 1 ) 		
	{
		if( StructKeyExists( application, 'CS_SameRecordsCache' ) )
			StructDelete( application, 'CS_SameRecordsCache' );
	}	
</cfscript>

<!--- if not in read mode, display link to clear the mem cache & render element normally --->
<cfif request.renderstate.RenderMode neq 'Read'>
		<!--- Render extra break so element icon does not hide --->
		<cfoutput><br></cfoutput>
		
		<!--- Display Cache Info --->
		<cfif attributes.ShowClearLink eq 1>
			<cfoutput>
			<div style="font-size: 12px; padding-left: 25px; background-color: ##FFFFC0; border: 1px solid ##c0c0c0; padding: 5px; margin: 10px;">
				<strong>Custom Element Records Cache:</strong> 
				CacheName:#attributes.cacheName# 
				[<a href="#cgi.script_name#?ClearType=1" title="Clicking this link will clear the memory cache for this type of element.">Clear Type</a>]
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

<cfif StructKeyExists(application.CS_SameRecordsCache, attributes.ElementType) AND StructKeyExists(application.CS_SameRecordsCache[attributes.ElementType],attributes.cacheName)>

	<cfif attributes.debug eq 1>
		<cfoutput><br>Expires: #application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].expires#</cfoutput>
	</cfif>

	<!---// Check if the structure exists for the element. If not create it and set the render handler to teh passed in render handler //--->	
	<cfscript>
		if( NOT StructKeyExists( application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName], '#pageIDControlID#' ) )
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID] = StructNew();

		if( NOT StructKeyExists( application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID], 'renderhandler' ) )	
		{
			if( StructKeyExists( attributes, 'renderHandler' ) )
				application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID].renderhandler = attributes.renderhandler;
			else	
				application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID].renderhandler = '';
				
			if( StructKeyExists( attributes, 'classNames' ) )				
				application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID].classNames = attributes.classNames;
			else	
				application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID].classNames = '';
		}	
	</cfscript>

	<!---// check if it is OK to render from cache //--->
	<cfif application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID].renderHandler neq '' 
				AND DateCompare( now(), application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].expires) eq -1 
				AND isStruct(application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].elementInfo) 
				AND Request.Params.ForceRender neq 1>
			
			<cfif attributes.debug eq 1>
				<cfoutput><br><strong>Rendered from cache.</strong> Expires in #DateDiff( 's', now(), application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].expires)# seconds at #application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].expires# 
				<br><strong>Render Handler:</strong> #application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID].renderhandler#
				<br><strong>ClassNames:</strong> #application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID].classNames#</cfoutput>
				<cfset xtc = GetTickcount()>
			</cfif>

			<!--- render div to simulate the div that the element would have rendered, as we are bypassing calling the real element --->
			<cfscript>
				classNames = 'zz ';
				if( structKeyExists( application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][PageIDControlID], 'ClassNames' ) )
				{
					classNames = application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][PageIDControlID].classNames;
					if( Len(classNames) ) 
						application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].ElementInfo.ClassNames = classNames;
				}	
			</cfscript>
			<cfoutput><div <cfif classNames neq ''>class='#classNames#'</cfif>></cfoutput>			
			
			<!--- Call render handler and pass it the cached data --->
			<cfmodule template="#application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][PageIDControlID].renderhandler#"
						elementInfo = "#application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].elementInfo#">
						
			<cfoutput></div></cfoutput>						
			
			<cfif attributes.debug eq 1>
				<cfoutput><br>#GetTickcount() - xtc#ms to render element from cached data.</cfoutput>
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
		pushed_CS_SameRecordsInfo = copyStruct(request.CS_SameRecordsInfo);
		pushed = 1;
	}	
	request.CS_SameRecordsInfo = StructNew();
	request.CS_SameRecordsInfo.elementInfo = '';
	if( StructKeyExists( attributes,'renderhandler' ) )
		request.CS_SameRecordsInfo.renderhandler = attributes.renderhandler;
	else	
		request.CS_SameRecordsInfo.renderhandler = '';
	request.CS_SameRecordsInfo.ClassNames = '';

	tc = GetTickcount();
</cfscript>

<!--- 
	Invoke the element.  It will set the following variables:
		request.CS_SameRecordsInfo.elementInfo 
		request.CS_SameRecordsInfo.RenderHandler
		request.CS_SameRecordsInfo.ClassNames
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
	ClassNames:#request.CS_SameRecordsInfo.ClassNames# &nbsp;
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
			if( NOT StructKeyExists( application.CS_SameRecordsCache, attributes.ElementType ) )
				application.CS_SameRecordsCache[attributes.ElementType] = StructNew();
			if( NOT StructKeyExists( application.CS_SameRecordsCache[attributes.ElementType], attributes.cacheName ) )
				application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName] = StructNew();
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName].elementInfo = copyStruct(request.CS_SameRecordsInfo.elementInfo);
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID] = StructNew();
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID].renderhandler = request.CS_SameRecordsInfo.renderHandler;
			application.CS_SameRecordsCache[attributes.ElementType][attributes.cacheName][pageIDControlID].classNames = request.CS_SameRecordsInfo.classNames;
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
		request.CS_SameRecordsInfo = Server.CommonSpot.UDF.util.duplicateBean(pushed_CS_SameRecordsInfo);
</cfscript>


<!------ // FUNCTIONS // ------------------------------->


<!----------------------------------
	getMissingAttributes() - returns a string of missing attributes
------------------------------------>
<cffunction name="getMissingAttributes" access="private" output="No" returntype="string">
	<cfscript>
		var missingAttr = '';
		
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
		if( NOT StructKeyExists(Application,"CS_SameRecordsCache") )
			application.CS_SameRecordsCache = StructNew();
			
		if( NOT StructKeyExists(Application.CS_SameRecordsCache, arguments.elementType) )
			application.CS_SameRecordsCache[arguments.elementType] = StructNew();
	</cfscript>
</cffunction>

<!----------------------------------
	copyStruct	
History:
	2015-09-10 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
------------------------------------>
<cffunction name="copyStruct" access="private" output="no" returntype="struct">
	<cfargument name="srcStruct" type="struct" required="Yes">
	
	<cfscript>
		var retStruct = StructNew();
		var key = '';
		
		retStruct = server.commonspot.udf.util.duplicateBean(arguments.srcStruct);
//		for( key in arguments.srcStruct )
//			retStruct[key] = arguments.srcStruct[key];
	</cfscript>
	
	<cfreturn retStruct>
</cffunction> 