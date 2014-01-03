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
	param-cache.cfm
Summary:
	This modules handles caching of paged results for a pageIndex or custom element
	
	Requires the following custom script parameters:
		ElementType - For example 'PageIndex' or 'custom:Profile'
		ElementName - The unique name of the element
		MinutesToCache - The default number of minutes to cache the content for.
		ShowClearLink - If set to 1 will display a link to clear the cache in author/edit/approve mode
		Debug - If set to 1 will show debug info in read mode 
		Params - comma deliminated list of url or form params to cache, if none cache will be built on all params
		MaxItemsToCache - the maximun number of items to cache for this element
		Exp1..Exp10
			- List of two items. First item is an expression (i.e. year=2014), second is the Minutes to Cache if params contains that expression
		
	URL or Post Parameters:
		clearmemcache - clear all memory caches for this element
		ForceRender - causes element to render and then cache.
		
	This module will store the data in a structure in application space named application.CS_PageParamCache.  The name of first level 
	key will be made from #request.page.id#_#request.element.id#, then a secondary level key will be a string with the param field
	names & values.

Version:
	1.0
History:
	2013-12-09 - TP - Created
--->

<cfscript>
	// this element should always be dynamic	
	request.element.isStatic = 0;
	
	// calc base name (Pageid + ControlID)
	basename = "#request.page.id#_#request.element.id#";	

	// Check if any missing attributes
	missingAttr = getMissingAttributes();
</cfscript>

<cfif missingAttr neq ''>
	<cfoutput><br><strong>Page Param Cache</strong><br>Error: Missing custom script parameters: #Replace( missingAttr, ",", ", ", "ALL")#</cfoutput>
	<cfexit>
</cfif>
		
<cfscript>
	// copy params
	if( StructKeyExists( attributes, 'params' ) )
		paramsList = Trim(attributes.params);
	else
		paramsList = '';	

	// Create Memory Structures if they don't exist
	CreateMemStructures(attributes.elementType, basename);
	
	// build ordered param string which will be key to memory cache
	paramStr = BuildOrderParams(paramsList);

	// default forceRender to 0 if not specified		
	if( NOT StructKeyExists(request.params,"ForceRender") )
		request.params.ForceRender = 0;

	// Get Minutes to Cache		
	minToCache = CheckExpressions(paramStr);	
		

	// Handle request to clear the memory, if 'ClearMemCache' is specified in URL params
	if( StructKeyExists(request.params,'ClearMemCache') AND StructKeyExists(application.CS_PageParamCache[attributes.ElementType],basename) )
	{
		StructDelete(application.CS_PageParamCache[attributes.ElementType],basename);
		application.CS_PageParamCache[attributes.ElementType][basename] = StructNew();
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
				<strong>Page Param Cache:</strong> [<a href="#cgi.script_name#?ClearMemCache=#basename#" title="Clicking this link will clear the memory cache for this element.">Clear Memory Cache</a>]
				&nbsp; Cache Duration: [#minToCache# minutes] &nbsp; Count: [#StructCount(application.CS_PageParamCache[attributes.ElementType][basename])#] MaxItems: [#attributes.MaxItemsToCache#]
				<!--- List: [#StructKeyList(application.CS_PageParamCache[attributes.ElementType][basename])#] --->
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
	<div>
		<span title="This Custom Script element takes parameters to control the child element and its caching parameters.">Page Param Cache:</span> <span style="color:Red">DEBUG Parameter is ON</span>
		<br>[<a href="#cgi.script_name#?ClearMemCache=#basename#" title="Clicking this link will clear the memory cache used to cache the results pages of the embedded '#attributes.ElementType#' element.">Clear Memory Cache</a>]
		&nbsp; Cache Duration: [#minToCache# minutes] Count: [#StructCount(application.CS_PageParamCache[attributes.ElementType][basename])#]  MaxItems: [#attributes.MaxItemsToCache#]
	</div>
	</cfoutput>
</cfif>

<cfif StructKeyExists(application.CS_PageParamCache[attributes.ElementType][basename],paramStr)>

	<cfif DateCompare( now(), application.CS_PageParamCache[attributes.ElementType][basename][paramStr].expires) eq -1 
				AND application.CS_PageParamCache[attributes.ElementType][basename][paramStr].data neq ''
				AND Request.Params.ForceRender neq 1>
			
			<cfif attributes.debug eq 1>
				<cfoutput><br>---Rendered from cache. Expires in #DateDiff( 's', now(), application.CS_PageParamCache[attributes.ElementType][basename][paramStr].expires)# second at #application.CS_PageParamCache[attributes.ElementType][basename][paramStr].expires# ----</cfoutput>
			</cfif>
			
			<!--- Output what is in the cache --->
			<cfoutput>#application.CS_PageParamCache[attributes.ElementType][basename][paramStr].data#</cfoutput>
			
			<!--- increment hit count & last use --->
			<cfscript>
				application.CS_PageParamCache[attributes.ElementType][basename][paramStr].hitCount = application.CS_PageParamCache[attributes.ElementType][basename][paramStr].hitCount + 1;
				application.CS_PageParamCache[attributes.ElementType][basename][paramStr].lastuse = now();
			</cfscript>	
			
			<!--- Stop further Processing --->
			<cfexit>
	</cfif>
</cfif>

<cfif attributes.debug eq 1>
	<cfoutput><br>==== RENDERED ELEMENT ===<br></cfoutput>
</cfif>

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
		// Make sure we don't cache more than the max specified. If attributes.MaxItemsToCache = 0, then unlimited
		// If the item already exist in mem cache allow.
		alreadyExists = StructKeyExists( application.CS_PageParamCache[attributes.ElementType][basename],'#paramStr#' );
		curItemCount = ListLen( StructKeyList(application.CS_PageParamCache[attributes.ElementType][basename]) );

		if( alreadyExists OR attributes.MaxItemsToCache eq 0 OR curItemCount LT attributes.MaxItemsToCache )
		{
			application.CS_PageParamCache[attributes.ElementType][basename][paramStr] = StructNew();
			application.CS_PageParamCache[attributes.ElementType][basename][paramStr].expires = DateAdd( "n", minToCache, now() );
			application.CS_PageParamCache[attributes.ElementType][basename][paramStr].data = theOutput;
			application.CS_PageParamCache[attributes.ElementType][basename][paramStr].hitCount = 0;
			application.CS_PageParamCache[attributes.ElementType][basename][paramStr].created = now();
			application.CS_PageParamCache[attributes.ElementType][basename][paramStr].lastuse = now();			
			application.CS_PageParamCache[attributes.ElementType][basename][paramStr].minutesToCache = minToCache;
		}
	}
</cfscript>

<!--- Debug: Dump the Memory Cache Structure --->
<cfif attributes.debug eq 1 AND StructCount(application.CS_PageParamCache[attributes.ElementType][basename]) gt 0>
	<cfdump var="#application.CS_PageParamCache[attributes.ElementType][basename]#" expand="No" label="application.CS_PageParamCache[#attributes.ElementType#][#basename#]">
</cfif>


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
		if( NOT StructKeyExists(attributes,"MaxItemsToCache") )
			attributes.MaxItemsToCache = 200;
	</cfscript>
	<cfreturn missingAttr>
</cffunction>

<!----------------------------------
	CreateMemStructures	
------------------------------------>
<cffunction name="CreateMemStructures" access="private" output="No">
	<cfargument name="elementType" required="Yes" type="string">
	<cfargument name="basename" required="Yes" type="string">
	
	<cfscript>
		// Create the base memory structure if it does not exist.
		if( NOT StructKeyExists(application,"CS_PageParamCache") )
			application.CS_PageParamCache = StructNew();
			
		if( NOT StructKeyExists(application.CS_PageParamCache, arguments.elementType) )
			application.CS_PageParamCache[arguments.elementType] = StructNew();
			
		if( NOT StructKeyExists(application.CS_PageParamCache[arguments.elementType], arguments.basename) )
			application.CS_PageParamCache[arguments.elementType][arguments.basename] = StructNew();
	</cfscript>
</cffunction>

<!----------------------------------
	BuildOrderParams()	
------------------------------------>
<cffunction name="BuildOrderParams" access="private" output="Yes" returntype="string">
	<cfargument name="includeList" type="string" required="No" default="">
	
	<cfscript>
		var i = 1;
		var item = '';
		var paramStr = '';
		var paramKeyList = StructKeyList(request.params);	
		var excludeList = 'noparams,clearmemcache,forcerender,cs_pgisinlview,cs_forcereadmode,renderelements,renderforprint,rendercontrolidlist,fieldnames,comments,RENDERCONTROLIDLIST,RENDERELEMENTS';
	
		if( ListLen(paramKeyList) )
		{
			paramKeyList = LCase( paramKeyList );
			paramKeyList = ListSort( paramKeyList, "textnocase" );
		
			for( i=1; i lte ListLen( paramKeyList ); i = i + 1 )
			{
				item = Trim(ListGetAt(paramKeyList,i));
				if( arguments.includeList neq '' )
				{
					if( ListFindNoCase( includeList, item) )
						paramStr = paramStr & "&" & item & "=" & Trim(request.params[item]);
				}
				else if( NOT ListFindNoCase(excludeList, item) )
					paramStr = paramStr & "&" & item & "=" & Trim(request.params[item]);
			}
		}
		if( paramStr eq '' )
			paramStr = '&noparams=1';		
	</cfscript>
	
	<cfreturn paramStr>
</cffunction>



<cffunction name="CheckExpressions" access="Private" output="Yes" returntype="numeric">
	<cfargument name="paramStr" type="string" required="Yes">
	
	<cfscript>
		var i = 1;
		var MinToCache = attributes.MinutesToCache;
		var expression = '';
		var found = 0;
		
		for( i=1; i lte 10; i = i + 1 )
		{
			if( NOT StructKeyExists( attributes,'Exp#i#' ) )
				break;
				
			expression = ListFirst( attributes['Exp#i#'] );	
			found = FindNoCase( expression, arguments.paramStr );			
			
			if( attributes.Debug eq 1 )
				WriteOutput( '<br>Checking Expression #i#: exp:#expression# params:#arguments.paramStr# found:#found#' );

			if( found )
			{
				MinToCache = ListLast( attributes['Exp#i#'] );	
				break;
			} 
		}
	</cfscript>
	
	<cfreturn MinToCache>
</cffunction>