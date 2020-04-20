`define EN_SYSN
module pe_rram #(
    parameter WID_X = 6,
    parameter WID_Y = 8,
    parameter ROW = 36,
    parameter COL = 2**WID_Y,
    parameter DLY   = 1
)(
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input [ROW-1:0]xin,// x input
    input pulse_in, //input pause
    // output reg [(WID_X+1)*COL-1:0]cnt_out, //colum output
    output reg [COL-1:0]cnt_out, //colum output pause
    output reg pim_ready, //output data valid signal

    input [WID_Y-1:0]bl_address, // bit line control
    input bl_en,
    input bl_work_mode, //0:write rram; 1:other mode

    input [WID_X-1:0]wl_address, // word line control
    input wl_en,
    input wl_work_mode, //0:write rram; 1:other mode

    input rram_set,
    input rram_rset

);


// ================ results of output ============= //
reg [WID_X-1:0]dout_delay_reg;
`ifdef EN_SYSN
always @(*) begin 
    dout_delay_reg = xin[0] + xin[1] + xin[2] + xin[3] + xin[4] + xin[5] + xin[6] + xin[7] +
                 xin[8] + xin[9] + xin[10] + xin[11] + xin[12] + xin[13] + xin[14] + xin[15] +
                 xin[16] + xin[17] + xin[18] + xin[19] + xin[20] + xin[21] + xin[22] + xin[23] +
                 xin[24] + xin[25] + xin[26] + xin[27] + xin[28] + xin[29] + xin[30] + xin[31] + 
                 xin[32] + xin[33] + xin[34] + xin[35];
end
`else 
always @(*) begin 
    dout_delay_reg = $countones(xin);
end
`endif

wire [WID_X-1:0]dout_delay;
assign dout_delay = (dout_delay_reg == 0) ? dout_delay_reg + 1'b1 : dout_delay_reg;

reg [WID_X-1:0]word_line_real;
reg [WID_Y-1:0]bit_line_real;

// =================== write mode ===========================//
reg [ROW-1:0]rram_mem[COL-1:0];
always @(posedge clk) begin
    if(bl_work_mode == 1'b0 && wl_work_mode == 1'b0 && bl_en == 1'b1 && wl_en == 1'b1) begin
        if(rram_set == 1'b1 && rram_rset == 1'b0) begin 
            rram_mem[bl_address][wl_address] <= #DLY 1'b1;
        end
        else if(rram_set == 1'b0 && rram_rset == 1'b1) begin 
            rram_mem[bl_address][wl_address]<= #DLY 1'b0;
        end
    end
end

// =================== computing mode =======================//
reg [WID_X:0]result[COL-1:0];
genvar k;
generate
for(k=0;k<COL;k=k+1) begin
always @(negedge rst_n or posedge clk) begin
    if(rst_n == 1'b0) begin
        result[k] <= 'd0;
    end else begin
        if(pulse_in == 1'b1) begin 
            `ifdef EN_SYSN
            result[k] <= #DLY (rram_mem[k][0] & xin[0]) + (rram_mem[k][1] & xin[1]) + (rram_mem[k][2] & xin[2]) + (rram_mem[k][3] & xin[3]) +
                              (rram_mem[k][4] & xin[4]) + (rram_mem[k][5] & xin[5]) + (rram_mem[k][6] & xin[6]) + (rram_mem[k][7] & xin[7]) +
                              (rram_mem[k][8] & xin[8]) + (rram_mem[k][9] & xin[9]) + (rram_mem[k][10] & xin[10]) + (rram_mem[k][11] & xin[11]) +
                              (rram_mem[k][12] & xin[12]) + (rram_mem[k][13] & xin[13]) + (rram_mem[k][14] & xin[14]) + (rram_mem[k][15] & xin[15]) +
                              (rram_mem[k][16] & xin[16]) + (rram_mem[k][17] & xin[17]) + (rram_mem[k][18] & xin[18]) + (rram_mem[k][19] & xin[19]) +
                              (rram_mem[k][20] & xin[20]) + (rram_mem[k][21] & xin[21]) + (rram_mem[k][22] & xin[22]) + (rram_mem[k][23] & xin[23]) +
                              (rram_mem[k][24] & xin[24]) + (rram_mem[k][25] & xin[25]) + (rram_mem[k][26] & xin[26]) + (rram_mem[k][27] & xin[27]) +
                              (rram_mem[k][28] & xin[28]) + (rram_mem[k][29] & xin[29]) + (rram_mem[k][30] & xin[30]) + (rram_mem[k][31] & xin[31]) +
                              (rram_mem[k][32] & xin[32]) + (rram_mem[k][33] & xin[33]) + (rram_mem[k][34] & xin[34]) + (rram_mem[k][35] & xin[35]);
            `else
            result[k] <= #DLY $countones(rram_mem[k] & xin);
            `endif
        end
    end
end
end
endgenerate

reg [WID_X:0]cnt_dout_wait;
reg start_compute;
always @(negedge rst_n or posedge clk) begin
    if(rst_n == 1'b0) begin
        start_compute <= 1'b0;
    end else begin
        if(pulse_in == 1'b1 && bl_work_mode == 1'b1 && wl_work_mode == 1'b1) begin 
            start_compute <= #DLY 1'b1;
        end
        else if(cnt_dout_wait == (dout_delay-1'b1)) begin 
            start_compute <= #DLY 1'b0;
        end
    end
end

always @(negedge rst_n or posedge clk) begin
    if(rst_n == 1'b0) begin
        cnt_dout_wait <= 'd0;
    end else begin
         if((start_compute == 1'b1) && (cnt_dout_wait != (dout_delay-1'b1))) begin 
            cnt_dout_wait <= #DLY cnt_dout_wait + 1'b1;
         end
         else begin 
            cnt_dout_wait <= #DLY 'd0;
         end
    end
end

always @(negedge rst_n or posedge clk) begin
    if(rst_n == 1'b0) begin
        pim_ready <= 1'b0;
    end else begin
        if(cnt_dout_wait == (dout_delay-1'b1) && (start_compute | pulse_in)== 1'b1) begin 
            pim_ready <= #DLY 1'b1;
        end
    end
end

// genvar l;
// generate
// for(l=0;l<COL;l=l+1) begin : result_blk
// always @(negedge rst_n or posedge clk) begin
//     if(rst_n == 1'b0) begin
//         cnt_out[(l+1)*(WID_X+1)-1:l*(WID_X+1)] <= 'd0;
//     end else begin
//         if(cnt_dout_wait == (dout_delay-1'b1) && start_compute == 1'b1) begin 
//             cnt_out[(l+1)*(WID_X+1)-1:l*(WID_X+1)] <= #DLY result[l];
//         end
//     end
// end
// end
// endgenerate

reg [WID_X:0]cnt_pause[COL-1:0];
genvar l;
generate
for(l=0;l<COL;l=l+1) begin : result_blk
always @(negedge rst_n or posedge clk) begin
    if(rst_n == 1'b0) begin
        cnt_pause[l] <= 'd0;
    end else begin
        if(start_compute == 1'b1) begin 
            if(cnt_pause[l] != result[l]) begin
                cnt_pause[l] <= #DLY cnt_pause[l] + 1'b1;
            end
        end
        else begin 
            cnt_pause[l] <= #DLY 'd0;
        end
    end
end
end
endgenerate

genvar i;
generate
for(i=0;i<COL;i=i+1) begin 
always @(*) begin
    cnt_out[i] = (cnt_pause[i] != result[i] && start_compute == 1'b1) ? clk : 1'b1;
end
end
endgenerate

endmodule