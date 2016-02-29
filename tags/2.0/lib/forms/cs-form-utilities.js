/*
*
* ADF CommonSpot Form Utilities
* v 1.0
* 2015-08-28 - DRM - Created
*
* */
var adf = adf || {};
adf.formUtils =
{
	version: '1.0',


	// shows or hides a standard CommonSpot custom form field given the dom id of the field itself
	// mostly for use with (custom only, for now at least) field types that let you set the dom id of the field, independently from the CommonSpot form and field ID
	showHideCSFieldByDomId: function(id, show)
	{
		var fld = document.getElementById(id);
		var display = show ? '' : 'none';
		var container;
		if (fld)
		{
			container = adf.formUtils.getFieldContainerByFieldName(fld.name);
			if (container)
				container.style.display = display;
			container = adf.formUtils.getDescrContainerByFieldName(fld.name);
			if (container)
				container.style.display = display;
		}
	},

	// these methods return a reference to the requested field container
	getFieldContainerByFieldDomId: function(id)
	{
		var fld = document.getElementById(id);
		if (fld)
			return adf.formUtils.getFieldContainerByFieldName(fld.name);
	},
	getFieldContainerByFieldName: function(fieldName)
	{
		return document.getElementById(fieldName + '_container');
	},

	// these methods return a reference to the requested field description container
	getDescrContainerByFieldDomId: function(id)
	{
		var fld = document.getElementById(id);
		if (fld)
			return adf.formUtils.getDescrContainerByFieldName(fld.name);
	},
	getDescrContainerByFieldName: function(fieldName)
	{
		return document.getElementById(fieldName + '_descr_container');
	},

	// these methods return a reference to the requested field or description container, from its actual CommonSpot form and field name
	// IMPORTANT: those names are the text ones defined in CommonSpot for the form or element and the field, NOT ID-based fic_... names
	getFieldContainerByFormFieldName: function(formName, fieldName)
	{
		var fieldFullName = (formName + '__' + fieldName).replace(/ /g, '_');
		var selector = 'div[data-containerfor="' + fieldFullName + '"]';
		var elems = document.querySelectorAll(selector);
		if (elems.length >= 1)
			return elems[0];
	},
	getDescrContainerByFormFieldName: function(formName, fieldName)
	{
		var fieldFullName = (formName + '__' + fieldName).replace(/ /g, '_');
		var selector = 'div[data-descrcontainerfor="' + fieldFullName + '"]';
		var elems = document.querySelectorAll(selector);
		if (elems.length >= 1)
			return elems[0];
	},
	// shows or hides a standard CommonSpot custom form field by its actual CommonSpot form and field name; see above
	showHideCSFieldByFormFieldName: function(formName, fieldName, show)
	{
		var display = show ? '' : 'none';
		var container = adf.formUtils.getFieldContainerByFormFieldName(formName, fieldName);
		if (container)
			container.style.display = display;
		container = adf.formUtils.getDescrContainerByFormFieldName(formName, fieldName);
		if (container)
			container.style.display = display;
	},
	// returns a reference to the requested CommonSpot hidden field, from its actual CommonSpot form and field name
	// note that the container methods don't work for CommonSpot's built-in hidden field type, because no containers are rendered
	getHiddenFieldByFormFieldName: function(formName, fieldName)
	{
		var fieldFullName = (formName + '__' + fieldName).replace(/ /g, '_');
		var selector = 'input[data-fieldFullName="' + fieldFullName + '"]';
		var elems = document.querySelectorAll(selector);
		if (elems.length >= 1)
			return elems[0];
	}
};