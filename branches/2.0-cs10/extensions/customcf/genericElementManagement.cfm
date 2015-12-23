<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->
<!---
/* *********************************************************************** */
Author:
	PaperThin, Inc.
Name:
	genericElementManagement.cfm
Summary:
	Renders a custom element datasheet management page 
	- Adds a datasheet element on a tabbed interface when more than one custom element is specified 
	- An optional 'Add Button' is added above each datasheet element
Attributes:
	See "/ADF/extensions/customcf/ceManagement/1.0/ceManagement.cfm" for docs and a list of "Attributes"
	
History:
	2011-09-01 - RAK - Created
	2011-09-01 - RAK - Added multiple element support
	2011-12-08 - GAC - Added attribute for themeName that can be passed via the customcf parameters dialog 
	2012-01-05 - GAC - Added attribute for hiding the 'Add Button' 
					 - Added attrubutes for securing the 'Add Button' 
	2012-01-10 - MFC - Updated HTML to make the tabs work. 
					 - Added condition to not render tabs when only 1 element.
					 - Added JQuery Cookie to remember the last tab visited. 
	2012-01-10 - GAC - Fixed the logic for the show/hide of the 'Add Button'
					 - Fixed the logic for securing 'Add Button' 
					 - Fixed the 'Add Button' Lightbox Title so it doesn't pass the full list of the elementNames
					 - Added additional comments for the attributes that can be passed in via the custom script parameters tab
					 - Added logic to handle a display option to show or hide the 'Add Button' on each tab using a a comma-delimited list of true/false values 
	2012-01-13 - GAC - Fixed logic for checking the comma-delimited list of boolean values passed in with the 'showAddButtons' attribute
	2012-03-08 - MFC - Call Forms buildAddEditLink for the Add New button.
	2012-03-09 - GAC - Updated the form.buildAddEditLink to use the buildAddEditLink in the UI lib (buildAddEditLink in form_1_0 is deprecated)
					 - Added a trim to the ceName value generated from the items passed in via the elementName parameter
					 - Updated comments for the code that builds structure key names and datasheet element names based on ceName values
	2012-05-08 - GAC - Fixed an issue with the displayAddButtonList variable name
					 - Added a option for custom "Add New" button text
	2013-01-15 - GAC - If tabs are not being rendered, then don't add additional line breaks.
	2013-02-13 - GAC - Added a hook to override the Attributes passed in from the Custom Script Parameters tab with a structure from an App 
					 - Updated to use a UTILS lib function to process the override 
	2013-02-22 - MFC - Added the "formBeanName" into the attributes.
	2013-10-15 - GAC - Updated the App Level Override Parameters comments
					 - Removed 'themeName' value from the paramsExceptionList in the appOverrideCSParams function. 
	2014-05-01 - GAC - Added an extra <br> tag with in EDIT MODE to be able to see the custom script element indicator when not showing the 'ADD' button
	2014-10-24 - GAC - Added a script config version to allow for updates that would otherwise break previously configured datasheets
					 - Updated the Datasheet Control Name in the <cfmodule> to use the FormID as the uniqueID... so Datasheet configs don't break if the element name changes
					 - Added a option for custom "Tab Labels" when building multiple datasheets on the same page
	2015-10-12 - GAC - Updated the Forms_2_0 for ADF 2.0 and CommonSpot 10
	2015-10-13 - GAC - Added an optional jsCallback parameter to allow a javascript function name be passed to the buildAddEditLink() 
						and through the request scope to the edit-delete.cfm datasheet module
					 - Updated for ADF 2.0 and CommonSpot 10 loadResources()
    2015-12-23 - GAC - Moved base script to allow for versioning and simplification of future iterations
--->
<cfscript>
        // Set the default path to the v1.0 version of the ceManagement script
        include "/ADF/extensions/customcf/ceManagement/1.0/ceManagement.cfm";
</cfscript>