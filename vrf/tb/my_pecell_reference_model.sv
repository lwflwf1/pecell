///////////////////////////////////////////////
// file name  : my_pecell_reference_model.sv
// creat time : 2020-04-21
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_pecell_reference_model.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_pecell_reference_model
//
class my_pecell_reference_model extends uvm_component;
    `uvm_component_utils(my_pecell_reference_model);
    `uvm_analysis_imp_decl(_apb);
    `uvm_analysis_imp_decl(_inout);

    //  Group: Config
    my_pecell_tb_config tbcfg;


    //  Group: Variables
    

    //  Group: Ports
    uvm_analysis_imp_apb #(my_pecell_apb_transaction, my_pecell_reference_model) imp_apb;
    uvm_analysis_imp_inout #(my_pecell_inout_transaction, my_pecell_reference_model) imp_inout;
    uvm_analysis_port #(my_pecell_transaction) to_scb_ap;


    //  Group: Functions
    extern virtual function void write_apb(input my_pecell_apb_transaction tr);
    extern virtual function void write_inout(input my_pecell_inout_transaction tr);

    
    //  Constructor: new
    function new(string name = "my_pecell_reference_model", uvm_component parent);
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
    
endclass: my_pecell_reference_model


/*----------------------------------------------------------------------------*/
/*  UVM Build Phases                                                          */
/*----------------------------------------------------------------------------*/
function void my_pecell_reference_model::build_phase(uvm_phase phase);
    /*  note: Do not call super.build_phase() from any class that is extended from an UVM base class!  */
    /*  For more information see UVM Cookbook v1800.2 p.503  */
    // super.build_phase(phase);
    if (!uvm_config_db#(my_pecell_tb_config)::get(this, "", "tbcfg", tbcfg)) begin
        `uvm_fatal(get_type_name(), "cannot get tbcfg")
    end

    // create ports
    imp_apb = new("imp_apb", this);
    imp_inout = new("imp_inout", this);
    to_scb_ap = new("to_scb_ap", this);

endfunction: build_phase


function void my_pecell_reference_model::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase


function void my_pecell_reference_model::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase


/*----------------------------------------------------------------------------*/
/*  UVM Run Phases                                                            */
/*----------------------------------------------------------------------------*/
function void my_pecell_reference_model::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task my_pecell_reference_model::reset_phase(uvm_phase phase);
endtask: reset_phase


task my_pecell_reference_model::configure_phase(uvm_phase phase);
endtask: configure_phase


task my_pecell_reference_model::main_phase(uvm_phase phase);
endtask: main_phase


task my_pecell_reference_model::shutdown_phase(uvm_phase phase);
endtask: shutdown_phase


task my_pecell_reference_model::run_phase(uvm_phase phase);
endtask: run_phase


/*----------------------------------------------------------------------------*/
/*  UVM Cleanup Phases                                                        */
/*----------------------------------------------------------------------------*/
function void my_pecell_reference_model::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction: report_phase


function void my_pecell_reference_model::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction: extract_phase



/*----------------------------------------------------------------------------*/
/* uvm_analysis_imp write functions                                           */
function void my_pecell_reference_model::write_apb(input my_pecell_apb_transaction tr);
endfunction


function void my_pecell_reference_model::write_inout(input my_pecell_inout_transaction tr);
endfunction




/*----------------------------------------------------------------------------*/
/*  Other Class Functions and Tasks                                           */
/*----------------------------------------------------------------------------*/
