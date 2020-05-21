///////////////////////////////////////////////
// file name   : my_case7.sv
// create time : 2020-5-4
// author      : Gong Yingfan
// version     : v1.0
// cescript    : my_case7
// log         : no
///////////////////////////////////////////////

/*---------------------------------------------------*/
/* sequeces                                          */
/*---------------------------------------------------*/

//  Class:my_pecell_apb_sequence
//
class my_pecell_apb_sequence extends uvm_sequence;
    `uvm_object_utils(my_pecell_apb_sequence)

    //  Group: Variables
    my_pecell_register_model m_regmdl;
    uvm_status_e status;
    uvm_reg_data_t value[0:4];

    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_pecell_apb_sequence");
        super.new(name);
    endfunction: new

    extern virtual task body();
    
endclass: my_pecell_apb_sequence


task my_pecell_apb_sequence::body();
    bit set_reg_done = 0;
    my_pecell_apb_transaction tr;
    if (!uvm_config_db#(my_pecell_register_model)::get(null, get_full_name(), "regmdl", m_regmdl)) begin
        `uvm_fatal(get_type_name(), "cannot get regmdl")
    end
    tr = my_pecell_apb_transaction::type_id::create("tr");
    tr.randomize() with {data[7:3] == 'd31; data[1:0] == 'b10;};
    value = '{5{0}};
    value[0] = 'b1;
    value[4] = tr.data;
    m_regmdl.reg_set_cycle0.write(status, value[0], UVM_FRONTDOOR, .parent(this));
    m_regmdl.reg_set_cycle1.write(status, value[1], UVM_FRONTDOOR, .parent(this));
    m_regmdl.reg_set_cycle2.write(status, value[2], UVM_FRONTDOOR, .parent(this));
    m_regmdl.reg_set_cycle3.write(status, value[3], UVM_FRONTDOOR, .parent(this));
    m_regmdl.reg_reuse.write(status, value[4], UVM_FRONTDOOR, .parent(this));
    `uvm_info(get_type_name(), $sformatf("  set register done\n\
                                            set reg_set_cycle0: %0d\n\
                                            set reg_set_cycle1: %0d\n\
                                            set reg_set_cycle2: %0d\n\
                                            set reg_set_cycle3: %0d\n\
                                            set reg_reuse: %8b\n", value[0], value[1], value[2], value[3], value[4]), UVM_MEDIUM)
    uvm_config_db#(bit)::set(null, "uvm_test_top.m_env.m_ref_mdl", "set_reg_done", set_reg_done);
endtask: body



//  Class: my_pecell_inout_sequence
//
class my_pecell_inout_sequence extends uvm_sequence;
    `uvm_object_utils(my_pecell_inout_sequence)

    //  Group: Variables
    my_pecell_inout_transaction tr;
    my_pecell_inout_transaction tr_idle;
    int input_data_num = 36;
    

    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_pecell_inout_sequence");
        super.new(name);
    endfunction: new

    extern virtual task body();

    
endclass: my_pecell_inout_sequence

task my_pecell_inout_sequence::body();
    tr = my_pecell_inout_transaction::type_id::create("tr");
    for(int i = 0; i < 32; i++) begin
        start_item(tr);
        assert(tr.randomize() with {
            work_mode == WRITE;
            foreach (wdata_interval_cycle[i]) wdata_interval_cycle[i] == 0;
            cvalid_after_csn == 1;
            csn_undo_cycle == 0;
        });
        finish_item(tr);
        `uvm_info(get_type_name(), "send one weight vector to driver", UVM_MEDIUM)
    end
    tr = my_pecell_inout_transaction::type_id::create("tr");
    for(int i = 0; i < input_data_num; i++) begin
        start_item(tr);
        tr.randomize() with {
            work_mode == READ;
            foreach (wdata_interval_cycle[i]) wdata_interval_cycle[i] == 0;
            foreach(data[j]) data[j] == 0;
            cvalid_after_csn == 1;
            csn_undo_cycle == 0;
        };
        tr.data[tr.read_index] = 1;
        finish_item(tr);
    end
    start_item(tr);
    assert(tr.randomize() with {
        work_mode == IDLE;
        wdata_len == 1;
        foreach (wdata_interval_cycle[i]) wdata_interval_cycle[i] == 0;
        cvalid_after_csn == 1;
        csn_undo_cycle == 0;
    });
    finish_item(tr);
endtask: body


//  Class: my_pecell_virtual_sequence
//
class my_pecell_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(my_pecell_virtual_sequence)
    `uvm_declare_p_sequencer(my_pecell_virtual_sequencer)

    //  Group: Sequences
    my_pecell_apb_sequence m_apb_seq;
    my_pecell_inout_sequence m_inout_seq;
    

    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_pecell_virtual_sequence");
        super.new(name);
    endfunction: new

    // Task: body
    extern virtual task body();
    // Task: pre_start
    extern virtual task pre_start();
    // Task: post_start
    extern virtual task post_start();

    
endclass: my_pecell_virtual_sequence


// Task: body
task my_pecell_virtual_sequence::body();
    // start every sequence on each sequencer

    /*------------------------------------------------------------*/
    /* note: Be careful to start sequence array in fork join_none */
    /* Codes below will not work correctly because i is static                        
        for (int i = 0; i < 10; i++) begin
            fork
                `uvm_do_on(seq[i], p_sequencer.sqr[i]
            join_none
        end
    --------------------------------------------------------------*/

    /* note: Use tb_config to control whether to start a sequence */
    m_apb_seq = my_pecell_apb_sequence::type_id::create("m_apb_seq");
    m_inout_seq = my_pecell_inout_sequence::type_id::create("m_inout_seq");
    m_apb_seq.start(p_sequencer.m_pecell_apb_sqr);
    m_inout_seq.start(p_sequencer.m_pecell_inout_sqr);
endtask: body


// Task: pre_start
task my_pecell_virtual_sequence::pre_start();
    if (starting_phase != null) begin
        starting_phase.raise_objection(this);
    end
endtask: pre_start


// Task: post_start
task my_pecell_virtual_sequence::post_start();
    #1000;
    if (starting_phase != null) begin
        starting_phase.drop_objection(this);
    end
endtask: post_start









//  Class: my_case7
//
class my_case7 extends my_pecell_base_test;
    `uvm_component_utils(my_case7)

    //  Group: Config
    logic [6:0] pe_id;
    

    //  Group: Variables
    my_pecell_virtual_sequence m_vseq;
    

    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_case7", uvm_component parent);
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
    
endclass: my_case7


/*----------------------------------------------------------------------------*/
/*  UVM Build Phases                                                          */
/*----------------------------------------------------------------------------*/
function void my_case7::build_phase(uvm_phase phase);
    /*  note: Do not call super.build_phase() from any class that is extended from an UVM base class!  */
    /*  For more information see UVM Cookbook v1800.2 p.503  */

    // set tbcfg, this must before super.build_phase() 
    tbcfg.apb_agt_is_active = UVM_ACTIVE;
    tbcfg.inout_agt_is_active = UVM_ACTIVE;
    tbcfg.rdata_busy_mode = RAND;
    std::randomize(pe_id);
    tbcfg.pe_id = pe_id;

    super.build_phase(phase);
    m_vseq = my_pecell_virtual_sequence::type_id::create("m_vseq");

endfunction: build_phase


function void my_case7::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // override report verbosity level, default is UVM_HIGH
    // m_env.set_report_verbosity_level_hier(UVM_LOW);

    // override max quit count, default is 10
    // set_report_max_quit_count(10);

endfunction: connect_phase


function void my_case7::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase


/*----------------------------------------------------------------------------*/
/*  UVM Run Phases                                                            */
/*----------------------------------------------------------------------------*/
function void my_case7::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task my_case7::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
endtask: reset_phase


task my_case7::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask: configure_phase


task my_case7::main_phase(uvm_phase phase);
    super.main_phase(phase);
endtask: main_phase


task my_case7::shutdown_phase(uvm_phase phase);
    super.shutdown_phase(phase);
endtask: shutdown_phase


task my_case7::run_phase(uvm_phase phase);
    super.run_phase(phase);
    // start vseq on vsqr
    m_vseq.starting_phase = phase;
    m_vseq.start(m_env.m_vsqr);
endtask: run_phase


/*----------------------------------------------------------------------------*/
/*  UVM Cleanup Phases                                                        */
/*----------------------------------------------------------------------------*/
function void my_case7::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction: report_phase


function void my_case7::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction: extract_phase


/*----------------------------------------------------------------------------*/
/*  Other Class Functions and Tasks                                           */
/*----------------------------------------------------------------------------*/
