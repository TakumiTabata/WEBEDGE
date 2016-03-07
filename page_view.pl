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
    print "<HTML><HEAD><TITLE>POD�y�[�W�r���[</TITLE><META http-equiv=\"Refresh\" Content=\"60\"></HEAD>\n";
	print "<BODY>\n";
}
sub html_body()
{
	print "<DIV align=\"center\">\n";
	print "<FONT size=\"4\"><B>POD�y�[�W�r���[</B></FONT><BR>\n";
	print "<FONT size=\"2\">60�b���Ɏ����I�ɍX�V����܂��B</FONT><BR><BR>\n";
	print "<TABLE border=\"1\" cellpadding=\"3\" cellspacing=\"0\">\n";
	&table_head();

	for($i=0;$i<@dir;$i++){
        $file=$count_dir.$dir[$i];
		&read_cnt();
		print "<TR><TD>$service{$dir[$i]}</TD><TD>$total</TD><TD>$daily</TD><TD>$yesterday</TD><TD>$weekly</TD><TD>$monthly</TD><TD>$yearly</TD></TR>\n";
	}

	print "</TABLE><BR>\n";
	print "<TABLE><TR><TD>\n";
	print "<FONT size=\"2\">POD�e�T�[�r�X�̃g�b�v�y�[�W�̉{���񐔂ł�<BR>\n";
	print "�y�[�W�������[�h���ꂽ�ꍇ���J�E���g���Ă���̂ŁA<BR>�A�N�Z�X�����l���ł͂���܂���<BR>\n";
	print "�ڑ�����202.213.202.215�i�C���j�̏ꍇ�̓J�E���g<BR>���Ȃ��悤�ɂ��Ă��܂�<BR>\n";
	print "�i���Ȃ���$ENV{REMOTE_ADDR}����ڑ����Ă��܂��B�j</FONT><BR>\n";
	print "</TD></TR></TABLE>\n";
	print "</DIV>\n";
	print "<BR><BR>\n";
}
sub html_foot()
{
	print "<DIV align=\"right\">�J�E���g�J�n�F2000/10/25 21:00</DIV>\n";
	&printDate();
	print "</BODY></HTML>\n";
}
sub table_head()
{
	print "<TR><TD>�T�[�r�X��</TD><TD>���v</TD><TD>����</TD><TD>���</TD><TD>���T</TD><TD>����</TD><TD>���N</TD></TR>\n";
}
sub service_tbl()
{
	%service=("meishi","���hQ","futo","����Q","nenga","�N��","mochu","�r��","diary","�_�C�A���[","folder","�N���A�z���_�[","stamper","�X�^���p�[","stamp","�X�^���v","tebori","�蒤��","s_print","���hS","s_futo","����S","aisatu","���A��","ballpen","�{�[���y��","post","�|�X�g�C�b�g","denpyo","�`�[","shochu","��������","uchiwa","�����햼����","xstamper","X�X�^���p�[","formal","�t�H�[�}��","plate","�l�[���v���[�g","wear","�v�����g�E�F�A");
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
	
	print "<DIV align=\"right\">���ݎ����F$yearg/$mong/$mdayg $hourg:$ming </DIV>\n";
}
