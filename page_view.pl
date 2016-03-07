#!/usr/bin/perl

&Init();

if($mode eq "view"){
	&get_fname();
	&service_tbl()
	&html_head();
	&html_body();
	&html_foot();
}else{
	if($ENV{REMOTE_ADDR} ne "202.213.202.215"){
	    &count_setup();
    	&lock_chk();
	    cntLock: for($i=0;$i<10;$i++){
	        if(mkdir($lock,0755)){
	        	&read_cnt();
	            &count_up();
	            rmdir($lock);
	            last cntLock;
	         }else{
	            sleep 1;
	         }
    	}
	}
	&print_dummy();
}
exit;


sub Init()
{
	@query = split( /=/, $ENV{'QUERY_STRING'} );
	$count_dir='/home/d2admin/docs_club/count/page_view/';
	$mode = $query[1];
}
sub read_cnt()
{
    open(CNT,$file);
    $count = <CNT>;
	close(CNT);
	chomp($count);
    ($total, $daily, $yesterday, $weekly, $monthly, $yearly, $fds, $fws) = split(/\t/, $count);
    $log = '/home/d2admin/docs_club/shochu_csv/';
    open(LOG, "> $log");
    print LOG "$count\n";
    close(LOG);
    
}
sub count_up()
{
    $ds = daystamp();
    $ws = weekstamp();
    if(substr($fds,0,4) < substr($ds,0,4)){
    	$yearly = 0;
    }
    if(substr($fds,4,2) < substr($ds,4,2)){
    	$monthly = 0;
    }
    if($fws < $ws){
    	$weekly = 0;
    	$fws = $ws;
    }
    if($fds < $ds){
    	$yesterday = $daily;
    	$daily = 0;
    	$fds = $ds;
    }
    $total++; $daily++; $weekly++; $monthly++; $yealy++;
    $count = "$total\t$daily\t$yesterday\t$weekly\t$monthly\t$yearly\t$fds\t$fws";
    open(CNT,"> $file");
    print CNT $count;
    close(CNT);
}
sub print_dummy()
{
    print "Content-type: image/gif\n\n";
}
sub count_setup()
{
    $file=$count_dir.$mode;
    $lock=$file.'_lock';
}
sub lock_chk()
{
    if(-M $lock > 5/1440){
        rmdir($lock);
    }
}
sub get_fname()
{
	opendir(CDIR,$count_dir);
	@dir=grep !/^\./, readdir CDIR;
    closedir CDIR;
}
sub daystamp()
{
    my ($d,$m,$y) = (localtime())[3,4,5];
    return sprintf("%4d%02d%02d",$y+=1900,++$m,$d);
}
sub weekstamp()
{
    my ($d,$m,$y) = (localtime(((7-(localtime())[6])*86400)+time))[3,4,5];
    return sprintf("%4d%02d%02d",$y+=1900,++$m,$d);
}
sub html_head()
{
    print "Content-type: text/html\n\n";
    print "<HTML><HEAD><TITLE>PODページビュー</TITLE><META http-equiv=\"Refresh\" Content=\"60\"></HEAD>\n";
	print "<BODY>\n";
}
sub html_body()
{
	print "<DIV align=\"center\">\n";
	print "<FONT size=\"4\"><B>PODページビュー</B></FONT><BR>\n";
	print "<FONT size=\"2\">60秒毎に自動的に更新されます。</FONT><BR><BR>\n";
	print "<TABLE border=\"1\" cellpadding=\"3\" cellspacing=\"0\">\n";
	&table_head();

	for($i=0;$i<@dir;$i++){
        $file=$count_dir.$dir[$i];
		&read_cnt();
		print "<TR><TD>$service{$dir[$i]}</TD><TD>$total</TD><TD>$daily</TD><TD>$yesterday</TD><TD>$weekly</TD><TD>$monthly</TD><TD>$yearly</TD></TR>\n";
	}

	print "</TABLE><BR>\n";
	print "<TABLE><TR><TD>\n";
	print "<FONT size=\"2\">POD各サービスのトップページの閲覧回数です<BR>\n";
	print "ページがリロードされた場合もカウントしているので、<BR>アクセスした人数ではありません<BR>\n";
	print "接続元が202.213.202.215（辰巳）の場合はカウント<BR>しないようにしています<BR>\n";
	print "（あなたは$ENV{REMOTE_ADDR}から接続しています。）</FONT><BR>\n";
	print "</TD></TR></TABLE>\n";
	print "</DIV>\n";
	print "<BR><BR>\n";
}
sub html_foot()
{
	print "<DIV align=\"right\">カウント開始：2000/10/25 21:00</DIV>\n";
	&printDate();
	print "</BODY></HTML>\n";
}
sub table_head()
{
	print "<TR><TD>サービス名</TD><TD>合計</TD><TD>今日</TD><TD>昨日</TD><TD>今週</TD><TD>今月</TD><TD>今年</TD></TR>\n";
}
sub service_tbl()
{
	%service=("meishi","名刺Q","futo","封筒Q","nenga","年賀","mochu","喪中","diary","ダイアリー","folder","クリアホルダー","stamper","スタンパー","stamp","スタンプ","tebori","手彫り","s_print","名刺S","s_futo","封筒S","aisatu","挨拶状","ballpen","ボールペン","post","ポストイット","denpyo","伝票","shochu","暑中見舞","uchiwa","うちわ名入れ","xstamper","Xスタンパー","formal","フォーマル","plate","ネームプレート","wear","プリントウェア");
}
sub	printDate()
{	
	($secg,$ming,$hourg,$mdayg,$mong,$yearg,$wdayg,$ydayg,$isdstg)=localtime( time );

	$yearg += 1900;
	$mong += 1;

	if ($mong < 10) {$mong="0$mong";}
	if ($mdayg < 10) {$mdayg="0$mdayg";}
	if ($hourg < 10) {$hourg="0$hourg";}
	if ($ming < 10) {$ming="0$ming";}
	if ($secg < 10) {$secg="0$secg";}
	
	print "<DIV align=\"right\">現在時刻：$yearg/$mong/$mdayg $hourg:$ming </DIV>\n";
}
