///////////////////////////////////////////////
// file name  : my_pecell_inout_transaction.sv
// creat time : 2020-04-21
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_pecell_inout_transaction.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_pecell_inout_transaction
//
class my_pecell_inout_transaction extends uvm_sequence_item;
    typedef my_pecell_inout_transaction this_type_t;
    /*   Be careful to use `uvm_field_* marco     */
    `uvm_object_utils(my_pecell_inout_transaction);
    typedef enum logic[1:0] {IDLE, CALCULATE, READ, WRITE} work_mode_e;
    typedef enum logic {LOW, RAND} rdata_busy_mode_e;

    //  Group: Variables
    rand work_mode_e work_mode;
    rand int cvalid_after_csn;
    rand logic [4:0]waddr;
    rand signed logic [`WID_BUS-1:0]wdata[];
    rand int wdata_interval_cycle[];
    rand int wdata_len;
    rand int csn_undo_cycle; //-1: do not undo cs_n
    rand rdata_busy_mode_e rdata_busy_mode;

    //  Group: Constraint
    constraint addr_c {
        waddr inside {[0:31]};
    }

    constraint wdata_len_c {
        soft wdata_len == 36;
        wdata.size() == wdata_len;
        wdata_interval_time.size() == wdata_len;
    }

    constraint cycle_c {
        foreach (wdata_interval_cycle[i]) wdata_interval_cycle[i] inside {[0:100]};
        cvalid_after_csn inside {[1:100]};
        csn_undo_cycle inside {[-1:100]};
    }


    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_pecell_inout_transaction");
        super.new(name);
    endfunction: new

    //  Function: do_copy
    // extern virtual function void do_copy(uvm_object rhs);
    //  Function: do_compare
    // extern virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    //  Function: convert2string
    // extern virtual function string convert2string();
    //  Function: do_print
    // extern virtual function void do_print(uvm_printer printer);
    //  Function: do_record
    // extern virtual function void do_record(uvm_recorder recorder);
    //  Function: do_pack
    // extern virtual function void do_pack();
    //  Function: do_unpack
    // extern virtual function void do_unpack();

    
endclass: my_pecell_inout_transaction
