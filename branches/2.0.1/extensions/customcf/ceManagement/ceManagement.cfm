<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
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
	ceManagement.cfm
Summary:
	Renders a custom element datasheet management page
	- Adds a datasheet element on a tabbed interface when more than one custom element is specified
	- An optional 'Add Button' is added above each datasheet element
Attributes:
	elementName - a comma-delimited list of Custom Element Names (required: at least one elementName is needed)
	themeName - the name of a jQueryUI theme (default: the ADF standard theme for jQueryUI - ui-lightness)
	showAddButtons -  a comma-delimited list of true/false for each element name to show the 'Add Button' or not  on each tab (default: true)
	useAddButtonSecurity - true/false to enable or disable security for the 'Add Button' (default: true)
	customAddButtonText - a comma-delimited list of custom "Add Button" names (default: Add New {{elementName}})
	customTabLabels - a comma-delimited list of custom "Tab" labels (Note: tabs only render when more than one elementName is defined.)
	formBeanName - Override the form bean (component) to open for the form.
	jsCallback - Name of a Javascript Callback function on the same page as the genericElementManagement.cfm customcf file
	// App Level Override Parameters
	appBeanName - the AppBeanName of the app from the appBeanConfig.cfm file
	appParamsVarName - a variable name of a struct that contains key/values for the custom script attrubutes
	configVersion - used to utilize updated config options but can break pre-existing datasheets built from older configVersions

	/* NOTE: When both of the  App Level Override Params (appBeanName and appParamsVarName) are defined in the Custom Script Parameters and together they can be evaluated to create a data structure
	that defines key/value pairs, then the keys that match the standard Attributes will be used to OVERRIDE any additional attributes passed in. */

Custom Script Parameters Tab Examples:
	elementName=My Element One,My Element Two,My Element Three
	themeName=redmond
	showAddButtons=true,false,true
	useAddButtonSecurity=true
	customAddButtonText=Add New Item 1, Add New Item 2, Add New Three
	customTabLabels=One, Two, Three
	formBeanName = forms_2_0
	jsCallback = jsCallbackFunc
	appBeanName = ptBlog
	appParamsVarName = elementManagementParams
	configVersion = 2.0

History:
	2016-01-07 - GAC - Created
--->
<cfscript>
        defaultScriptVersion  = "2.0";

        // Include the original genericElementManagement script
        include "/ADF/extensions/customcf/ceManagement/#defaultScriptVersion#/ceManagement.cfm";
</cfscript>