module pe_cell_reg_inf #(
	parameter ROW     = 36,
    parameter WID_Y   = 8,
    parameter NUM_Y   = (2**WID_Y)/8,
    parameter WID_BUS = 8,
    parameter WID_ACC = 24,
    parameter DLY     = 1
)(
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    
    input psel,
    input [7:0]paddr,
    input pwrite,
    input [7:0]pwdata,
    input penable,

    output reg [7:0]prdata,
    output pready,

    output [31:0]reg_set_cycle,
    output [7:0]reg_reuse,
    input [WID_ACC*NUM_Y-1:0]reg_acc,
    input [WID_BUS*ROW-1:0]reg_pe_cache,
    input [7:0]reg_alarm

);

localparam SET_CYCLE0_PA = 8'h00;
localparam SET_CYCLE1_PA = 8'h01;
localparam SET_CYCLE2_PA = 8'h02;
localparam SET_CYCLE3_PA = 8'h03;
localparam REUSE_PA      = 8'h04;

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
    .INI(8'h50)
) U_REG_RW_REG_SET_CYCLE0(
.clk    (clk)              ,
.rst_n  (rst_n)            ,
.wen    (reg_set_cycle0_wr),
.din    (pwdata)           ,
.dout   (reg_set_cycle0)           
);

REG_RW #(
    .INI(8'hc3)
) U_REG_RW_REG_SET_CYCLE1(
.clk    (clk)              ,
.rst_n  (rst_n)            ,
.wen    (reg_set_cycle1_wr),
.din    (pwdata)           ,
.dout   (reg_set_cycle1)           
);

REG_RW #(
    .INI(8'h00)
) U_REG_RW_REG_SET_CYCLE2(
.clk    (clk)              ,
.rst_n  (rst_n)            ,
.wen    (reg_set_cycle2_wr),
.din    (pwdata)           ,
.dout   (reg_set_cycle2)           
);

REG_RW #(
    .INI(8'h00)
) U_REG_RW_REG_SET_CYCLE3(
.clk    (clk)              ,
.rst_n  (rst_n)            ,
.wen    (reg_set_cycle3_wr),
.din    (pwdata)           ,
.dout   (reg_set_cycle3)           
);

REG_RW #(
    .INI({5'd6,1'b0,2'b01})
) U_REG_RW_REG_REUSE(
.clk    (clk)         ,
.rst_n  (rst_n)       ,
.wen    (reg_reuse_wr),
.din    (pwdata)      ,
.dout   (reg_reuse)           
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
                8'd5: prdata <= #DLY reg_acc[(0+1)*8-1:0*8];
                8'd6: prdata <= #DLY reg_acc[(1+1)*8-1:1*8];
                8'd7: prdata <= #DLY reg_acc[(2+1)*8-1:2*8];
                8'd8: prdata <= #DLY reg_acc[(3+1)*8-1:3*8];
                8'd9: prdata <= #DLY reg_acc[(4+1)*8-1:4*8];
                8'd10: prdata <= #DLY reg_acc[(5+1)*8-1:5*8];
                8'd11: prdata <= #DLY reg_acc[(6+1)*8-1:6*8];
                8'd12: prdata <= #DLY reg_acc[(7+1)*8-1:7*8];
                8'd13: prdata <= #DLY reg_acc[(8+1)*8-1:8*8];
                8'd14: prdata <= #DLY reg_acc[(9+1)*8-1:9*8];
                8'd15: prdata <= #DLY reg_acc[(10+1)*8-1:10*8];
                8'd16: prdata <= #DLY reg_acc[(11+1)*8-1:11*8];
                8'd17: prdata <= #DLY reg_acc[(12+1)*8-1:12*8];
                8'd18: prdata <= #DLY reg_acc[(13+1)*8-1:13*8];
                8'd19: prdata <= #DLY reg_acc[(14+1)*8-1:14*8];
                8'd20: prdata <= #DLY reg_acc[(15+1)*8-1:15*8];
                8'd21: prdata <= #DLY reg_acc[(16+1)*8-1:16*8];
                8'd22: prdata <= #DLY reg_acc[(17+1)*8-1:17*8];
                8'd23: prdata <= #DLY reg_acc[(18+1)*8-1:18*8];
                8'd24: prdata <= #DLY reg_acc[(19+1)*8-1:19*8];
                8'd25: prdata <= #DLY reg_acc[(20+1)*8-1:20*8];
                8'd26: prdata <= #DLY reg_acc[(21+1)*8-1:21*8];
                8'd27: prdata <= #DLY reg_acc[(22+1)*8-1:22*8];
                8'd28: prdata <= #DLY reg_acc[(23+1)*8-1:23*8];
                8'd29: prdata <= #DLY reg_acc[(24+1)*8-1:24*8];
                8'd30: prdata <= #DLY reg_acc[(25+1)*8-1:25*8];
                8'd31: prdata <= #DLY reg_acc[(26+1)*8-1:26*8];
                8'd32: prdata <= #DLY reg_acc[(27+1)*8-1:27*8];
                8'd33: prdata <= #DLY reg_acc[(28+1)*8-1:28*8];
                8'd34: prdata <= #DLY reg_acc[(29+1)*8-1:29*8];
                8'd35: prdata <= #DLY reg_acc[(30+1)*8-1:30*8];
                8'd36: prdata <= #DLY reg_acc[(31+1)*8-1:31*8];
                8'd37: prdata <= #DLY reg_acc[(32+1)*8-1:32*8];
                8'd38: prdata <= #DLY reg_acc[(33+1)*8-1:33*8];
                8'd39: prdata <= #DLY reg_acc[(34+1)*8-1:34*8];
                8'd40: prdata <= #DLY reg_acc[(35+1)*8-1:35*8];
                8'd41: prdata <= #DLY reg_acc[(36+1)*8-1:36*8];
                8'd42: prdata <= #DLY reg_acc[(37+1)*8-1:37*8];
                8'd43: prdata <= #DLY reg_acc[(38+1)*8-1:38*8];
                8'd44: prdata <= #DLY reg_acc[(39+1)*8-1:39*8];
                8'd45: prdata <= #DLY reg_acc[(40+1)*8-1:40*8];
                8'd46: prdata <= #DLY reg_acc[(41+1)*8-1:41*8];
                8'd47: prdata <= #DLY reg_acc[(42+1)*8-1:42*8];
                8'd48: prdata <= #DLY reg_acc[(43+1)*8-1:43*8];
                8'd49: prdata <= #DLY reg_acc[(44+1)*8-1:44*8];
                8'd50: prdata <= #DLY reg_acc[(45+1)*8-1:45*8];
                8'd51: prdata <= #DLY reg_acc[(46+1)*8-1:46*8];
                8'd52: prdata <= #DLY reg_acc[(47+1)*8-1:47*8];
                8'd53: prdata <= #DLY reg_acc[(48+1)*8-1:48*8];
                8'd54: prdata <= #DLY reg_acc[(49+1)*8-1:49*8];
                8'd55: prdata <= #DLY reg_acc[(50+1)*8-1:50*8];
                8'd56: prdata <= #DLY reg_acc[(51+1)*8-1:51*8];
                8'd57: prdata <= #DLY reg_acc[(52+1)*8-1:52*8];
                8'd58: prdata <= #DLY reg_acc[(53+1)*8-1:53*8];
                8'd59: prdata <= #DLY reg_acc[(54+1)*8-1:54*8];
                8'd60: prdata <= #DLY reg_acc[(55+1)*8-1:55*8];
                8'd61: prdata <= #DLY reg_acc[(56+1)*8-1:56*8];
                8'd62: prdata <= #DLY reg_acc[(57+1)*8-1:57*8];
                8'd63: prdata <= #DLY reg_acc[(58+1)*8-1:58*8];
                8'd64: prdata <= #DLY reg_acc[(59+1)*8-1:59*8];
                8'd65: prdata <= #DLY reg_acc[(60+1)*8-1:60*8];
                8'd66: prdata <= #DLY reg_acc[(61+1)*8-1:61*8];
                8'd67: prdata <= #DLY reg_acc[(62+1)*8-1:62*8];
                8'd68: prdata <= #DLY reg_acc[(63+1)*8-1:63*8];
                8'd69: prdata <= #DLY reg_acc[(64+1)*8-1:64*8];
                8'd70: prdata <= #DLY reg_acc[(65+1)*8-1:65*8];
                8'd71: prdata <= #DLY reg_acc[(66+1)*8-1:66*8];
                8'd72: prdata <= #DLY reg_acc[(67+1)*8-1:67*8];
                8'd73: prdata <= #DLY reg_acc[(68+1)*8-1:68*8];
                8'd74: prdata <= #DLY reg_acc[(69+1)*8-1:69*8];
                8'd75: prdata <= #DLY reg_acc[(70+1)*8-1:70*8];
                8'd76: prdata <= #DLY reg_acc[(71+1)*8-1:71*8];
                8'd77: prdata <= #DLY reg_acc[(72+1)*8-1:72*8];
                8'd78: prdata <= #DLY reg_acc[(73+1)*8-1:73*8];
                8'd79: prdata <= #DLY reg_acc[(74+1)*8-1:74*8];
                8'd80: prdata <= #DLY reg_acc[(75+1)*8-1:75*8];
                8'd81: prdata <= #DLY reg_acc[(76+1)*8-1:76*8];
                8'd82: prdata <= #DLY reg_acc[(77+1)*8-1:77*8];
                8'd83: prdata <= #DLY reg_acc[(78+1)*8-1:78*8];
                8'd84: prdata <= #DLY reg_acc[(79+1)*8-1:79*8];
                8'd85: prdata <= #DLY reg_acc[(80+1)*8-1:80*8];
                8'd86: prdata <= #DLY reg_acc[(81+1)*8-1:81*8];
                8'd87: prdata <= #DLY reg_acc[(82+1)*8-1:82*8];
                8'd88: prdata <= #DLY reg_acc[(83+1)*8-1:83*8];
                8'd89: prdata <= #DLY reg_acc[(84+1)*8-1:84*8];
                8'd90: prdata <= #DLY reg_acc[(85+1)*8-1:85*8];
                8'd91: prdata <= #DLY reg_acc[(86+1)*8-1:86*8];
                8'd92: prdata <= #DLY reg_acc[(87+1)*8-1:87*8];
                8'd93: prdata <= #DLY reg_acc[(88+1)*8-1:88*8];
                8'd94: prdata <= #DLY reg_acc[(89+1)*8-1:89*8];
                8'd95: prdata <= #DLY reg_acc[(90+1)*8-1:90*8];
                8'd96: prdata <= #DLY reg_acc[(91+1)*8-1:91*8];
                8'd97: prdata <= #DLY reg_acc[(92+1)*8-1:92*8];
                8'd98: prdata <= #DLY reg_acc[(93+1)*8-1:93*8];
                8'd99: prdata <= #DLY reg_acc[(94+1)*8-1:94*8];
                8'd100: prdata <= #DLY reg_acc[(95+1)*8-1:95*8];
                8'd101: prdata <= #DLY reg_pe_cache[(0+1)*8-1:0*8];
                8'd102: prdata <= #DLY reg_pe_cache[(1+1)*8-1:1*8];
                8'd103: prdata <= #DLY reg_pe_cache[(2+1)*8-1:2*8];
                8'd104: prdata <= #DLY reg_pe_cache[(3+1)*8-1:3*8];
                8'd105: prdata <= #DLY reg_pe_cache[(4+1)*8-1:4*8];
                8'd106: prdata <= #DLY reg_pe_cache[(5+1)*8-1:5*8];
                8'd107: prdata <= #DLY reg_pe_cache[(6+1)*8-1:6*8];
                8'd108: prdata <= #DLY reg_pe_cache[(7+1)*8-1:7*8];
                8'd109: prdata <= #DLY reg_pe_cache[(8+1)*8-1:8*8];
                8'd110: prdata <= #DLY reg_pe_cache[(9+1)*8-1:9*8];
                8'd111: prdata <= #DLY reg_pe_cache[(10+1)*8-1:10*8];
                8'd112: prdata <= #DLY reg_pe_cache[(11+1)*8-1:11*8];
                8'd113: prdata <= #DLY reg_pe_cache[(12+1)*8-1:12*8];
                8'd114: prdata <= #DLY reg_pe_cache[(13+1)*8-1:13*8];
                8'd115: prdata <= #DLY reg_pe_cache[(14+1)*8-1:14*8];
                8'd116: prdata <= #DLY reg_pe_cache[(15+1)*8-1:15*8];
                8'd117: prdata <= #DLY reg_pe_cache[(16+1)*8-1:16*8];
                8'd118: prdata <= #DLY reg_pe_cache[(17+1)*8-1:17*8];
                8'd119: prdata <= #DLY reg_pe_cache[(18+1)*8-1:18*8];
                8'd120: prdata <= #DLY reg_pe_cache[(19+1)*8-1:19*8];
                8'd121: prdata <= #DLY reg_pe_cache[(20+1)*8-1:20*8];
                8'd122: prdata <= #DLY reg_pe_cache[(21+1)*8-1:21*8];
                8'd123: prdata <= #DLY reg_pe_cache[(22+1)*8-1:22*8];
                8'd124: prdata <= #DLY reg_pe_cache[(23+1)*8-1:23*8];
                8'd125: prdata <= #DLY reg_pe_cache[(24+1)*8-1:24*8];
                8'd126: prdata <= #DLY reg_pe_cache[(25+1)*8-1:25*8];
                8'd127: prdata <= #DLY reg_pe_cache[(26+1)*8-1:26*8];
                8'd128: prdata <= #DLY reg_pe_cache[(27+1)*8-1:27*8];
                8'd129: prdata <= #DLY reg_pe_cache[(28+1)*8-1:28*8];
                8'd130: prdata <= #DLY reg_pe_cache[(29+1)*8-1:29*8];
                8'd131: prdata <= #DLY reg_pe_cache[(30+1)*8-1:30*8];
                8'd132: prdata <= #DLY reg_pe_cache[(31+1)*8-1:31*8];
                8'd133: prdata <= #DLY reg_pe_cache[(32+1)*8-1:32*8];
                8'd134: prdata <= #DLY reg_pe_cache[(33+1)*8-1:33*8];
                8'd135: prdata <= #DLY reg_pe_cache[(34+1)*8-1:34*8];
                8'd136: prdata <= #DLY reg_pe_cache[(35+1)*8-1:35*8];
                8'd137: prdata <= #DLY reg_alarm;
                default: prdata <= #DLY 'd0;
            endcase
        end
        else begin 
            prdata <= #DLY 'd0;
        end
    end
end
endmodule


