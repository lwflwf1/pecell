module pe_cell_top #(
    parameter WID_X = 6,
    parameter WID_Y = 8,
    parameter ROW = 36,
    parameter COL = 2**WID_Y,
    parameter WID_BUS = 8,
    parameter WID_ACC = 24,
    parameter DLY   = 1
)(
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input [6:0]pe_id, // PE Block ID
    
    input psel,
    input [7:0]paddr,
    input pwrite,
    input [7:0]pwdata,
    input penable,

    output [7:0]prdata,
    output pready,

    input [WID_BUS-1:0]wdata,
    input wdata_valid,
    output wdata_busy,
    input wdata_last,

    output [WID_BUS-1:0]rdata,
    output rdata_valid,
    input rdata_busy,
    output rdata_last,

    input cs_n,
    input cvalid,
    output pe_busy,
    input [1:0]work_mode,
    input [4:0]waddr
    
);

wire rst_pe_rram;
wire [ROW-1:0]xin;// x input
wire pulse_in; //input pause
wire [COL-1:0]cnt_out; //colum output
wire pim_ready; //output data valid signal
wire [WID_X-1:0]wl_address; // word line control
wire wl_en;
wire wl_work_mode;
wire [WID_Y-1:0]bl_address;
wire bl_en;
wire bl_work_mode;
wire rram_set;
wire rram_rset;

pe_cell #(
    .WID_X      (WID_X),
    .WID_Y      (WID_Y),
    .ROW          (ROW),
    .COL          (COL),
    .WID_BUS    (WID_BUS),
    .WID_ACC    (WID_ACC),
    .DLY          (DLY)
) u_pe_cell( 
    .clk          (clk),
    .rst_n       (rst_n),
    .pe_id          (pe_id),
    .psel          (psel),
    .paddr          (paddr),
    .pwrite      (pwrite),
    .pwdata      (pwdata),
    .penable      (penable),
    .prdata      (prdata),
    .pready      (pready),
    .wdata          (wdata),
    .wdata_valid (wdata_valid),
    .wdata_busy  (wdata_busy),
    .wdata_last  (wdata_last),
    .rdata          (rdata),
    .rdata_valid (rdata_valid),
    .rdata_busy  (rdata_busy),
    .rdata_last  (rdata_last),
    .cs_n          (cs_n),
    .cvalid      (cvalid),
    .pe_busy      (pe_busy),
    .work_mode      (work_mode),
    .waddr          (waddr),
    .rst_pe_rram (rst_pe_rram),
    .xin          (xin),
    .pulse_in      (pulse_in),
    .cnt_out      (cnt_out),
    .pim_ready      (pim_ready),
    .bl_address  (bl_address),
    .bl_en          (bl_en),
    .bl_work_mode(bl_work_mode),
    .wl_address  (wl_address),
    .wl_en          (wl_en),
    .wl_work_mode(wl_work_mode),
    .rram_set      (rram_set),
    .rram_rset      (rram_rset)
);

pe_rram #(
    .WID_X      (WID_X),
    .WID_Y      (WID_Y),
    .ROW          (ROW),
    .COL          (COL),
    .DLY          (DLY)
    ) u_pe_rram (
    .clk(clk),
    .rst_n(rst_pe_rram),
    .xin(xin),
    .pulse_in(pulse_in),
    .cnt_out(cnt_out),
    .pim_ready(pim_ready),
    .bl_address  (bl_address),
    .bl_en       (bl_en),
    .bl_work_mode(bl_work_mode),
    .wl_address  (wl_address),
    .wl_en       (wl_en),
    .wl_work_mode(wl_work_mode),
    .rram_set    (rram_set),
    .rram_rset   (rram_rset)
);

endmodule


