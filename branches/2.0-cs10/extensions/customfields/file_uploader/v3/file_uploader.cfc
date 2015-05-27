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
	Ryan Kahn
Name:
	file_uploader.cfc
Summary:
	File uploader configuration and validation defaults
History:
 	2011-09-01 - RAK - Created
	2011-09-22 - RAK - Updated file uploader to be able to get more detailed information if they choose to override the props.
	2013-05-13 - MFC - Updated the "variables.destinationDir" to use the "request.subsiteCache[1].url" variable and
						corrected issue with multiple "//" in the path.
					   Added the "createUploadDir" function.
	2014-04-04 - GAC - Changed the cfscript thow to the utils.doThow with a new logging option
	2015-05-26 - DJM - Added the 3.0 version
--->
<cfcomponent name="file_uploader" extends="ADF.core.Base">
	<cfproperty name="version" value="2_0_0">
	<cfscript>
		//Default settings, you can override these in your extended cfc
		variables.acceptedExtensions = "png,pdf";
		variables.maxSize = "1000";//In kB
		variables.destinationDir = "#expandPath(request.subsiteCache[1].url&'_cs_apps/uploads/')#";
		variables.overwriteExistingFiles = false;

		//Thumbnails
		variables.generateThumbnails = true;
		variables.thumbnailMaxHeight = 100;
		variables.thumbnailMaxWidth = 100;

		//Validation functions, an array of function names that get called in order.
		//If any of them fails the entire upload fails.
		variables.validationFunctions = ArrayNew(1);
		ArrayAppend(variables.validationFunctions,"validateExtension");
		ArrayAppend(variables.validationFunctions,"validateSize");

		variables.thumbnailGenerators = ArrayNew(1);
		ArrayAppend(variables.thumbnailGenerators,"generateThumbnailForImage");

		//Final fallthrough transparent image when nobody else above can handle it
		ArrayAppend(variables.thumbnailGenerators,"transparentImageGenerator");
	</cfscript>



<!----------------------------------------------------------------
******************************************************************
******************************************************************
------------------ User Defined Functions-----------------------
******************************************************************
******************************************************************
----------------------------------------------------------------->

	<!---
	/* *************************************************************** */
	Author:
		PaperThin, Inc.
		Ryan Kahn
	Name:
		$validateExtension
	Summary:
		Validates the file extension
	Returns:
		struct
	Arguments:

	History:
	 	2011-09-01 - RAK - Created
	--->
	<cffunction name="validateExtension" access="public" returntype="struct" hint="Validates the file extension">
		<cfargument name="fileDetails" type="struct" required="true" default="" hint="Structure containing file details">
		<cfscript>
			var rtnStruct = StructNew();
			var fileExtension = '';

			rtnStruct.success = false;
			rtnStruct.msg = "Invalid extension. Valid extensions are: #variables.acceptedExtensions#";

			if(ListFindNoCase(variables.acceptedExtensions,listLast(fileDetails.fileName,'.'))){
				rtnSTruct.success = true;
				rtnStruct.msg = "Valid Extension";
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
		$validateSize
	Summary:
		Validates the filesize
	Returns:
		struct
	Arguments:

	History:
	 	2011-09-01 - RAK - Created
	--->
	<cffunction name="validateSize" access="public" returntype="struct" hint="Validates the filesize">
		<cfargument name="fileDetails" type="struct" required="true" default="" hint="Structure containing file details">
		<cfscript>
			var rtnStruct = StructNew();
			rtnStruct.success = false;
			rtnStruct.msg = "File too large. Maximum file size is #variables.maxSize#kb";
			//kB, 1000 Bytes, 8 bits in a Byte. We are dealing with binary data.
			if(len(fileDetails.binary) lt variables.maxSize*8*100){
				rtnStruct.success = true;
				rtnStruct.msg = "Valid Filesize";
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
		$getUniqueFileName
	Summary:
		Returns a unique filename for the destination file
	Returns:
		string
	Arguments:

	History:
	 	2011-09-02 - RAK - Created
		2014-03-05 - JTP - Var declarations
	--->
	<cffunction name="getUniqueFileName" access="public" returntype="string" hint="Returns a unique filename for the destination file">
		<cfargument name="sourceFileName" type="string" required="true" default="" hint="Source File Name">
		
		<cfscript>
			var rtnFileName = sourceFileName;
			var unique = false;
			var i = 0;
			var extension = '';
			var rootFileName = '';			
			
			if( FileExists("#variables.destinationDir##sourceFileName#") )
			{
				//The file exists, lets loop until we get a unique number.
				unique = false;
				i = 1;
				extension = listLast(sourceFileName,'.');
				rootFileName = left(sourceFileName,(Len(sourceFileName)-Len(extension)-1));
				while(!unique)
				{
					rtnFileName = "#rootFileName##i#.#extension#";
					if(!FileExists("#variables.destinationDir##rootFileName##i#.#extension#")){
						unique = true;
					}
					i = i+1;
				}
			}
			return rtnFileName;
		</cfscript>
	</cffunction>

	<!---
	/* *************************************************************** */
	Author:
		PaperThin, Inc.
		Ryan Kahn
	Name:
		$generateThumbnailForImage
	Summary:
		Generates a thumbnail for an image
	Returns:
		struct
	Arguments:

	History:
	 	2011-09-02 - RAK - Created
		2014-03-05 - JTP - Var declarations
	--->
	<cffunction name="generateThumbnailForImage" access="public" returntype="struct" hint="Generates a thumbnail for an image">
		<cfargument name="filePath" type="string" required="true" default="" hint="Fully qualified filepath">
		
		<cfscript>
			var rtnStruct = StructNew();
			var thumbnailWidth = 0;
			var thumbnailHeight = 0;
			var resizeDimension = '';
			
			rtnStruct.handledImage = false;
			rtnStruct.image = "";
		</cfscript>

		<!---Check to see if coldfusion can read this file--->
		<cfif listFindNoCase(GetReadableImageFormats(),listLast(filePath,"."))>
			<cfimage action="info" structname="imageInfo" source="#filePath#">
			<cfscript>
				resizeDimension = "";
				//Figure out what we need to do to maintain the aspect ratio.
				if(imageInfo.width gt variables.thumbnailMaxWidth
						and imageInfo.height gt variables.thumbnailMaxHeight){
					if(imageInfo.width gt imageInfo.height){
						resizeDimension = "width";
					}else{
						resizeDimension = "height";
					}
				}else if(imageInfo.width gt variables.thumbnailMaxWidth){
						resizeDimension = "width";
				}else if(imageInfo.height gt variables.thumbnailMaxHeight){
						resizeDimension = "height";
				}
			</cfscript>
			<cfif resizeDimension eq "width">
				<cfimage action="resize" source="#filePath#" width="#variables.thumbnailMaxWidth#" height="" name="rtnStruct.image">
			<cfelseif resizeDimension eq "height">
				<cfimage action="resize" source="#filePath#" height="#variables.thumbnailMaxHeight#" width="" name="rtnStruct.image">
			<cfelse>
				<cfimage action="read" source="#filePath#" name="rtnStruct.image">
			</cfif>
			<cfscript>
				rtnStruct.handledImage = true;
			</cfscript>
		</cfif>
		<cfreturn rtnStruct>
	</cffunction>

	<!---
	/* *************************************************************** */
	Author:
		PaperThin, Inc.
		Ryan Kahn
	Name:
		$transparentImageGenerator
	Summary:
		Genereates a transparent image.
	Returns:
		struct
	Arguments:

	History:
	 	2011-09-02 - RAK - Created
	--->
	<cffunction name="transparentImageGenerator" access="public" returntype="struct" hint="Genereates a transparent image.">
		<cfscript>
			var rtnStruct = StructNew();
			rtnStruct.image = ImageNew("",variables.thumbnailMaxWidth,variables.thumbnailMaxHeight,"argb");
			rtnStruct.handledImage = true;
			return rtnStruct;
		</cfscript>
	</cffunction>

	<!---
	/* *************************************************************** */
	Author:
		PaperThin, Inc.
		Ryan Kahn
	Name:
		$getCurrentValueRenderData
	Summary:
		Returns a structure containing both name and image
	Returns:
		struct
	Arguments:

	History:
	 	2011-09-07 - RAK - Created
	--->
	<cffunction name="getCurrentValueRenderData" access="public" returntype="struct" hint="Returns a structure containing both name and image">
		<cfargument name="currentValue" type="string" required="true" default="" hint="Current Value of the field">
		<cfscript>
			var rtnStruct = StructNew();
			rtnStruct.name = "";
			rtnStruct.image = "";
			if(len(currentValue)){
				rtnStruct.name = currentValue;
				if(variables.generateThumbnails){
					rtnStruct.image = _getThumbnail(currentValue);
				}
			}
			return rtnStruct;
		</cfscript>
	</cffunction>

<!----------------------------------------------------------------
******************************************************************
******************************************************************
------------------ System Defined Functions-----------------------
******************************************************************
******************************************************************
----------------------------------------------------------------->


	<!---
	/* *************************************************************** */
	Author:
		PaperThin, Inc.
		Ryan Kahn
	Name:
		$_validateFile
	Summary:
		Magic validation function, it takes the array of validation functions and executes them. On error it returns the results
	Returns:
		struct
	Arguments:

	History:
	 	2011-09-01 - RAK - Created
		2014-03-05 - JTP - Var declarations
	--->
	<cffunction name="_validateFile" access="public" returntype="struct" hint="Magic validation function, it takes the array of validation functions and executes them. On error it returns the results">
		<cfargument name="filePath" type="string" required="true" default="" hint="Fully qualified filepath">
		<cfargument name="fileName" type="string" required="true" default="" hint="Filename for the destination file">
		<cfargument name="fieldID" type="string" required="false" default="" hint="Field ID of the field we are uploading to">
		
		<cfscript>
			var returnStruct = StructNew();
			var argumentCollection = StructNew();
			var validationResults = '';
			var fileDetails = StructNew();
			var i = 0;
			
			fileDetails.fileName = arguments.fileName;
			fileDetails.temporaryPath = arguments.filePath;
			argumentCollection.fileDetails = fileDetails;
		</cfscript>
		
		<cffile action="read" variable="fileDetails.binary" file="#filePath#">
		<cfloop from="1" to="#ArrayLen(variables.validationFunctions)#" index="i">
			<cfinvoke method = "#variables.validationFunctions[i]#"
				returnVariable = "validationResults"
				argumentCollection = "#argumentCollection#">
			<cfif !validationResults.success>
				<cffile action="delete" file="#arguments.filePath#">
				<cfreturn validationResults>
			</cfif>
		</cfloop>
		<cfscript>
			returnStruct.success = true;
			returnStruct.message = "Validation Success";
			return returnStruct;
		</cfscript>
	</cffunction>


	<!---
	/* *************************************************************** */
	Author:
		PaperThin, Inc.
		Ryan Kahn
	Name:
		$_preformFileMove
	Summary:
		Preforms the file move from temporary to permanent storage
	Returns:
		struct
	Arguments:

	History:
	 	2011-09-02 - RAK - Created
	 	2013-05-13 - MFC - Updated to call the "createUploadDir" function.
		2014-03-05 - JTP - Var declarations
	--->
	<cffunction name="_preformFileMove" access="public" returntype="struct" hint="Preforms the file move from temporary to permanent storage">
		<cfargument name="filePath" type="string" required="true" default="" hint="Fully qualified filepath">
		<cfargument name="fileName" type="string" required="true" default="" hint="Filename for the destination file">
		<cfargument name="fieldID" type="string" required="false" default="" hint="Field ID of the field we are uploading to">
		
		<cfscript>
			var source = arguments.filePath;
			var rtnStruct = StructNew();
			var destination = "";
			var createDirStatus = false;
			var logFileName = "fileUploadError.log";
			
			
			if(!FileExists(source))
				application.ADF.utils.doThrow(message="Source file does not exist.",type="custom",logerror=1,logfile=logFileName);

			if(!DirectoryExists(variables.destinationDir))
			{
				// Create the directory
				createDirStatus = createUploadDir();
				if ( !createDirStatus )
					application.ADF.utils.doThrow(message="Destination directory does not exist.",type="custom",detail="Please create directory: #variables.destinationDir#",logerror=1,logfile=logFileName);
			}

			//Dont overwrite, so get a unique filename!
			if(!variables.overwriteExistingFiles)
				arguments.fileName = getUniqueFileName(arguments.fileName);

			destination = "#variables.destinationDir##arguments.fileName#";

			FileMove(source,destination);
			application.ADF.utils.logAppend("File move success. From-- "&source&" To-- "&destination,"fileUpload.txt");
			rtnStruct.success = true;
			rtnStruct.message = "File move success.";
			rtnStruct.fileName = arguments.fileName;
			return rtnStruct;
		</cfscript>
	</cffunction>

	<!---
	/* *************************************************************** */
	Author:
		PaperThin, Inc.
		Ryan Kahn
	Name:
		$_isThumbnailGenerationOn
	Summary:
		Returns t/f if thumbnail generation is on
	Returns:
		boolean
	Arguments:

	History:
	 	2011-09-02 - RAK - Created
	--->
	<cffunction name="_isThumbnailGenerationOn" access="public" returntype="boolean" hint="Returns t/f if thumbnail generation is on">
		<cfreturn variables.generateThumbnails>
	</cffunction>

	<!---
	/* *************************************************************** */
	Author:
		PaperThin, Inc.
		Ryan Kahn
	Name:
		$_getThumbnail
	Summary:
		Returns a thumbnail to the browser
	Returns:
		string
	Arguments:

	History:
	 	2011-09-02 - RAK - Created
	 	2011-09-21 - RAK - Added fieldID to overrides can use it to get more details
		2014-03-05 - JTP - Var declarations
	--->
	<cffunction name="_getThumbnail" access="public" returntype="string" hint="Returns a thumbnail to the browser">
		<cfargument name="fileName" type="string" required="true" default="" hint="Filename to get the thumbnail of">
		<cfargument name="fieldID" type="string" required="false" default="" hint="Field ID of the field we are uploading to">

		<cfscript>
			var i = "";
			var rtnHTML = "";
			var argumentCollection = StructNew();
			var img = "";
			var thumbnailResults = '';

			argumentCollection.filePath = "#variables.destinationDir##arguments.fileName#";
		</cfscript>

		<!---Loop over the thumbnail generators letting them do their thing--->
		<cfloop from="1" to="#ArrayLen(variables.thumbnailGenerators)#" index="i">
			<cfinvoke method = "#variables.thumbnailGenerators[i]#"
				returnVariable = "thumbnailResults"
				argumentCollection = "#argumentCollection#">
			<!---If we had a generator that handled the image then set the image and break out of the loop--->
			<cfif thumbnailResults.handledImage>
				<cfset img = thumbnailResults.image>
				<cfbreak>
			</cfif>
		</cfloop>
		<!---If we had a valid image then write it to the browser!--->
		<cfif !isSimpleValue(img)>
			<cfsavecontent variable="rtnHTML">
				<cfoutput>
					<cfimage action="writeTobrowser" source="#img#">
				</cfoutput>
			</cfsavecontent>
		</cfif>
		<cfreturn rtnHTML>
	</cffunction>

	<!---
	/* *************************************************************** */
	Author:
		PaperThin, Inc.
		Ryan Kahn
	Name:
		$getConfiguration
	Summary:
		Returns the configuration object for the file uploader
	Returns:
		struct
	Arguments:

	History:
	 	2011-09-06 - RAK - Created
	--->
	<cffunction name="getConfiguration" access="public" returntype="struct" hint="Returns the configuration object for the file uploader">
		<cfreturn variables>
	</cffunction>
	
	<!---
	/* *************************************************************** */
	Author:
		PaperThin, Inc.
		Ryan Kahn
	Name:
		$createUploadDir
	Summary:
		Returns T/F to create the uploads directory.
	Returns:
		struct
	Arguments:

	History:
	 	2013-05-13 - MFC - Created
	--->
	<cffunction name="createUploadDir" access="private" returntype="boolean">
		<cftry>
			<cfdirectory directory="#variables.destinationDir#" action="create">
			<cfreturn true>
			<cfcatch>
				<cfreturn false>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!---
	/* *************************************************************** */
	Author:
		PaperThin, Inc.
	Name:
		$doThrowError
	Summary:
		Used to throw errors in CFSCRIPT blocks since the cfscript 'throw' is not cf8 compatible
	Returns:
		struct
	Arguments:

	History:
	 	2014-04-01 - GAC - Created
	--->
	<cffunction name="doThrowError" access="private" returntype="void" hint="Used to throw errors in CFSCRIPT blocks since the cfscript 'throw' is not cf8 compatible">
		<cfargument name="message" type="string" required="false" default="" hint="Error Message to Throw">
		<cfargument name="type" type="string" required="false" default="Application" hint="Error Type to Throw">
		<cfargument name="detail" type="string" required="false" default="" hint="Error Message Detail to Throw">
		<cfif LEN(TRIM(arguments.message))>
			<cfthrow message="#arguments.message#" type="#arguments.type#" detail="#arguments.detail#">
		</cfif> 
	</cffunction>
</cfcomponent>