package MyModules;
use strict;
#use Warning;
use LWP::UserAgent;
use HTML::TreeBuilder;
use HTML::TableExtract;
use DBI;
#########Database Handle#######
sub databaseHandle(){
my $username = "*********";
my $password = "*********";
my $dsn = "DBI:mysql:**************";
my $dbh = DBI->connect($dsn, $username, $password,{PrintError => 0}) or die "Cannot connect to server: $DBI::errstr ($DBI::err)\n";
return $dbh;
}
#########Get  A  Verse from Database ###########
sub returnVerse(){
my $dbh = databaseHandle();
my @arr;
 my $sql = "select verse, bible_ref from topVerses";
 my $dbh_p = $dbh->prepare($sql);
 $dbh_p->execute() or die "Cannot connect to table: $DBI::errstr ($DBI::err)\n";;
 while (my $p = $dbh_p->fetch) {#print "@$p\n";
    push @arr, @$p;
 } #print "@arr\n";
 my %verses   = @arr; # print %verses;
my @hash_keys    = keys %verses;
my $random_key   = $hash_keys[rand @hash_keys];
my $random_value = $verses{$random_key};
my @verse ;
push  @verse , $random_value;
push @verse , $random_key ;
#print "\n--\n@verse\n";
return @verse;
}    
######Get all the files of folder #########
sub getRealtedlinks{
	my $dbh = databaseHandle();
	my $link = shift;
	my %h;
	my $allRelated = "select * from datas where file_link=?";
	my $sqlsth = $dbh->prepare($allRelated);
	$sqlsth->execute($link);
		while (my $ref = $sqlsth->fetchrow_hashref()) {
		            #print  "for->links\n" ;
		            my $file  = $$ref{'fileName'};
		            my $file_link        = $$ref{'file_link'};
		            my $file1 = $file;
		            $file1 =~ s/\s/_/g;
		            #my $link = "home.pl?link=" . $file_link ."&name=". $file1;
		            my $link = "/" . $file_link ."/". $file1 . ".html";
		            $h{$file} = $link;
		        }
		while (my($k, $v) = each %h){
		         # print   "$k <----> $v\nlink above\n\n\n\n";
	        }
	return %h;
}

#########Get Content of the File of webPage########
sub getFileContents{
	my $dbh = databaseHandle();
    my ($sql, %hash);
    my ($link, $name) = @_;#
    $name =~ s/_/ /mg; #print $name;
    if ($link eq "") {#localhost/about
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
	   return %hash;
    }else{
          if($link =~ m/(.*)\/reviews$/ig){#localhost/bible/reviews/filename
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
            my $sql  = "select aboutAuthor from bookAuthors where authors='$author'";
            my ($authorDetail) = $dbh->selectrow_array($sql);
            $hash{'authorDetail'} = $authorDetail;
            while (my($k, $v) = each %hash){
                #print   "$k ====> $v\n\n\n\n\n";
            }
        return %hash;
      }else{#localhost/bible/somethingElse/filename
            #print "\n no review in the link\n";
            $sql = "select * from datas where file_link=? and fileName=?";
            #print "$link->$name\n";
            my $sth = $dbh->prepare($sql);
            #print "$sql\n";
            $sth->execute($link, $name)  or die "Cannot connect to table: $DBI::errstr ($DBI::err)\n";;
            while (my $ref = $sth->fetchrow_hashref()) {
                #print  "in the ref\n" ;
                $hash{'Page_name'}      = $name;
                $hash{'content'}        = $$ref{'content'};
                $hash{'keywords'}       = $$ref{'keywords'};
                $hash{'description'}     = $$ref{'description'}; 
                $hash{'file_toolTips'}  = $$ref{'file_toolTips'};
            }
            while (my($k, $v) = each %hash){
                #print   "$k ====> $v\n\n\n\n\n";
            }
            return %hash;
      }
    }
  
}

####Getting Recent Addtions #######
sub getLatestUpdates(){
my $dbh = databaseHandle();

my $sql= "SELECT image, fileName, description, file_link, file_toolTips  FROM  datas ORDER BY timemade DESC LIMIT 3";
#print "$sql\n";
my $sth  = $dbh->prepare($sql)  or die "Couldn't prepare statement:  $DBI::errstr; stopped";
$sth->execute() or die "Cannot connect to table: $DBI::errstr ($DBI::err)\n";
my @arrayhash;
while (my ($image, $name, $text, $file_link, $title) = $sth->fetchrow_array()) {
		$name =~ s/ /_/mg;
		my $filelink = $file_link . $name;
      #print "$timemade \t $title \t $text \n\n***********************************\n";  
      push @arrayhash,  {'image' => $image, 'title' => $title,'text' => $text, 'file_link' => $filelink, };
}
return @arrayhash;
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

##############################
1;
