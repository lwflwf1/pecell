#!/usr/bin/perl
use warnings;

$ENV{LD_LIBRARY_PATH} = "$ENV{LD_LIBRARY_PATH}".":/app/synopsys/verdi1403/share/PLI/VCS/LINUX64";
# $ENV{NOVAS_HOME} = "/app/synopsys/verdi1403";
my $verdi_home = $ENV{VERDI_HOME};

my $case;
my $dump_off = 0;
my $cov = 0;
my $seed = time;
my $vcs_opt = "-debug_pp -R -full64 +plusarg_save +v2k -sverilog  +no_notifier +vc ";
my $verdi_opt;

sub main {
    foreach (@ARGV) {
        if (/case/) { $case = $_; }
        if (/dump_off/) { $dump_off = 1; }
        if (/cov/) { $cov = 1; }
        if (/verdi/) {$verdi_opt = 1;}
        if (/help/) { &help; return; } 
        if (/seed/) {
            s/seed=//;
            $seed = $_;
        }
    }
    if (!defined($case)) {die "case not set!\n";}
    if (defined($verdi_opt)) { &verdi; return; }

    my $log = "./log/$case.log";
    my $topname = glob './tb/*top.sv';
    $vcs_opt .= "-ntb_opts uvm +UVM_TESTNAME=$case +UVM_OBJECTION_TRACE +define+UVM_NO_DEPRECATED +UVM_PHASE_TRACE -timescale=1ns/1ps -l $log  +ntb_random_seed=$seed ";
    open CASECFG, "<", "./tc/$case/$case.cfg" or die "open file fail:$!\n";
    while(<CASECFG>) {
        if (/vcs options/) {
            if (defined($line = readline CASECFG)) {
                chomp $line;
                $vcs_opt .= $line;
            }
        }
    }

    if ($dump_off == 0) {
        $vcs_opt .= " +define+DUMP -LDFLAGS -rdynamic -P $verdi_home/share/PLI/VCS/LINUX64/novas.tab $verdi_home/share/PLI/VCS/LINUX64/pli.a ";
        rename $topname, $topname.".bak";
        open my $topfileorigin, '<', $topname.".bak" or die "open file fail:$!\n";
        open my $topfile, '>', $topname or die "open file fail:$!\n";
        while(<$topfileorigin>) {
            s/test_fsdb/$case/;
            print $topfile $_;
        }
        close $topfile;
        close $topfileorigin;
    } 

    if ($cov == 1) {
        $vcs_opt .= "-cm_name RTL -cm_log ./log/cm.log ";
        # $vcs_opt .= "-cm_hier ./cfg/hier_file.conf ";
        $vcs_opt .= "-cm line+cond+fsm+assert ";
        $vcs_opt .= "-cm_line contassign ";
        $vcs_opt .= "-cm_cond allops+event+anywidth ";
        $vcs_opt .= "-cm_ignorepragmas -cm_noconst ";
        $vcs_opt .= "-cm_dir ./cov/$case ";
    }

    $vcs_opt .= "-f ./filelist/filelist.f ./tc/$case/$case.sv ";
    $vcs_opt .= "+notimingcheck ";

    system "vcs $vcs_opt";
    print "\n/*------------------------------------------------------------*/\n";
    print "    finish test $case\n";
    print "/*------------------------------------------------------------*/\n";
    
    if ($dump_off == 0) {
        unlink $topname;
        rename $topname.".bak", $topname;
    }
}

sub verdi {
    $verdi_opt = "-2012 -f ./filelist/filelist.f -nologo -ssf ./fsdb/$case*.fsdb -logdir ./verdilog -logfile -guiConf ./verdilog/novas.conf -veriSimType VCS -rcFile ./verdilog/novas.rc";
    system "verdi $verdi_opt &";
}

sub help {
    print "usage example:\n\t";
    print "simulation:\n\t";
    print "./scripts/sim.pl my_case1                        //run my_case1, dump on, cov off\n\t";
    print "./scripts/sim.pl my_case1 dump_off               //run my_case1, dump off, cov off\n\t";
    print "./scripts/sim.pl my_case1 dump_off cov           //run my_case1, dump off, cov on\n\t";
    print "./scripts/sim.pl my_case1 dump_off cov seed=10   //run my_case1, dump off, cov on, seed=10\n\t";
    print "the four arguments can be in any order\n\n\t";
    print "verdi:\n\t";
    print "./scripts/sim.pl my_case1 verdi\n\t";
    print "the two arguments can be in any order\n";
}

main;