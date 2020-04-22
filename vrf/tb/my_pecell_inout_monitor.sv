///////////////////////////////////////////////
// file name  : my_pecell_inout_monitor.sv
// creat time : 2020-04-21
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_pecell_inout_monitor.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_pecell_inout_monitor
//
class my_pecell_inout_monitor extends uvm_monitor;
    `uvm_component_utils(my_pecell_inout_monitor)

    //  Group: Config
    my_pecell_tb_config tbcfg;
    unsigned int tr_id = 0;

    //  Group: Variables
    virtual my_pecell_interface vif;

    //  Group: Ports
    uvm_analysis_port #(my_pecell_inout_transaction) to_ref_mdl_ap;
    uvm_analysis_port #(my_pecell_inout_transaction) to_scb_ap;
    uvm_analysis_port #(my_pecell_inout_transaction) to_sbr_ap;
    

    //  Group: Functions
    extern virtual virtual task collect_rdata_pkt(ref my_pecell_inout_transaction tr);
    extern virtual virtual task collect_wdata_pkt(ref my_pecell_inout_transaction tr);

    //  Constructor: new
    function new(string name = "my_pecell_inout_monitor", uvm_component parent);
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
    
endclass: my_pecell_inout_monitor


/*----------------------------------------------------------------------------*/
/*  UVM Build Phases                                                          */
/*----------------------------------------------------------------------------*/
function void my_pecell_inout_monitor::build_phase(uvm_phase phase);
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
    to_ref_mdl_ap = new("to_ref_mdl_ap", this);
    to_scb_ap = new("to_scb_ap", this);
    to_sbr_ap = new("to_sbr_ap", this);

endfunction: build_phase


function void my_pecell_inout_monitor::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase


function void my_pecell_inout_monitor::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase


/*----------------------------------------------------------------------------*/
/*  UVM Run Phases                                                            */
/*----------------------------------------------------------------------------*/
function void my_pecell_inout_monitor::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task my_pecell_inout_monitor::reset_phase(uvm_phase phase);
endtask: reset_phase


task my_pecell_inout_monitor::configure_phase(uvm_phase phase);
endtask: configure_phase


task my_pecell_inout_monitor::main_phase(uvm_phase phase);
endtask: main_phase


task my_pecell_inout_monitor::shutdown_phase(uvm_phase phase);
endtask: shutdown_phase


task my_pecell_inout_monitor::run_phase(uvm_phase phase);
    my_pecell_inout_transaction tr;
    wait(vif.rst_n == 1);
    fork
        forever begin
            tr = my_pecell_inout_transaction::type_id::create("tr");
            collect_rdata_pkt(tr);
            tr_id++;
            tr.id = tr_id;
            to_sbr_ap.write(tr);
        end
        forever begin
            tr = my_pecell_inout_transaction::type_id::create("tr");
            collect_wdata_pkt(tr);
            to_ref_mdl_ap.write(tr);
            to_sbr_ap.write(tr);
        end
    join
endtask: run_phase



/*----------------------------------------------------------------------------*/
/*  UVM Cleanup Phases                                                        */
/*----------------------------------------------------------------------------*/
function void my_pecell_inout_monitor::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction: report_phase


function void my_pecell_inout_monitor::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction: extract_phase


/*----------------------------------------------------------------------------*/
/*  Other Class Functions and Tasks                                           */ 
/*----------------------------------------------------------------------------*/
task my_pecell_inout_monitor::collect_rdata_pkt(ref my_pecell_inout_transaction tr);
    @(vif.inout_mon_cb);
    for (int i = 0; i < 32;)
        if (vif.inout_mon_cb.rdata_valid == 'b1 && vif.inout_mon_cb.rdata_busy == 'b0) begin
            tr.data[i] == vif.inout_mon_cb.rdata;
            i++;
        end
        else begin
            @(vif.inout_mon_cb);
        end
    end
endtask: collect_rdata_pkt

task my_pecell_inout_monitor::collect_wdata_pkt(ref my_pecell_inout_transaction tr);
    @(vif.inout_mon_cb);
    forever begin
        if (vir.inout_mon_cb.cvalid == 'b1) begin
            tr.waddr = vif.inout_mon_cb.waddr;
            tr.work_mode = vif.inout_mon_cb.work_mode
            break;
        end
        else begin
            @(vif.inout_mon_cb);
        end
    end
    if (tr.work_mode != my_pecell_inout_transaction::IDLE) begin
        for (int i = 0; i < 35;) begin
            if (vif.inout_mon_cb.wdata_valid == 'b1 && vif.inout_mon_cb.wdata_busy == 'b0) begin
                tr.data[i] = vif.inout_mon_cb.wdata;
                i++;
            end
            else begin
                @(vif.inout_mon_cb);
            end
        end
    end
endtask