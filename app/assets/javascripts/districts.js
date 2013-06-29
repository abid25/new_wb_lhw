if ($('#districts_controller').length)
{	
	if ($('.indicators_report_action').length || $('.indicators_report_by_people_action').length)
	{
		console.log ("Districts - District Visitors Reports");	
		
		var loading_functions = new Object();
		loading_functions["Barchart"] = new Object();
		loading_functions["Trend"] = new Object();
		var preloading_functions = new Object();
		var current_visualization = "ReportingBirthDeath_live_births";
		var current_visualization_type = "Barchart";
	
		$(document).ready(function() 
		{
			indicator_script()
			apply_indicators_datatable()
		})
	}
	
	if ($('.compliance_report_action').length)
	{
		console.log ("Districts - District Compliance Reports");
		var loading_functions = new Object();
		var preloading_functions = new Object();
		var map_reload = 1;
		var current_visualization = "total_compliance_barchart";
		var current_visualization_type = "barchart"
					
		$(document).ready(function() 
		{
			$("#color-legend").popover
			(
				{
					placement: 'left',
					content: color_legend()
				} 
			); 
		
			Gmaps.map.callback = function() 
			{			  
				create_entries_legend();
			}
			
			
			preloading_functions[current_visualization_type]();
			loading_functions[current_visualization]();
			
			$("#total_compliance_barchart_link").click(function () 
			{
				current_visualization = "total_compliance_barchart";
				
				if (current_visualization_type != "barchart")
				{
					current_visualization_type = "barchart";
					preloading_functions[current_visualization_type]();
				}
								
				loading_functions[current_visualization]();
				$("#help_bar").html(
					"This chart displays a <strong>snap-shot view</strong> of the <strong>total number of phone entries submitted</strong> by officers of the district as a <strong>percentage of the total number of phone entries expected</strong> from them (compliance). A <strong>better compliance percentage</strong> shows that an officer is achieving <strong>a quantitatively higher standard</strong> in their phone-based reporting/monitoring activities."
				);
				$("#visualization_selector").html($("#total_compliance_barchart_link").html()+"<span class=\"caret\"></span>");
				$("#visualization_type").html("Overall Barchart - Compliance Report");
			});
			
			apply_compliance_datatable()
		});
	}
}