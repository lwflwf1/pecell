///////////////////////////////////////////////
// file name  : my_pecell_register_model.sv
// creat time : 2020-04-23
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_pecell_register_model.sv
// log        : no
///////////////////////////////////////////////

//  Class: register_set_cycle
//
class register_set_cycle0 extends uvm_reg;
    `uvm_object_utils(register_set_cycle0);

    //  Group: Variables
    rand uvm_reg_field field;
    

    //  Group: Functions

    //  Constructor: new
    function new(string name = "register_set_cycle0");
        super.new(name, 8, UVM_CVR_ALL);
    endfunction: new

    virtual function build();
        field = uvm_reg_field::type_id::create("field");
        field.configure(this, 8, 0, "RW", 0, 8'h2, 1, 1, 0);
    endfunction

    
endclass: register_set_cycle0

class register_set_cycle extends uvm_reg;
    `uvm_object_utils(register_set_cycle);

    //  Group: Variables
    rand uvm_reg_field field;
    

    //  Group: Functions

    //  Constructor: new
    function new(string name = "register_set_cycle");
        super.new(name, 8, UVM_CVR_ALL);
    endfunction: new

    virtual function void build();
        field = uvm_reg_field::type_id::create("field");
        field.configure(this, 8, 0, "RW", 0, 8'h0, 1, 1, 0);
    endfunction

    
endclass: register_set_cycle

//  Class: register_reuse
//
class register_reuse extends uvm_reg;
    `uvm_object_utils(register_reuse);

    //  Group: Variables
    rand uvm_reg_field output_config;
    rand uvm_reg_field work_mode;
    rand uvm_reg_field rram_set;
    

    //  Group: Functions

    //  Constructor: new
    function new(string name = "register_reuse");
        super.new(name, 8, UVM_CVR_ALL);
    endfunction: new

    virtual function void build();
        output_config = uvm_reg_field::type_id::create("output_config");
        work_mode = uvm_reg_field::type_id::create("work_mode");
        rram_set = uvm_reg_field::type_id::create("rram_set");
        output_config.configure(this, 4, 4, "RW", 0, 4'h6, 1, 1, 0);
        work_mode.configure(this, 2, 2, "RW", 0, 2'h0, 1, 1, 0);
        rram_set.configure(this, 2, 0, "RW", 0, 2'h1, 1, 1, 0);
    endfunction

    
endclass: register_reuse


//  Class: my_pecell_register_model
//
class my_pecell_register_model extends uvm_reg_block;
    `uvm_object_utils(my_pecell_register_model);

    //  Group: Variables
    rand register_set_cycle0 reg_set_cycle0;
    rand register_set_cycle reg_set_cycle1;
    rand register_set_cycle reg_set_cycle2;
    rand register_set_cycle reg_set_cycle3;
    rand register_reuse reg_reuse;

    uvm_reg_map map;
    

    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_pecell_register_model");
        super.new(name, UVM_CVR_ALL);
    endfunction: new

    virtual function void build();
        reg_set_cycle0 = register_set_cycle0::type_id::create("reg_set_cycle0");
        reg_set_cycle1 = register_set_cycle::type_id::create("reg_set_cycle1");
        reg_set_cycle2 = register_set_cycle::type_id::create("reg_set_cycle2");
        reg_set_cycle3 = register_set_cycle::type_id::create("reg_set_cycle3");
        reg_reuse = register_reuse::type_id::create("reg_reuse");
        reg_set_cycle0.configure(this, null, "");
        reg_set_cycle1.configure(this, null, "");
        reg_set_cycle2.configure(this, null, "");
        reg_set_cycle3.configure(this, null, "");
        reg_reuse.configure(this, null, "");
        reg_set_cycle0.build();
        reg_set_cycle1.build();
        reg_set_cycle2.build();
        reg_set_cycle3.build();
        reg_reuse.build();
        map = create_map("map", 'h0, 1, UVM_LITTLE_ENDIAN, 0);
        map.add_reg(reg_set_cycle0, 4'h0, "RW");
        map.add_reg(reg_set_cycle1, 4'h1, "RW");
        map.add_reg(reg_set_cycle2, 4'h2, "RW");
        map.add_reg(reg_set_cycle3, 4'h3, "RW");
        map.add_reg(reg_reuse, 4'h4, "RW");
        lock_model();
        add_hdl_path("my_pecell_top.pe_cell_dut.u_pe_cell.u_pe_cell_reg_inf");
        reg_set_cycle0.add_hdl_path_slice("U_REG_RW_REG_SET_CYCLE0.mem", 0, 8);
        reg_set_cycle1.add_hdl_path_slice("U_REG_RW_REG_SET_CYCLE1.mem", 0, 8);
        reg_set_cycle2.add_hdl_path_slice("U_REG_RW_REG_SET_CYCLE2.mem", 0, 8);
        reg_set_cycle3.add_hdl_path_slice("U_REG_RW_REG_SET_CYCLE3.mem", 0, 8);
        reg_reuse.add_hdl_path_slice("U_REG_RW_REG_REUSE.mem", 0, 8);
    endfunction

    
endclass: my_pecell_register_model


