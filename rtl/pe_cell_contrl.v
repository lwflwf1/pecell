module pe_cell_contrl #(
	parameter WID_X = 6,
    parameter WID_Y = 8,
    parameter ROW = 36,
    parameter COL = 2**WID_Y,
    parameter NUM_Y = COL/8,
    parameter WID_BUS = 8,
    parameter WID_ACC = 22,
    parameter DLY   = 1
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	input [6:0]pe_id, // PE Block ID

	input [WID_BUS-1:0]wdata,
	input wdata_valid,
	input wdata_last,
	output reg wdata_busy,

	output reg [WID_BUS-1:0]rdata,
	output reg rdata_valid,
	output reg rdata_last,
	input rdata_busy,

	input cs_n,
	input cvalid,
	output reg pe_busy,
	input [1:0]work_mode,
	input [4:0]waddr,

	output reg rst_pe_rram, // pe rram reset

	output reg [ROW-1:0]xin,// x output reg
    output reg pulse_in, //output reg pause
    input pim_ready, //output data valid signal

    input [WID_X*COL-1:0]partial_result, //colum output pause

    output reg [WID_Y-1:0]bl_address, // bit line control
    output reg bl_en,
    output reg bl_work_mode, //0:write rram; 1:other mode

    output reg [WID_X-1:0]wl_address, // word line control
    output reg wl_en,
    output reg wl_work_mode, //0:write rram; 1:other mode

    output reg rram_set,
    output reg rram_rset,

    input [31:0]reg_set_cycle, // rram set_cycle config
    input [1:0]reg_set_level, // rram set and rst level voltage
    input [1:0]reg_work_mode,
    input [3:0]reg_data_trunc
);

// ============================= work mode of pe_cell define ============================= //
localparam COMPUTE_MODE_PA = 2'b01;
localparam READ_MODE_PA = 2'b10;
localparam WRITE_MODE_PA = 2'b11;

// ============================= state machine define ============================= //
localparam IDLE      = 3'b001;
localparam WRITE_MEM = 3'b010;
localparam PIM_MEM   = 3'b100;
reg [2:0]cur_state;
reg [2:0]next_state;

// ============================= configure load logic ============================= //
reg [1:0]real_work_mode;
reg [4:0]reg_waddr;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		reg_waddr <= 'd0;
		real_work_mode <= 'd0;
	end else begin
		if(cs_n == 1'b0 && cvalid == 1'b1 && pe_busy == 1'b0) begin 
			reg_waddr <= #DLY waddr;
			real_work_mode <= #DLY work_mode;
		end
	end
end

// ============================= pe_busy logic ============================= //
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		pe_busy <= 1'b0;
	end else begin
		if(cur_state == PIM_MEM || cur_state == WRITE_MEM) begin 
			if(next_state == IDLE) begin 
				pe_busy <= #DLY 1'b0;
			end
			else if(wdata_valid == 1'b1) begin 
				pe_busy <= #DLY 1'b1;
			end
		end
	end
end

// ============================= cs_n edge ============================= //
reg cs_n_d1;
reg cs_n_d2;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{cs_n_d2,cs_n_d1} <= 2'b00;
	end else begin
		{cs_n_d2,cs_n_d1} <= {cs_n_d1,cs_n};
	end
end

wire cs_n_neg;
assign cs_n_neg = cs_n_d2 & (~cs_n_d1);

// ============================= write rram logic ============================= //
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		wdata_busy <= 1'b1;
	end else begin
		if(cs_n_neg == 1'b1 || cur_state == IDLE) begin 
			wdata_busy <= #DLY 1'b0;
		end
		else if(wdata_last == 1'b1) begin 
			wdata_busy <= #DLY 1'b1;
		end
	end
end

reg [5:0]cnt_rev_wdata;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		cnt_rev_wdata <= 'd0;
	end else begin
		if((cur_state == WRITE_MEM || cur_state == PIM_MEM) && wdata_valid == 1'b1 && wdata_busy == 1'b0) begin 
			if(cnt_rev_wdata != 6'd35) begin 
				cnt_rev_wdata <= #DLY cnt_rev_wdata + 1'b1;
			end
		end
		else if(cur_state == IDLE) begin 
			cnt_rev_wdata <= #DLY 'd0;
		end
	end
end

reg [7:0]pe_cache[ROW-1:0];
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		pe_cache[0] <= 'd0;
		pe_cache[1] <= 'd0;
		pe_cache[2] <= 'd0;
		pe_cache[3] <= 'd0;
		pe_cache[4] <= 'd0;
		pe_cache[5] <= 'd0;
		pe_cache[6] <= 'd0;
		pe_cache[7] <= 'd0;
		pe_cache[8] <= 'd0;
		pe_cache[9] <= 'd0;
		pe_cache[10] <= 'd0;
		pe_cache[11] <= 'd0;
		pe_cache[12] <= 'd0;
		pe_cache[13] <= 'd0;
		pe_cache[14] <= 'd0;
		pe_cache[15] <= 'd0;
		pe_cache[16] <= 'd0;
		pe_cache[17] <= 'd0;
		pe_cache[18] <= 'd0;
		pe_cache[19] <= 'd0;
		pe_cache[20] <= 'd0;
		pe_cache[21] <= 'd0;
		pe_cache[22] <= 'd0;
		pe_cache[23] <= 'd0;
		pe_cache[24] <= 'd0;
		pe_cache[25] <= 'd0;
		pe_cache[26] <= 'd0;
		pe_cache[27] <= 'd0;
		pe_cache[28] <= 'd0;
		pe_cache[29] <= 'd0;
		pe_cache[30] <= 'd0;
		pe_cache[31] <= 'd0;
		pe_cache[32] <= 'd0;
		pe_cache[33] <= 'd0;
		pe_cache[34] <= 'd0;
		pe_cache[35] <= 'd0;
	end else begin
		if((cur_state == WRITE_MEM || cur_state == PIM_MEM) && wdata_valid == 1'b1 && wdata_busy == 1'b0) begin 
			pe_cache[cnt_rev_wdata] <= #DLY wdata;
		end
		else if(cur_state == IDLE) begin 
			pe_cache[0] <= #DLY 'd0;
			pe_cache[1] <= #DLY 'd0;
			pe_cache[2] <= #DLY 'd0;
			pe_cache[3] <= #DLY 'd0;
			pe_cache[4] <= #DLY 'd0;
			pe_cache[5] <= #DLY 'd0;
			pe_cache[6] <= #DLY 'd0;
			pe_cache[7] <= #DLY 'd0;
			pe_cache[8] <= #DLY 'd0;
			pe_cache[9] <= #DLY 'd0;
			pe_cache[10] <= #DLY 'd0;
			pe_cache[11] <= #DLY 'd0;
			pe_cache[12] <= #DLY 'd0;
			pe_cache[13] <= #DLY 'd0;
			pe_cache[14] <= #DLY 'd0;
			pe_cache[15] <= #DLY 'd0;
			pe_cache[16] <= #DLY 'd0;
			pe_cache[17] <= #DLY 'd0;
			pe_cache[18] <= #DLY 'd0;
			pe_cache[19] <= #DLY 'd0;
			pe_cache[20] <= #DLY 'd0;
			pe_cache[21] <= #DLY 'd0;
			pe_cache[22] <= #DLY 'd0;
			pe_cache[23] <= #DLY 'd0;
			pe_cache[24] <= #DLY 'd0;
			pe_cache[25] <= #DLY 'd0;
			pe_cache[26] <= #DLY 'd0;
			pe_cache[27] <= #DLY 'd0;
			pe_cache[28] <= #DLY 'd0;
			pe_cache[29] <= #DLY 'd0;
			pe_cache[30] <= #DLY 'd0;
			pe_cache[31] <= #DLY 'd0;
			pe_cache[32] <= #DLY 'd0;
			pe_cache[33] <= #DLY 'd0;
			pe_cache[34] <= #DLY 'd0;
			pe_cache[35] <= #DLY 'd0;
		end
	end
end

reg write_mem_ready;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		write_mem_ready <= 1'b0;
	end else begin
		if(cur_state == WRITE_MEM && next_state != IDLE && cnt_rev_wdata == 6'd35) begin 
			write_mem_ready <= #DLY 1'b1;
		end
		else if(cur_state == WRITE_MEM && next_state == IDLE) begin
			write_mem_ready <= #DLY 1'b0;
		end
	end
end

reg [2:0]cnt_rram_col;
reg [5:0]cnt_rram_row;
reg [31:0]cnt_set_cycle;

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		cnt_rram_col <= 'd0;
	end else begin
		if(write_mem_ready == 1'b1) begin 
			if(cnt_set_cycle == reg_set_cycle) begin 
				cnt_rram_col <= #DLY cnt_rram_col + 1'b1;
			end
		end
		else begin 
			cnt_rram_col <= #DLY 'd0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		cnt_rram_row <= 'd0;
	end else begin
		if(write_mem_ready == 1'b1) begin 
			if(cnt_rram_row != (ROW-1'b1)) begin 
				if(cnt_rram_col == 3'd7 && cnt_set_cycle == reg_set_cycle) begin 
					cnt_rram_row <= #DLY cnt_rram_row + 1'b1;
				end
			end
			else if(cnt_rram_col == 3'd7 && cnt_set_cycle == reg_set_cycle) begin 
				cnt_rram_row <= #DLY 'd0;
			end
		end
		else begin 
			cnt_rram_row <= #DLY 'd0;
		end
	end
end

wire write_value;
assign write_value = cur_state == WRITE_MEM ? pe_cache[cnt_rram_row][cnt_rram_col] : 1'b0;

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		cnt_set_cycle <= 'd0;
	end else begin
		if(write_mem_ready == 1'b1) begin
			if(cnt_set_cycle != reg_set_cycle) begin
				cnt_set_cycle <= #DLY cnt_set_cycle + 1'b1;
			end
			else begin 
				cnt_set_cycle <= #DLY 'd0;
			end
		end
		else begin 
			cnt_set_cycle <= #DLY 'd0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		rram_set <= 1'b0;
	end
	else begin
		rram_set <= #DLY (cur_state == WRITE_MEM) && (write_mem_ready == 1'b1) && (write_value == reg_set_level[0]);
	end 
end

always @(posedge clk or negedge rst_n) begin 
	if(~rst_n) begin
		rram_rset <= 1'b0;
	end
	else begin
		rram_rset <= #DLY (cur_state == WRITE_MEM) && (write_mem_ready == 1'b1) && (write_value == reg_set_level[1]);
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		wl_en <= 1'b0;
		wl_address <= 'd0;
		wl_work_mode <= 1'b1;

		bl_en <= 1'b0;
		bl_address <= 'd0;
		bl_work_mode <= 1'b1;
	end else begin
		if(cur_state == WRITE_MEM) begin 
			wl_en <= #DLY 1'b1;
			wl_address <= #DLY cnt_rram_row;
			wl_work_mode <= #DLY 1'b0;

			bl_en <= #DLY 1'b1;
			bl_address <= #DLY cnt_rram_col + (reg_waddr << 3);
			bl_work_mode <= #DLY 1'b0;
		end
		else begin 
			wl_en <= #DLY 1'b0;
			wl_address <= #DLY 'd0;
			wl_work_mode <= #DLY 1'b1;

			bl_en <= #DLY 1'b0;
			bl_address <= #DLY 'd0;
			bl_work_mode <= #DLY 1'b1;
		end
	end
end

// ============================= computing in rram logic ============================= //
reg computing_ready;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		computing_ready <= 1'b0;
	end else begin
		computing_ready <= #DLY (cnt_rev_wdata == 6'd35) && (cur_state == PIM_MEM);
	end
end

reg computing_ready_d1;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		computing_ready_d1 <= 'd0;
	end else begin
		computing_ready_d1 <= #DLY computing_ready;
	end
end

reg pim_ready_d1;
reg pim_ready_d2;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{pim_ready_d2,pim_ready_d1} <= 2'b00;
	end else begin
		{pim_ready_d2,pim_ready_d1} <= #DLY {pim_ready_d1,pim_ready};
	end
end

wire pim_ready_neg;
assign pim_ready_neg = pim_ready_d2 & (~pim_ready_d1);

wire pim_ready_pos;
assign pim_ready_pos = pim_ready_d1 & (~pim_ready_d2);

reg [2:0]cnt_x_wid;
always @(posedge clk or negedge rst_n) begin : proc_cnt_x_wid
	if(~rst_n) begin
		cnt_x_wid <= 'd0;
	end else begin
		if(computing_ready == 1'b1 && pim_ready_neg == 1'b1 && cnt_x_wid != 3'd7) begin
			cnt_x_wid <= #DLY cnt_x_wid + 1'b1;
		end
		else if(computing_ready == 1'b0) begin 
			cnt_x_wid <= #DLY 'd0;
		end
	end
end

reg pulse_in_temp1;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		pulse_in_temp1 <= 1'b0;
	end else begin
		if(computing_ready == 1'b1) begin 
			if(pulse_in_temp1 == 1'b1) begin 
				pulse_in_temp1 <= #DLY 1'b0;
			end
			else if((pim_ready_neg == 1'b1) && (cnt_x_wid != 3'd7)) begin 
				pulse_in_temp1 <= #DLY 1'b1;
			end
		end
		else begin 
			pulse_in_temp1 <= #DLY 1'b0;
		end
	end
end

reg pulse_in_temp2;
always @(*) begin 
	pulse_in_temp2 = (~computing_ready_d1 & computing_ready) | pulse_in_temp1;
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		pulse_in <= 'd0;
	end else begin
		pulse_in <= #DLY pulse_in_temp2;
	end
end

always @(negedge rst_n or posedge clk) begin
    if(rst_n == 1'b0) begin
		xin <= 'd0;
    end else begin
    	if(computing_ready == 1'b1) begin 
			if(pulse_in_temp2 == 1'b1) begin 
				xin <= #DLY {pe_cache[0][cnt_x_wid],pe_cache[1][cnt_x_wid],pe_cache[2][cnt_x_wid],pe_cache[3][cnt_x_wid],
							 pe_cache[4][cnt_x_wid],pe_cache[5][cnt_x_wid],pe_cache[6][cnt_x_wid],pe_cache[7][cnt_x_wid],
							 pe_cache[8][cnt_x_wid],pe_cache[9][cnt_x_wid],pe_cache[10][cnt_x_wid],pe_cache[11][cnt_x_wid],
							 pe_cache[12][cnt_x_wid],pe_cache[13][cnt_x_wid],pe_cache[14][cnt_x_wid],pe_cache[15][cnt_x_wid],
							 pe_cache[16][cnt_x_wid],pe_cache[17][cnt_x_wid],pe_cache[18][cnt_x_wid],pe_cache[19][cnt_x_wid],
							 pe_cache[20][cnt_x_wid],pe_cache[21][cnt_x_wid],pe_cache[22][cnt_x_wid],pe_cache[23][cnt_x_wid],
							 pe_cache[24][cnt_x_wid],pe_cache[25][cnt_x_wid],pe_cache[26][cnt_x_wid],pe_cache[27][cnt_x_wid],
							 pe_cache[28][cnt_x_wid],pe_cache[29][cnt_x_wid],pe_cache[30][cnt_x_wid],pe_cache[31][cnt_x_wid],
							 pe_cache[32][cnt_x_wid],pe_cache[33][cnt_x_wid],pe_cache[34][cnt_x_wid],pe_cache[35][cnt_x_wid]
							 };
			end
		end
		else begin 
			xin <= #DLY 'd0;
		end
    end
end

// ================= pe_rram reset generate =============== //
reg rst_pe_rram_reg;
always @(posedge clk or negedge rst_n) begin : proc_rst_pe_rram
	if(~rst_n) begin
		rst_pe_rram_reg <= 1'b1;
	end else begin
		if(pim_ready_pos == 1'b1) begin
			rst_pe_rram_reg <= #DLY 1'b0;
		end
		else if(rst_pe_rram_reg == 1'b0) begin 
			rst_pe_rram_reg <= #DLY 1'b1;
		end
	end		
end

always @(*) begin 
	rst_pe_rram = rst_pe_rram_reg && rst_n;
end

// ================= parital sum result  =============== //

wire [WID_ACC-1:0]col_sum[NUM_Y-1:0];
genvar i1;
generate
for(i1=0;i1<NUM_Y;i1=i1+1) begin 
assign col_sum[i1] = (cur_state == PIM_MEM && real_work_mode == COMPUTE_MODE_PA) ? 
					 ((partial_result[(i1*8+1)*WID_X-1:i1*8*WID_X] << 0)     + (partial_result[(i1*8+2)*WID_X-1:(i1*8+1)*WID_X] << 1) + 
					 (partial_result[(i1*8+3)*WID_X-1:(i1*8+2)*WID_X] << 2)  + (partial_result[(i1*8+4)*WID_X-1:(i1*8+3)*WID_X] << 3) +
					 (partial_result[(i1*8+5)*WID_X-1:(i1*8+4)*WID_X] << 4)  + (partial_result[(i1*8+6)*WID_X-1:(i1*8+5)*WID_X] << 5) + 
					 (partial_result[(i1*8+7)*WID_X-1:(i1*8+6)*WID_X] << 6)  - (partial_result[(i1*8+8)*WID_X-1:(i1*8+7)*WID_X] << 7)):
					 (cur_state == PIM_MEM && real_work_mode == READ_MODE_PA) ? 
					 {partial_result[7*WID_X+i1*WID_X*8],partial_result[6*WID_X+i1*WID_X*8],partial_result[5*WID_X+i1*WID_X*8],partial_result[4*WID_X+i1*WID_X*8],
					  partial_result[3*WID_X+i1*WID_X*8],partial_result[2*WID_X+i1*WID_X*8],partial_result[WID_X+i1*WID_X*8],partial_result[i1*WID_X*8]} :
					  'd0;
end
endgenerate

reg [WID_ACC-1:0]xin_sum[NUM_Y-1:0]; // signal bit: 21bit
genvar i2;
generate
for(i2 = 0; i2 < NUM_Y; i2 = i2 + 1) begin 
always @(posedge clk or negedge rst_n) begin : proc_cell_result
	if(~rst_n) begin
		xin_sum[i2] <= 'd0;
	end else begin
		if(cur_state == PIM_MEM && real_work_mode == COMPUTE_MODE_PA) begin 
			if(pim_ready_pos == 1'b1) begin
				// $display("col_sum[%2d] = %h",i2,col_sum[i2]);
				// $display("cnt_x_wid = %2d",cnt_x_wid);
				if(cnt_x_wid != 'd7) begin
					xin_sum[i2] <= #DLY xin_sum[i2] + (col_sum[i2]<<cnt_x_wid);
				end
				else begin 
					xin_sum[i2] <= #DLY xin_sum[i2] - (col_sum[i2]<<cnt_x_wid);
				end
				// $display("xin_sum[%2d] = %h\n",i2,xin_sum[i2]);
			end
		end
		else if(cur_state == PIM_MEM && real_work_mode == READ_MODE_PA) begin 
			if(pim_ready_pos == 1'b1 && cnt_x_wid == 'd0) begin
				xin_sum[i2] <= #DLY col_sum[i2];
			end
		end
		else if(cur_state == IDLE) begin 
			xin_sum[i2] <= #DLY 'd0;
		end
	end
end
end
endgenerate

reg result_valid;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		result_valid <= 1'b0;
	end else begin
		if(pim_ready_pos == 1'b1 && cnt_x_wid == 3'd7 && cur_state == PIM_MEM) begin
			result_valid <= #DLY 1'b1;
		end
		else if(cur_state == IDLE) begin 
			result_valid <= #DLY 1'b0;
		end
	end
end

// ============================= send computing result ============================= //

reg id_cycle;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		id_cycle <= 1'b0;
	end else begin
		if(cur_state == PIM_MEM && rdata_valid == 1'b1 && rdata_busy == 1'b0) begin 
			id_cycle <= #DLY 1'b1;
		end
		else if(cur_state == IDLE) begin 
			id_cycle <= #DLY 1'b0;
		end
	end
end

reg [4:0]cnt_send_rdata;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		cnt_send_rdata <= 'd0;
	end else begin
		if(cur_state == PIM_MEM && rdata_valid == 1'b1 && rdata_busy == 1'b0 && id_cycle == 1'b1) begin 
			if(cnt_send_rdata != 5'd31) begin
				cnt_send_rdata <= #DLY cnt_send_rdata + 1'b1;
			end
		end
		else if(cur_state == IDLE) begin 
			cnt_send_rdata <= #DLY 'd0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		rdata_last <= 1'b0;
	end else begin
		if(rdata_busy == 1'b0) begin 
			if(rdata_last == 1'b1) begin 
				rdata_last <= #DLY 1'b0;
			end
			else if(cnt_send_rdata == 5'd30) begin 
				rdata_last <= #DLY 1'b1;
			end
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		rdata_valid <= 1'b0;
	end else begin
		if(rdata_last == 1'b1 && rdata_busy == 1'b0) begin 
			rdata_valid <= #DLY 1'b0;
		end
		else if(result_valid == 1'b1 && cur_state == PIM_MEM) begin 
			rdata_valid <= #DLY 1'b1;
		end
	end
end

reg [7:0]cut_data_temp;
always @(*) begin 
	case(reg_data_trunc)
		4'd0: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-2:WID_ACC-8]};
		4'd1: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-3:WID_ACC-9]};
		4'd2: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-4:WID_ACC-10]};
		4'd3: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-5:WID_ACC-11]};
		4'd4: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-6:WID_ACC-12]};
		4'd5: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-7:WID_ACC-13]};
		4'd6: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-8:WID_ACC-14]};
		4'd7: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-9:WID_ACC-15]};
		4'd8: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-10:WID_ACC-16]};
		4'd9: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-11:WID_ACC-17]};
		4'd10: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-12:WID_ACC-18]};
		4'd11: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-13:WID_ACC-19]};
		4'd12: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-14:WID_ACC-20]};
		4'd13: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-15:WID_ACC-21]};
		4'd14: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-1],xin_sum[cnt_send_rdata][WID_ACC-16:WID_ACC-22]};
		default: cut_data_temp = {xin_sum[cnt_send_rdata][WID_ACC-15:WID_ACC-22]};
	endcase

	rdata = (id_cycle == 1'b0 && rdata_busy == 1'b0 && rdata_valid == 1'b1) ? {1'b0,pe_id} : 
			(id_cycle == 1'b1 && rdata_busy == 1'b0 && rdata_valid == 1'b1) ? cut_data_temp : 'd0;
end

// ============================= read rram logic ============================= //


// ============================= state machine ============================= //
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		cur_state <= 'd0;
	end else begin
		cur_state <= #DLY next_state;
	end
end

always @(*) begin 
	case(cur_state)
		IDLE: begin 
			if(cs_n == 1'b0 && cvalid == 1'b1) begin 
				if(work_mode == WRITE_MODE_PA) begin 
					next_state = WRITE_MEM;
				end
				else if(work_mode == COMPUTE_MODE_PA || work_mode == READ_MODE_PA) begin 
					next_state = PIM_MEM;
				end
				else begin 
					next_state = IDLE;
				end
			end
			else begin 
				next_state = IDLE;
			end
		end
		WRITE_MEM: begin 
			if(cnt_rram_row == (ROW-1'b1) && cnt_rram_col == 3'd7 && cnt_set_cycle == reg_set_cycle) begin 
				next_state = IDLE;
			end
			else begin 
				next_state = WRITE_MEM;
			end
		end
		PIM_MEM: begin 
			if(cnt_send_rdata == 5'd31) begin 
				next_state = IDLE;
			end
			else begin
				next_state = PIM_MEM;
			end
		end
		default: begin 
			next_state = IDLE;
		end
	endcase
end

endmodule



