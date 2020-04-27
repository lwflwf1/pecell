///////////////////////////////////////////////
// file name  : my_pecell_env.sv
// creat time : 2020-04-21
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_pecell_env.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_pecell_env
//
class my_pecell_env extends uvm_env;
    `uvm_component_utils(my_pecell_env)
    typedef uvm_reg_predictor #(my_pecell_apb_transaction) my_pecell_predictor;

    //  Group: Config
    my_pecell_tb_config tbcfg;
    

    //  Group: Variables
    my_pecell_apb_agent m_pecell_apb_agt;
    my_pecell_inout_agent m_pecell_inout_agt;
    my_pecell_scoreboard m_scb;
    my_pecell_reference_model m_ref_mdl;
    my_pecell_subscriber m_sbr;
    my_pecell_virtual_sequencer m_vsqr;
    my_pecell_adapter m_adapter;
    my_pecell_predictor m_predictor;
    my_pecell_register_model m_regmdl;


    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_pecell_env", uvm_component parent);
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
    
endclass: my_pecell_env


/*----------------------------------------------------------------------------*/
/*  UVM Build Phases                                                          */
/*----------------------------------------------------------------------------*/
function void my_pecell_env::build_phase(uvm_phase phase);
    /*  note: Do not call super.build_phase() from any class that is extended from an UVM base class!  */
    /*  For more information see UVM Cookbook v1800.2 p.503  */
    // super.build_phase(phase);
    // create component
    m_pecell_apb_agt = my_pecell_apb_agent::type_id::create("m_pecell_apb_agt", this);
    m_pecell_inout_agt = my_pecell_inout_agent::type_id::create("m_pecell_inout_agt", this);
    m_ref_mdl = my_pecell_reference_model::type_id::create("m_ref_mdl", this);
    m_sbr     = my_pecell_subscriber::type_id::create("m_sbr", this);
    m_scb     = my_pecell_scoreboard::type_id::create("m_scb", this);
    m_vsqr    = my_pecell_virtual_sequencer::type_id::create("m_vsqr", this);
    m_adapter = my_pecell_adapter::type_id::create("m_adapter");
    m_predictor = my_pecell_predictor::type_id::create("m_predictor", this);
    
    // get config
    if(!uvm_config_db#(my_pecell_tb_config)::get(this, "", "tbcfg", tbcfg)) begin
        `uvm_fatal(get_type_name(), "cannot get tbcfg!")
    end
    if(!uvm_config_db#(my_pecell_register_model)::get(this, "", "regmdl", m_regmdl)) begin
        `uvm_fatal(get_type_name(), "cannot get m_regmdl!")
    end
    // set config
    m_pecell_apb_agt.is_active = tbcfg.apb_agt_is_active;
    m_pecell_inout_agt.is_active = tbcfg.inout_agt_is_active;
    m_regmdl.build();
    m_regmdl.reset();
    
endfunction: build_phase


function void my_pecell_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // connect sequencer
    m_vsqr.m_pecell_apb_sqr = m_pecell_apb_agt.m_sqr;
    m_vsqr.m_pecell_inout_sqr = m_pecell_inout_agt.m_sqr;

    // connect ports
    m_pecell_apb_agt.to_ref_mdl_ap.connect(m_ref_mdl.imp_apb);
    m_pecell_inout_agt.to_ref_mdl_ap.connect(m_ref_mdl.imp_inout);
    m_pecell_apb_agt.to_scb_ap.connect(m_scb.imp_apb);
    m_pecell_inout_agt.to_scb_ap.connect(m_scb.imp_inout);
    m_pecell_apb_agt.to_sbr_ap.connect(m_sbr.imp_apb);
    m_pecell_inout_agt.to_sbr_ap.connect(m_sbr.imp_inout);
    m_ref_mdl.to_scb_ap.connect(m_scb.imp_ref);

    
    m_regmdl.map.set_sequencer(m_pecell_apb_agt.m_sqr, m_adapter);
    m_regmdl.map.set_auto_predict(1);
    m_predictor.map = m_regmdl.map;
    m_predictor.adapter = m_adapter;
    m_pecell_apb_agt.m_mon.ap.connect(m_predictor.bus_in);

endfunction: connect_phase


function void my_pecell_env::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase


/*----------------------------------------------------------------------------*/
/*  UVM Run Phases                                                            */
/*----------------------------------------------------------------------------*/
function void my_pecell_env::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task my_pecell_env::reset_phase(uvm_phase phase);
endtask: reset_phase


task my_pecell_env::configure_phase(uvm_phase phase);
endtask: configure_phase


task my_pecell_env::main_phase(uvm_phase phase);
endtask: main_phase


task my_pecell_env::shutdown_phase(uvm_phase phase);
endtask: shutdown_phase


task my_pecell_env::run_phase(uvm_phase phase);
endtask: run_phase


/*----------------------------------------------------------------------------*/
/*  UVM Cleanup Phases                                                        */
/*----------------------------------------------------------------------------*/
function void my_pecell_env::report_phase(uvm_phase phase);
    uvm_report_server server;
    int err_num;

    super.report_phase(phase);
    
    server = get_report_server();
    err_num = server.get_severity_count(UVM_ERROR);
    
    if (err_num == 0) begin
        `uvm_info("TEST CASE PASS", "", UVM_LOW)
    end
    else begin
        `uvm_error("TEST CASE FAIL", "")
    end
endfunction: report_phase


function void my_pecell_env::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction: extract_phase


/*----------------------------------------------------------------------------*/
/*  Other Class Functions and Tasks                                           */
/*----------------------------------------------------------------------------*/
