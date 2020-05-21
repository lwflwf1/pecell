module pe_cell #(
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
    input [4:0]waddr,

    // rram cell signal
    output rst_pe_rram,
    output [ROW-1:0]xin, // x input
    output pulse_in, //input pause

    input [COL-1:0]cnt_out, //colum output pause
    input pim_ready, //output data valid signal

    output [WID_Y-1:0]bl_address, // bit line control
    output bl_en,
    output bl_work_mode, //0:write rram; 1:other mode

    output [WID_X-1:0]wl_address, // word line control
    output wl_en,
    output wl_work_mode, //0:write rram; 1:other mode

    output rram_set,
    output rram_rset

);

// register 
wire [31:0]reg_set_cycle;
wire [7:0]reg_reuse;
wire [WID_ACC*(COL/8)-1:0]reg_acc;
wire [WID_BUS*ROW-1:0]reg_pe_cache;
wire [7:0]reg_alarm;

wire [WID_X*COL-1:0]partial_result; //colum output

// wire rst_pe_rram;
// wire [ROW-1:0]xin;// x input
// wire pulse_in; //input pause
// wire [COL-1:0]cnt_out; //colum output
// wire pim_ready; //output data valid signal
// wire [WID_X-1:0]wl_address; // word line control
// wire wl_en;
// wire wl_work_mode;
// wire [WID_Y-1:0]bl_address;
// wire bl_en;
// wire bl_work_mode;
// wire rram_set;
// wire rram_rset;

pe_cell_contrl #(
    .WID_X      (WID_X),
    .WID_Y      (WID_Y),
    .ROW        (ROW),
    .COL        (COL),
    .WID_BUS    (WID_BUS),
    .WID_ACC    (WID_ACC),
    .DLY        (DLY)
    ) u_pe_cell_contrl(
    .clk           (clk),
    .rst_n         (rst_n),
    .pe_id         (pe_id),
    .wdata         (wdata),
    .wdata_valid   (wdata_valid),
    .wdata_busy    (wdata_busy),
    .wdata_last    (wdata_last),
    .rdata         (rdata),
    .rdata_valid   (rdata_valid),
    .rdata_busy    (rdata_busy),
    .rdata_last    (rdata_last),
    .cs_n          (cs_n),
    .cvalid        (cvalid),
    .pe_busy       (pe_busy),
    .work_mode     (work_mode),
    .waddr         (waddr),
    .rst_pe_rram   (rst_pe_rram),
    .xin           (xin),
    .pulse_in      (pulse_in),
    .partial_result(partial_result),
    .pim_ready     (pim_ready),
    .bl_address    (bl_address),
    .bl_en         (bl_en),
    .bl_work_mode  (bl_work_mode),
    .wl_address    (wl_address),
    .wl_en         (wl_en),
    .wl_work_mode  (wl_work_mode),
    .rram_set      (rram_set),
    .rram_rset     (rram_rset),
    .reg_set_cycle (reg_set_cycle),
    .reg_set_level (reg_reuse[1:0]),
    .reg_work_mode (reg_reuse[3:2]),
    .reg_data_trunc(reg_reuse[7:4]),
    .reg_acc       (reg_acc),
    .reg_pe_cache  (reg_pe_cache),
    .reg_alarm     (reg_alarm)
);


pe_cell_reg_inf #(
    .ROW        (ROW),
    .WID_Y      (WID_Y),
    .WID_ACC    (WID_ACC),
    .WID_BUS    (WID_BUS),
    .DLY        (DLY)
    ) u_pe_cell_reg_inf(
    .clk          (clk),
    .rst_n        (rst_n),
    .psel         (psel),
    .paddr        (paddr),
    .pwrite       (pwrite),
    .pwdata       (pwdata),
    .penable      (penable),
    .prdata       (prdata),
    .pready       (pready),

    .reg_set_cycle(reg_set_cycle),
    .reg_reuse    (reg_reuse),
    .reg_acc      (reg_acc),
    .reg_pe_cache (reg_pe_cache),
    .reg_alarm    (reg_alarm)
);

// pe_rram #(
//       .WID_X      (WID_X),
//       .WID_Y      (WID_Y),
//       .ROW              (ROW),
//       .COL              (COL),
//       .DLY              (DLY)
//       ) u_pe_rram (
//       .clk(clk),
//       .rst_n(rst_pe_rram),
//       .xin(xin),
//       .pulse_in(pulse_in),
//       .cnt_out(cnt_out),
//       .pim_ready(pim_ready),
//       .bl_address  (bl_address),
//       .bl_en       (bl_en),
//       .bl_work_mode(bl_work_mode),
//       .wl_address  (wl_address),
//       .wl_en       (wl_en),
//       .wl_work_mode(wl_work_mode),
//       .rram_set    (rram_set),
//       .rram_rset   (rram_rset)
// );


genvar i1;
generate
for (i1 = 0; i1 < COL; i1=i1+1) begin :ripple_counter_col
ripple_counter #(.WID_COUNT(WID_X)) u_ripple_counter(
    .clk   (cnt_out[i1]),
    .rst_n (rst_pe_rram),
    .result(partial_result[(i1+1)*WID_X-1:i1*WID_X])
    );
end
endgenerate

endmodule



