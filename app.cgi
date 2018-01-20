#!/usr/bin/perl
# I want this to reflect the current state of my art: apps made easy!

BEGIN {
	use warnings;
	use strict;
	use lib "/Users/dad/Sites/00_common";	# works on einstein!
	use Scgi;
	use Sutil;
}
# turn on basic cgi; also puts methods in "main" space
#use CGI::Pretty ':standard';
	#$CGI::Pretty::INDENT = "  ";
#use CGI::Carp qw(fatalsToBrowser);	# helps with debug!

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# Model
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# called when date button is pressed
sub up_date {
	{function => 'up_date', args => {date => date_x()}};
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# View
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub view {
	my ($cgi) = @_;
	# returns a page of html, ready to go
	html_head_body(
		$cgi,
		# elements of html head
		{
			title => 'app_test', 
			# an array of CSS references or strings
			style => [
				{src => 'app.css'},
				{code => '
					h3 {
						font-family: sans-serif;
					}
				'},
			],
			# an array of javascript references or strings
			script => [
				{src => 'app.js'},
			],
		},
		# a few ways to write the html part
		h3('hi dad'),
		'<h3>yo dude</h3>',
		div_local_server_time(),
		div_cgi($cgi),
	);
}

# build a simple div
sub div_cgi {
	my ($cgi) = @_;
	use Data::Dumper;
	div(
		pre(
			Dumper $cgi,
		),
	),
}

# offer a little button to show browser and server calls
sub div_local_server_time {
	div(
		{ style => '
				color:red;
				background-color:#20FFFF;
				width:20em;
				height:100px;
		'},
		button00('date'),	# inserts a button, defines _btn_onclick()
		p({id => 'server_date'}, date_x()),
	),
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# main
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cgi_rt00();

__DATA__

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# javascript
print <<END;
<canvas id="myCanvas" onclick="textToCanvas()"></canvas>
<script type="text/javascript">
function textToCanvas()
{
	var ctx=document.getElementById('myCanvas').getContext('2d');
	ctx.font="20px Georgia";
	ctx.fillStyle='#FFFF00';
	ctx.fillRect(10,50,10,10);
	ctx.fillStyle='#FFF000';
	ctx.fillRect(0,0,70,90);
	ctx.fillStyle='#FFFF00';
	ctx.fillText("finally",10,50);
	ctx.fillRect(10,50,10,10);
}
var canvas=document.getElementById('myCanvas');
var ctx=canvas.getContext('2d');
ctx.fillStyle='#FF0000';
ctx.fillRect(0,0,80,100);
</script>
END

#!/usr/local/bin/perl
##!/volume/perl/5.8.8/bin/perl
BEGIN {
	use lib qw(/homes/msavini/libperl/lib/perl5/site_perl);
	use CGI::Pretty ':standard';
		$CGI::Pretty::INDENT = "  ";
	use CGI::Carp qw(fatalsToBrowser);	# helps with debug!
	use Data::Dumper;
	use HtmlPerl;
	use Http;	# my HTTP parser and router
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# Model
sub get_data_btn_click {
	my ($args) = @_;
	my $ah = [
		{col_sort => ['name', 'hair', 'eyes'], },
		{name => 'jill', hair => 'brown', eyes => 'green'},
		{name => 'mike', hair => 'brown', eyes => 'brown'},
		{name => 'vicki', hair => 'brown', eyes => 'hazel'},
	];
	push $ah, {name => $args->{name}, hair => $args->{pwd}, eyes => 'red'};
	return {
		msg => 'almost there',
		function => 'table_ah00',
		args => {
			table_id => 'kids',
			table_data => $ah,
		},
	};
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# View
sub view {
	print 
		header,
		start_html({
			title => 'app_test', 
			#style => '../000_Universal_Notes_and_Tools/mvc/css/notes.css',
			style => './notes.css',
			script => [
				{ src => 
	'https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js' },
				{ src => 'notes.js' },
			],
		}),
		playground(),
		end_html,
	;
}
sub playground {
		div(
			button00('yo'),
			button00('get_data'),
			table({id => 'kids', class => 't00'}, TR()),
			pre({id => 'debug'}, qx(which perl)),
		),
		div(
		),
}
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# main
cgi_rt00();		# my CGI router, Http.pm
