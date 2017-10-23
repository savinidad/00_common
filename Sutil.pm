# utility functions for all
# possibly not portable, be careful to respect local needs and
# restrictions: einstein vs. hw-lnx-shell8 for example
package Sutil;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw();
@EXPORT = qw(
	rd_file wr_file rmw_file txt_file 
	note note_and_print
	hash_str_arr hash_db
	date_x date_int_x
);

use Data::Dumper;
use Path::Tiny;
use Fcntl qw(:flock);
use Time::Local;

# primitive debug log
sub note {
	local $| = 1;
	open(OUT, ">>", "notes.txt");
	print OUT "\n", date_x(), "  ";
	print OUT (@_);
	close OUT;
}
sub note_and_print {
	local $| = 1;
	open(OUT, ">>", "notes.txt");
	print OUT "\n", date_x(), "  ";
	print OUT (@_);
	close OUT;
	print (@_);
}

# protected file reading and writing, poor man's SQL
sub rd_file {
	my ($filename, $dat) = @_;
	$_[1] = eval path($filename)->slurp;
}
sub wr_file {
	my ($filename, $dat) = @_;
	unless (-e $filename) {
		qx(cat "hi dad" > $filename);
		qx(chmod a+rw $filename);
	}
	# path($filename)->spew(Dumper $dat);	# changes file permissions, pain
	# instead, truncate and re-write the existing file
	path($filename)->append({truncate => 1}, (Dumper $dat));
}
# read a file, $do some operation, write the result, all atomic
# the caller owns $dat, and thus can access the final state of the file
# http://www.perlmonks.org/?node_id=7058
# http://www.perlmonks.org/?node_id=1139901
# http://stackoverflow.com/questions/34920/how-do-i-lock-a-file-in-perl
sub rmw_file {
	my ($filename, $dat, $do) = @_;
	my ($rmw_fh);
	open($rmw_fh, '+<', $filename) or warn "rmw_file failed open\n"; 
	local $/ = undef;	# slurp mode
	flock($rmw_fh, 2);	# waits for exclusive lock opportunity
    $_[1] = eval(<$rmw_fh>);	# set the referenced $dat from caller
	seek($rmw_fh, 0, 0); truncate($rmw_fh, 0);	# erase file, back up to 0
	&$do($_[1]);					# run the caller's code
	print $rmw_fh (Dumper $_[1]);	# write the updated data to the file
	close($rmw_fh);				# close removes the lock
}
# return content of a file as text
sub txt_file {
	my ($file) = @_;
	return path($file)->slurp;
}

# array of strings "key:val" in, hash out
sub hash_str_arr {
	my $hash = {};
	for (@_) {
		if (/(\w+):(\w+)/) { $hash->{$1} = $2; }
		elsif (defined $hash->{_other}) {
			$hash->{_other} .= " $_";
		} else {
			$hash->{_other} = $_;
		}
	}
	return $hash;
}
# return a hash from a db
# assumes every rec has a unique _key
sub hash_db {
	my ($db) = @_;
	my ($hash, $rec);
	for $rec (@$db) {
		$hash->{$rec->{_key}} = $rec;
	}
	return $hash;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# date and time tools, put in raggedy text, get a nice date string or int
# massage the inputs for Date::Parse:
#   messages-style date_time, year
#   messages-style date_time
#   none, returns current time
#   resolve the year, which may not be provided
sub date_x {
	my ($date_time, $year_in) = @_;
	my ($out);
	my ($sec, $min, $hour, $mday, $month, $year) = _find_date_x(@_);
	$out = sprintf "%s-%02s-%02s", $year, $month, $mday;
	if ((defined $hour) and (defined $min)) { 
		$out .= sprintf ".%02d%02d", $hour, $min; 
	}
	if (defined $sec) {
		$out .= sprintf "%02d", $sec;
	}
	return $out;
}
# return date and time integer given a date in several formats, Jan 1, 1900
sub date_int_x {
	my ($sec, $min, $hour, $mday, $month, $year) = _find_date_x(@_);
	return timelocal($sec, $min, $hour, $mday, $month-1, $year-1900);
}
# this is internal only
# find the date and massage it
#   returns month and year in human format, not 0-11 and 1900
sub _find_date_x {
	my ($date_time, $year_in) = @_;
	my ($sec, $min, $hour, $mday, $month, $year, $out);
	# if no value is passed in, return "now"
	if (not defined $date_time) { 
		($sec, $min, $hour, $mday, $month, $year) = localtime(time);
		$month += 1;
		$year += 1900;
	}
	# those that strptime can handle
	# when month is a number, strptime demands seconds, barf
	elsif (($date_time =~ /(\w+ \d+, \d+)/) or
		# > show log format, lists log files: blah... Jul  9 20:50
		($date_time =~ /(\w\w\w\s+\d\d?\s+\d\d:\d\d(:\d\d)?)/) or
		($date_time =~ /(\d+\/\d+\/\d+)/)) {
			$date_time =~ s/ at / /;	 # strptime chokes on "at"
		($sec, $min, $hour, $mday, $month, $year) = strptime($1);
		$month += 1;
		if ($year) { $year += 1900; }
		elsif ($year_in) { $year = $year_in; }
		else { $year = 1900 + (localtime(time))[5]; }
	}
	# router reservation format: 2012-07-15 14:55
	elsif ($date_time =~ /(\d\d\d\d)-(\d\d)-(\d\d)\s+(\d\d):(\d\d):?(\d\d)?/) {
			($sec, $min, $hour, $mday, $month, $year) = ($6, $5, $4, $3, $2, $1);
	}
	# savini format: 2012-07-15.1455
	elsif ($date_time =~ /(\d\d\d\d)-(\d\d)-(\d\d).?(\d\d)?(\d\d)?(\d\d)?/) {
			($sec, $min, $hour, $mday, $month, $year) = ($6, $5, $4, $3, $2, $1);
	}
	else {
			($sec, $min, $hour, $mday, $month, $year) = (0, 0, 0, 8, 9, 1963);
	}
	return ($sec, $min, $hour, $mday, $month, $year);
}

# compact a hash
sub str_h {
	my ($h) = @_;
	my ($str);
	for (sort keys %$h) {
		$str .= sprintf "%s:%s ", $_, $h->{$_};
	}
	return $str;
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# db functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# given two hash arrays, marry them according to the key 
sub marry_dat_dat_key {
	my ($data, $datb, $key) = @_;
	my ($ha, $hb, $hc, $rec, $keys, $dat);
	for $rec (@$data) { $ha->{$rec->{$key}} = $rec; $keys->{$rec->{$key}} = 1; }
	for $rec (@$datb) { $hb->{$rec->{$key}} = $rec; $keys->{$rec->{$key}} = 1; }
	local ($^W) = 0;	# disable the uninitialized warning
	for $key (keys %$keys) {
		%$hc = (%{$ha->{$key}}, %{$hb->{$key}});
		push(@$dat, $hc); $hc = +{};
	}
	return $dat;
}

# assuming a space-delimited string representing a list, merge in a potentially
# redundant entry
sub list_merge {
	my ($list, $new) = @_;
	my ($hash);
	# uniq, basically
	map {$hash->{$_} = 1} split(" ", join(" ", $list, $new));
	return join(" ", sort keys %$hash);
}

'bye dad';
