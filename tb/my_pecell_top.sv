///////////////////////////////////////////////
// file name  : my_pecell_top.v
// creat time : 2020-04-21
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_pecell_top.sv
// log        : no
///////////////////////////////////////////////

// `include "uvm_macros.svh"
// import uvm_pkg::*;

//  Module: my_pecell_top
//
module my_pecell_top(); 
    // timeunit 1ns;
    // timeprecision 1ps;

    // parameters

    // variables


    // interface
    my_pecell_interface m_if();

    // Clock model instantiation
    my_pecell_clock_model clk_mdl (
        .clk(m_if.clk),
        .rst_n(m_if.rst_n)
    );

    // DUT instantiation and interface connection  
    pe_cell #(
        .WID_X(`WID_X),
        .WID_Y(`WID_Y),
        .ROW(`ROW),
        .COL(`COL),
        .WID_BUS(`WID_BUS),
        .WID_ACC(`WID_ACC),
        .DLY(`DLY)
    ) pe_cell_dut (
        .clk(m_if.clk),
        .rst_n(m_if.rst_n),
        .pe_id(m_if.pe_id),
        .psel(m_if.psel),
        .paddr(m_if.paddr),
        .pwrite(m_if.pwrite),
        .pwdata(m_if.pwdata),
        .penable(m_if.penable),
        .prdata(m_if.prdata),
        .pready(m_if.pready),
        .wdata(m_if.wdata),
        .wdata_valid(m_if.wdata_valid),
        .wdata_busy(m_if.wdata_busy),
        .wdata_last(m_if.wdata_last),
        .rdata(m_if.rdata),
        .rdata_valid(m_if.rdata_valid),
        .rdata_busy(m_if.rdata_busy),
        .rdata_last(m_if.rdata_last),
        .cs_n(m_if.cs_n),
        .cvalid(m_if.cvalid),
        .pe_busy(m_if.pe_busy),
        .work_mode(m_if.work_mode),
        .waddr(m_if.waddr)
    );

    // start simulation
    initial begin
        $timeformat(-9, 1, "ns", 5);
        run_test();
    end



    // dump fsdb
    `ifdef DUMP
    initial begin//do_not_remove 
        $fsdbAutoSwitchDumpfile(1000, "./fsdb/test_fsdb.fsdb", 10);//do_not_remove 
        $fsdbDumpvars(0, my_pecell_top);//do_not_remove 
        $fsdbDumpMDA(1000, my_pecell_top);//do_not_remove 
        // $fsdbDumpflush();//do_not_remove 
        //$fsdbDumpvars("+all");//do_not_remove 
    end//do_not_remove 
    `endif

    // initial begin
    //     forever begin
    //         repeat(1000) @(posedge m_if.clk);
    //         $fsdbDumpflush()
    //     end
    // end






endmodule: my_pecell_top
