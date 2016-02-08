var listFormats = jQuery.parseJSON(editor.config.listBuilder.content);
var selectedEle = null;
var obj = null;
var d = new CKEDITOR.dom.element('p').$;
var curDivID = null;
var outHTML = '';

var wraptag = 'div';

formatsAssocArr = {};
jQuery.each(listFormats, function(idx, obj) {
	if (obj.wrapperTag == '')
		formatsAssocArr[obj.formatName] = 'div';
	else
		formatsAssocArr[obj.formatName] = obj.wrapperTag;
});	
CKEDITOR.plugins.add('listformat', {
	//icons: 'listformat',
	requires : ['richcombo'],
	checkListFormat: function(event)
	{
		var data = event.data.$;
		var id = null;
		var format = null;
		selectedEle = data.target;
		while (selectedEle)
		{
			if (selectedEle.className == 'placeholder')
			{
				id = selectedEle.id;
				break;
			}
			else if (selectedEle.className == 'placeholderWrapper')
			{
				selectedEle = selectedEle.getElementsByClassName('placeholder')[0];
				id = selectedEle.id;
				break;
			}
			else
				selectedEle = selectedEle.parentNode;
		}
		if (id)
		{
			format = selectedEle.getAttribute('data-format');
			var arr = jQuery.grep(listFormats, function(thisFormat, i ) {
				if (thisFormat.formatName == format)
					return ( thisFormat.formatName );
			});
			if (arr.length)
			{
				editor.ui.get('listformat').setValue(format);
				editor.ui.get('listformat').label = arr[0].displayName;
			}			
		}
	},
	init: function (editor) {
			
		var ajaxBeanName = editor.config.listBuilder.ajaxBeanName;
		var ajaxComURL = editor.config.listBuilder.ajaxComURL;
		editor.ui.addRichCombo('listformat',
		{
			label: "List Format",
			title: "List Format",
			multiSelect: false,
			className: 'cke_format comboClassname',
			panel: {
				css: ['/ADF/extensions/customfields/object_list_builder/plugins/listformat/css/listformat.css']
			},        		
							
			init: function () {

				var self = this;
				jQuery.each(listFormats, function(idx, obj) {
					self.add(obj.formatName, obj.displayName, obj.displayName);
				});	
				
			},
			onClick: function( value )
			{
				editor.focus();
				editor.fire( 'saveSnapshot' );
				var html= '';
				var id = null;

				if (selectedEle && selectedEle.className == 'placeholder')
				{
					id = selectedEle.id;
					id = id.replace('PL_', '');
					curDivID = id;
					obj = selectedEle.parentNode;
				}
				if (id && obj)
				{
					jQuery(d).html('');
					var nde = new CKEDITOR.dom.element( selectedEle );
					var rangeObjForSelection = new CKEDITOR.dom.range( editor.document );
					rangeObjForSelection.selectNodeContents( nde );
					//rangeObjForSelection.deleteContents();
					
					var dataToBeSent = 
						{ 
							bean: ajaxBeanName,
							method: 'renderItem',
							format : value,
							id: id,
							returnformat: 'html',
							async: true
											
					 	};				
					jQuery.when(					
						jQuery.post( ajaxComURL, 
									dataToBeSent, 
									null, 
									"json" )
	
					).always(function(itemData){		
						var html = itemData.responseText;
						var updHTML = '';
						//jQuery(d).html(html);
						try
						{
							outHTML = html;
							wraptag = formatsAssocArr[value];
							// <#wrapTag# contenteditable="false" class="placeholderWrapper" id="DIV_#curID#" onfocus="editor.plugins.listformat.checkListFormat(''#curFormat#'');">
							updHTML = '<' + wraptag + ' contenteditable="false" class="placeholderWrapper" id="DIV_' + curDivID + '" onfocus="editor.plugins.listformat.checkListFormat(\'' + value + '\');"><' + wraptag + ' class="placeholder" id="PL_' + curDivID + '" data-format="' + value + '">' + outHTML + '</' + wraptag + '></' + wraptag + '>';
					//		d.remove();
						}
						catch(e)
						{
							updHTML = '';
						}
						obj.outerHTML = updHTML;
						//jQuery(obj).replaceWith(updHTML);
 						//editor.insertHtml(updHTML);
						editor.fire( 'saveSnapshot' );
					});	
				}
			}		
		});
	}
});	


