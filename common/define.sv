// Clock Period, default: 10ns
`ifndef PERIOD
`define PERIOD 10
`endif

// simulation timeout, default: 5s
`ifndef TIMEOUT
`define TIMEOUT 5s
`endif

// DUT parameters
`ifndef WID_X
`define WID_X 6
`endif

`ifndef WID_Y
`define WID_Y 8
`endif

`ifndef ROW
`define ROW 36
`endif

`ifndef COL
`define COL 2**`WID_Y
`endif

`ifndef WID_BUS
`define WID_BUS 8
`endif

`ifndef WID_ACC
`define WID_ACC 24
`endif

`ifndef PE_ID
`define PE_ID 7'd0
`endif

`ifndef DLY
`define DLY 1
`endif

typedef enum logic {LOW, RAND} rdata_busy_mode_e;
typedef enum logic[1:0] {IDLE, CALCULATE, READ, WRITE} work_mode_e;
