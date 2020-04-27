///////////////////////////////////////////////
// file name  : my_pecell_scoreboard.sv
// creat time : 2020-04-21
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_pecell_scoreboard.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_pecell_scoreboard
//
class my_pecell_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(my_pecell_scoreboard)
    `uvm_analysis_imp_decl(_apb)
    `uvm_analysis_imp_decl(_inout)
    `uvm_analysis_imp_decl(_ref)
    

    //  Group: Config
    my_pecell_tb_config tbcfg;
    my_pecell_inout_transaction act_q[$];
    my_pecell_inout_transaction exp_q[$];
    virtual my_pecell_interface vif;
    

    //  Group: Variables
    

    //  Group: Ports
    uvm_analysis_imp_apb #(my_pecell_apb_transaction, my_pecell_scoreboard) imp_apb;
    uvm_analysis_imp_inout #(my_pecell_inout_transaction, my_pecell_scoreboard) imp_inout;
    uvm_analysis_imp_ref #(my_pecell_inout_transaction, my_pecell_scoreboard) imp_ref;


    //  Group: Functions
    extern virtual function void write_apb(input my_pecell_apb_transaction tr);
    extern virtual function void write_inout(input my_pecell_inout_transaction tr);
    extern virtual function void write_ref(input my_pecell_inout_transaction tr);
    extern virtual function void compare(input my_pecell_inout_transaction act, input my_pecell_inout_transaction exp);

    //  Constructor: new
    function new(string name = "my_pecell_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    /*---  UVM Build Phases            ---*/
    /*------------------------------------*/
    //  Function: build_phase
    extern virtual function void build_phase(uvm_phase phase);
    //  Function: connect_phase
    extern virtual function void connect_phase(uvm_phase phase);
    //  Function: end_of_elaboration_phase
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);

    /*---  UVM Run Phases              ---*/
    /*------------------------------------*/
    //  Function: start_of_simulation_phase
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    //  Function: reset_phase
    extern virtual task reset_phase(uvm_phase phase);
    //  Function: configure_phase
    extern virtual task configure_phase(uvm_phase phase);
    //  Function: main_phase
    extern virtual task main_phase(uvm_phase phase);
    //  Function: shutdown_phase
    extern virtual task shutdown_phase(uvm_phase phase);
    //  Function: run_phase
    extern virtual task run_phase(uvm_phase phase);
    

    /*---  UVM Cleanup Phases          ---*/
    /*------------------------------------*/
    //  Function: extract_phase
    extern virtual function void extract_phase(uvm_phase phase);
    //  Function: report_phase
    extern virtual function void report_phase(uvm_phase phase);
    
endclass: my_pecell_scoreboard


/*----------------------------------------------------------------------------*/
/*  UVM Build Phases                                                          */
/*----------------------------------------------------------------------------*/
function void my_pecell_scoreboard::build_phase(uvm_phase phase);
    /*  note: Do not call super.build_phase() from any class that is extended from an UVM base class!  */
    /*  For more information see UVM Cookbook v1800.2 p.503  */
    // super.build_phase(phase);
    if (!uvm_config_db#(my_pecell_tb_config)::get(this, "", "tbcfg", tbcfg)) begin
        `uvm_fatal(get_type_name(), "cannot get tbcfg")
    end
    if (!uvm_config_db#(virtual my_pecell_interface)::get(this, "", "vif", vif)) begin
        `uvm_fatal(get_type_name(), "cannot get interface")
    end


    // create ports
    imp_apb = new("imp_apb", this);
    imp_inout = new("imp_inout", this);
    imp_ref = new("imp_ref", this);

endfunction: build_phase


function void my_pecell_scoreboard::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase


function void my_pecell_scoreboard::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase


/*----------------------------------------------------------------------------*/
/*  UVM Run Phases                                                            */
/*----------------------------------------------------------------------------*/
function void my_pecell_scoreboard::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task my_pecell_scoreboard::reset_phase(uvm_phase phase);
endtask: reset_phase


task my_pecell_scoreboard::configure_phase(uvm_phase phase);
endtask: configure_phase


task my_pecell_scoreboard::main_phase(uvm_phase phase);
endtask: main_phase


task my_pecell_scoreboard::shutdown_phase(uvm_phase phase);
endtask: shutdown_phase


task my_pecell_scoreboard::run_phase(uvm_phase phase);
    forever begin
        if (exp_q.size() > 0 && act_q.size() > 0) begin
            compare(act_q.pop_back(), exp_q.pop_back());
        end
        else begin
            @(posedge vif.clk);
        end
    end
endtask: run_phase



/*----------------------------------------------------------------------------*/
/*  UVM Cleanup Phases                                                        */
/*----------------------------------------------------------------------------*/
function void my_pecell_scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);
    for(;exp_q.size() > 0 && act_q.size() > 0;) begin
        compare(act_q.pop_back(), exp_q.pop_back());
    end
    if (exp_q.size() == 0 && act_q.size() == 0) begin
        `uvm_info(get_type_name(), "compare done", UVM_MEDIUM)
    end
    else begin
        `uvm_error(get_type_name(), $sformatf("expect transaction number and actual number mismatch!\nexq_q.size = %0d\nact_q.size = %0d\n", exp_q.size(), act_q.size()))
    end
    
endfunction: report_phase


function void my_pecell_scoreboard::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction: extract_phase



/*----------------------------------------------------------------------------*/
/* uvm_analysis_imp write functions                                           */
function void my_pecell_scoreboard::write_apb(input my_pecell_apb_transaction tr);
endfunction


function void my_pecell_scoreboard::write_inout(input my_pecell_inout_transaction tr);
    act_q.push_back(tr);
endfunction


function void my_pecell_scoreboard::write_ref(input my_pecell_inout_transaction tr);
    exp_q.push_back(tr);
endfunction





/*----------------------------------------------------------------------------*/
/*  Other Class Functions and Tasks                                           */
/*----------------------------------------------------------------------------*/
function void my_pecell_scoreboard::compare(input my_pecell_inout_transaction act, input my_pecell_inout_transaction exp);
    if (act.id != exp.id) begin
        `uvm_fatal(get_type_name(), $sformatf("transaction id mismatch!!!\nact.id = %0d; exp_id = %0d\n", act.id, exp.id))
    end
    foreach ( act.data[i] ) begin
        if (act.data[i] != exp.data[i]) begin
            `uvm_error(get_type_name(), $sformatf("[%0d]: compare fail!\nact: %p\nexp: %p\n", act.id, act.data, exp.data))
            return;
        end
    end
    `uvm_info(get_type_name(), "compare success", UVM_MEDIUM)
endfunction: compare
