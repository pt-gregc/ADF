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
	ceManagement.cfm - v1.0
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
	2015-12-23 - GAC - Moved base script to allow for versioning and simplification of future iterations
--->

<!--- // The version of this custom script code --->
<cfset scriptVersion = "1.3.0">

<!--- // Optional ADF App Override Attributes for the Custom Script Parameters tab --->
<!--- // !!!! DO NOT MODIFY THIS OVERRIDE LOGIC to force changes via the Custom Script Parameters from the CommonSpot UI!!! --->
<cfscript>
    if ( StructKeyExists(attributes,"appBeanName") AND LEN(TRIM(attributes.appBeanName)) AND StructKeyExists(attributes,"appParamsVarName") AND LEN(TRIM(attributes.appParamsVarName)) ) {
        attributes = application.ADF.utils.appOverrideCSParams(
                                                        csParams=attributes,
                                                        appName=attributes.appBeanName,
                                                        appParamsVarName=attributes.appParamsVarName,
                                                        paramsExceptionList="appBeanName,appParamsVarName");
    }

    // This is the default script Configuration Version
    // - FYI: Changing this value will break any existing v1 datasheet configurati
    scriptConfigVersion = "1.0";

    // Check to see if the attribute 'configVersion' was passed in.
    // - This will override the default scriptConfigVersion
    // - Only use configVersion=2.0 on new datasheet setups! For a new setups "configVersion=2.0" can be passed via the custom script parameters dialog
    if ( StructKeyExists(attributes,"configVersion") AND LEN(TRIM(attributes.configVersion)) )
        scriptConfigVersion = attributes.configVersion;
</cfscript>

<cfoutput>
    <cfif structKeyExists(attributes,"elementName") and Len(attributes.elementName)>
        <cfscript>
            application.ADF.scripts.loadJQuery();

            if ( StructKeyExists(attributes,"themeName") AND LEN(TRIM(attributes.themeName)) )
                application.ADF.scripts.loadJQueryUI(themeName=attributes.themeName);
            else
                application.ADF.scripts.loadJQueryUI();

            // Load jquery cookie to remember the last tab visited
            application.ADF.scripts.loadJQueryCookie();
            application.ADF.scripts.loadADFLightbox();

            // Check for CS Author Mode
            csMode = "";
            if ( StructKeyExists(request,"renderstate") AND StructKeyExists(request.renderstate,"rendermode") )
                csMode = request.renderstate.rendermode;

            // Bean Name for the Add Button
            beanName = "Forms_2_0";

            // Check to see if the attribute 'formBeanName' was passed in.
            //	This will override the bean to open for the form
            if ( StructKeyExists(attributes,"formBeanName") AND LEN(TRIM(attributes.formBeanName)) )
                beanName = attributes.formBeanName;

            urlParams = "";
            if ( StructKeyExists(attributes,"jsCallback") AND LEN(TRIM(attributes.jsCallback)) )
                urlParams = urlParams & "&callback=" & attributes.jsCallback;

            // Pass the URLParams to the ADF Datasheet Modules
            if ( LEN(TRIM(urlParams)) )
                request.adfDSmodule.urlParams = urlParams;

            // Set the 'Add Button' display defaults
            displayAddButtonDefault = true; // Display the 'Add Button'
            secureAddButtons = true;  // Only show 'Add Button' if user is logged in

            // Set the flag for the locking a secured 'Add Button'
            enableAddButton = true;

            // Create the struct for the 'Add Button' status
            displayAddBtnOptions = StructNew();
            displayAddButtonList = "";

            // Set the Add Button Defualt Text
            addButtonTextDefault = "Add New {{elementName}}";
            customAddButtonTextList = "";
            tabLabelsList = "";

            // Check to see if the attribute 'showAddButtons' was passed in with a list of display option values
            // - attributes.showAddButtons=false takes presidence over enableAddButton=true
            if ( StructKeyExists(attributes,"showAddButtons") AND LEN(TRIM(attributes.showAddButtons)) )
            {
                // Set the default if only one showAddButton option is passed in use it as the default for all
                if ( ListLen(attributes.showAddButtons) EQ 1 AND IsBoolean(attributes.showAddButtons) )
                    displayAddButtonDefault = attributes.showAddButtons;
                else
                    displayAddButtonList = attributes.showAddButtons;
            }

            // Build structure with CEName as the key and the 'Add Button' display option as the value
            for ( a=1;a LTE ListLen(attributes.elementName);a=a+1 )
            {
                ce = TRIM(ListGetAt(attributes.elementName,a));

                // Build a structure Key (without spaces) based on the CEName
                // to be used to store the Add Button display options for each element passed in
                elmt = REREPLACE(ce,"[\s]","","all");
                abtn = displayAddButtonDefault;

                // set the display value for each 'Add Button' for each element tab
                if ( a LTE ListLen(displayAddButtonList) )
                    abtn = ListGetAt(displayAddButtonList,a);

                // Set the elementName key of the struct with the status value
                if ( IsBoolean(abtn) )
                    displayAddBtnOptions[elmt] = abtn;
                else
                    displayAddBtnOptions[elmt] = displayAddButtonDefault;
            }

            // Check to see if the attribute 'useAddButtonSecurity' was passed in
            if ( StructKeyExists(attributes,"useAddButtonSecurity") AND IsBoolean(attributes.useAddButtonSecurity) )
                secureAddButtons = attributes.useAddButtonSecurity;

            // Security Check for 'Add Button'
            // - enableAddButton=false takes presidence over attributes.showAddButtons=true
            if ( secureAddButtons AND (LEN(request.user.userid) EQ 0 OR request.user.userid EQ "anonymous") )
                enableAddButton = false;

            // Check to see if the attribute 'customAddButtonText' was passed in with a list of display values
            if ( StructKeyExists(attributes,"customAddButtonText") )
                customAddButtonTextList = attributes.customAddButtonText;

            // Check to see if the attribute 'customTabLabels' was passed in with a list of display values
            if ( StructKeyExists(attributes,"customTabLabels") AND LEN(TRIM(attributes.customTabLabels)) )
                tabLabelsList = attributes.customTabLabels;
            else
                tabLabelsList = attributes.elementName;

            // Check the list of elements to see if need the tabs.
            //	Set flag to render tabs or not
            //  Set the class name for the surrounding div based on if
            //		we are rendering tabs or not.
            if ( ListLen(attributes.elementName) GT 1 )
            {
                renderTabFormat = true;
                divClass = "tabs";
            }
            else
            {
                renderTabFormat = false;
                divClass = "no-tabs";
            }
        </cfscript>
        <!--- // Add the STYLE block as a CSS Header Resource --->
        <cfsavecontent variable="adfGenericElmtMgmtHeaderCSS">
        <cfoutput>
            <style>
                a.ui-button:hover {
                    cursor:pointer;
                }
                a.ui-button {
                    padding: 10px;
                }
            </style>
        </cfoutput>
        </cfsavecontent>

        <!--- // Add the JavaScript block as a JS Footer Resource --->
        <cfsavecontent variable="adfGenericElmtMgmtFooterJS">
        <cfoutput>
            <script type="text/javascript">
                jQuery(document).ready(function(){
                // Load jquery cookie to remember the last tab visited
                jQuery('##tabs').tabs( { cookie: { expires: 30 } } );

                // Hover states on the static widgets
                jQuery("a.ui-button").hover(
                    function() {
                        jQuery(this).addClass('ui-state-hover');
                    },
                    function() {
                        jQuery(this).removeClass('ui-state-hover');
                    }
                );
            });
            </script>
        </cfoutput>
        </cfsavecontent>

        <cfscript>
            // Load the inline CSS as a CSS Resource
            application.ADF.scripts.addHeaderCSS(adfGenericElmtMgmtHeaderCSS, "SECONDARY"); //  PRIMARY, SECONDARY, TERTIARY
            // Load the inline JS as a JS Resource
            application.ADF.scripts.addFooterJS(adfGenericElmtMgmtFooterJS, "SECONDARY"); //  PRIMARY, SECONDARY, TERTIARY
        </cfscript>

        <div id="#divClass#">
            <!--- // Check if we want to render tabs --->
            <cfif renderTabFormat>
                <ul>
                <cfloop from="1" to="#listLen(tabLabelsList)#" index="i">
                        <li><a href="##tabs-#i#" title="tabs-#i#">#TRIM(ListGetAt(tabLabelsList,i))#</a></li>
                </cfloop>
                </ul>
            </cfif>
            <cfloop from="1" to="#listLen(attributes.elementName)#" index="i">
                <div id="tabs-#i#">
                <cfscript>
                    ceName = TRIM(ListGetAt(attributes.elementName,i));
                    // Build an 'elementName' based on the CEName without spaces
                    custEl = REREPLACE(ceName,"[\s]","","all");
                    custElID = application.ADF.ceData.getFormIDByCEName(CEName=ceName);

                    if ( ListFirst(scriptConfigVersion,".") LTE 1 )
                    {
                        // Use custel for the datasheet  "ct-render-named-element.cfm" call
                        controlSuffix = custEl;

                        // ^ Using the ceName in the datasheet control name does NOT allow account for the case
                        //   when the Name of the Custom Element changes since changing that will break the existing datasheet configurations
                        //   IMPORTANT -- this will be deprecated in ADF 2.0 ---
                    }
                    else
                    {
                        // Updated to allow for configuration of the v2 of this script
                        // Better solution ... will keep the datasheet config even if the element name changes
                        controlSuffix = custElID;
                    }

                    customControlName = "customManagementFor" & controlSuffix;
                </cfscript>
                <cfif renderTabFormat>
                        <br/>
                        <br/>
                </cfif>
                <cfif enableAddButton>
                    <cfif StructKeyExists(displayAddBtnOptions,custel) AND displayAddBtnOptions[custel]>
                        <!--- // Get the Custom Add Button Text if it was provided --->
                        <cfif ListLen(customAddButtonTextList) GTE i>
                            <cfset addBtnText = TRIM(ListGetAt(customAddButtonTextList,i))>
                        <cfelse>
                            <cfset addBtnText = REPLACE(addButtonTextDefault,"{{elementName}}","#ceName#","one")><!--- // "New #ceName#" --->
                        </cfif>
                        <!--- // Call UI buildAddEditLink for the Add New button --->
                        #application.ADF.UI.buildAddEditLink(linkTitle=addBtnText,
                                                                formName=ceName,
                                                                dataPageID=0,
                                                                refreshparent=true,
                                                                urlParams=urlParams,
                                                                formBean=beanName,
                                                                formMethod="renderAddEditForm",
                                                                lbTitle=addBtnText,
                                                                linkClass="ui-button ui-state-default ui-corner-all")#
                        <br/>
                        <br/>
                    </cfif>
                <cfelse>
                    <cfif StructKeyExists(displayAddBtnOptions,custel) AND displayAddBtnOptions[custel]>
                            Please <a href="#request.subsitecache[1].url#login.cfm">LOGIN</a> to add new records.
                        <br/>
                        <br/>
                    </cfif>
                </cfif>
                <cfif ListFindNoCase("author,edit",csMode)>
                        <br/>
                </cfif>
                <cfif ListFirst(scriptConfigVersion,".") LTE 1>
                    <CFMODULE TEMPLATE="/commonspot/utilities/ct-render-named-element.cfm"
                            elementtype="datasheet"
                            elementName="#customControlName#">
                <cfelse>
                    <!--- // For v2 of this script make sure the custom element exists --->
                    <cfif custElID GT 0>
                        <CFMODULE TEMPLATE="/commonspot/utilities/ct-render-named-element.cfm"
                                elementtype="datasheet"
                                elementName="#customControlName#">
                    <cfelse>
                            The custom element specified in the 'elementName=' parameter of this custom script does not exist.
                    </cfif>
                </cfif>
                </div>
            </cfloop>
        </div>
    <cfelse>
        Please add the parameter of 'elementName=<strong>My Element Name</strong>'.  At least one Custom Element name is required for this administration custom script.
    </cfif>
</cfoutput>