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
	same-records-cache-rebuild-job.cfm
Summary:
	This modules rebuilds memory cache according to the following URL parmeters. It should be scheduled to be run a a background job
	every minute or two.
	
	URL Parameters:
	
		Action
			RebuildJustBeforeExpiration (DEFAULT) - If the underlying custom element has been modified since the cache was 
					built, the cache will be rebuild just before it is about to expire.
			RebuildImmediately - If the underlying custom element has been modified since the cache was 
					built, the cache will be rebuild immediately. 
				defaults to RebuildOnExpiration
			
		rebuildMinutesBeforeExpire  
			The number of minutes before expire to trigger rebuild, 
				defaults to 1
				
		rebuildTimeout 
			Timeout in seconds when making HTTP call to rebuild cache; 
				defaults to 30 
Version:
	1.0
History:
	2013-12-09 - TP - Created
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
		<title>Same Records Cache</title>
		<style>
			Body { font-family: verdana; font-size:9pt; }
			h2 {clear:both; padding-top:20px; }
			.element { font-weight:bold; clear: both; padding-bottom: 5px; }
			.indent { padding-left: 25px; clear: both; }
			.elementname { width:250px; float: left; display:inline-block; }
			.exp, .created, .rebuildtime, .sectorebuild, .lastuse { width:95px; float: left; display:inline-block; }
			.time, .status, .hitcount, .actions { width:80px; float: left; display:inline-block; }
			.header { background-color:##eeeeee; font-weight:bold; clear: both; height: 14pt; border-top: 1px solid ##cccccc; }
			.row { clear: both; border-bottom: 1px solid ##cccccc; }
		</style>
	</head>
	<body>
	<h1>Same Records Cache</h1>
	</cfoutput>
	
	<cfscript>
		if( NOT StructKeyExists(request,'params') )
			request.params = StructNew();
			
		if( NOT StructKeyExists(request.params,'action') )
			request.params.action = 'RebuildJustBeforeExpiration';	
		if( NOT StructKeyExists(request.params,'rebuildMinutesBeforeExpire') )
			request.params.rebuildMinutesBeforeExpire = 1;	// 1 minute		
		if( NOT StructKeyExists(request.params,'rebuildTimeout') )
			request.params.rebuildTimeout = 30;					// 30 seconds
			
		WriteOutput('<br>Rebuild Minutes Before Expire: #request.params.rebuildMinutesBeforeExpire#');	
		WriteOutput('<br>Rebuild Timeout: #request.params.rebuildTimeout#');	

		
		LogIt( "Param Cache Rebuild Job ran. Parameters: RebuildMinutesBeforeExpire:[#request.params.rebuildMinutesBeforeExpire#] RebuildTimeout:[#request.params.rebuildTimeout#] " );
	</cfscript>		
	
	<cfif StructKeyExists( application,"CS_SameRecordsCache" )>
	
		<!--- Get list of element types cached --->
		<cfscript>
			types = StructKeyList(application.CS_SameRecordsCache);
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
			

				WriteOutput('<div class="header">');
					WriteOutput('<div class="time">Time</div>'); 
					WriteOutput('<div class="elementname">Element Name</div>');
					WriteOutput('<div class="exp">Created</div>');
					WriteOutput('<div class="lastuse">Last Use</div>');
					WriteOutput('<div class="rebuildtime">Rebuild Time</div>'); 
					WriteOutput('<div class="exp">Expires</div>'); 
					WriteOutput('<div class="sectorebuild">Secs</div>'); 
					WriteOutput('<div class="hitcount">Hit Count</div>');
					WriteOutput('<div class="status">Status</div>');					
					WriteOutput('<div class="actions">Actions</div>');
				WriteOutput('</div>');
			
				// get list of element names
				elements = StructKeyList(application.CS_SameRecordsCache[type]);
			
			</cfscript>
	
			<!---// Loop over Element Instances //---->			
			<cfloop index="i" from="1" to="#ListLen(elements)#" step="1">
		
				<cfscript>
					elementName = ListGetAt(elements,i);
				</cfscript>	
				
				<cfflush>
					
				<cfscript>
					expires = application.CS_SameRecordsCache[type][elementName].expires;
					rebuildTime = DateAdd('n', -request.params.rebuildMinutesBeforeExpire, expires);
					secBeforeRebuild = DateDiff( 's', now(), rebuildTime );
					hitCount = application.CS_SameRecordsCache[type][elementName].hitCount;
					created = application.CS_SameRecordsCache[type][elementName].created;
					lastuse = application.CS_SameRecordsCache[type][elementName].lastuse;
					pageurl = application.CS_SameRecordsCache[type][elementName].pageurl;

					if( DateCompare( elementLastUpdated, created ) eq 1 )
						status = 'Stale';
					else 
						status = 'Valid';
					
					if( DateCompare( now(), expires ) eq 1 )
						status = 'EXPIRED';
					else if( secBeforeRebuild lt 0 )
						status = 'REBUILDING';	 

					if( Find( "?", pageurl ) eq 0 )					
					{
						relativeurl = pageurl & "?forceRender=1";
						fullurl = CGI.http_host & pageurl & "?forceRender=1";
					}	
					else	
					{
						relativeurl = pageurl & "&forceRender=1";
						fullurl = CGI.http_host & pageurl & "&forceRender=1";
					}	
					
				
					WriteOutput('<div class="row">');
					WriteOutput('<div class="time">#TimeFormat(now(),"HH:mm:ss")#</div>'); 
					WriteOutput('<div class="elementname">#ElementName#</div>');
					WriteOutput('<div class="created">#dtf(created)#</div>'); 
					WriteOutput('<div class="lastuse" title="#pageurl#">#dtf(lastuse)#</div>');
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
							application.CS_SameRecordsCache[type][elementName].expires = DateAdd( 'n', application.CS_SameRecordsCache[type][elementName].minutesToCache, now() );
							WriteOutput('<div class="indent">Element not updated. Extending cache to #dtf(application.CS_SameRecordsCache[type][elementName].expires)#</div>');
							LogIt( "Element Type not updated since #dtf(elementLastUpdated)#.  Extending cache for '#elementName#' to #dtf(application.CS_SameRecordsCache[type][elementName].expires)#" );
						}
					
						else 
						{
							// The element was updated since the cache was built. Invoke the page to rebuild.
							status = requestPage( fullurl, request.params.rebuildTimeout );
							WriteOutput('<div class="indent">Rebuilt <a href="#fullurl#" target="x">#fullURL#</a> #status#</div>');
							LogIt( "Rebuilt about to expire [#dtf(expires)#] #status#" );
						}
					}
					
					// cache is expired
					else if( DateCompare( now(), expires ) eq 1 )		
					{
						if( DateCompare( elementLastUpdated, created ) neq 1 )
						{
							// element has NOT been updated since cache was created. Cache is still good. Extend the expiration date.
							application.CS_SameRecordsCache[type][elementName].expires = DateAdd( 'n', application.CS_SameRecordsCache[type][elementName].minutesToCache, now() );
							WriteOutput('<div class="indent">Element not updated. Extending cache to #dtf(application.CS_SameRecordsCache[type][elementName].expires)#</div>');
							LogIt( "Element Type not updated since #dtf(elementLastUpdated)#.  Extending cache for '#elementName#' to #dtf(application.CS_SameRecordsCache[type][elementName].expires)#" );
						}
						
						// Rebuild - for some reason we did not get to it
						// only try rebuilding if expired with the limit specified in reverse
						else if( DateCompare( now(), DateAdd( 'n', request.params.rebuildMinutesBeforeExpire, expires) ) eq -1 )
						{
							// invoke page
							status = requestPage( fullurl, request.params.rebuildTimeout );
							WriteOutput('<div class="indent">Rebuilt expired <a href="#fullurl#" target="x">#fullURL#</a> #status#</div>');
							LogIt( "Rebuilt expired [#dtf(expires)#] #status#" );
						}
					}
					
					else 
					{
						// if Element has been updated since cache was created and Action = RebuildImmediately
						if( request.params.action eq 'RebuildImmediately' AND DateCompare( elementLastUpdated, created ) eq 1 )
						{
							// invoke page
							status = requestPage( fullurl, request.params.rebuildTimeout );
							WriteOutput('<div class="indent">Element Type changed on #dtf(elementLastUpdated)#.  Rebuilt cache <a href="#fullurl#" target="x">#fullURL#</a> #status#</div>');
							LogIt( "Element Type changed on #dtf(elementLastUpdated)#.  Rebuilt cache. #status#" );
						}
					}
					
					WriteOutput('</div>');
				</cfscript>

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
			var start = 0;
			var end = '';
			var tc = 0;
			
			sleep(3000);	// sleep for 3 seconds before building to ensure we don't flood the system if may items neeed to be rebuilt
			
			start = GetTickCount();
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
		if( NOT StructKeyExists( application,'CS_SameRecordsCacheElementNames' ) )
			application.CS_SameRecordsCacheElementNames = StructNew();
		if( StructKeyExists( application.CS_SameRecordsCacheElementNames, elType ) )
			retID = application.CS_SameRecordsCacheElementNames[elType].elementTypeID;
		else
		{
			application.CS_SameRecordsCacheElementNames[elType] = StructNew();
			application.CS_SameRecordsCacheElementNames[elType].elementTypeID = 0;
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
				application.CS_SameRecordsCacheElementNames[elType].elementTypeID = qry.ID;
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
		Logs the passed comment into a same-records log
--------------------------------------->
<cffunction name="logIt" access="private" output="No">
	<cfargument name="comment" required="yes" type="string">
	
	<cfscript>
		var filename = expandPath( "/commonspot/logs" ) & "/" & DateFormat( now(), "yyyymmdd" ) & "-same-records-cache.log";
	</cfscript>

	<cffile action="APPEND" file="#filename#" output="#TimeFormat(now(),'HH:mm:ss')# #arguments.comment#" addnewline="Yes"> 
</cffunction>