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
    `uvm_component_utils(my_pecell_reference_model)
    `uvm_analysis_imp_decl(_apb)
    `uvm_analysis_imp_decl(_inout)
    typedef logic signed [`WID_BUS-1:0] in_vector_t[35:0];
    

    //  Group: Config
    my_pecell_tb_config tbcfg;
    logic signed [`WID_BUS-1:0] weight[31:0][35:0];
    in_vector_t in_vector_q[$];
    bit [7:0]regs[4:0];
    logic signed [`WID_BUS-1:0] rdata[32:0];
    int rdata_tmp;
    int unsigned tr_id = 0;
    virtual my_pecell_interface vif;
    my_pecell_register_model m_regmdl;
    logic [6:0] pe_id;
    


    //  Group: Variables
    

    //  Group: Ports
    uvm_analysis_imp_apb #(my_pecell_apb_transaction, my_pecell_reference_model) imp_apb;
    uvm_analysis_imp_inout #(my_pecell_inout_transaction, my_pecell_reference_model) imp_inout;
    uvm_analysis_port #(my_pecell_inout_transaction) to_scb_ap;


    //  Group: Functions
    extern virtual function void write_apb(input my_pecell_apb_transaction tr);
    extern virtual function void write_inout(input my_pecell_inout_transaction tr);
    extern virtual task calculate(ref my_pecell_inout_transaction tr);

    
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
    if (!uvm_config_db#(virtual my_pecell_interface)::get(this, "", "vif", vif)) begin
        `uvm_fatal(get_type_name(), "cannot get interface")
    end
    if (!uvm_config_db#(my_pecell_register_model)::get(this, "", "regmdl", m_regmdl)) begin
        `uvm_fatal(get_type_name(), "can not get m_regmdl")
    end
    pe_id = tbcfg.pe_id;

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
    my_pecell_inout_transaction tr;
    forever begin
        if (in_vector_q.size() > 0) begin
            tr = my_pecell_inout_transaction::type_id::create("tr");
            tr.data = new[33];
            calculate(tr);
            tr_id++;
            tr.id = tr_id;
            to_scb_ap.write(tr);
            `uvm_info(get_type_name(), "send one packet", UVM_MEDIUM)
        end
        else begin
            @(posedge vif.clk);
        end
    end
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
    if (tr.work_mode == WRITE) begin
        foreach ( tr.data[i] ) begin
            weight[tr.addr][i] = tr.data[i];
        end
    end
    else if (tr.work_mode == CALCULATE || tr.work_mode == READ) begin
        in_vector_q.push_back(tr.data);
    end
endfunction




/*----------------------------------------------------------------------------*/
/*  Other Class Functions and Tasks                                           */
/*----------------------------------------------------------------------------*/
task my_pecell_reference_model::calculate(ref my_pecell_inout_transaction tr);
    in_vector_t vector = in_vector_q.pop_back();
    uvm_status_e status;
    uvm_reg_data_t value;
    tr.data[0] = pe_id;
    foreach (weight[i]) begin
        foreach ( weight[,j] ) begin
            rdata_tmp += weight[i][j] * vector[j]; 
        end
        m_regmdl.reg_reuse.read(status, value, UVM_FRONTDOOR);
        if (status != UVM_IS_OK) begin
            `uvm_fatal(get_type_name(), "read reg_reuse fail")
        end
        case (value[7:4])
            4'd0: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[20:14]};
            4'd1: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[19:13]};
            4'd2: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[18:12]};
            4'd3: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[17:11]};
            4'd4: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[16:10]};
            4'd5: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[15:9]};
            4'd6: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[14:8]};
            4'd7: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[13:7]};
            4'd8: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[12:6]};
            4'd9: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[11:5]};
            4'd10: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[10:4]};
            4'd11: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[9:3]};
            4'd12: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[8:2]};
            4'd13: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[7:1]};
            4'd14: tr.data[i+1] = {rdata_tmp[0], rdata_tmp[6:0]};
            default: tr.data[i+1] = {rdata_tmp[7:0]};
        endcase
        
    end
endtask: calculate

