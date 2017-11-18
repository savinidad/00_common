// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
// HTTP utilities, CONTROLLER(?)
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// How to call a function on the server side
//	var args = {
//		name: 'dad',
//		pwd: 'hi',
//	};
//  sub is the string name of PERL sub which gets args as a hash
function ajax_sub_args(sub, args) {
	$.ajax({
		url: "app.cgi", 
		type: "POST",
		data: {
			sub: sub,
			args: JSON.stringify(args),
		},
		// .cgi is running sub, preparing result, then when it comes ret is 
		// already parsed into a javascript object (stringify it if you want to
		// see what you got)
		success: function(ret, status) { 
			$('#debug').prepend('POST ret:'+ret.msg+'\n');
			$('#debug').prepend('ret:'+JSON.stringify(ret)+'\n');
			execute_obj(ret);
		},
		error: function(xhr, status, error) {
			$('#debug').prepend('POST error:'+status+error+'\n');
		},
	});
}

// a mechanism for server to "call" javascript functions
function execute_obj(obj) { window[obj.function](obj.args); }

// historical
function ajax_post(dat) {
	$.ajax({
		url: "app.cgi", 
		type: "POST",
		data: dat,
		// .cgi is running sub, preparing result, then when it comes:
		success: function(ret, status) { 
			$("#login_msg").text("");
			$("#login_msg").prepend(ret.redirect);
			if (ret.pwd_check == "fail") {
				$("#login_msg").text(ret.msg);
			} else if (ret.pwd_check == "success") {
				if (ret.user == "admin") {
					$.mobile.changePage("#admin_page", {transition: "slideup"});
				// if a redirect is defined, take it
				} else if (
					(typeof ret.redirect != "undefined") &&
					(ret.redirect !== "") &&
					(ret.redirect !== null)) {
					window.location.assign(ret.redirect);
				//$.mobile.changePage("#users_page", {transition: "slideup"});
				} else {
					$("#login_msg").text("expected redirect, but here we are");
				}
			}
		},
		error: function(xhr, status, error) {
			http_error("Login Attempt  error:", error);
		},
	});
	// no matter what the outcome, clear the screen
	$("#login_msg").text("sent credentials, awaiting response");
	$("#login_user_txt").val(""); 
	$("#login_pwd_txt").val("");
}
// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
// HTML utilities, VIEW(?)
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// html table from table_id and table_data, array of hashes
// [
//	{
//		col_sort: ['name', 'hair', 'eyes'],
//	},
//	{name: 'jill', hair: 'brown', eyes: 'green'},
//	{name: 'mike', hair: 'brown', eyes: 'brown'},
//	{name: 'vicki', hair: 'brown', eyes: 'brown'},
// ]
function table_ah00(args) {
	var tbl = $("#"+args.table_id)[0];
	var ah = args.table_data;
	var col_sort = ah[0]['col_sort'];
	var head; var row; var cell; var i; var j; var data_row; var key;
	for (i = 1; i < ah.length; i++) {
		row = tbl.insertRow(-1);
		data_row = ah[i];
		for (j = 0; j < col_sort.length; j++) {
			cell = row.insertCell(-1);
			key = col_sort[j];
			if (data_row.hasOwnProperty(key)) {
				cell.innerHTML = data_row[key];
			}
		}
	}
	head = tbl.createTHead();
	row = head.insertRow(0);
	for (i = 0; i < col_sort.length; i++) {
		cell = row.insertCell(-1);
		cell.innerHTML = col_sort[i];
	}
}
function table_hash(table_id, dat) {
	var row;
	var col;
	var cell;
	var i; var j;
	var table = document.getElementById(table_id);
	table.innerHTML = "";
	var datx = {
		_headers: ['Name', 'Login', 'Color'],
		_keys: ['name', 'login', 'color'],
		_data: [
			{name:"mom", login:"1200", color:"green"},
			{name:"dad", login:"800",  color:"red"},
		],
	};
	if ("_headers" in dat) {
		var header = table.createTHead();
		row = header.insertRow(0);     
		for (j = 0; j < dat._headers.length; j++) {
			cell = row.insertCell(-1);
        	cell.innerHTML = dat._headers[j];
		}
	}
	for (i = 0; i < dat._data.length; i++) {
		row = table.insertRow(-1);
		for (j = 0; j < dat._keys.length; j++) {
			cell = row.insertCell(-1);
			cell.innerHTML = dat._data[i][dat._keys[j]];
		}
	}
}
