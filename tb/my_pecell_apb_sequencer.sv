///////////////////////////////////////////////
// file name  : my_pecell_apb_sequencer.sv
// creat time : 2020-04-21
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_pecell_apb_sequencer.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_pecell_apb_sequencer
//
class my_pecell_apb_sequencer extends uvm_sequencer #(my_pecell_apb_transaction);
    `uvm_component_utils(my_pecell_apb_sequencer)

    //  Group: Config
    

    //  Group: Variables
    

    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_pecell_apb_sequencer", uvm_component parent);
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
    
endclass: my_pecell_apb_sequencer


/*----------------------------------------------------------------------------*/
/*  UVM Build Phases                                                          */
/*----------------------------------------------------------------------------*/
function void my_pecell_apb_sequencer::build_phase(uvm_phase phase);
    /*  note: Do not call super.build_phase() from any class that is extended from an UVM base class!  */
    /*  For more information see UVM Cookbook v1800.2 p.503  */
    // super.build_phase(phase);
endfunction: build_phase


function void my_pecell_apb_sequencer::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase


function void my_pecell_apb_sequencer::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase


/*----------------------------------------------------------------------------*/
/*  UVM Run Phases                                                            */
/*----------------------------------------------------------------------------*/
function void my_pecell_apb_sequencer::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task my_pecell_apb_sequencer::reset_phase(uvm_phase phase);
endtask: reset_phase


task my_pecell_apb_sequencer::configure_phase(uvm_phase phase);
endtask: configure_phase


task my_pecell_apb_sequencer::main_phase(uvm_phase phase);
endtask: main_phase


task my_pecell_apb_sequencer::shutdown_phase(uvm_phase phase);
endtask: shutdown_phase


task my_pecell_apb_sequencer::run_phase(uvm_phase phase);
endtask: run_phase



/*----------------------------------------------------------------------------*/
/*  UVM Cleanup Phases                                                        */
/*----------------------------------------------------------------------------*/
function void my_pecell_apb_sequencer::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction: report_phase


function void my_pecell_apb_sequencer::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction: extract_phase

