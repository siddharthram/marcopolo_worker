$(document).ready(function(){
alert("Doc is ready!"+ $('#edit_task'));
$(".edit_task").bind("ajax:success",function(evt,data,status,xhr) {
	var $form = $(this);
	alert ("form is" + $form);
	$form.bind('submit', function() {
	var act = $(".edit_task").attr('action');
	alert ("action "+ act);
	var portal = "http://ximly.herokuapp.com" + act;
	var data = $('.edit_task').serialize();
	$.ajax({ 
		type: 'PUT',
		url: portal,
		data: data
	});
  req.done(function(response, ts, jqXHR) {
  alert ("ok, done! " + response);
  //$(formtag).attr("action","http://workersandbox.mturk.com/mturk/externalSubmit");
  //$(formtag).submit(); 
  $('.edit_task').unbind('submit');
  $('.edit_task').attr("action","http://workersandbox.mturk.com/mturk/externalSubmit");
  $('.edit_task').submit();
  });
  req.fail(function(response, ts, error){
  alert("failed" +ts + error);
});

});
return false;
});	
return;
});