# Sav cgi is intended to bring together all the standard http and html
# functions of PERL's cgi module and augment all that with my very own
# simple web app ideas, all in the name of creating simple web apps!
package Scgi;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw();
@EXPORT = qw(
	div header p pre a input textfield password_field button table Tr th td
	h3 br
	p_red button00 
	cgi_parse view_if_login_cgi
	html_head_body
	obs_register obs_delete send_obs_dat 
	sse_header sse_dat sse_json
	cgi_rt00
);
use CGI::Pretty ':standard';
	$CGI::Pretty::INDENT = "  ";
use CGI::Cookie;
use JSON;
use Sutil;
use Data::Dumper;

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# 2014-05-12
# The flexibility of writing directly in HTML is nice, but the price is noisy
# text, prone to errors.  My intent in this module is to add one layer of
# machine intelligence which will get the syntax right, remove 90% of the
# syntax in the input text, and create a space where new ideas for generating
# HTML can easily be added.  For example, there are many ways I may want to
# express an Array-of-Hashes (with titles, without, ...) without reverting to
# writing in HTML - so I can create some small number of methods for this
# conversion and get the benefits of the the machine assist for creating my
# HTML, the consistency of machine assist, and the flexibility of PERL
# programming when I wish to create a slightly different HTML output.
#
# PERL goodies related to this challenge:
# call a PERL sub within a string like so:  "hi ${string_gen(args)} dad"
#   where string_gen(args) returns a string reference, as in: \"my"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# PERL data => HTML
# A collection of methods for transforming PERL data to HTML strings.  In my
# view, this is the necessary "structure" that HTML begs for, but in no way
# enforces.  
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# fundamental Array of Arrays => <table>
sub aa {
	my ($aa) = @_;
	return table(
		join "", map { 
			my $row = $_; 
			TR( join "", map { td($_) } @$row);
		} @$aa
	);
}
sub aa_alt {
	my ($aa) = @_;
	return table( {-class => "alt"},
		join "", map { 
			my $row = $_; 
			TR( join "", map { td($_) } @$row);
		} @$aa
	);
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# HTML
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub button00 {
	my ($name) = @_;
	button(
		{
			id => 		$name . "_btn", 
			value =>	$name,
			onclick => 	$name . "_btn_click()",
		}, 
	);
}

# my favorite a href= and img src= combo, clickable images
sub aimg {
	my ($link) = @_;
	my ($out);
	$out = <<END;
<a href="$link" target="_blank">
<img src="$link" width="500px"></a>
END
	return $out;
}
# the most basic hyperlink
sub aref {
	my ($url, $text) = @_;
	unless (defined $text) { $text = $url; }
	return "<a href=\"$url\">$text</a>";
}
sub arefb {		# and the special case, on a new tab
	my ($url, $text) = @_;
	return a({href => $url, target => "_blank"}, $text);
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# HTTP
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# dad's apps, data exchange reminders
# 
# # to siimplify the POST data parser, I'll support a sub(args) pair and
# # let PERL do the "routing" via symbol table
# $.ajax({url:"foo", type:"POST", 
# 	data:
#		{ from:"foo", msg:"bar", sub:"cli", args:"user" }
# })
#
# $cgi = {
#	params => 
#		{ from => "foo", msg => "bar" }
# }
# 
# sub execute_and_respond_cgi calls sub btn_click 
# $ret = {
#	msg => "hi dad",
#	center => 5,
# }
#
# $.ajax({success: function(ret, status) {
# ret = {
#	msg: "hi dad",
#	center: 5,
# }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

sub html_head_body {
	my $cgi = shift;
	my $args = shift;
	header(
		-type => "text/html", 
		-charset => "utf-8",
		-status => "200 OK",
		-cookie => bake_cookies_cgi($cgi),
	),
	start_html(
		-title => $args->{title},
		-encoding => "utf-8",
		# meta tag to ensure proper rendering and touch zooming
		-meta => { 
			viewport => 
				"user-scalable=no,width=device-width,initial-scale=1.0", 
			content => "text/html",
		},
		-style => [
			(@{$args->{style}}),
		],
		-script => [
			{src => "http://code.jquery.com/jquery-1.11.3.min.js"},
			(@{$args->{script}}),
		],
	),
	@_,	# @_ is the whole page
	end_html,
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# given $cgi, make a cookie of all its cookies, to send back to browser
#   in this way, app can add or remove from $cgi->{cookies} to control cookie
sub bake_cookies_cgi {
	my ($cgi) = @_;
	my ($count, $cs, $c, $name, $value);
	# return one cookie, or an array ref
	$count = (scalar keys %{$cgi->{cookies}});
	if ($count == 0) {
		$c = cookie(
			-name => 'dummy_cookie_name',
			-value => 'dummy_cookie_value',
		);	
		push(@$cs, $c);		# otherwise, construct a list of cookies
	} else {
		for $name (keys %{$cgi->{cookies}}) {
			$c = cookie(
				-name => $name,
				-value => $cgi->{cookies}{$name},
				#-expires => '+1h',
			);	
			push(@$cs, $c);		# otherwise, construct a list of cookies
		}
	}
	return $cs;
}

# streamline some details of PERL CGI/http experience
sub cgi_parse {
	my $cgi;
	# depending upon the client IP, set the best server IP
	if (remote_host() =~ /192.168|::1/) {
		$cgi->{server_addr} = qx(ipconfig getifaddr en0);
		chomp $cgi->{server_addr};
		$cgi->{server_addr} .= ':8864';
	} 
	# uverse: find current from router 192.168.1.254
	else {
		$cgi->{server_addr} = '45.28.143.191:8864';
	}
	# http request
	if (request_method() =~ /POST|GET/) {
		$cgi->{request_method} = request_method();
		$cgi->{remote_host} = remote_host();
		$cgi->{remote_addr} = remote_addr();
		$cgi->{url} = url();
		$cgi->{url_base} = url(-base => 1);
		# gather cookie value using cookie(name)
		# alternates: %cookies = CGI::Cookie->fetch;
		# note: only the value is available, the expiration and path are 
		#	write-only and sent as part of the HTTP header
		map { $cgi->{cookies}{$_} = cookie($_) } cookie();
		# gather both URL and POST params like this
		map { $cgi->{params}{$_} = param($_) } param();
	} 
	# user on the CLI, map key:val pairs into params
	else {	
		$cgi->{request_method} = 'cli';
		$cgi->{params} = hash_str_arr(@ARGV);
	}
	#note "$0  cgi_parse"; note (Dumper $cgi);
	note sprintf("%s %s %s", $0, "cgi_parse", $cgi->{request_method});
	return $cgi;
}

# called by the SSE proc
sub obs_register {
	my ($cgi) = @_;
	my ($app);
	# 2017-05-27 I demonstrated that one fifo can have multiple readers,
	# and that these readers race to read the data written to the FIFO, 
	# and that only one will get each line written, and they co-exist
	# without any other apparent problem.
	my $user = $cgi->{cookies}{user};
	note("obs_register: about to register user:$user");

	# atomic operation on app.dat, gives me exclusive on all FIFOs too
	rmw_file('app.dat', $app, sub {
		# if this overwrites a zombie user, no problem, that zombie
		# will leave the new entry alone
		if (defined $app->{observers}{$user}) {
			note("new proc for user:$user old:" . 
			$app->{observers}{$user} . "new:$$");
		}
		$app->{observers}{$user} = $$;	# process ID stored per user
		if (-p $user) {
			# no problem, as of 2017-07-27 I leave fifo hanging around
		} else {
			qx(mkfifo -m 0666 $user);
		}
	});
	note("obs_register: added user:$user");
}
# 2017-05-28 let each process manage its existence as observer
sub obs_delete {
	my ($cgi) = @_;
	my ($app, $user);
	$user = $cgi->{cookies}{user};
	rmw_file('app.dat', $app, sub {
		# if I am the active process, delete everything,
		# but if I'm not the active process, go away silently!
		if ((defined $app->{observers}{$user}) &&
			($app->{observers}{$user} eq $$)) {
			note("obs_delete removing user:$user proc:".
				$app->{observers}{$user});
			delete $app->{observers}{$user};
		}
	});
}
# Finally, one table that summarizes pipe behavior, at bottom of entry
# http://unix.stackexchange.com/questions/81763/problem-with-pipes-pipe-terminates-when-reader-done
# send_obs_dat presumes a lock on app.dat, so FIFOs need no lock
sub send_obs_dat {
	my ($dat, $ob) = @_;
	my ($app, $user, $fifo_fh, $obs);
	# if an observer is passed, just him, else send to all observers
	if (defined $ob) { 
		@$obs = ($ob);
	} else {
		rd_file('app.dat', $app);
		@$obs = keys %{$app->{observers}};
	}
	for $user (@$obs) {
		# protect against a zombie observer no longer reading fifo
		# fifo open blocks until a listener is open
		# the alarm will cause a waiting open to return fail
		# 2017-07-26 I'm only seeing sigpipe, never an open fail
		alarm 1; $alarm = "timeout waiting to open fifo user:$user for wr";
		if ((-p $user) && (open($fifo_fh, ">", $user))) {
			alarm 0; $alarm = "";
			print $fifo_fh encode_json($dat);	# format and send the data
			print $fifo_fh "\n";
			close $fifo_fh;
		} else {
			if (-p $user) {
				note("send_obs_dat: fifo open failed:$! user:$user");
			} else {
				note("send_obs_dat: fifo missing for user:$user");
			}
		}
	}
}
sub sse_header {
	select((select(STDOUT), $|=1)[0]);      # works, alone
	print "Content-Type: text/event-stream\n\n";
}
# distribute data or json to the listeners in the browser
sub sse_dat {
	my ($dat) = @_;
	sse_json(encode_json($dat));
}
sub sse_json {
	my ($json) = @_;
	select((select(STDOUT), $|=1)[0]);      # works, alone
	print (
		"data: ",
		$json,
		"\n\n",
	);
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# router
sub execute_and_respond_cgi {
	my ($cgi) = @_;
	my ($sub, $args, $ret);
	note ($0, "execute_and_respond_cgi", $cgi->{params}{sub});
	# look for element "sub" and call it, return the results
	if (
		(defined ($sub = $cgi->{params}{'sub'})) &&
		(defined &{"main::$sub"})
	) {
		$args = decode_json $cgi->{params}{args};
		$ret = &{"main::$sub"}($args);
	}
	print 
		header(
			-type => "application/json", 
			-status => "200 OK",
			-cookie => bake_cookies_cgi($cgi),
		),
		encode_json($ret),
	;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# controller support
# apps ask this logic to verify login and respond with page view
sub view_if_login_cgi {
	my ($cgi) = @_;
	note sprintf("%s %s %s", $0, "view_if_login_cgi", $cgi->{request_method});
	note (Dumper $cgi->{cookies});
	# if login is complete, just proceed with page view
	if (defined $cgi->{cookies}{user}) {
		print &{"main::view"}($cgi);
	} 
	# if this is a login in progress, offer the login page
	elsif ($0 =~ /15_login/) {
		print &{"main::view"}($cgi);
	}
	# if this is a request for some page and login is incomplete, redirect
	else {
		$cgi->{cookies}{page_redirect} = $cgi->{url};
		# note this only works on a GET
		note_and_print redirect($cgi, "Login Required", 
			'http://' . $cgi->{server_addr} . '/~dad/15_login/app.cgi');
	}
}
# the following only works with a GET
# ajax does not support redirect header, stackoverflow 199099
sub redirect {
	my ($cgi, $message, $url) = @_;
	header(
		-type => "HTTP/1.1 302 $message", 
		-location => $url,
		-cookie => bake_cookies_cgi($cgi),
	);
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# my most basic controller
sub cgi_controller00 {
	my ($cgi) = @_;
	if ($cgi->{request_method} eq 'GET') {
		view_if_login_cgi($cgi);
	} elsif ($cgi->{request_method} eq 'POST') {
		execute_and_respond_cgi($cgi);
	} elsif ($cgi->{request_method} eq 'cli') {
		print main::view();
	}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# my CGI router
sub cgi_rt00 {
	my ($cgi) = cgi_parse();
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# GET
	# assume the user wants to get started, script can use the sub "view" to 
	# put out the initial HTML, and can also put a little router in there to 
	# further parse the CGI parameters it gets
	if ($cgi->{request_method} eq 'GET') {
		print main::view($cgi);
	} 
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# POST
	# assume the user wants to call a sub with args, do so if the sub exists, 
	# else hand it all off to a sub called post where a user might just put
	# his own little router
	elsif ($cgi->{request_method} eq 'POST') {
		note("POST");
		execute_and_respond_cgi($cgi);
	} 
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# CLI
	# a debug entrance where user is calling by command line 
	# default action: print the "view" to the 
	elsif ($cgi->{request_method} eq 'cli') {
		print main::view($cgi);
	}
}

"bye dad";
