module  REG_RC(
clk           ,
rst_n         ,
ren           ,
din           ,
dout              
);
parameter     INI = 32'h0  ;
parameter     DLY = 1      ;
input              clk     ;
input              rst_n   ;
input              ren     ;
input   [31:0]     din     ;
output  [31:0]     dout    ;

reg     [31:0]     mem     ;
wire    [31:0]     dout    ;
genvar   i                 ;
for(i=0;i<32;i=i+1) begin
always @(negedge rst_n or posedge clk) begin
    if(rst_n == 1'b0) begin
        mem[i] <= 1'b0;
    end
    else begin
        if(din[i] == 1'b1) begin
            mem[i] <= #DLY 1'b1;
        end
        else if(ren == 1'b1) begin
            mem[i] <= #DLY 1'b0;
        end
    end
end
end

assign dout = mem;

endmodule
