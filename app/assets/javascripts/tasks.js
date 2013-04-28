
function sendToTurk() {

$(".edit_task").bind("ajax:success",function(evt,data,status,xhr) {
	var $form = $(this);
	alert ("form is" + $form);
	//$('.edit_task').bind('submit', function() {
	var act = $(".edit_task").attr('action');
	alert ("action "+ act);
	var portal = act;
	var mydata = $('.edit_task').serialize();
	var req = $.ajax({ 
		type: 'put',
		url: portal,
		data: mydata
	});

  req.done(function(response, ts, jqXHR) {
  alert ("ok, done! " + ts);
  //$(formtag).attr("action","http://workersandbox.mturk.com/mturk/externalSubmit");
  //$(formtag).submit(); 
  alert("type is" + $('.edit_task').attr("type"));
  $('.edit_task').attr("type", "post");
  $('.edit_task').attr("method","post");

  $('.edit_task').unbind('submit');
  $('.edit_task').attr("action","http://workersandbox.mturk.com/mturk/externalSubmit");
  $('.edit_task').submit();
  });
  req.fail(function(response, ts, error){
  alert("failed" +ts + error);
});

});
return false;
//});	
return;
}

function doClick() {
			var act = $(".edit_task").attr("action");
			alert ("put goes to " + act);
			$.ajax({
				type: 'PUT',
				url : act,
				data : $('.edit_task').serialize(),
				success : function(response) {
					$('.edit_task').html(response);
					//$('.edit_task').unbind('submit');
	            	alert("submmiting to mturk from edit");
	            	var ac = "http://workersandbox.mturk.com/mturk/externalSubmit";
	            	alert ("ac is" + ac);
	            	alert("calling mturk");
					$(".edit_task").attr("action", ac);
					$('.edit_task').submit();
			}
		});
		}