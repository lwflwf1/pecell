module pe_cell_reg_inf #(
	parameter DLY = 1
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	input psel,
	input [3:0]paddr,
	input pwrite,
	input [7:0]pwdata,
	input penable,

	output reg [7:0]prdata,
	output pready,

	output [31:0]reg_set_cycle,
	output [7:0]reg_reuse
	// output [15:0]reg_data_trunc

);

localparam SET_CYCLE0_PA = 4'h0;
localparam SET_CYCLE1_PA = 4'h1;
localparam SET_CYCLE2_PA = 4'h2;
localparam SET_CYCLE3_PA = 4'h3;
localparam REUSE_PA      = 4'h4;

wire write;

wire reg_set_cycle0_wr;
wire reg_set_cycle1_wr;
wire reg_set_cycle2_wr;
wire reg_set_cycle3_wr;
wire reg_reuse_wr;

wire [7:0]reg_set_cycle0;
wire [7:0]reg_set_cycle1;
wire [7:0]reg_set_cycle2;
wire [7:0]reg_set_cycle3;


assign write  = pwrite & psel & penable & pready;
assign read   = ~pwrite & psel & ~penable;
assign pready = 1'b1;

assign reg_set_cycle0_wr = write & (paddr == SET_CYCLE0_PA);
assign reg_set_cycle1_wr = write & (paddr == SET_CYCLE1_PA);
assign reg_set_cycle2_wr = write & (paddr == SET_CYCLE2_PA);
assign reg_set_cycle3_wr = write & (paddr == SET_CYCLE3_PA);
assign reg_reuse_wr      = write & (paddr == REUSE_PA);

assign reg_set_cycle = {reg_set_cycle3,reg_set_cycle2,reg_set_cycle1,reg_set_cycle0};


REG_RW #(
	.INI(8'h02)
) U_REG_RW_REG_SET_CYCLE0(
.clk    (clk)           ,
.rst_n	(rst_n)         ,
.wen 	(reg_set_cycle0_wr),
.din 	(pwdata)           ,
.dout 	(reg_set_cycle0)           
);

REG_RW #(
	.INI(8'h00)
) U_REG_RW_REG_SET_CYCLE1(
.clk    (clk)           ,
.rst_n	(rst_n)         ,
.wen 	(reg_set_cycle1_wr),
.din 	(pwdata)           ,
.dout 	(reg_set_cycle1)           
);

REG_RW #(
	.INI(8'h00)
) U_REG_RW_REG_SET_CYCLE2(
.clk    (clk)           ,
.rst_n	(rst_n)         ,
.wen 	(reg_set_cycle2_wr),
.din 	(pwdata)           ,
.dout 	(reg_set_cycle2)           
);

REG_RW #(
	.INI(8'h00)
) U_REG_RW_REG_SET_CYCLE3(
.clk    (clk)           ,
.rst_n	(rst_n)         ,
.wen 	(reg_set_cycle3_wr),
.din 	(pwdata)           ,
.dout 	(reg_set_cycle3)           
);

REG_RW #(
	.INI({4'h6,4'h1})
) U_REG_RW_REG_REUSE(
.clk    (clk)           ,
.rst_n	(rst_n)         ,
.wen 	(reg_reuse_wr),
.din 	(pwdata)           ,
.dout 	(reg_reuse)           
);

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		prdata <= 'd0;
	end else begin
		if(read == 1'b1) begin 
			case(paddr)
				SET_CYCLE0_PA: prdata <= #DLY reg_set_cycle0;
				SET_CYCLE1_PA: prdata <= #DLY reg_set_cycle1;
				SET_CYCLE2_PA: prdata <= #DLY reg_set_cycle2;
				SET_CYCLE3_PA: prdata <= #DLY reg_set_cycle3;
				REUSE_PA: prdata <= #DLY reg_reuse;
				default: prdata <= #DLY 'd0;
			endcase
		end
		else begin 
			prdata <= #DLY 'd0;
		end
	end
end
endmodule


