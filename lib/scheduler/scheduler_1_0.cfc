<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	scheduler_1_0.cfc
Summary:
	Scheduler base for the ADF
Version:
	1.0
History:
	2010-11-30 - RAK - Created
	2011-09-17 - GAC - Added checks to each method to verify that the application.schedule variable exists
	2011-09-26 - GAC - Updated application.schedule to be application.ADFscheduler 
	2011-09-27 - GAC - Added the UTILS and SCRIPTS LIBs as a dependencies and converted all application.ADF references to the local 'variables.'. 
	2012-11-29 - GAC - Added the DATA lib as a dependency 
--->
<cfcomponent displayname="scheduler_1_0" extends="ADF.core.Base" hint="Scheduler base for the ADF">
	
<cfproperty name="version" value="1_0_1">
<cfproperty name="type" value="singleton">
<cfproperty name="scripts" injectedBean="scripts_1_1" type="dependency">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_1">
<cfproperty name="wikiTitle" value="Scheduler_1_0">

<cfscript>
	// Verify the application.ADFscheduler structure exists
	if ( !StructKeyExists(application,"ADFscheduler") )
		application.ADFscheduler = StructNew();
</cfscript>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$getSchedulerVars
Summary:
	Returns the schedule data structure that is stored in the application.ADFscheduler variable
Returns:
	struct
Arguments:
	NA
History:
	2011-09-26 - GAC - Created
--->
<cffunction name="getSchedulerVars" access="public" returntype="struct" hint="Returns the schedule data that is stored in the application.ADFscheduler variable">
	<cfscript>
		// Verify the schedule structure exists
		if ( !StructKeyExists(application,"ADFscheduler") )
			application.ADFscheduler = StructNew();
		return application.ADFscheduler;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$scheduleProcess
Summary:
	The main process for scheduling a bunch of commands to be processed. When a process is scheduled it begins immediately.
Returns:
	void
Arguments:
	String - scheduleName
	Array - commands
		Commands can be a string value for an HTML URL or structure.
		Structure format used to access an ADF bean object.
			commands.bean - Name of the ADF object factory bean.
			commands.method - Name of the method in the bean to run.
			commands.arg - Structure for the arguments to the method.
	Struct - scheduleParams
History:
	2010-10-30 - RAK - Created
	2011-09-16 - MFC - Added param to delay running the scheduled task immediately.
						Default is set to TRUE.
	2011-09-17 - GAC - Added a check to verify that application.schedule variable exists
	2011-09-26 - GAC - Updated application.schedule to be application.ADFscheduler 
--->
<cffunction name="scheduleProcess" access="public" returntype="void" hint="The main process for scheduling a bunch of commands to be processed. When a process is scheduled it begins immediately.">
	<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
	<cfargument name="commands" type="array" required="true" hint="Array of URL's to execute each step of your schedule">
	<cfargument name="scheduleParams" type="struct" required="false" default="#StructNew()#" hint="optional settings as to the schedule timings">
	<cfargument name="startProcessNow" type="boolean" required="false" default="true" hint="If true the process will run its first step automatically.">
	
	<cfscript>
		var defaultScheduleParams = StructNew();//Default Values
		defaultScheduleParams.delay = 5; //minutes till next schedule item
		defaultScheduleParams.tasksPerBatch = 1; //how many tasks to do per iteration
		defaultScheduleParams.scheduleStart = 1; //Where in the command list to start processing
		defaultScheduleParams.scheduleStop = ArrayLen(commands); //When to stop processing (say stop at position 11)
		//Override defaults with passed in values
		if( !StructIsEmpty(arguments.scheduleParams) )
		{
			for(key in arguments.scheduleParams){
				if(StructKeyExists(defaultScheduleParams,key))
				{
					defaultScheduleParams[key] = arguments.scheduleParams[key];
				}
				else
				{
					//Invalid parameters passed in... throw error in the future?
				}
			}
		}
		
		// Verify the schedule structure exists
		if( !StructKeyExists(application,"ADFscheduler") )
			application.ADFscheduler = StructNew();	
		
		//Verify the schedule exists, if it does wipe it out
		if( !StructKeyExists(application.ADFscheduler,arguments.scheduleName) )
		{
			StructInsert(application.ADFscheduler,arguments.scheduleName,StructNew() );
		}
		else
		{
			application.ADFscheduler[arguments.scheduleName] = StructNew();
		}
		
		//Set schedule
		application.ADFscheduler[arguments.scheduleName].commands = arguments.commands;
		application.ADFscheduler[arguments.scheduleName].scheduleParams = defaultScheduleParams;
		application.ADFscheduler[arguments.scheduleName].status = "active";
		application.ADFscheduler[arguments.scheduleName].scheduleProgress = defaultScheduleParams.scheduleStart;
		
		// Check if want to start the procecing now or set the schedule
		if ( arguments.startProcessNow ) 
		{
			//BEGIN!
			processNextScheduleItem(arguments.scheduleName);
		}
		else 
		{
			setSchedule(arguments.scheduleName);
		}
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$processNextScheduleItem
Summary:	
	Executes the next item in the schedule. If there are no more it marks the schedule as ran.
Returns:
	boolean
Arguments:
	String - scheduleName
History:
	Nov 30, 2010 - RAK - Created
	2011-01-13 - GAC - Modified - Updated to add the date string and the site name to the schedule task output log file
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-09-17 - GAC - Added a check to verify that application.schedule variable exists
	2011-09-26 - GAC - Updated application.schedule to be application.ADFscheduler 
	2011-09-27 - GAC - Added a call to delete the CF Scheduled Task after process is marked as 'complete'
					   Converted application.ADF references to the local 'variables.'. 
--->
<cffunction name="processNextScheduleItem" access="public" returntype="boolean" hint="Executes the next item in the schedule. If there are no more it marks the schedule as ran.">
	<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
	<cfscript>
		var cfcatchDump = '';
		var currentSchedule = "";
		var errorScheduleItem = "";
		var scheduleURL = "";
		var currentCommand = "";
		var siteName = request.site.name;
		var logFilePrefix = dateFormat(now(), "yyyymmdd") & "." & siteName & ".";
		var schedLogFileName = logFilePrefix & "scheduledStatus-" & arguments.scheduleName & ".html";
		
		// Verify the schedule structure exists
		if ( !StructKeyExists(application,"ADFscheduler") )
			application.ADFscheduler = StructNew();
	</cfscript>
	
	<cfif StructKeyExists(application.ADFscheduler,arguments.scheduleName)>
		<cfset currentSchedule = application.ADFscheduler[arguments.scheduleName]>
		<!---
			If the schedule is active, there are further things to do. And we have not hit the stop point yet.
			Continue with the schedule
		---->
		<cfif ArrayLen(currentSchedule.commands) gte currentSchedule.scheduleProgress 
				and currentSchedule.scheduleProgress lte currentSchedule.scheduleParams.scheduleStop
				and currentSchedule.status eq "active">
			<cfscript>
				//Log the scheduled process start
				variables.utils.logAppend("Scheduled process started '#arguments.scheduleName#' Progress: #currentSchedule.scheduleProgress#/#ArrayLen(currentSchedule.commands)#","scheduledProcess-#arguments.scheduleName#.txt");
			</cfscript>

<!---				Execute the next scheduled item. AKA execute the next cfhttp or bean call--->
			<cftry>
				<cfset currentCommand = currentSchedule.commands[currentSchedule.scheduleProgress]>
				<cfif isSimpleValue(currentCommand)>
					<cfhttp url="#currentCommand#" throwOnError="yes">
				<cfelse>
<!---						This is a command structure! Execute the struct--->
					<cfscript>
						if(isStruct(currentCommand)
								and StructKeyExists(currentCommand,"bean")
								and StructKeyExists(currentCommand,"method"))
						{
							if(!StructKeyExists(currentCommand,"args"))
							{
								currentCommand.args = "";
							}
							variables.utils.runCommand(currentCommand.bean,currentCommand.method,currentCommand.args);
						}
						else
						{
                   			errorScheduleItem = variables.utils.doDump(currentCommand,"Failed Schedule Item","false",true);
							variables.utils.logAppend("Scheduled process error '#arguments.scheduleName#'. Schedule item missing struct key 'bean' or 'method' while processing Schedule Item:<br/> '#errorScheduleItem#'<br/><br/>","scheduledProcess-#arguments.scheduleName#.html");
                   		}
					</cfscript>
				</cfif>

			<cfcatch>
<!---				There was an issue! Do as much as we can to log the error. Set the status of the schedule to failure and break out--->
				<cfsavecontent variable="cfcatchDump">
					<cfdump var="#cfcatch#" expand="false">
				</cfsavecontent>
				<cfscript>
					errorScheduleItem = variables.utils.doDump(currentSchedule.commands[currentSchedule.scheduleProgress],"Failed Schedule Item","false",true);
					variables.utils.logAppend("Scheduled process error '#arguments.scheduleName#' while processing Schedule Item:<br/> '#errorScheduleItem#'<br/><br/>","scheduledProcess-#arguments.scheduleName#.html");
					application.ADFscheduler[arguments.scheduleName].status = "failure";
					variables.utils.logAppend("#cfcatchDump#","scheduledProcessFailure-#arguments.scheduleName#.html");
					return false;
				</cfscript>
			</cfcatch>
			</cftry>

			<cfscript>
				//Horray! The scheduled process finished. Log it, increment the progress.
				variables.utils.logAppend("Scheduled process complete. '#arguments.scheduleName#' Progress: #currentSchedule.scheduleProgress#/#ArrayLen(currentSchedule.commands)#","scheduledProcess-#arguments.scheduleName#.txt");
				currentSchedule.scheduleProgress = currentSchedule.scheduleProgress + 1;
				if(currentSchedule.scheduleProgress gt ArrayLen(currentSchedule.commands)){
					variables.utils.logAppend("Scheduled complete '#arguments.scheduleName#'","scheduledProcess-#arguments.scheduleName#.txt");
					currentSchedule.status = "complete";
					// Delete CF Scheduled Task to Clean up when the Process has completed
					variables.utils.deleteScheduledTask(taskName=arguments.scheduleName);
					variables.utils.logAppend("CF Scheduled Task '#arguments.scheduleName#' has been removed!","scheduledProcess-#arguments.scheduleName#.txt");
					return true;
				}
				//If this is a batch process do batchyness.
				if( currentSchedule.scheduleParams.tasksPerBatch gt 1 and
					currentSchedule.scheduleProgress mod currentSchedule.scheduleParams.tasksPerBatch - 1 neq 0 ) 
				{
					processNextScheduleItem(arguments.scheduleName);
				}
				else
				{
					scheduleURL = "http://#cgi.server_name#:#cgi.server_port##application.ADF.ajaxProxy#?bean=scheduler_1_0&method=processNextScheduleItem&scheduleName=#arguments.scheduleName#";
					//Schedule the next task
					variables.utils.setScheduledTask(scheduleURL,arguments.scheduleName,schedLogFileName,currentSchedule.scheduleParams.delay); //"ScheduledTaskError-#arguments.scheduleName#.html"
				}
			</cfscript>
		<cfelse>
<!---				The schedule is complete! Make it so... --->
			<cfscript>
				if(currentSchedule.scheduleProgress gt currentSchedule.scheduleParams.scheduleStop)
				{
					variables.utils.logAppend("Scheduled complete '#arguments.scheduleName#' stopping at position: #currentSchedule.scheduleProgress-1#/#ArrayLen(currentSchedule.commands)#","scheduledProcess-#arguments.scheduleName#.txt");
					currentSchedule.status = "complete";
					
					return true;
				}
			</cfscript>
		</cfif>
	</cfif>
	<cfreturn false>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$getScheduleStatus
Summary:
	Returns a structure representative of the current status of a given schedule.
Returns:
	struct
Arguments:
	String - scheduleName
History:
	2010-11-30 - RAK - Created
	2011-09-17 - GAC - Added a check to verify that application.schedule variable exists
	2011-09-26 - GAC - Updated application.schedule to be application.ADFscheduler 
--->
<cffunction name="getScheduleStatus" access="public" returntype="struct" hint="Returns a structure representative of the current status of a given schedule.">
	<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
	<cfscript>
		var rtnStruct = StructNew();
		var currentSchedule = StructNew();
		//Set Defaults
		rtnStruct.currentTask = -1;
		rtnStruct.totalTasks = -1;
		rtnStruct.status = "nonexistant";
		
		// Verify the scheduler structure exists
		if( !StructKeyExists(application,"ADFscheduler") )
			application.ADFscheduler = StructNew();

		//if there is an existing schedule get its current status information and return it!
		if ( StructKeyExists(application.ADFscheduler,arguments.scheduleName) )
		{
			currentSchedule = application.ADFscheduler[arguments.scheduleName];
			rtnStruct.currentTask = currentSchedule.scheduleProgress-1;
			rtnStruct.totalTasks = ArrayLen(currentSchedule.commands);
			rtnStruct.status = currentSchedule.status;
			rtnStruct.scheduleParams = currentSchedule.scheduleParams;
		}
		return rtnStruct;
	</cfscript>
</cffunction>	

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$pauseSchedule
Summary:
	Pauses passed in schedule name.
Returns:
	boolean
Arguments:
	String - ScheduleName
History:
	2010-11-30 - RAK - Created
	2011-09-17 - GAC - Added a check to verify that application.schedule variable exists
	2011-09-26 - GAC - Updated application.schedule to be application.ADFscheduler 
--->
<cffunction name="pauseSchedule" access="public" returntype="boolean" hint="Pauses passed in schedule name.">
	<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
	<cfscript>
		// Verify the schedule structure exists
		if ( !StructKeyExists(application,"ADFscheduler") )
			application.ADFscheduler = StructNew();
		
		if ( StructKeyExists(application.ADFscheduler,arguments.scheduleName) and
			application.ADFscheduler[arguments.scheduleName].status == "active" ) 
		{
			application.ADFscheduler[arguments.scheduleName].status = "paused";
			return true;
		}
	</cfscript>
	<cfreturn false>
</cffunction>	

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$resumeSchedule
Summary:
	Resumes a previously paused schedule.
Returns:
	boolean
Arguments:
	String - ScheduleName
History:
	2010-11-30 - RAK - Created
	2011-09-17 - GAC - Added a check to verify that application.schedule variable exists
	2011-09-26 - GAC - Updated application.schedule to be application.ADFscheduler 
--->
<cffunction name="resumeSchedule" access="public" returntype="boolean" hint="Resumes a previously paused schedule.">
	<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
	<cfscript>
		// Verify the schedule structure exists
		if ( !StructKeyExists(application,"ADFscheduler") )
			application.ADFscheduler = StructNew();
		
		//If the schedule exists, is paused and has remaining arguments resume it.
		if ( StructKeyExists(application.ADFscheduler,arguments.scheduleName) and
			application.ADFscheduler[arguments.scheduleName].status == "paused" and
			ArrayLen(application.ADFscheduler[arguments.scheduleName].commands) GTE application.ADFscheduler[arguments.scheduleName].scheduleProgress ) 
		{
			application.ADFscheduler[arguments.scheduleName].status = "active";
			processNextScheduleItem(arguments.scheduleName);
			return true;
		}
	</cfscript>
	<cfreturn false>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$getScheduleHTML
Summary:
	Returns the management HTML for the specified schedule name.
Returns:
	string
Arguments:
	String - ScheduleName
History:
	2010-11-30 - RAK - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-09-17 - GAC - Added a check to verify that application.schedule variable exists
	2011-09-26 - GAC - Updated application.schedule to be application.ADFscheduler 
	2011-09-27 - GAC - Converted application.ADF references to the local 'variables.'. 
--->
<cffunction name="getScheduleHTML" access="public" returntype="string" hint="Returns the management HTML for the specified schedule name.">
	<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
	<cfscript>
		var currentSchedule = '';
		var scheduleID = '';
		var rtnHTML = '';
		
		// Verify the schedule structure exists
		if ( !StructKeyExists(application,"ADFscheduler") )
			application.ADFscheduler = StructNew();
	</cfscript> 
	<cfsavecontent variable="rtnHTML">
		<cfoutput>
			<cfif !StructKeyExists(application.ADFscheduler,arguments.scheduleName)>
				Schedule does not exist.
			<cfelse>
				<cfset currentSchedule = application.ADFscheduler[arguments.scheduleName]>
				<cfset scheduleID = "schedule"&Replace(scheduleName," ","","all")>
				#variables.scripts.loadJQuery()#
				#variables.scripts.loadJQueryUI()#
				<script type="text/javascript">
					jQuery(function (){
						jQuery("###scheduleID# .progressBar").progressbar({ value: #currentSchedule.scheduleProgress/ArrayLen(currentSchedule.commands)*100# });
						updateSchedule('#scheduleID#');
					});
					
					function updateSchedule(scheduleID){
						jQuery.getJSON(
							"#application.ADF.ajaxProxy#",
							{
								bean: "scheduler_1_0",
								method: "getScheduleStatus",
								scheduleName: "#arguments.scheduleName#",
								returnFormat: "json"
							},
							function (data){
								currentTaskOffset = data.CURRENTTASK - (data.SCHEDULEPARAMS.SCHEDULESTART-1);
								totalTasks = (data.SCHEDULEPARAMS.SCHEDULESTOP+1)-(data.SCHEDULEPARAMS.SCHEDULESTART-1)-1;
								progress = (currentTaskOffset)/(totalTasks)*100;
								jQuery("##"+scheduleID+" .progressBar").progressbar({ value: progress });
								jQuery("##"+scheduleID+" .scheduleStatus").html("Status: "+data.STATUS+" <br>Completion: "+currentTaskOffset+"/"+totalTasks);
								if(data.STATUS == "active"){
									//Refresh every 10 seconds.
									setTimeout("updateSchedule('"+scheduleID+"')",10*1000);
									jQuery("##"+scheduleID+" .changeScheduleStatus .pause").show();
									jQuery("##"+scheduleID+" .changeScheduleStatus .resume").hide();
									jQuery("##"+scheduleID+" .progressBar").progressbar({ disabled: false });
								}else if(data.STATUS == "paused"){
									jQuery("##"+scheduleID+" .changeScheduleStatus .pause").hide();
									jQuery("##"+scheduleID+" .changeScheduleStatus .resume").show();
									jQuery("##"+scheduleID+" .progressBar").progressbar({ disabled: true });
								}else if(data.STATUS == "complete"){
									jQuery("##"+scheduleID+" .changeScheduleStatus .pause").hide();
									jQuery("##"+scheduleID+" .changeScheduleStatus .resume").hide();
									jQuery("##"+scheduleID+" .progressBar").progressbar({ disabled: false });
								}else if(data.STATUS == "failure"){
									jQuery("##"+scheduleID+" .changeScheduleStatus .pause").hide();
									jQuery("##"+scheduleID+" .changeScheduleStatus .resume").hide();
									jQuery("##"+scheduleID+" .progressBar").progressbar({ disabled: true });
								}
							}
						);
					}
					function pauseSchedule(scheduleName,scheduleID){
						jQuery.get(
							"#application.ADF.ajaxProxy#",
							{
								bean: "scheduler_1_0",
								method: "pauseSchedule",
								scheduleName: "#arguments.scheduleName#"
							}
						);
						updateSchedule(scheduleID);
						jQuery("##"+scheduleID+" .changeScheduleStatus .resume").show();
						jQuery("##"+scheduleID+" .changeScheduleStatus .pause").hide();
					}
					function resumeSchedule(scheduleName,scheduleID){
						jQuery.get(
							"#application.ADF.ajaxProxy#",
							{
								bean: "scheduler_1_0",
								method: "resumeSchedule",
								scheduleName: "#arguments.scheduleName#"
							}
						);
						jQuery("##"+scheduleID+" .changeScheduleStatus .pause").show();
						jQuery("##"+scheduleID+" .changeScheduleStatus .resume").hide();
						//The resume may take a second to take effect. Update the schedule in one second.
						setTimeout("updateSchedule('"+scheduleID+"')",1000);
					}
				</script>
				<div id="#scheduleID#">
					<div class="progressBar"></div>
					<div class="scheduleStatus">#currentSchedule.status#</div>
					<div class="changeScheduleStatus">
						<div class="pause" style="display:none"><a href="javascript:pauseSchedule('#arguments.scheduleName#','#scheduleID#')">Pause</a></div>
						<div class="resume" style="display:none"><a href="javascript:resumeSchedule('#arguments.scheduleName#','#scheduleID#')">Resume</a></div>
					</div>
				</div>
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfreturn rtnHTML>
</cffunction>

<!---
/* *************************************************************** */
Posted By: Rahul Narula  | 8/29/06 2:20 PM  
	http://forta.com/blog/index.cfm/2006/8/28/GetScheduledTasks-Function-Returns-Scheduled-Task-List#c5B2902E2-3048-80A9-EF04942A953D2ED7
Name:
	$getScheduledTasks
Summary:
	Obtains an Array of CF scheduled tasks 
Returns:
	Array
Arguments:
	String - taskNameFilter
History:
	2010-12-21 - GAC - Added
	2010-12-21 - GAC - Added task name filter
	2012-11-29 - GAC - Updated to handle getting the CFSCHEDULED tasks list from RAILO
--->
<cffunction name="getScheduledTasks" returntype="array" output="no" access="public" hint="Obtain an Array of CF scheduled tasks ">
	<cfargument name="taskNameFilter" type="string" required="false" default="" hint="Used to only display Scheduled Task Names that contain this filter value">	
	<cfscript>
		var result = ArrayNew(1);
		var newResultA = ArrayNew(1);
		var newResultB = ArrayNew(1);
		var taskService = "";
		var taskQuery = QueryNew("temp");
		var i = 1;
		var taskName = "";
		var cfmlEngineType = server.coldfusion.productname;
		var a = 1;
		var keyVal = "";
		var logError = false;
		var schedArgs = StructNew();
	</cfscript>
	<!--- // Check what CFML engine were are in and then get a list of CF SCHEDULED TASKS --->
	<cfif FindNoCase(cfmlEngineType,'ColdFusion Server')>
		<!--- // if in Adobe Coldfusion get the Scheduled via this JAVA object --->
		<cfset taskService = createobject('java','coldfusion.server.ServiceFactory').getCronService()>
		<!--- // Get Array of Structs of the current Scheduled tasks on the server from the task service --->
		<cfset result = taskservice.listall()>
	<cfelseif FindNoCase(cfmlEngineType,'Railo')>
		<!--- // Use an attributeCollection for the cfscheduele tag so Adobe ColdFusion will not throw an error on the non-ACF attribute --->
		<cfset schedArgs.action = "list">
		<cfset schedArgs.returnvariable = "taskQuery">
		<cfschedule attributeCollection="#schedArgs#">
				
		<cfif taskQuery.RecordCount>
			<cfscript>
				// Convert the Scheduled task query from Railo to a Array of Struts
				result = variables.DATA.queryToArrayOfStructures(queryData=taskQuery,keysToLowercase=true);
				// Now convert Railo specific keys names to ACF compatible key names
				for ( a=1; a LTE ArrayLen(result); a=a+1 ) {
					for (key in result[a]) {
						keyVal = result[a][key]; 
						if ( key EQ "startdate" )
							newResultA[a]["start_date"] = keyVal; 
						else if ( key EQ "starttime" )
							newResultA[a]["start_time"] = keyVal;
						if ( key EQ "enddate" )
							newResultA[a]["end_date"] = keyVal; 
						else if ( key EQ "endtime" )
							newResultA[a]["end_time"] = keyVal;
						else if ( key EQ "port" )
							newResultA[a]["http_port"] = keyVal;
						else if ( key EQ "proxyport" )
							newResultA[a]["http_proxy_port"] = keyVal;
						else if ( key EQ "timeout" )
							newResultA[a]["request_time_out"] = keyVal;
						else
							newResultA[a][key] = keyVal; 
					}
				}
				result = newResultA;
			</cfscript>
		</cfif>
	</cfif>
	<!--- // If we have results filter the list --->
	<cfscript>
		if ( ArrayLen(result) ){
			// If filter value is passed in loop over the Array of task and build a new array
			if ( LEN(TRIM(arguments.taskNameFilter)) ) { 
				for ( i; itm LTE ArrayLen(result); i=i+1 ) {
					taskName = result[i].task;
					// Only Add Tasks to the Result Array if they contain the filter value
					if ( FindNoCase(arguments.taskNameFilter,taskName,1) NEQ 0 ) {
						arrayAppend(newResultB,result[i]);
					}
				}
				result = newResultB;
			}
		}
		return result;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$setSchedule
Summary:
	Sets the schedule task.
Returns:
	Boolean
Arguments:
	string scheduleName
History:
	2011-08-29 - MFC - Created
	2011-09-17 - GAC - Added a check to verify that application.schedule variable exists
	2011-09-26 - GAC - Updated application.schedule to be application.ADFscheduler 
	2011-09-27 - GAC - Converted application.ADF references to the local 'variables.'. 
--->
<cffunction name="setSchedule" access="private" returntype="boolean" output="true" hint="Sets the scheduled task">
	<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
	<cfscript>
		var scheduleURL = "http://#cgi.server_name#:#cgi.server_port##application.ADF.ajaxProxy#?bean=scheduler_1_0&method=processNextScheduleItem&scheduleName=#arguments.scheduleName#";
		var logFilePrefix = dateFormat(now(), "yyyymmdd") & "." & request.site.name & ".";
		var schedLogFileName = logFilePrefix & "scheduledStatus-" & arguments.scheduleName & ".html";
		var currentSchedule = "";
	
		// Verify the schedule structure exists
		if ( !StructKeyExists(application,"ADFscheduler") )
			application.ADFscheduler = StructNew();

		try 
		{	
			// Check if the schedule exists
			if ( StructKeyExists(application.ADFscheduler,arguments.scheduleName) )
			{
				currentSchedule = application.ADFscheduler[arguments.scheduleName];
			}
			
			// Schedule the task within CF
			variables.utils.setScheduledTask(scheduleURL,arguments.scheduleName,schedLogFileName,currentSchedule.scheduleParams.delay); //"ScheduledTaskError-#arguments.scheduleName#.html"
			
			return true;
		}
		catch ( Any e )
		{
			//variables.utils.dodump(e,"e", true);
			return false;
		}
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Greg Cronkright
Name:
	$deleteSchedulerVar
Summary:
	Deletes a specific schedule struct key in the scheduler Application variable
Returns:
	Boolean
Arguments:
	String scheduleName - Key of the Scheduler Struct Application Variable 
History:
	2011-09-27 - GAC - Created
--->
<cffunction name="deleteSchedulerVar" returntype="boolean" output="no" access="public" hint="Deletes a specific schedule struct key in the scheduler Application variable">
	<cfargument name="scheduleName" type="string" required="true" hint="Name of the Schedule variable to be deleted">
	<cfscript>
		// Verify the schedule structure exists
		if ( !StructKeyExists(application,"ADFscheduler") )
			application.ADFscheduler = StructNew();
		try 
		{
    		StructDelete(application.ADFscheduler, arguments.scheduleName, false);
    		return true;
		}
		catch(Any e) 
		{
    		return false;
		}
	</cfscript>
</cffunction>

</cfcomponent>