
jQuery(function($) {
	$('[data-btn-ec2-action="stop-instance"]').each(function() {
		$(this).click(function() {
			var instanceId = $(this).data('ec2InstanceId');
			var url = "/ec2/control/stop/" + instanceId;
			location.href = url;
		});
	});

});

