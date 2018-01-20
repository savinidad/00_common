// automatically referenced by button00, just click on button element 
// that has the id='date'
function date_btn_click() {
	// calling server sub up_date
	ajax_sub_args('up_date', {});
	// see app.cgi, server responds by calling function up_date, below
}

// the server can call this function
function up_date(args){
	$("#server_date").html(args.date);
	$("#server_date").append('<br><hr>');
	$("#server_date").append(Date());
}
