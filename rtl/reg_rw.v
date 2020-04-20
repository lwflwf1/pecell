module  REG_RW(
clk           ,
rst_n         ,
wen           ,
din           ,
dout           
);
parameter     INI = 8'h0  ;
parameter     DLY = 1      ;
input              clk     ;
input              rst_n   ;
input              wen     ;
input   [7:0]     din     ;
output  [7:0]     dout    ;

reg     [7:0]     mem     ;
wire    [7:0]     dout    ;


always @(negedge rst_n or posedge clk) begin
    if(rst_n == 1'b0) begin
        mem <= INI;
    end
    else begin
        if (wen == 1'b1) begin
            mem <= #DLY din;
        end
    end
end
assign dout = mem;

endmodule
