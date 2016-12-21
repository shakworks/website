#!perl! -w
use strict;
use lib("/home/apakista/perl");
use lib "perlScript";
use LWP::UserAgent;
use HTML::TreeBuilder;
use HTML::TableExtract;
use Try::Tiny;
use MIME::Lite;
use Email::Simple;
use Email::Simple::Creator;
use Email::Sender::Simple qw(sendmail);
my @list = "";
######Persecution.org#########
try{
    @list = &Persecution();
    &persecute(@list);
}catch {
    warn "caught error: $_"; # not $@
    my @array = ("persecute", $_);
    sendEmail(@array);
};
sub persecute{
    my @s =  @_;
    open PERSE, ">" ,"/home/NewsXML/persecution.xml" or die "Cannot open File \n $!";
    print PERSE '<?xml version="1.0" encoding="UTF-8"?> <persecution>';
    foreach(@s){print PERSE "<news>\n<![CDATA[ $_ ]]>\n</news>\n";}
    print PERSE "</persecution>\n";
    close PERSE;
}
sub Persecution(){
    my $link = "http://www.persecution.org/?s=pakistan&x=0&y=0";
    my $linkspage = &browz($link);
    my $links = HTML::TreeBuilder->new();
    $links->parse($linkspage);
    $links->eof;
    my @Nlinks;
    #$links->dump;
    my @link = $links->look_down("_tag" , "h3");
    my $counter = 1;
    foreach my $node (@link) {
        last  if $counter > 5;
        my @kids = $node->content_list( );
        for my $a(@kids){
        no warnings 'uninitialized';
            if (@kids and ref $kids[$b] and $kids[$b]->tag( ) eq 'a') {
                my $c = $kids[$b]->attr("href" );
                #print $c;
                #print "$counter\n-- " . $kids[$b]->as_text  . "   --\n";
                my $a = "<a href='" . $kids[$b]->attr("href" ) . "' title='" . $kids[$b]->as_text . "'>" . $kids[$b]->as_text . "</a>";
                #print $a;
                #print PERSE "<news>\n<![CDATA[ $a ]]>\n</news>\n";
                push @Nlinks, $a;
                $counter++;  
             }
         }
    }
    return @Nlinks;
}


#######PakistanChristianPost#############
try{
    @list = &PakistanChristianPost();
    &chirsitianPost(@list);
}catch {
    warn "caught error: $_"; # not $@
    my @array = ("christianPost", $_);
    sendEmail(@array);
};
sub chirsitianPost{
    my @s = @_;
open PAKPOST, ">" ,"/home/NewsXML/pakchristpost.xml" or die "Cannot open File \n $!";
print PAKPOST '<?xml version="1.0" encoding="UTF-8"?> <pakchristpost>';
foreach(@s){print PAKPOST "<news>\n<![CDATA[ $_ ]]>\n</news>\n";}
print PAKPOST "</pakchristpost>\n";
close PAKPOST;
}
sub PakistanChristianPost(){
    my @array;
  my $file = &browz("http://pakistanchristianpost.com/news.php");
  my ($urlLink, $newsTitle);
  my $newExt = HTML::TableExtract->new(depth => 6, count => 0, keep_html=>1);
  $newExt->parse($file);
  foreach my $ts ($newExt->tables) {
    foreach my $row ($ts->rows) {
      my ($newslink) = @$row;
        if (! defined $newslink){}
        elsif ($newslink =~ m!<a href="(.*)">(.*)</a>!){
            $urlLink   = "http://pakistanchristianpost.com/".$1;
            $newsTitle = $2;
            my $n = "<a href=\"$urlLink\" title=\"$newsTitle\" target=\"_blank\">$newsTitle</a>";;
            #print PAKPOST "<news>\n<![CDATA[ $n ]]>\n</news>\n";
            push @array, "<a href=\"$urlLink\" title=\"$newsTitle\" target=\"_blank\">$newsTitle</a>";
        }
    }
  }
  return @array;
}

######Christians in Pakistan##########
try{
    @list = &ChristiansInPakistan();
    &pakchirstians(@list);
}catch {
    warn "caught error: $_"; # not $@
    my @array = ("apakchristian", $_);
    sendEmail(@array);
};
sub pakchirstians{
    	my @s = @_;
	open CHRISTinPAK, ">" ,"/home/NewsXML/christinpak.xml" or die "Cannot open File \n $!";
	print CHRISTinPAK '<?xml version="1.0" encoding="UTF-8"?> <christinpak>';
	foreach(@s){print CHRISTinPAK "<news>\n<![CDATA[ $_ ]]>\n</news>\n";}
	print CHRISTinPAK "</christinpak>\n";
	close CHRISTinPAK;
}
sub ChristiansInPakistan(){
    my $link = "http://www.christiansinpakistan.com/category/cip-news/";
    my $linkspage = &browz($link);
    my $links = HTML::TreeBuilder->new();
    $links->parse($linkspage);
    $links->eof;
    my @Nlinks;
    #$links->dump;
    my @link = $links->look_down("_tag" , "h3");
    my $counter = 1;
    foreach my $node (@link) {
      last  if $counter > 5;
      my @kids = $node->content_list( );
      for my $a(@kids){
      no warnings 'uninitialized';
           if (@kids and ref $kids[$b] and $kids[$b]->tag( ) eq 'a') {
                my $c = $kids[$b]->attr("href" );
                #print "$counter\n-- " . $kids[$b]->as_text  . "   --\n";
                my $a = "<a href='" . $kids[$b]->attr("href" ) . "' title='" . $kids[$b]->as_text . "' target='_blank'>" . $kids[$b]->as_text . "</a>";
                #print CHRISTinPAK "<news>\n<![CDATA[ $a ]]>\n</news>\n";
                push @Nlinks, $a;
                $counter++;  
            }
       }
    }
    return @Nlinks;
}

#########Browser#########################
sub browz(){
     my $link = shift;
    my $ua = LWP::UserAgent->new;
    my $con;
    my $response = $ua->get($link);
    #print "$link\n";
    print $response->content_encoding( );
    if ($response->is_success) {
       $con = $response->decoded_content();
    }else{
        die $response->status_line;
    }
    return $con;
}
##############Email sent##################
sub sendEmail{
 	my($sub, $mess)= @_;
	my $to = "postmaster\@sitename.com";
	my $from = "postmaster\@sitename.com";
	my $subject = "Message from " . $sub;
	my $message = $mess;

	my $email = Email::Simple->create(
    		header => [
      		To      => '"Shak" <firstEmail@sitename.com>',
      		From    => '"postMaster" <postmaster@sitename.com>',
      		Subject => $subject,
    		],
    		body => $mess,
  	);

  
  	try{
   		sendmail($email);#
	}catch {
    		warn "caught error: $_"; # not $@
   
	};

	print "Email Sent Successfully\n";
}
