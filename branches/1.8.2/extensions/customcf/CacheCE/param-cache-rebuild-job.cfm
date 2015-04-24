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
	param-cache-rebuild-job.cfm
Summary:
	This modules rebuilds memory cache according to the following URL parmeters. It should be scheduled to be run a a background job
	every minute or two.
	
	URL Parameters:
	
		rebuildMinutesBeforeExpire  
			The number of minutes before expire to trigger rebuild, 
				defaults to 1
				
		Action
			The action to take if the cache is about to expire
				RebuildIfHit - Rebuild only if it has been hit since last rebuild
				RebuildAlways - Always rebuild the cache even if hit count is 0. Use with caution, as this may increase load on server.
				Delete - Always delete when expired
			default is RebuildIfHit
			
		MaxUnusedMinutes
			Anything that has not been hit within this duration is removed from Cache
				defaults to 480 minutes (8 hours), if 0 unused cache time will not be factored
			
		rebuildTimeout 
			Timeout in seconds when making HTTP call to rebuild cache; 
				defaults to 30 
Version:
	1.0
History:
	2013-12-09 - JTP - Created
	2014-03-05 - JTP - Var declarations
--->

<cfif NOT request.user.isContributor()>
	<cfoutput>Permission denied</cfoutput>
	<cfheader statuscode="503" statustext="Permission denied">
	<cfexit>
</cfif>

<cflock timeout="1" throwontimeout="Yes" name="ParamCacheSchedJob" type="EXCLUSIVE">

	<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	
	<html>
	<head>
		<title>Params Cache</title>
		<style>
			Body { font-family: verdana; font-size:9pt; }
			h2 {clear:both; padding-top:20px; }
			.element { font-weight:bold; clear: both; padding-bottom: 5px; }
			.indent { padding-left: 25px; clear: both; }
			.cachename { width:300px; float: left; display:inline-block; }
			.exp, .created, .rebuildtime, .sectorebuild, .lastuse { width:95px; float: left; display:inline-block; }
			.time, .status, .hitcount, .actions { width:80px; float: left; display:inline-block; }
			.header { background-color:##eeeeee; font-weight:bold; clear: both; height: 14pt; border-top: 1px solid ##cccccc; }
			.row { clear: both; border-bottom: 1px solid ##cccccc; }
		</style>
	</head>
	<body>
	<h1>Params Cache</h1>
	</cfoutput>
	
	<cfscript>
		if( NOT StructKeyExists(request,'params') )
			request.params = StructNew();
			
		if( NOT StructKeyExists(request.params,'Action') )
			request.params.action = 'RebuildIfHit';
		if( NOT StructKeyExists(request.params,'rebuildMinutesBeforeExpire') )
			request.params.rebuildMinutesBeforeExpire = 1;	// 1 minute		
		if( NOT StructKeyExists(request.params,'rebuildTimeout') )
			request.params.rebuildTimeout = 30;					// 30 seconds
		if( NOT StructKeyExists(request.params,'MaxUnusedMinutes') )
			request.params.MaxUnusedMinutes = 480;				// 8 hours
			
		WriteOutput('<p>Action: #request.params.action#');	
		WriteOutput('<br>Rebuild Minutes Before Expire: #request.params.rebuildMinutesBeforeExpire#');	
		WriteOutput('<br>Rebuild Timeout: #request.params.rebuildTimeout#');	
		WriteOutput('<br>Max Unused Minutes: #request.params.MaxUnusedMinutes#</p><hr>');	
		
		LogIt( "Param Cache Rebuild Job ran. Parameters: Action:[#request.params.action#] RebuildMinutesBeforeExpire:[#request.params.rebuildMinutesBeforeExpire#] RebuildTimeout:[#request.params.rebuildTimeout#] MaxUnusedMinutes:[#request.params.MaxUnusedMinutes#]" );
	</cfscript>		
	
	<cfif StructKeyExists( application,"CS_PageParamCache" )>
	
		<!--- Get list of element types cached --->
		<cfscript>
			types = StructKeyList(application.CS_PageParamCache);
		</cfscript>
			
		<!---// Loop over Element Types //---->	
		<cfloop index="t" from="1" to="#ListLen(types)#" step="1">
	
			<cfscript>
				type = ListGetAt(types,t);
	
				// If custom element, query to figure out when the last time the element was updated.  
				//  	If not updated after cache was written, cache is still good and can be extended
				// For non-custom elements make update date now to force cache rebuild if about to expire.
				elementLastUpdated = now();
				if( FindNoCase('custom:', type ) )
				{
					elementTypeID = getElementIDGivenName(type);			
					if( elementTypeID ) 
						elementLastUpdated = getElementTypeLastUpdate(elementTypeID);			
				}
					
				WriteOutput('<h2>#type# (Last Updated:#dtf(elementLastUpdated)#)</h2>');	
			
				// get list of element instances
				elements = StructKeyList(application.CS_PageParamCache[type]);
			</cfscript>
	
			<!---// Loop over Element Instances //---->			
			<cfloop index="i" from="1" to="#ListLen(elements)#" step="1">
		
				<cfscript>
					element = ListGetAt(elements,i);
					caches = StructKeyList(application.CS_PageParamCache[type][element]);
		
					PageID = ListFirst( element, "_" );
					ControlID = ListLast( element, "_" );
					page_url = getPageURL( PageID );
					
					WriteOutput('<div class="element">#Page_URL# #ControlID# [<a href="#page_url#?ClearMemCache=1" target="x">Clear All</a>]</div>');			
				</cfscript>	
				
				<cfflush>
		
				<cfif page_URL neq ''>
				
					<cfscript>
						WriteOutput('<div class="header">');
						WriteOutput('<div class="time">Time</div>'); 
						WriteOutput('<div class="cachename">Cache Name</div>');
						WriteOutput('<div class="exp">Created</div>');
						WriteOutput('<div class="lastuse">Last Use</div>');
						WriteOutput('<div class="rebuildtime">Rebuild Time</div>'); 
						WriteOutput('<div class="exp">Expires</div>'); 
						WriteOutput('<div class="sectorebuild">Secs</div>'); 
						WriteOutput('<div class="hitcount">Hit Count</div>');
						WriteOutput('<div class="status">Status</div>');					
						WriteOutput('<div class="actions">Actions</div>');
						WriteOutput('</div>');
					</cfscript>		
	
					<!---// Loop over Cached Parameters //---->			
					<cfloop index="j" from="1" to="#ListLen(caches)#" step="1">
						<cfscript>
							cache = ListGetAt( caches, j );
							if( StructKeyExists(application.CS_PageParamCache[type][element], cache) )
							{
								expires = application.CS_PageParamCache[type][element][cache].expires;
								rebuildTime = DateAdd('n', -request.params.rebuildMinutesBeforeExpire, expires);
								secBeforeRebuild = DateDiff( 's', now(), rebuildTime );
								hitCount = application.CS_PageParamCache[type][element][cache].hitCount;
								created = application.CS_PageParamCache[type][element][cache].created;
								lastuse = application.CS_PageParamCache[type][element][cache].lastuse;
		
								if( DateCompare( elementLastUpdated, created ) eq 1 )
									status = 'Stale';
								else 
									status = 'Valid';
								
								if( DateCompare( now(), expires ) eq 1 )
									status = 'EXPIRED';
								else if( secBeforeRebuild lt 0 AND 
											(request.params.action eq 'RebuildAlways' OR (request.params.action eq 'RebuildIfHit' AND hitCount gt 0) ) )
									status = 'REBUILDING';	 
								
								relativeurl = page_url & "?forceRender=1" & cache;
								fullurl = CGI.http_host & page_url & "?forceRender=1" & cache;
							
								WriteOutput('<div class="row">');
								WriteOutput('<div class="time">#TimeFormat(now(),"HH:mm:ss")#</div>'); 
								WriteOutput('<div class="cachename">#dispCacheName(cache)#</div>');
								WriteOutput('<div class="created">#dtf(created)#</div>'); 
								WriteOutput('<div class="lastuse">#dtf(lastuse)#</div>');
								WriteOutput('<div class="rebuildtime">#dtf(rebuildTime)#</div>'); 
								WriteOutput('<div class="exp">#dtf(expires)#</div>'); 
								WriteOutput('<div class="sectorebuild">#secBeforeRebuild#</div>'); 
								WriteOutput('<div class="hitcount">#hitCount#</div>');
								WriteOutput('<div class="status">#status#</div>');
								if( status eq 'REBUILDING' )	
									WriteOutput('<div class="actions">&nbsp;</div>');
								else
									WriteOutput('<div class="actions"><a href="#relativeurl#" target="x">Rebuild</a></div>');
								WriteOutput('</div>');
							}
						</cfscript>	
						
						<cfflush>
							
						<cfscript>	
							// cache is about to expire
							if( DateCompare( now(), rebuildTime ) eq 1 AND 
								 DateCompare( now(), expires ) eq -1 )
							{
								if( DateCompare( elementLastUpdated, created ) neq 1 )
								{
									// element has NOT been updated since cache was created. Cache is still good. Extend the expiration date.
									application.CS_PageParamCache[type][element][cache].expires = DateAdd( 'n', application.CS_PageParamCache[type][element][cache].minutesToCache, expires );
									WriteOutput('<div class="indent">Element not updated. Extending cache to #dtf(application.CS_PageParamCache[type][element][cache].expires)#</div>');
									LogIt( "Element Type not updated since #dtf(elementLastUpdated)#.  Extending cache '#cache#' to #dtf(application.CS_PageParamCache[type][element][cache].expires)#" );
								}
							
								else if( request.params.action eq 'RebuildAlways' OR (request.params.action eq 'RebuildIfHit' AND hitCount gt 0) )
								{
									// The element was updated since the cache was built. Invoke the page to rebuild.
									status = requestPage( fullurl, request.params.rebuildTimeout );
									WriteOutput('<div class="indent">Rebuilt <a href="#fullurl#" target="x">#fullURL#</a> #status#</div>');
								}
							}
							
							// cache is expired
							else if( DateCompare( now(), expires ) eq 1 )		
							{
								// Rebuild - for some reason we did not get to it
								if( request.params.action eq 'RebuildAlways' OR (request.params.action eq 'RebuildIfHit' AND hitCount gt 0) )
								{
									// only try rebuilding if expired with the limit specified in reverse
									if( DateCompare( now(), DateAdd( 'n', request.params.rebuildMinutesBeforeExpire, expires) ) eq -1 )
									{
										// invoke page
										status = requestPage( fullurl, request.params.rebuildTimeout );
										WriteOutput('<div class="indent">Rebuilt expired <a href="#fullurl#" target="x">#fullURL#</a> #status#</div>');
									}
								}
								
								// Delete						
								if( request.params.action eq 'Delete' OR (request.params.action eq 'RebuildIfHit' AND hitCount eq 0) )
								{
									WriteOutput('<div class="indent">Deleting expired non-hit cache #cache#</div>');
									StructDelete( application.CS_PageParamCache[type][element],cache );
									LogIt('Deleting expired non-hit cache #cache#');
								}
							}
							
							// if cache has not been used in the past N minutes (defaults to 240) kill the cache
							else if( request.params.MaxUnusedMinutes neq 0 AND DateCompare( lastuse, DateAdd( 'n', -1 * request.params.MaxUnusedMinutes, now() ) ) eq -1 )
							{
								WriteOutput('<div class="indent">Deleting unused #cache#. Last use: #dtf(lastuse)#</div>');
								StructDelete( application.CS_PageParamCache[type][element],cache );
								LogIt('Deleting unused #cache#. Last use: #dtf(lastuse)#');
							}
							
							WriteOutput('</div>');
						</cfscript>
						
					</cfloop>
				</cfif>
			</cfloop>	
		</cfloop>	
	</cfif> 
	
	<cfoutput>
	</body>
	</html>
	</cfoutput>

</cflock>

<!--------------------------- // FUNCTIONS // -------------------------------------------->


<!---------------------------
	getPageURL()
		returns the server relative URL to the spcified page
---------------------------->
<cffunction name="getPageURL" access="private" output="No" returntype="string">
	<cfargument name="PageID" type="numeric" required="yes">
	
	<cfscript>
		var ret_url = '';
		var qry = '';
	</cfscript>
	
	<cftry>
		<cfquery name="qry" datasource="#request.site.datasource#">
			select SitePages.Filename, Subsites.subsiteurl
				from SitePages, Subsites
			where SitePages.SubsiteID = Subsites.ID
					AND SitePages.ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.pageID#">
		</cfquery>
		
		<cfscript>
			if( qry.recordcount eq 1 )
				ret_url = qry.subsiteurl & qry.filename;
		</cfscript>
		
		<cfcatch>
			<cfscript>
				logIt("Error in GetPage() - #cfcatch.message# #cfcatch.detail#");
			</cfscript>
		</cfcatch>
	</cftry>
	
	<cfreturn ret_url>	
</cffunction>	


<!---------------------------
	requestPage()
		Requests the specified page with the specified URL parameters
---------------------------->
<cffunction name="requestPage" access="private" output="No" returntype="string" >
	<cfargument name="fullurl" type="string" required="yes">
	<cfargument name="timeout" type="string" required="yes">
	
	<cftry>
		<cfscript>
			var start = GetTickCount();
			var end = '';
			var tc = 0;
		</cfscript>
		
		<!--- request the URL --->
		<cfhttp url="#arguments.fullURL#" method="GET" timeout="#arguments.timeout#">
		
		<cfscript>
			end = GetTickcount();
			tc = end - start;
			logIt("Rebuilt #attributes.fullurl# [#cfhttp.statusCode#] [#tc# ms]");
		</cfscript>
		
		<cfcatch>
			<cfscript>
				logIt( "Error in requestPage() - #cfcatch.message# #cfcatch.detail#" );
			</cfscript>
		</cfcatch>
	</cftry>
	
	<cfreturn "#cfhttp.statusCode# #tc#ms">	
</cffunction>	


<!---------------------------
	dtf - DateTimeFormat()
		returns a string in the standard date/time format (yyyy-mm-dd HH:mm:ss)
---------------------------->
<cffunction name="dtf" access="private" output="No" returntype="string">
	<cfargument name="dt" required="Yes" type="date"> 
	
	<cfreturn DateFormat(arguments.dt,'yyyy-mm-dd') & " " & TimeFormat(arguments.dt,'HH:mm:ss')>
</cffunction>


<!---------------------------
	getElementIDGivenName()
		gets the elementType ID given the name
---------------------------->
<cffunction name="getElementIDGivenName" access="private" output="no" returntype="numeric">
	<cfargument name="name" type="string" required="yes">
	
	<cfscript>
		var elType = ReplaceNoCase(arguments.name, 'custom:', '' );
		var qry = '';
		var retID = 0;
		
		// Build memory cache structure so we don't have to run query on every run of background job
		if( NOT StructKeyExists( application,'CS_PageParamCacheElementNames' ) )
			application.CS_PageParamCacheElementNames = StructNew();
		if( StructKeyExists( application.CS_PageParamCacheElementNames, elType ) )
			retID = application.CS_PageParamCacheElementNames[elType].elementTypeID;
		else
		{
			application.CS_PageParamCacheElementNames[elType] = StructNew();
			application.CS_PageParamCacheElementNames[elType].elementTypeID = 0;
		}	
	</cfscript>

	<cfif retID eq 0>
		<!--- Run the query if not retreived from memory --->
		<cfquery name="qry" datasource="#request.site.datasource#">
			select ID 
				from AvailableControls 
			where 
				<cfif FindNoCase( 'custom:', arguments.name)> 
					ShortDesc = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#elType#">
				<cfelse>
					Name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.name#">
				</cfif> 
		</cfquery>	
		
		<cfscript>
			if( qry.recordcount eq 1 )
			{
				// set ID to return
				retID = qry.ID;

				// cache off so query is not needed next time
				application.CS_PageParamCacheElementNames[elType].elementTypeID = qry.ID;
			}
		</cfscript>
	</cfif>
	
	<cfreturn retID>
</cffunction>


<!-------------------------------------
	getElementTypeLastUpdate()  
		returns the Last Update date for the specified custom element
--------------------------------------->
<cffunction name="getElementTypeLastUpdate" access="private" output="no" returntype="date">
	<cfargument name="elementTypeID" type="numeric" required="Yes">
	
	<cfscript>
		var qry = '';
	</cfscript>

	<cfquery name="qry" datasource="#request.site.datasource#">
		select Max(DateApproved) As DateApproved
			from Data_FieldValue 
		where FormID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.elementTypeID#"> 
			AND VersionState = 2
	</cfquery>
	
	<cfreturn qry.dateApproved>
</cffunction>


<!-------------------------------------
	dispCacheName()  
		returns the cache name with spaces so it wraps when displayed.
--------------------------------------->
<cffunction name="dispCacheName" returntype="string" output="no">
	<cfargument name="cachename" required="yes" type="string">
	<cfreturn Replace( arguments.cachename, "&", " &", "All")>
</cffunction>


<!-------------------------------------
	logIt()  
		Logs the passed comment into a param-cache log
--------------------------------------->
<cffunction name="logIt" access="private" output="No">
	<cfargument name="comment" required="yes" type="string">
	
	<cfscript>
		var filename = expandPath( "/commonspot/logs" ) & "/" & DateFormat( now(), "yyyymmdd" ) & "-param-cache.log";
	</cfscript>

	<cffile action="APPEND" file="#filename#" output="#TimeFormat(now(),'HH:mm:ss')# #arguments.comment#" addnewline="Yes"> 
</cffunction>