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
use CGI::Pretty ':standard';
	$CGI::Pretty::INDENT = "  ";
use CGI::Carp qw(fatalsToBrowser);	# helps with debug!


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# main
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
my $q = CGI->new();

print $q->header();
print $q->start_html('dad home cgi');
print "plain text hello out there<br><br>\n";
print "this is a html5/cgi play-space I've started at <br>
~/Sites/00_common/app.cgi\n"; 

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# cgi: this is done on the server side
# put out a simple text box and submit button
print
	"<hr>\n",
	start_form(),
	# a submit button
	submit('Action','test_submit'),
	# text field with leading label
	" touched within ", 
	textfield(-name => 'test_text', -size => 3, -default => "pica"),
	end_form,
	"<hr>\n",
;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# cgi
# do a simple calculate on the input
if (defined param(test_text)) {
	printf "found %s in the box<br>\n", param(test_text);
}

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

print "<hr>\nsome javascript goodies<br>\n";
print '<button type="button" onclick="textToCanvas()">hi on canvas</button>';



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# play around with some html5
print "<hr>\n";


print $q->end_html();

__DATA__


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
