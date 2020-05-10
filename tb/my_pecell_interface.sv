///////////////////////////////////////////////
// file name  : my_pecell_interface.sv
// creat time : 2020-04-21
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_pecell_interface.sv
// log        : no
///////////////////////////////////////////////

//  Interface: my_pecell_interface
//
interface my_pecell_interface
    /*  package imports  */
    #(
        // parameter_list
    )(
        // port_list
    );


    // DUT ports
    logic clk;
    logic rst_n;
    logic [6:0]pe_id;
    logic psel;
    logic [3:0]paddr;
    logic pwrite;
    logic [7:0]pwdata;
    logic penable;
    logic [7:0]prdata;
    logic pready;
    logic [`WID_BUS-1:0]wdata;
    logic wdata_valid;
    logic wdata_busy;
    logic wdata_last;
    logic [`WID_BUS-1:0]rdata;
    logic rdata_valid;
    logic rdata_busy;
    logic rdata_last;
    logic cs_n;
    logic cvalid;
    logic pe_busy;
    logic [1:0]work_mode;
    logic [4:0]waddr;

    // clocking block
    default clocking apb_drv_cb @(posedge clk);
        output psel;
        output paddr;
        output pwrite;
        output pwdata;
        output penable;
        input  prdata;
        input  pready;
    endclocking
    
    clocking apb_mon_cb @(posedge clk);
        input psel;
        input paddr;
        input pwrite;
        input pwdata;
        input penable;
        input prdata;
        input pready;
    endclocking

    clocking inout_drv_cb @(posedge clk);
        output wdata;
        output wdata_valid;
        input wdata_busy;
        output wdata_last;
        input rdata;
        input rdata_valid;
        output rdata_busy;
        input rdata_last;
        output cs_n;
        output cvalid;
        input pe_busy;
        output work_mode;
        output waddr;
    endclocking

    clocking inout_mon_cb @(posedge clk);
        input wdata;
        input wdata_valid;
        input wdata_busy;
        input wdata_last;
        input rdata;
        input rdata_valid;
        input rdata_busy;
        input rdata_last;
        input cs_n;
        input cvalid;
        input pe_busy;
        input work_mode;
        input waddr;
    endclocking
    // assert and cover property
    property rlast_p;
        @(posedge clk) $rose(rdata_valid) |-> (rdata_valid && !rdata_busy)[->32] ##1 $rose(rdata_last) ##0 (rdata_valid && rdata_last)[*1:$] ##0 !rdata_busy ##1 $fell(rdata_last) ##0 $fell(rdata_valid);
    endproperty
    property reset_p;
        @(posedge clk) $fell(rst_n) |-> ( (pready == 'b1) && (prdata == 8'b0) && (wdata_busy == 'b1) && (rdata == 8'b0) && (rdata_valid == 'b0) && (rdata_last == 'b0) && (pe_busy == 'b0))[*1:$] ##0 $rose(rst_n);
    endproperty

    `ifndef RESET_CAL
    rlast_a: assert property(rlast_p) else `uvm_error("assert", "assert rlast fail")
    `ifdef COV
    rlast_c: cover property(rlast_p);
    `endif
    `endif
    reset_a: assert property(reset_p) else `uvm_error("assert", "assert reset fail")
    `ifdef COV
    reset_c: cover property(reset_p);
    `endif
endinterface: my_pecell_interface
