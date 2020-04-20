module testbench_pe_cell();

`define DUMP;
string dump_file;
initial begin
    `ifdef DUMP
        if($value$plusargs("FSDB=%s",dump_file))
            $display("dump_file = %s",dump_file);
        $fsdbDumpfile(dump_file);        
        $fsdbDumpvars(0, testbench_pe_cell);
        $fsdbDumpMDA();
    `endif

end

parameter vcd_start = 100000;
parameter vcd_hold = 100;

initial begin
    `ifdef VCD_ON
        #vcd_start;
        $dumpfile("./vcd_pe_cell.vcd");
        $dumpvars(0,testbench_pe_cell.dut);
        #vcd_hold;
        # 100;
        $fclose("./vcd_pe_cell.vcd");
    `endif
end


parameter t = 20;
parameter rst_time = 5;
parameter rst_time_delete = 10;
parameter finish_time = 1000001;

parameter WID_X   = 6;
parameter WID_Y   = 8;
parameter ROW     = 36;
parameter COL     = 2**WID_Y;
parameter WID_BUS = 8;
parameter WID_ACC = 22;
parameter PE_ID   = 7'd127;
parameter DLY     = 1;

logic clk;
logic rst_n;
logic psel;
logic [3:0]paddr;
logic pwrite;
logic [7:0]pwdata;
logic penable;
logic [7:0]prdata;
logic pready;
logic [WID_BUS-1:0]wdata;
logic wdata_valid;
logic wdata_busy;
logic wdata_last;
logic [WID_BUS-1:0]rdata;
logic rdata_valid;
logic rdata_busy;
logic rdata_last;
logic cs_n;
logic cvalid;
logic pe_busy;
logic [1:0]work_mode;
logic [4:0]waddr;
pe_cell #(
	.WID_X      (WID_X),
	.WID_Y      (WID_Y),
	.ROW  		(ROW),
	.COL  		(COL),
	.WID_BUS    (WID_BUS),
	.WID_ACC    (WID_ACC),
	.PE_ID  	(PE_ID),
	.DLY  		(DLY)
)dut(
	.clk(clk),
	.rst_n(rst_n),
	.psel(psel),
	.paddr(paddr),
	.pwrite(pwrite),
	.pwdata(pwdata),
	.penable(penable),
	.prdata(prdata),
	.pready(pready),
	.wdata(wdata),
	.wdata_valid(wdata_valid),
	.wdata_busy(wdata_busy),
	.wdata_last(wdata_last),
	.rdata(rdata),
	.rdata_valid(rdata_valid),
	.rdata_busy(rdata_busy),
	.rdata_last(rdata_last),
	.cs_n(cs_n),
	.cvalid(cvalid),
	.pe_busy(pe_busy),
	.work_mode(work_mode),
	.waddr(waddr)
);

initial begin   //clock
    clk = 1'b0;
    forever begin
        #(t/2) clk = ~clk;
    end
end

initial begin   //reset
    rst_n = 1'b1;
    #rst_time rst_n = 1'b0;
    #rst_time_delete rst_n = 1'b1;
end

initial begin       //finish
    # finish_time;
    $finish;
end

// ============== result list ============== //
// xin:    0     8'h01     8'hff    
// wei:    x     8'hff     8'hff
// result: 0	 8'hdc	   8'h24
logic [COL-1:0]mem_data[ROW-1:0];
initial begin 
	for (int i = 0; i < ROW; i++) begin
		// mem_data[i] = $random();
		mem_data[i] = {COL{1'b1}};
	end
end

logic [7:0]xin_data[ROW-1:0];
initial begin 
	for (int i = 0; i < ROW; i++) begin
		// xin_data[i] = 8'h00;
		// xin_data[i] = 8'h01;
		xin_data[i] = 8'hff;
	end
end

initial begin 
	psel = 'd0;
	paddr = 'd0;
	pwrite = 'd0;
	pwdata = 'd0;
	penable = 'd0;
	wdata = 'd0;
	wdata_valid = 'd0;
	wdata_last = 'd0;
	rdata_busy = 'd1;
	cs_n = 'd1;
	cvalid = 'd0;
	work_mode = 'd0;
	waddr = 'd0;
	@(posedge rst_n); @(posedge clk);
	// =========== configure register =========== //
	write_register(0,8'h02);
	write_register(4,{4'd14,2'b00,2'b01});
	
	// =========== write rram units =========== //
	for (int i_addr = 0; i_addr < (COL/WID_Y); i_addr++) begin
		logic [7:0]temp_data[ROW-1:0];
		for (int j = 0; j < ROW; j++) begin
			temp_data[j] = mem_data[j][i_addr*8+:8];
		end
		write_mem(i_addr,temp_data);
	end

	// =========== computing in rram  =========== //
	computing(xin_data);

	// =========== read rram units  =========== //
	// write_register(4,{4'd15,2'b00,2'b01}); // configure data trunction register to output result[7:0]
	// read_mem(0);
end

initial begin 
	forever begin 
		@(posedge rdata_valid); @(negedge clk) rdata_busy = 1'b0;
		for (int i = 0; i <= COL/8; i++) begin
			/* code */
			@(posedge clk); $display("%2d byte: rdata = 8'h%2h",i,rdata);
		end
		@(negedge rdata_valid); rdata_busy = 1'b1;
	end
end

// ==================== write rram units task ================= //
localparam COMPUTE_MODE_PA = 2'b01;
localparam READ_MODE_PA = 2'b10;
localparam WRITE_MODE_PA = 2'b11;
task write_mem(input [4:0]addr, input [7:0]data[ROW-1:0]);
	$display("*-*-*-*-*-*-*-*- RUNING WRITE MEMORY TASK OF PE_CELL TEST CASE -*-*-*-*-*-*-*-*");

	@(posedge clk);
	cs_n = 1'b0;
	repeat(2) @(posedge clk);
	cvalid = 1'b1; waddr = addr; work_mode = WRITE_MODE_PA;
	@(posedge clk); cvalid = 1'b0;
	repeat(2) @(posedge clk); 
	// while(wdata_busy != 1'b0) begin 
	// 	;
	// end
	wdata_valid = 1'b1; 
	for (int i = 0; i < ROW; i++) begin
		wdata = data[i];
		if(i == ROW-1) begin 
			wdata_last = 1'b1;
		end
		@(posedge clk);
	end	
	wdata_valid = 1'b0; wdata_last = 1'b0;
	@(posedge clk); cs_n = 1'b1;

	@(negedge pe_busy);
endtask : write_mem

// ==================== read rram units task ================= //
task read_mem(input [5:0]addr);
	logic [7:0]temp_data[ROW-1:0];

	$display("*-*-*-*-*-*-*-*- RUNING READ MEMORY TASK OF PE_CELL TEST CASE -*-*-*-*-*-*-*-*");
	for (int i = 0; i < ROW; i++) begin
		/* code */
		temp_data[i] = 8'h00;
	end
	temp_data[addr] = 8'h01;

	@(posedge clk);
	cs_n = 1'b0;
	repeat(2) @(posedge clk);
	cvalid = 1'b1; work_mode = READ_MODE_PA;
	@(posedge clk); cvalid = 1'b0;
	repeat(2) @(posedge clk); 
	// while(wdata_busy != 1'b0) begin 
	// 	;
	// end
	
	wdata_valid = 1'b1; 
	for (int i = 0; i < ROW; i++) begin
		wdata = temp_data[i];
		if(i == ROW-1) begin 
			wdata_last = 1'b1;
		end
		@(posedge clk);
	end	
	wdata_valid = 1'b0; wdata_last = 1'b0;
	@(posedge clk); cs_n = 1'b1;

	@(negedge pe_busy);

endtask : read_mem

// ==================== configure register using APB protocol task ================= //
task write_register(input [3:0]addr, input [7:0]data);
	$display("*-*-*-*-*-*-*-*- RUNING WRITE REGISTER TASK OF PE_CELL TEST CASE -*-*-*-*-*-*-*-*");
	@(posedge clk);
	paddr = addr; pwdata = data; psel = 1'b1; pwrite = 1'b1;
	@(posedge clk); penable = 1'b1;
	@(posedge clk); psel = 1'b0; pwrite = 1'b0; penable = 1'b0;
endtask : write_register

// ==================== PIM task ================= //
task computing(input [7:0]data[ROW-1:0]);
	$display("*-*-*-*-*-*-*-*- RUNING COMPUTING TASK OF PE_CELL TEST CASE      -*-*-*-*-*-*-*-*");
	@(posedge clk);
	cs_n = 1'b0; rdata_busy = 1'b1;
	repeat(2) @(posedge clk);
	cvalid = 1'b1; work_mode = COMPUTE_MODE_PA;
	@(posedge clk); cvalid = 1'b0;
	repeat(2) @(posedge clk); 
	// while(wdata_busy != 1'b0) begin 
	// 	;
	// end
	wdata_valid = 1'b1; 
	for (int i = 0; i < ROW; i++) begin
		wdata = data[i];
		if(i == ROW-1) begin 
			wdata_last = 1'b1;
		end
		@(posedge clk);
	end	
	wdata_valid = 1'b0; wdata_last = 1'b0;
	@(posedge clk); cs_n = 1'b1;

	@(negedge pe_busy);
endtask : computing

endmodule

