<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
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
	$file_uploader_1_0.cfc
Summary:
	File uploader configuration and validation defaults
History:
 	2011-09-01 - RAK - Created
--->
<cfcomponent name="file_uploader" extends="ADF.core.Base">
	<cfproperty name="version" value="1_0_0">
	<cfscript>
		//Default settings, you can override these in your extended cfc
		variables.acceptedExtensions = "png,pdf";
		variables.maxSize = "1000";//In kB
		variables.destinationDir = "#expandPath(request.site.cp_url&'/_cs_apps/uploads/')#";
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
	--->
	<cffunction name="getUniqueFileName" access="public" returntype="string" hint="Returns a unique filename for the destination file">
		<cfargument name="sourceFileName" type="string" required="true" default="" hint="Source File Name">
		<cfscript>
			var rtnFileName = sourceFileName;
			if(FileExists("#variables.destinationDir##sourceFileName#")){
				//The file exists, lets loop until we get a unique number.
				unique = false;
				i = 1;
				extension = listLast(sourceFileName,'.');
				rootFileName = left(sourceFileName,(Len(sourceFileName)-Len(extension)-1));
				while(!unique){
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
	--->
	<cffunction name="generateThumbnailForImage" access="public" returntype="struct" hint="Generates a thumbnail for an image">
		<cfargument name="filePath" type="string" required="true" default="" hint="Fully qualified filepath">
		<cfscript>
			var rtnStruct = StructNew();
			var thumbnailWidth = 0;
			var thumbnailHeight = 0;
			rtnStruct.handledImage = false;
			rtnStruct.image = "";

		</cfscript>
		<!---Check to see if coldfusion can read this file--->
		<cfif IsImageFile(filePath) and listFindNoCase(GetReadableImageFormats(),listLast(filePath,"."))>
			<cfimage name="rtnStruct.image" source="#filePath#">
			<cfscript>
				ImageSetAntialiasing(rtnStruct.image,"on");
				ImageScaleToFit(rtnStruct.image,variables.thumbnailMaxWidth,variables.thumbnailMaxHeight);
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
	--->
	<cffunction name="_validateFile" access="public" returntype="struct" hint="Magic validation function, it takes the array of validation functions and executes them. On error it returns the results">
		<cfargument name="filePath" type="string" required="true" default="" hint="Fully qualified filepath">
		<cfargument name="fileName" type="string" required="true" default="" hint="Filename for the destination file">
		<cfscript>
			var returnStruct = StructNew();
			var argumentCollection = StructNew();
			var validationResults = '';
			fileDetails = StructNew();
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
	--->
	<cffunction name="_preformFileMove" access="public" returntype="struct" hint="Preforms the file move from temporary to permanent storage">
		<cfargument name="filePath" type="string" required="true" default="" hint="Fully qualified filepath">
		<cfargument name="fileName" type="string" required="true" default="" hint="Filename for the destination file">
		<cfscript>
			var source = arguments.filePath;
			var rtnStruct = StructNew();
			var destination = "";
			if(!FileExists(source)){
				throw(message="Source file does not exist.",type="custom");
			}
			if(!DirectoryExists(variables.destinationDir)){
				throw(message="Destination directory does not exist.",type="custom",detail="Please create directory: #variables.destinationDir#");
			}
			//Dont overwrite, so get a unique filename!
			if(!variables.overwriteExistingFiles){
				fileName = getUniqueFileName(fileName);
			}
			destination = "#variables.destinationDir##fileName#";

			FileMove(source,destination);
			application.ADF.utils.logAppend("File move success. From-- "&source&" To-- "&destination,"fileUpload.txt");
			rtnStruct.success = true;
			rtnStruct.message = "File move success.";
			rtnStruct.fileName = fileName;
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
	--->
	<cffunction name="_getThumbnail" access="public" returntype="string" hint="Returns a thumbnail to the browser">
		<cfargument name="fileName" type="string" required="true" default="" hint="Filename to get the thumbnail of">
		<cfscript>
			var i = "";
			var rtnHTML = "";
			var argumentCollection = StructNew();
			var img = "";
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
</cfcomponent>