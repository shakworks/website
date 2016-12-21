#!/usr/bin/perl -w
use strict;
use DBI;
use LWP::UserAgent;
use HTML::TreeBuilder;
use HTML::TableExtract;
&Persecution();
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
                print "<news>\n<![CDATA[ $a ]]>\n</news>\n";
                push @Nlinks, $a;
                $counter++;  
             }
         }
    }
    return @Nlinks;
}
sub databaseHandle(){
my $username = "apakista_d4t4s";
my $password = "shakir1?";
my $dsn = "DBI:mysql:apakista_siteText";
my $dbh = DBI->connect($dsn, $username, $password,{PrintError => 0}) or die "Cannot connect to server: $DBI::errstr ($DBI::err)\n";
return $dbh;
}
sub getLatestUpdates(){
            my $dbh = databaseHandle();
            
            my $sql= "SELECT timemade, fileName, description  FROM  datas ORDER BY timemade ASC LIMIT 3";
            #print "$sql\n";
            my $sth  = $dbh->prepare($sql)  or die "Couldn't prepare statement:  $DBI::errstr; stopped";
            $sth->execute() or die "Cannot connect to table: $DBI::errstr ($DBI::err)\n";
            my @arrayhash;
            while (my ($timemade, $title, $text) = $sth->fetchrow_array()) {
                  #print "$timemade \t $title \t $text \n\n***********************************\n";  
                  push @arrayhash,  {'t' => $timemade, 'title' => $title,'text' => $text,};
            }
            return @arrayhash;
}
my @arrayhash;# = getLatestUpdates();
foreach my $s(@arrayhash){
   my %hash = %{$s};
    while (my($k, $v) = each %hash){
               #print   "$k ====> $v\n";
            }
    #print "\n+++++++++++++++++++++++++++++\n++++++++++++++++++++++++\n"
}
my @a = ("about");
my $dbh = databaseHandle();
    my ($sql, %hash);
    my ($link, $name) = @a;#
    $name =~ s/_/ /mg; #print $name;
    if ($link eq "") {
       #print "link is empty\n";
       $sql = "select * from datas where fileName=?";
       my $sth = $dbh->prepare($sql);
       $sth->execute($name) or die "Cannot Connect to the Table: $DBI::errstr ($DBI::err)\n";
       while (my $ref = $sth->fetchrow_hashref()) {
                    $hash{'authorName'}     = $$ref{'author'};
                    $hash{'Page_name'}      = $name;
                    $hash{'content'}        = $$ref{'content'};
                	$hash{'keywords'}       = $$ref{'keywords'};
                    $hash{'description'}     = $$ref{'description'}; 
                    $hash{'file_toolTips'}  = $$ref{'file_toolTips'};
       }
       while (my($k, $v) = each %hash){
                print   "$k ====> $v\n+++++++++++++\n";
            }
    }else{
          if($link =~ m/(.*)\/reviews\/$/ig){#localhost/bible/reviews/filename
                #print "reviews found\n";
                $sql = "select * from datas where file_link=? and fileName=?"; 
                #print "$sql";
                my $sth = $dbh->prepare($sql);
                $sth->execute($link, $name) or die "Cannot connect to table: $DBI::errstr ($DBI::err)\n";
                while (my $ref = $sth->fetchrow_hashref()) {
                    $hash{'authorName'}     = $$ref{'author'};
                    $hash{'Page_name'}      = $name;
                    $hash{'content'}        = $$ref{'content'};
                	$hash{'keywords'}       = $$ref{'keywords'};
                    $hash{'description'}     = $$ref{'description'}; 
                    $hash{'file_toolTips'}  = $$ref{'file_toolTips'};
                    
                }
            my $author = $hash{'authorName'};
            chomp($author);
            my $sql  = "select aboutAuthor from bookAuthors where authors='$author'";
            print "$sql\n-----\n";
            my ($authorDetail) = $dbh->selectrow_array($sql);
            $hash{'authorDetail'} = $authorDetail;
            while (my($k, $v) = each %hash){
                print   "$k ====> $v\n+++++++++++++\n";
            }
          }
    }



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