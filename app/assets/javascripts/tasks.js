
function sendToTurk() {

$(".edit_task").bind("ajax:success",function(evt,data,status,xhr) {
	var $form = $(this);
	var act = $(".edit_task").attr('action');
	var portal = act;
	var mydata = $('.edit_task').serialize();
	var req = $.ajax({ 
		type: 'put',
		url: portal,
		data: mydata
	});

  req.done(function(response, ts, jqXHR) {
  $('.edit_task').attr("type", "post");
  $('.edit_task').attr("method","post");
  $('.edit_task').unbind('submit');
  $('.edit_task').attr("action","http://workersandbox.mturk.com/mturk/externalSubmit");
  $('.edit_task').submit();

  });


  req.fail(function(response, ts, error){
});

return false;
});
}

