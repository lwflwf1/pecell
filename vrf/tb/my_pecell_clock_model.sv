///////////////////////////////////////////////
// file name  : my_pecell_clock_model.sv
// creat time : 2020-04-21
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_pecell_clock_model.sv
// log        : no
///////////////////////////////////////////////

//  Module: my_pecell_clock_model
//
module my_pecell_clock_model
    /*  package imports  */
    #(
        // parameter_list
    )(
        output logic clk,
        output logic rst_n
    );
    
    initial begin
        rst_n = 1'b0;
        #1000 rst_n = 1'b1;
    end

    initial begin
        clk <= 1'b0;
        forever #(`PERIOD/2) clk = ~clk;
    end
    
endmodule: my_pecell_clock_model








