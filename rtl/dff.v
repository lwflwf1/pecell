module dff #(
    parameter DLY = 1
    )(
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    input D,

    output reg Q,
    output Q_n
);

always @(negedge rst_n or posedge clk) begin
    if(rst_n == 1'b0) begin
        Q <= 1'b1;
    end else begin
        Q <= #DLY D;
    end
end

assign Q_n = ~Q;

endmodule


