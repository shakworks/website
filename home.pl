#!/usr/bin/perl -w
use strict;
use Template;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use URI;
use XML::Simple;
use HTML::Entities;
use lib qw(perlScript);

use perlScript::MyModules;
my $cgi = CGI->new();
print $cgi->header();

my @verses = MyModules::returnVerse();#print @verses;
my @recent = MyModules::getLatestUpdates();# recent updates

my $link = $cgi->param("link") || "";

my $name = lc($cgi->param("name"));
my $link1 = $link.$name;

my $name1 = $name;
$name1 =~ s/_/ /g;
#print "$name\n";

my %fileContent = MyModules::getFileContents($link, $name);#295c
my %getRelatedLink;
if ($name =~ m#^index#i) {

}elsif ($link =~ m#^Bible#i){
	%getRelatedLink = MyModules::getRealtedlinks($link);	
}
elsif($link =~ m#^295c#i){
	if($link =~ m#^295c\/victims#){
	$link = "295c/victims";
	
	%getRelatedLink = MyModules::getRealtedlinks($link);
	}else{
	$link = $link . "/victims";
	%getRelatedLink = MyModules::getRealtedlinks($link);
	}	
}

my $authorname = $fileContent{'authorName'};

		$authorname =~ s/_/ /mg; 

#		 $hash{'Page_name'}      = $name;
#                $hash{'file_toolTips'}  = $$ref{'file_toolTips'};
#                $hash{'content'}        = $$ref{'content'};
#                $hash{'keywords'}       = $$ref{'keywords'};
#                $hash{'description'}     = $$ref{'description'};
my $xml = XML::Simple->new();
#news From ChristianInPakistan.com
my $a = $xml->XMLin("perlScript/NewsXML/christinpak.xml");
my $news1 = $a->{news};
#news From PakistanChristianPost.com persecution.xml
$a = $xml->XMLin("perlScript/NewsXML/pakchristpost.xml");
my $news2 = $a->{news};
#news From Persecution.com
$a = $xml->XMLin("perlScript/NewsXML/persecution.xml");
my $news3 = $a->{news};


my $tt = Template->new({INCLUDE_PATH => "tt/",
						PRE_PROCESS=>"header.tt",
						POST_PROCESS=> "footer.tt"});
my $input = "firstIndex.tt";
my $vars = {
    heads 			=> "this is the header",
    topVerses 		=> \@verses,
    presentName		=> $name1,
    title			=> $fileContent{'file_toolTips'},
    content			=> decode_entities($fileContent{'content'}),
	author			=> $authorname,
	aboutauthor		=> decode_entities($fileContent{'authorDetail'}),
    keywords		=> $fileContent{'keywords'},
    description		=> $fileContent{'description'},
    moreLinks		=> \%getRelatedLink,
	news1           => \@$news1,
    news2           => \@$news2,
    news3           => \@$news3,
	recent			=> \@recent,# recent updates
};
#my $p =
$tt->process($input, $vars) || die print $tt->error();
