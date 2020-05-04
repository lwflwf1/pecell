///////////////////////////////////////////////
// file name  : my_pecell_apb_transaction.sv
// creat time : 2020-04-21
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_pecell_apb_transaction.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_pecell_apb_transaction
//
class my_pecell_apb_transaction extends uvm_sequence_item;
    typedef my_pecell_apb_transaction this_type_t;
    /*   Be careful to use `uvm_field_* marco     */
    `uvm_object_utils(my_pecell_apb_transaction)
    typedef enum bit {READ, WRITE} kind_e;

    //  Group: Variables
    rand logic [3:0]addr;
    rand logic [7:0]data;
    rand kind_e kind;
    rand logic [6:0]pe_id;
    

    //  Group: Constraint
    constraint paddr_c {
        addr inside {[0:4]};
    }

    constraint reg_set_cycle0_c {
        (addr == 'h0) -> (data != 'b0);
        (addr == 'h4) -> (data[1:0] inside {'b01, 'b10});
    }


    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_pecell_apb_transaction");
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

    
endclass: my_pecell_apb_transaction
