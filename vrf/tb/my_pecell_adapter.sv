///////////////////////////////////////////////
// file name  : my_pecell_adapter.sv
// creat time : 2020-04-23
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_pecell_adapter.sv
// log        : no
///////////////////////////////////////////////


//  Class: my_pecell_adapter
//
class my_pecell_adapter extends uvm_reg_adapter;
    `uvm_object_utils(my_pecell_adapter);

    //  Group: Variables
    

    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_pecell_adapter");
        super.new(name);
        provides_responses = 1;
    endfunction: new

    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        my_pecell_apb_transaction tr;
        tr = my_pecell_apb_transaction::type_id::create("tr");
        tr.kind = (rw.kind == UVM_WRITE) ? my_pecell_apb_transaction::WRITE : my_pecell_apb_transaction::READ;
        tr.addr = rw.addr;
        tr.data = rw.data;
        return tr;
    endfunction

    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        my_pecell_apb_transaction tr;
        if ($cast(tr, bus_item)) begin
            `uvm_fatal(get_type_name(), "type of bus_item is not correct")
        end
        rw.kind = (tr.kind == my_pecell_apb_transaction::WRITE) ? UVM_WRITE : UVM_READ;
        rw.data = tr.data;
        rw.addr = tr.addr;
        rw.status = UVM_IS_OK;
    endfunction
    
endclass: my_pecell_adapter
