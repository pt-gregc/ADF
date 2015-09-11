<cfcomponent output="false" hint="
<pre>
DEVELOPER NOTES:

*******************************************************************************************************
This component is a CFC implementation of Jacob Munson's cffpVerify.cfm (part of CFFormProtect) written 
by Dave Shuck dshuck@gmail.com.  All calculations/algorithms are a direct port of Jacob's original code,
with exceptions noted in the NOTES section below.
*******************************************************************************************************

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
TEMPLATE    : cffpVerify.cfc

CREATED     : 23 Mar 2007

USAGE       : Perform various tests on a form submission to ensure that a human submitted it.

DEPENDANCY  : NONE

NOTES       : Dave Shuck - created 
			  Dave Shuck - 23 Mar 2007 - Added testTooManyUrls() method and call to the method in testSubmission()
			  Dave Shuck - 23 Mar 2007 - Removed the '0' padding in FormTime in testTimedSubmission() which was causing
			  								consistent failure on that test
			  Dave Shuck - 24 Mar 2007 - Added logFailure() method and the call to the method in testSubmission().  This
			  								code is still backwards compatable with older ini files that do not make use of
			  								the properties 'logFailedTests' and 'logFile'
			  Dave Shuck - 26 Mar 2007 - Altered the FormTime in testTimedSubmission() to use NumberFormat as the previous
			  								change caused exceptions before 10:00am.  (see comments in method)	
			  Mary Jo Sminkey - 18 July 2007 - Added new function 'testSpamStrings' which allows the user to configure a list
			  									of text strings to test the form against. Similar to using Akismet but with no
			  									cost involved for commercial use and can be configured as needed for the spam 
			  									received. Update Akismet function to log to same file and not log as passed if 
			  									the key validation failed.	
History:
	2015-09-10 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
</pre>
">

<cfset iniPath = "#Request.site.csAppsDir#config/">

	<cffunction name="init" access="public" output="false" returntype="cffpVerify2">
		<cfargument name="configPath" required="false" default="#request.site.csAppsDir#config/" type="string" />
		<cfargument name="configFilename" required="false" default="cffp.ini.cfm" type="string" />
		<cfscript>
			setConfig(arguments.configPath);
			this.configFilename = arguments.configFilename;
			return this;
		</cfscript>
	</cffunction>
	
	<!---<cffunction name="getConfig" access="public" output="false" returntype="struct">
		<cfreturn variables.Config />
	</cffunction>--->
	
	<cffunction name="setConfig" access="private" output="false" returntype="void">
		<cfargument name="configPath" required="true" default="#request.site.csAppsDir#config/">
		<cfscript>
		var iniEntries = GetProfileSections(arguments.configPath & "/cffp.ini.cfm").CFFormProtect;
		var i = "";
		application.cfformprotect.config = StructNew();
		
		for (i=1;i LTE ListLen(iniEntries);i=i+1) {
			application.cfformprotect.config[ListGetAt(iniEntries,i)] = GetProfileString(arguments.configPath & "/cffp.ini.cfm","CFFormProtect",ListGetAt(iniEntries,i));
		}
		//set logfile
		if (NOT Len(application.cfformprotect.config.logFile))	{ application.cfformprotect.config.logFile = "CFFormProtect"; } 
		</cfscript>
	</cffunction>
	
	<cffunction name="testSubmission" access="public" output="false" returntype="any">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Pass = true;
		// each time a test fails, totalPoints is incremented by the user specified amount
		var TotalPoints = 0;
		// setup a variable to store a list of tests that failed, for informational purposes
		var TestsResults = StructNew();
		
		// Check first to make sure configuration is in memory
		try	{
			if (NOT StructKeyExists(application,'cfformprotect')) {
				application.cfformprotect = StructNew();
			}
			if (NOT StructKeyExists(application.cfformprotect,'encryptionkey')) {
				setConfig();
			}
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	
		
		// Begin tests
		// Test for mouse movement
		try	{
			if (application.cfformprotect.config.mouseMovement)	{
				TestResults.MouseMovement = testMouseMovement(arguments.FormStruct);
				if (NOT TestResults.MouseMovement.Pass)	{
					// The mouse did not move
					TotalPoints = TotalPoints + application.cfformprotect.config.mouseMovementPoints;
				}
			}
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	

		
		// Test for used keyboard
		try	{
			if (application.cfformprotect.config.usedKeyboard)	{
				TestResults.usedKeyboard = testUsedKeyboard(arguments.FormStruct);
				if (NOT TestResults.usedKeyboard.Pass)	{
					// No keyboard activity was detected
					TotalPoints = TotalPoints + application.cfformprotect.config.usedKeyboardPoints;			
				}
			}					
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	

		
		// Test for time taken on the form
		try	{
			if (application.cfformprotect.config.timedFormSubmission)	{
				TestResults.timedFormSubmission = testTimedFormSubmission(arguments.FormStruct);
				if (NOT TestResults.timedFormSubmission.Pass)	{
					// Time was either too short, too long, or the form field was altered
					TotalPoints = TotalPoints + application.cfformprotect.config.timedFormPoints;			
				}
			}						
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	


		// Test for empty hidden form field
		try	{
			if (application.cfformprotect.config.hiddenFormField)	{
				TestResults.hiddenFormField = testHiddenFormField(arguments.FormStruct);
				if (NOT TestResults.hiddenFormField.Pass)	{
					// The submitter filled in a form field hidden via CSS
					TotalPoints = TotalPoints + application.cfformprotect.config.hiddenFieldPoints;			
				}
			}			
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	

		
		// Test Akismet
		//try	{
			if (application.cfformprotect.config.akismet)	{
				TestResults.akismet = testAkismet(arguments.FormStruct);
				if (NOT TestResults.akismet.Pass)	{
					// Akismet says this form submission is spam
					TotalPoints = TotalPoints + application.cfformprotect.config.akismetPoints;
				}
			}		
		//}
		//catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	

		
		// Test tooManyUrls
		try	{
			if (application.cfformprotect.config.tooManyUrls)	{
				TestResults.tooManyUrls = TestTooManyUrls(arguments.FormStruct);
				if (NOT TestResults.tooManyUrls.Pass)	{
					// Submitter has included too many urls in at least one form field
					TotalPoints = TotalPoints + application.cfformprotect.config.tooManyUrlsPoints;
				}
			}			
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	

		// Test spamStrings
		try	{
			if (application.cfformprotect.config.teststrings)	{
				TestResults.SpamStrings = testSpamStrings(arguments.FormStruct);
				if (NOT TestResults.SpamStrings.Pass)	{
					// Submitter has included a spam string in at least one form field
					TotalPoints = TotalPoints + application.cfformprotect.config.spamStringPoints;
				}
			}			
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	
		
		// Test Project Honey Pot
		try	{
			if (application.cfformprotect.config.projectHoneyPot)	{
				TestResults.ProjHoneyPot = testProjHoneyPot(arguments.FormStruct);
				if (NOT TestResults.ProjHoneyPot.Pass)	{
					// Submitter has included a spam string in at least one form field
					TotalPoints = TotalPoints + application.cfformprotect.config.projectHoneyPotPoints;
				}
			}			
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	

		// Compare the total points from the spam tests to the user specified failure limit
		if (TotalPoints GTE application.cfformprotect.config.failureLimit)	{
			Pass = false;	
			try	{
				if (application.cfformprotect.config.emailFailedTests)	{
					emailReport(TestResults=TestResults,FormStruct=FormStruct,TotalPoints=TotalPoints);	
				}				
			}
			catch(any excpt)	{ /* an error has occurred emailing the report, but we will move on */ }
			try	{
				if (application.cfformprotect.config.logFailedTests)	{
					logFailure(TestResults=TestResults,FormStruct=FormStruct,TotalPoints=TotalPoints,LogFile=application.cfformprotect.config.logFile);	
				}				
			}
			catch(any excpt)	{ /* an error has occurred logging the spam, but we will move on */ }
		}
		return pass;
		</cfscript>
	</cffunction>
	
	<cffunction name="testMouseMovement" access="private" output="false" returntype="struct"
				hint="I make sure this form field exists, and it has a numeric value in it (the distance the mouse traveled)">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		Result.Pass = false;
		if (StructKeyExists(arguments.FormStruct,"formfield1234567891") AND IsNumeric(arguments.FormStruct.formfield1234567891))	{
			Result.Pass = true;
		}	
		return Result;
		</cfscript>
	</cffunction>	
	
	<cffunction name="testUsedKeyboard" access="private" output="false" returntype="struct"
				hint="I make sure this form field exists, and it has a numeric value in it (the amount of keys pressed by the user)">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		Result.Pass = false;
		if (StructKeyExists(arguments.FormStruct,"formfield1234567892") AND IsNumeric(arguments.FormStruct.formfield1234567892))	{
			Result.Pass = true;
		}	
		return Result;
		</cfscript>		
	</cffunction>
	
	<cffunction name="testTimedFormSubmission" access="private" output="false" returntype="struct" 
					hint="I check the time elapsed from the begining of the form load to the form submission">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		var FormDate = "";
		var FormTime = "";
		var FormDateTime = "";
		//var FormTimeElapsed = "";
		
		Result.Pass = true;
								
		// Decrypt the initial form load time
		if (StructKeyExists(arguments.FormStruct,"formfield1234567893") AND ListLen(form.formfield1234567893) eq 2)	{
			FormDate = ListFirst(form.formfield1234567893)-19740206;
			if (Len(FormDate) EQ 7) {
				FormDate = "0" & FormDate;	
			}
			FormTime = ListLast(form.formfield1234567893)-19740206;
			if (Len(FormTime))	{
				// in original form, FormTime was always padded with a "0" below.  In my testing, this caused the timed test to fail
				// consistantly after 9:59am due to the fact it was shifting the time digits one place to the right with 2 digit hours.  
				// To make this work I added NumberFormat()
				FormTime = NumberFormat(FormTime,000000);
			}
			
			FormDateTime = CreateDateTime(Left(FormDate,4),Mid(FormDate,5,2),Right(FormDate,2),Left(FormTime,2),Mid(FormTime,3,2),Right(FormTime,2));
			// Calculate how many seconds elapsed
			Result.FormTimeElapsed = DateDiff("s",FormDateTime,Now());
			if (Result.FormTimeElapsed LT application.cfformprotect.config.timedFormMinSeconds OR Result.FormTimeElapsed GT application.cfformprotect.config.timedFormMaxSeconds)	{
				Result.Pass = false;
			}
		}	
		else	{
			Result.Pass = false;
		}
		return Result;
		</cfscript>
	</cffunction>
	
	<cffunction name="testHiddenFormField" access="private" output="false" returntype="struct"
				hint="I make sure the CSS hidden form field doesn't have a value">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		Result.Pass = false;
		if (StructKeyExists(arguments.FormStruct,"formfield1234567894") AND NOT Len(arguments.FormStruct.formfield1234567894))	{
			Result.Pass = true;
		}	
		return Result;		
		</cfscript>
	</cffunction>

	<cffunction name="testAkismet" access="private" output="false" returntype="struct"
				hint="I send form contents to the public Akismet service to validate that it's not 'spammy'">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		var AkismetKeyIsValid = false;
		var AkismetHTTPRequest = true;
		var logfile = application.cfformprotect.config.logFile;
		Result.Pass = true;
		Result.ValidKey = false;
		</cfscript>
	
		<cftry>
			<!--- validate the Akismet API key --->
			<cfhttp url="http://rest.akismet.com/1.1/verify-key" timeout="10" method="post">
				<cfhttpparam name="key" type="formfield" value="#application.cfformprotect.config.akismetAPIKey#" />
				<cfhttpparam name="blog" type="formfield" value="#application.cfformprotect.config.akismetBlogURL#" />
			</cfhttp>
 			<cfcatch type="any">
				<cfset AkismetHTTPRequest = false />
			</cfcatch>
		</cftry>
		<cfif AkismetHTTPRequest AND Trim(cfhttp.FileContent) EQ "valid">
			<cfset AkismetKeyIsValid = true />
			<cfset Result.ValidKey = true />
		</cfif>
		<cfif AkismetKeyIsValid>
			<cftry>
				<!--- send form contents to Akismet API --->
				<cfhttp url="http://#application.cfformprotect.config.akismetAPIKey#.rest.akismet.com/1.1/comment-check" timeout="10" method="post">
					<cfhttpparam name="key" type="formfield" value="#application.cfformprotect.config.akismetAPIKey#" />
					<cfhttpparam name="blog" type="formfield" value="#application.cfformprotect.config.akismetBlogURL#" />
					<cfhttpparam name="user_ip" type="formfield" value="#cgi.remote_addr#" />
					<cfhttpparam name="user_agent" type="formfield" value="CFFormProtect/1.0 | Akismet/1.11" />
					<cfhttpparam name="referrer" type="formfield" value="#cgi.http_referer#" />
					<cfhttpparam name="comment_author" type="formfield" value="#arguments.FormStruct[application.cfformprotect.config.akismetFormNameField]#" />
					<cfif Len(application.cfformprotect.config.akismetFormEmailField)>
						<cfhttpparam name="comment_author_email" type="formfield" value="#arguments.FormStruct[application.cfformprotect.config.akismetFormEmailField]#" />
					</cfif>
					<cfif Len(application.cfformprotect.config.akismetFormURLField)>
						<cfhttpparam name="comment_author_url" type="formfield" value="#arguments.FormStruct[application.cfformprotect.config.akismetFormURLField]#" />
					</cfif>
					<cfhttpparam name="comment_content" type="formfield" value="#arguments.FormStruct[application.cfformprotect.config.akismetFormBodyField]#" />
				</cfhttp>
				<cfcatch type="any">
					<cfset akismetHTTPRequest = false />
				</cfcatch>
			</cftry>
				<!--- check Akismet results --->
				<cfif AkismetHTTPRequest AND Trim(cfhttp.FileContent)>
					<!--- Akismet says this form submission is spam --->
					<cfset Result.Pass = false />
				</cfif>
		<cfelse>
			<cflog file="#logfile#" text="Akismet API Key is invalid" />
		</cfif>
		<cfreturn Result />
	</cffunction>
	
	<cffunction name="testTooManyUrls" access="private" output="false" returntype="struct"
				hint="I test whether too many URLs have been submitted in fields">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		var i = "";
		// Make a duplicate since this is passed by reference and we don't want to modify the original data
		var FormStructCopy = Server.CommonSpot.UDF.util.duplicateBean(arguments.FormStruct);
		var UrlCount = "";
		
		Result.Pass = true;
		for (i=1;i LTE ListLen(arguments.FormStruct.FieldNames);i=i+1)	{
			UrlCount = -1;
			while (FindNoCase("http://",FormStructCopy[ListGetAt(arguments.FormStruct.FieldNames,i)]))	{
				FormStructCopy[ListGetAt(arguments.FormStruct.FieldNames,i)] = ReplaceNoCase(FormStructCopy[ListGetAt(arguments.FormStruct.FieldNames,i)],"http://","","one");
				UrlCount = UrlCount + 1;
			}	
			if (UrlCount GTE application.cfformprotect.config.tooManyUrlsMaxUrls)	{
				Result.Pass = false;
				break;	
			}
		}
		return Result;
		</cfscript>
	</cffunction>
	
	<cffunction name="listFindOneOf" output="false" returntype="boolean">
		<cfargument name="texttosearch" type="string" required="yes"/>
		<cfargument name="values" type="string" required="yes"/>
		<cfargument name="delimiters" type="string" required="no" default=","/>
		<cfset var value = 0/>
		<cfloop list="#arguments.values#" index="value" delimiters="#arguments.delimiters#">
			<cfif FindNoCase(value, arguments.texttosearch)>
				<cfreturn false />
			</cfif>
		</cfloop>
		<cfreturn true />
	</cffunction>

	<cffunction name="testSpamStrings" access="private" output="false" returntype="struct"
				hint="I test whether any of the configured spam strings are found in the form submission">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		var value = 0;
		var teststrings = application.cfformprotect.config.spamstrings;
		var checkfield = '';
		Result.Pass = true;
		
		// Loop through the list of spam strings to see if they are found in the form submission		
		for (checkfield in arguments.FormStruct)	{
			if (Result.Pass IS true)	{
				Result.Pass = listFindOneOf(arguments.FormStruct[checkfield],teststrings);
			}
		}
		return Result;
		</cfscript>
	</cffunction>

	<cffunction name="testProjHoneyPot" access="private" output="false" returntype="struct"
				hint="I send the user's IP address to the Project Honey Pot service to check if it's from a known spammer.">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfset var Result = StructNew()>
		<cfset var apiKey = application.cfformprotect.config.projectHoneyPotAPIKey>
		<cfset var visitorIP = cgi.remote_addr> <!--- 93.174.93.221 is known to be bad --->
		<cfset var reversedIP = "">
		<cfset var addressFound = 1>
		<cfset var isSpammer = 0>
		<cfset var inetObj = "">
		<cfset var hostNameObj = "">
		<cfset var projHoneypotResult = "">
		<cfset var resultArray = "">
		<cfset var threatScore = "">
		<cfset var classification = "">
		<cfset Result.Pass = true>
		
		<!--- Setup the DNS query string --->
		<cfset reversedIP = listToArray(visitorIP,".")>
		<cfset reversedIP = reversedIP[4]&"."&reversedIP[3]&"."&reversedIP[2]&"."&reversedIP[1]>

		<cftry>
			<!--- Query Project Honeypot for this address --->
			<cfset inetObj = createObject("java", "java.net.InetAddress")>
			<cfset hostNameObj = inetObj.getByName("#apiKey#.#reversedIP#.dnsbl.httpbl.org")>
			<cfset projHoneypotResult = hostNameObj.getHostAddress()>
			<cfcatch type="java.net.UnknownHostException">
				<!--- The above Java code throws an exception when the address is not
							found in the Project Honey Pot database. --->
				<cfset addressFound = 0>
			</cfcatch>
		</cftry>
		
		<cfif addressFound>
			<cfset resultArray = listToArray(projHoneypotResult,".")>
			<!--- resultArray[3] is the threat score for the address, rated from 0 to 255.
						resultArray[4] is the classification for the address, anything higher than
						1 is either a harvester or comment spammer --->
			<cfset threatScore = resultArray[3]>
			<cfset classification = resultArray[4]>
			<cfif (threatScore gt 10) and (classification gt 1)>
				<cfset isSpammer = isSpammer+1>
			</cfif>
		</cfif>
		
		<cfif isSpammer>
			<cfset Result.Pass = false>
		</cfif>
		
		<cfreturn Result>
	</cffunction>

	<cffunction name="emailReport" access="private" output="false" returntype="void">
		<cfargument name="TestResults" required="true" type="struct" />
		<cfargument name="FormStruct" required="true" type="struct">
		<cfargument name="TotalPoints" required="true" type="numeric" />
		<cfscript>
		var falsePositiveURL = "";
		var missedSpamURL = "";
		</cfscript>
		<!--- Here is where you might want to make some changes, to customize what happens
				if a spam message is found.  depending on your system, you can either just use
				my code here, or email yourself the failed test, or plug into your system
				in the best way for your needs --->
			<!---  --->
					
	 	<cfmail
			from="#application.cfformprotect.config.emailFromAddress#"
			to="#application.cfformprotect.config.emailToAddress#"
			subject="#application.cfformprotect.config.emailSubject#"
			server="#application.cfformprotect.config.emailServer#"
			username="#application.cfformprotect.config.emailUserName#"
			password="#application.cfformprotect.config.emailPassword#"
			type="html">
				This message was marked as spam because:
				<ol>
					<cfif StructKeyExists(arguments.TestResults,"mouseMovement") AND NOT arguments.TestResults.mouseMovement.Pass>
					<li>No mouse movement was detected.</li>
					</cfif>
					
					<cfif StructKeyExists(arguments.TestResults,"usedKeyboard") AND NOT arguments.TestResults.usedKeyboard.Pass>
					<li>No keyboard activity was detected.</li>
					</cfif>
					
					<cfif StructKeyExists(arguments.TestResults,"timedFormSubmission") AND NOT arguments.TestResults.timedFormSubmission.Pass>
						<cfif StructKeyExists(arguments.FormStruct,"formfield1234567893")>
						<li>The time it took to fill out the form was 
							<cfif arguments.FormStruct.formfield1234567893 lt application.cfformprotect.config.timedFormMinSeconds>
								too short.
							<cfelseif arguments.FormStruct.formfield1234567893 gt application.cfformprotect.config.timedFormMaxSeconds>
								too long.
							</cfif>
							It took them #arguments.FormStruct.formfield1234567893# seconds to submit the form, and your allowed
							threshold is #application.cfformprotect.config.timedFormMinSeconds#-#application.cfformprotect.config.timedFormMaxSeconds#
							seconds.
						</li>
						<cfelse>
							<li>The time it took to fill out the form did not fall within your
								configured threshold of #application.cfformprotect.config.timedFormMinSeconds#-#application.cfformprotect.config.timedFormMaxSeconds#
								seconds.  Also, I think the form data for this field was tampered with by the
								spammer.
							</li>
						</cfif>
					</cfif>
					
					<cfif StructKeyExists(arguments.TestResults,"hiddenFormField") AND NOT arguments.TestResults.hiddenFormField.Pass>
					<li>The hidden form field that is supposed to be blank contained data.</li>
					</cfif>
					
					<cfif StructKeyExists(arguments.TestResults,"SpamStrings") AND NOT arguments.TestResults.SpamStrings.Pass>
					<li>One of the configured spam strings was found in the form submission.</li>
					</cfif>
					
					<cfif StructKeyExists(arguments.TestResults,"akismet") AND NOT arguments.TestResults.akismet.Pass>
						<!--- The next few lines build the URL to submit a false
									positive notification to Akismet if this is not spam --->
						<cfset falsePositiveURL = replace("#application.cfformprotect.config.akismetBlogURL#cfformprotect/akismetFailure.cfm?type=ham","://","^^","all")>
						<cfset falsePositiveURL = replace(falsePositiveURL,"//","/","all")>
						<cfset falsePositiveURL = replace(falsePositiveURL,"^^","://","all")>
						<cfset falsePositiveURL = falsePositiveURL&"&user_ip=#urlEncodedFormat(cgi.remote_addr,'utf-8')#">
						<cfset falsePositiveURL = falsePositiveURL&"&referrer=#urlEncodedFormat(cgi.http_referer,'utf-8')#">
						<cfset falsePositiveURL = falsePositiveURL&"&comment_author=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormNameField],'utf-8')#">
						<cfif application.cfformprotect.config.akismetFormEmailField neq "">
						<cfset falsePositiveURL = falsePositiveURL&"&comment_author_email=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormEmailField],'utf-8')#">
						</cfif>
						<cfif application.cfformprotect.config.akismetFormURLField neq "">
						<cfset falsePositiveURL = falsePositiveURL&"&comment_author_url=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormURLField],'utf-8')#">
						</cfif>
						<cfset falsePositiveURL = falsePositiveURL&"&comment_content=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormBodyField],'utf-8')#">
						<li>Akisment thinks this is spam, if it's not please mark this as a
						false positive by <cfoutput><a href="#falsePositiveURL#">clicking here</a></cfoutput>.</li>
					<cfelseif StructKeyExists(arguments.TestResults,"akismet") AND arguments.TestResults.akismet.ValidKey AND arguments.TestResults.akismet.Pass>
						<!--- The next few lines build the URL to submit a missed
									spam notification to Akismet --->
						<cfset missedSpamURL = replace("#application.cfformprotect.config.akismetBlogURL#cfformprotect/akismetFailure.cfm?type=spam","://","^^","all")>
						<cfset missedSpamURL = replace(missedSpamURL,"//","/","all")>
						<cfset missedSpamURL = replace(missedSpamURL,"^^","://","all")>
						<cfset missedSpamURL = missedSpamURL&"&user_ip=#urlEncodedFormat(cgi.remote_addr,'utf-8')#">
						<cfset missedSpamURL = missedSpamURL&"&referrer=#urlEncodedFormat(cgi.http_referer,'utf-8')#">
						<cfset missedSpamURL = missedSpamURL&"&comment_author=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormNameField],'utf-8')#">
						<cfif application.cfformprotect.config.akismetFormEmailField neq "">
						<cfset missedSpamURL = missedSpamURL&"&comment_author_email=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormEmailField],'utf-8')#">
						</cfif>
						<cfif application.cfformprotect.config.akismetFormURLField neq "">
						<cfset missedSpamURL = missedSpamURL&"&comment_author_url=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormURLField],'utf-8')#">
						</cfif>
						<cfset missedSpamURL = missedSpamURL&"&comment_content=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormBodyField],'utf-8')#">
						Akismet did not think this message was spam.  If it was, please <a href="#missedSpamURL#">notify Akismet</a> that it
						missed one.
					</cfif>
					
					<cfif StructKeyExists(arguments.TestResults,"TooManyUrls") AND NOT arguments.TestResults.tooManyUrls.Pass>
					       <li>There were too many URLs in the form contents</li>
					</cfif>
					
					<cfif StructKeyExists(arguments.TestResults,"ProjHoneyPot") AND NOT arguments.TestResults.ProjHoneyPot.Pass>
					<li>The user's IP address has been flagged by Project Honey Pot.</li>
					</cfif>
					
				</ol>
				Failure score: #totalPoints#<br />
				Your failure threshold: #application.cfformprotect.config.failureLimit#
			<br /><br />
			IP address: #cgi.remote_addr#<br />
			User agent: #cgi.http_user_agent#<br />
			Previous page: #cgi.http_referer#<br />
			Form variables:
			<cfdump var="#form#">
		</cfmail> 
	</cffunction>

	<cffunction name="logFailure" acces="private" output="false" returntype="void">
		<cfargument name="TestResults" required="true" type="struct" />
		<cfargument name="FormStruct" required="true" type="struct">
		<cfargument name="TotalPoints" required="true" type="numeric" />
		<cfargument name="LogFile" required="true" type="string" />
		<cfscript>
		var falsePositiveURL = "";
		var missedSpamURL = "";
		var LogText = "Message marked as spam!   ";
		</cfscript>
	
		<cfif StructKeyExists(arguments.TestResults,"mouseMovement") AND NOT arguments.TestResults.mouseMovement.Pass>
			<cfset LogText = LogText & "--- No mouse movement was detected." />
		</cfif>
					
		<cfif StructKeyExists(arguments.TestResults,"usedKeyboard") AND NOT arguments.TestResults.usedKeyboard.Pass>
			<cfset LogText = LogText & "--- No keyboard activity was detected." />
		</cfif>
					
		<cfif StructKeyExists(arguments.TestResults,"timedFormSubmission") AND NOT arguments.TestResults.timedFormSubmission.Pass>
			<cfif StructKeyExists(arguments.FormStruct,("formfield1234567893"))>
				<cfset LogText = LogText & "--- The time it took to fill out the form did not fall within your configured threshold of #application.cfformprotect.config.timedFormMinSeconds#-#application.cfformprotect.config.timedFormMaxSeconds# seconds." />
				
			<cfelse>
				<cfset LogText = LogText & "The time it took to fill out the form did not fall within your configured threshold of #application.cfformprotect.config.timedFormMinSeconds#-#application.cfformprotect.config.timedFormMaxSeconds# seconds.  Also, I think the form data for this field was tampered with by the spammer." />
			</cfif>
		</cfif>
					
		<cfif StructKeyExists(arguments.TestResults,"hiddenFormField") AND NOT arguments.TestResults.hiddenFormField.Pass>
			<cfset LogText = LogText & "--- The hidden form field that is supposed to be blank contained data." />
		</cfif>
		
		<cfif StructKeyExists(arguments.TestResults,"SpamStrings") AND NOT arguments.TestResults.SpamStrings.Pass>
			<cfset LogText = LogText & "--- One of the configured spam strings was found in the form submission." />
		</cfif>
					
		<cfif StructKeyExists(arguments.TestResults,"akismet") AND NOT arguments.TestResults.akismet.Pass>
			<!--- The next few lines build the URL to submit a false
						positive notification to Akismet if this is not spam --->
			<cfset falsePositiveURL = replace("#application.cfformprotect.config.akismetBlogURL#cfformprotect/akismetFailure.cfm?type=ham","://","^^","all")>
			<cfset falsePositiveURL = replace(falsePositiveURL,"//","/","all")>
			<cfset falsePositiveURL = replace(falsePositiveURL,"^^","://","all")>
			<cfset falsePositiveURL = falsePositiveURL&"&user_ip=#urlEncodedFormat(cgi.remote_addr,'utf-8')#">
			<cfset falsePositiveURL = falsePositiveURL&"&referrer=#urlEncodedFormat(cgi.http_referer,'utf-8')#">
			<cfset falsePositiveURL = falsePositiveURL&"&comment_author=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormNameField],'utf-8')#">
			<cfif application.cfformprotect.config.akismetFormEmailField neq "">
				<cfset falsePositiveURL = falsePositiveURL&"&comment_author_email=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormEmailField],'utf-8')#">
			</cfif>
			<cfif application.cfformprotect.config.akismetFormURLField neq "">
				<cfset falsePositiveURL = falsePositiveURL&"&comment_author_url=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormURLField],'utf-8')#">
			</cfif>
			<cfset falsePositiveURL = falsePositiveURL&"&comment_content=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormBodyField],'utf-8')#">
			<cfset LogText = LogText & "--- Akisment thinks this is spam, if it's not please mark this as a
							false positive by visiting: #falsePositiveURL#" />
		<cfelseif StructKeyExists(arguments.TestResults,"akismet") AND arguments.TestResults.akismet.ValidKey AND arguments.TestResults.akismet.Pass>
			<!--- The next few lines build the URL to submit a missed 
						spam notification to Akismet --->
			<cfset missedSpamURL = replace("#application.cfformprotect.config.akismetBlogURL#cfformprotect/akismetFailure.cfm?type=spam","://","^^","all")>
			<cfset missedSpamURL = replace(missedSpamURL,"//","/","all")>
			<cfset missedSpamURL = replace(missedSpamURL,"^^","://","all")>
			<cfset missedSpamURL = missedSpamURL&"&user_ip=#urlEncodedFormat(cgi.remote_addr,'utf-8')#">
			<cfset missedSpamURL = missedSpamURL&"&referrer=#urlEncodedFormat(cgi.http_referer,'utf-8')#">
			<cfset missedSpamURL = missedSpamURL&"&comment_author=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormNameField],'utf-8')#">
			<cfif application.cfformprotect.config.akismetFormEmailField neq "">
				<cfset missedSpamURL = missedSpamURL&"&comment_author_email=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormEmailField],'utf-8')#">
			</cfif>
			<cfif application.cfformprotect.config.akismetFormURLField neq "">
				<cfset missedSpamURL = missedSpamURL&"&comment_author_url=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormURLField],'utf-8')#">
			</cfif>
			<cfset missedSpamURL = missedSpamURL&"&comment_content=#urlEncodedFormat(form[application.cfformprotect.config.akismetFormBodyField],'utf-8')#">
			<cfset LogText = LogText & "--- Akismet did not think this message was spam.  If it was, please visit: #missedSpamURL#" />
		</cfif>
					
		<cfif StructKeyExists(TestResults,"TooManyUrls") AND NOT arguments.TestResults.tooManyUrls.Pass>
		      <cfset LogText = LogText & "--- There were too many URLs in the form contents." />
		</cfif>
					
		<cfif StructKeyExists(TestResults,"ProjHoneyPot") AND NOT arguments.TestResults.ProjHoneyPot.Pass>
		      <cfset LogText = LogText & "--- The user's IP address has been flagged by Project Honey Pot." />
		</cfif>
					
		<cfset LogText = LogText & "--- Failure score: #totalPoints#.  Your failure threshold: #application.cfformprotect.config.failureLimit#.  IP address: #cgi.remote_addr#	User agent: #cgi.http_user_agent#	Previous page: #cgi.http_referer#" />
	
		<cflog file="#arguments.LogFile#" text="#LogText#" />
	</cffunction>


</cfcomponent>

