module ripple_counter #(
    parameter WID_COUNT = 6
    )(
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    
    output [WID_COUNT-1:0]result
);

wire [WID_COUNT:0]Q;
wire [WID_COUNT-1:0]Q_n;

assign Q[0] = clk;
genvar i;
generate
for(i=0;i<WID_COUNT;i=i+1) begin 
    dff u_dff(
        .clk  (Q[i]),
        .rst_n(rst_n),
        .D    (Q_n[i]),
        .Q    (Q[i+1]),
        .Q_n  (Q_n[i])
    );
end
endgenerate

assign result = Q_n;
endmodule