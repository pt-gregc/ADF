<cfcomponent displayname="scheduler_1_0" extends="ADF.core.Base" hint="Scheduler base for ADF">
	<cfproperty name="version" value="1_0_0">
	<cfproperty name="type" value="singleton">
	<cfproperty name="wikiTitle" value="scheduler_1_0">
	<cfscript>
		if(!StructKeyExists(application,"schedule")){
			application.schedule = StructNew();
		}
	</cfscript>
	
	<cffunction name="scheduleProcess" access="public" returntype="void" hint="Scheduler">
		<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
		<cfargument name="commands" type="array" required="true" hint="Array of URL's to execute each step of your schedule">
		<cfargument name="scheduleParams" type="struct" required="false" default="#StructNew()#" hint="optional settings as to the schedule timings">
		<cfscript>
			var defaultScheduleParams = StructNew();//Default Values
			defaultScheduleParams.delay = 5; //minutes till next schedule item
			defaultScheduleParams.tasksPerBatch = 1; //how many tasks to do per iteration
			defaultScheduleParams.scheduleStart = 1; //Where in the command list to start processing
			defaultScheduleParams.scheduleStop = ArrayLen(commands); //When to stop processing (say stop at position 11)
			
			//Override defaults with passed in values
			if(!StructIsEmpty(arguments.scheduleParams)){
				for(key in arguments.scheduleParams){
					if(StructKeyExists(defaultScheduleParams,key)){
						defaultScheduleParams[key] = arguments.scheduleParams[key];
					}else{
						//Invalid parameters passed in... throw error in the future?
					}
				}
			}
			
			//Verify the schedule exists, if it does wipe it out
			if(!StructKeyExists(application.schedule,arguments.scheduleName)){
				StructInsert(application.schedule,arguments.scheduleName,StructNew());
			}else{
				application.schedule[arguments.scheduleName] = StructNew();
			}
			
			//Set schedule
			application.schedule[arguments.scheduleName].commands = arguments.commands;
			application.schedule[arguments.scheduleName].scheduleParams = defaultScheduleParams;
			application.schedule[arguments.scheduleName].status = "active";
			application.schedule[arguments.scheduleName].scheduleProgress = defaultScheduleParams.scheduleStart;
			
			//BEGIN!
			processNextScheduleItem(arguments.scheduleName);
		</cfscript>
	</cffunction>
	
	
	<cffunction name="processNextScheduleItem" access="public" returntype="boolean">
		<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
		<cfif StructKeyExists(application.schedule,arguments.scheduleName)>
			<cfset currentSchedule = application.schedule[arguments.scheduleName]>
			<!---
				If the schedule is active, there are further things to do. And we have not hit the stop point yet.
				Continue with the schedule
			---->
			<cfif ArrayLen(currentSchedule.commands) gte currentSchedule.scheduleProgress 
					and currentSchedule.scheduleProgress lte currentSchedule.scheduleParams.scheduleStop+1
					and currentSchedule.status eq "active">
				<cfscript>
					//Log the scheduled process start
					application.ADF.utils.logAppend("Scheduled process started '#arguments.scheduleName#' Progress: #currentSchedule.scheduleProgress#/#ArrayLen(currentSchedule.commands)#","scheduledProcess-#arguments.scheduleName#.txt");
				</cfscript>
				<cftry>
					<cfhttp url="#currentSchedule.commands[currentSchedule.scheduleProgress]#" throwOnError="yes">
				<cfcatch>
					<cfsavecontent variable="cfcatchDump">
						<cfdump var="#cfcatch#" expand="false">
					</cfsavecontent>
					<cfscript>
						application.ADF.utils.logAppend("Scheduled process error '#arguments.scheduleName#' while processing URL: '#currentSchedule.commands[currentSchedule.scheduleProgress]#'","scheduledProcess-#arguments.scheduleName#.txt");
						application.schedule[arguments.scheduleName].status = "failure";
						application.ADF.utils.logAppend("#cfcatchDump#","scheduledProcessFailure-#arguments.scheduleName#.html");
						return false;
					</cfscript>
				</cfcatch>
				</cftry>
				<cfscript>
					application.ADF.utils.logAppend("Scheduled process complete. '#arguments.scheduleName#' Progress: #currentSchedule.scheduleProgress#/#ArrayLen(currentSchedule.commands)#","scheduledProcess-#arguments.scheduleName#.txt");
					currentSchedule.scheduleProgress = currentSchedule.scheduleProgress + 1;
					if(currentSchedule.scheduleProgress gt ArrayLen(currentSchedule.commands)){
						application.ADF.utils.logAppend("Scheduled complete '#arguments.scheduleName#'","scheduledProcess-#arguments.scheduleName#.txt");
						currentSchedule.status = "complete";
						return true;
					}
					//If this is a batch process do batchyness.
					if(currentSchedule.scheduleParams.tasksPerBatch gt 1 and
						currentSchedule.scheduleProgress mod currentSchedule.scheduleParams.tasksPerBatch - 1 neq 0 ){
						processNextScheduleItem(arguments.scheduleName);
					}else{
						scheduleURL = "http://#cgi.server_name#:#cgi.server_port##application.ADF.ajaxProxy#?bean=scheduler_1_0&method=processNextScheduleItem&scheduleName=#arguments.scheduleName#";
						//Schedule the next task
						application.ADF.utils.setScheduledTask(scheduleURL,arguments.scheduleName,"ScheduledTaskError-#arguments.scheduleName#.html",currentSchedule.scheduleParams.delay);
					}
				</cfscript>
			<cfelse>
				<cfscript>
					if(currentSchedule.scheduleProgress gt currentSchedule.scheduleParams.scheduleStop){
						application.ADF.utils.logAppend("Scheduled complete '#arguments.scheduleName#' stopping at position: #currentSchedule.scheduleProgress-1#/#ArrayLen(currentSchedule.commands)#","scheduledProcess-#arguments.scheduleName#.txt");
						currentSchedule.status = "complete";
						return true;
					}
				</cfscript>
			</cfif>
		</cfif>
		<cfreturn false/>
	</cffunction>
	
	<cffunction name="getScheduleStatus" access="public" returntype="struct">
		<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
		<cfscript>
			var rtnStruct = StructNew();
			var currentSchedule = StructNew();
			//Set Defaults
			rtnStruct.currentTask = -1;
			rtnStruct.totalTasks = -1;
			rtnStruct.status = "nonexistant";
			
			if(StructKeyExists(application.schedule,arguments.scheduleName)){
				currentSchedule = application.schedule[arguments.scheduleName];
				rtnStruct.currentTask = currentSchedule.scheduleProgress-1;
				rtnStruct.totalTasks = ArrayLen(currentSchedule.commands);
				rtnStruct.status = currentSchedule.status;
				rtnStruct.scheduleParams = currentSchedule.scheduleParams;
			}
			return rtnStruct;
		</cfscript>
	</cffunction>	
	
	<cffunction name="pauseSchedule" access="public" returntype="boolean">
		<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
		<cfscript>
			if(StructKeyExists(application.schedule,arguments.scheduleName) and
				application.schedule[arguments.scheduleName].status == "active"){
				application.schedule[arguments.scheduleName].status = "paused";
				return true;
			}
		</cfscript>
		<cfreturn false>
	</cffunction>	
	
	<cffunction name="resumeSchedule" access="public" returntype="boolean">
		<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
		<cfscript>
			if(StructKeyExists(application.schedule,arguments.scheduleName) and
				application.schedule[arguments.scheduleName].status == "paused" and
				ArrayLen(application.schedule[arguments.scheduleName].commands) gte application.schedule[arguments.scheduleName].scheduleProgress){
				application.schedule[arguments.scheduleName].status = "active";
				processNextScheduleItem(arguments.scheduleName);
				return true;
			}
		</cfscript>
		<cfreturn false>
	</cffunction>
	
	<cffunction name="getScheduleHTML" access="public" returnType="string">
		<cfargument name="scheduleName" type="string" required="true" hint="Unique name for the schedule you want to run">
		<cfsavecontent variable="rtnHTML">
			<cfoutput>
				<cfif !StructKeyExists(application.schedule,arguments.scheduleName)>
					Schedule does not exist.
				<cfelse>
					<cfset currentSchedule = application.schedule[arguments.scheduleName]>
					<cfset scheduleID = "schedule"&Replace(scheduleName," ","","all")>
					#application.ADF.scripts.loadJQuery()#
					#application.ADF.scripts.loadJQueryUI()#
					<script type="text/javascript">
						jQuery(document).ready(function (){
							$("###scheduleID# .progressBar").progressbar({ value: #currentSchedule.scheduleProgress/ArrayLen(currentSchedule.commands)*100# });
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
									currentTaskOffset = data.CURRENTTASK - (data.SCHEDULEPARAMS.SCHEDULESTART-1);//0 index
									totalTasks = (data.SCHEDULEPARAMS.SCHEDULESTOP+1)-(data.SCHEDULEPARAMS.SCHEDULESTART-1);
									progress = (currentTaskOffset)/(totalTasks)*100;
									jQuery("##"+scheduleID+" .progressBar").progressbar({ value: progress });
									jQuery("##"+scheduleID+" .scheduleStatus").html("Status: "+data.STATUS+" <br>Completion: "+currentTaskOffset+"/"+totalTasks);
									if(data.STATUS == "active"){
										setTimeout("updateSchedule('"+scheduleID+"')",10000);
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
	
</cfcomponent>