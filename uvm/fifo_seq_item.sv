// fifo_seq_item.sv
// Basic UVM sequence item for Asynchronous FIFO
`ifndef FIFO_SEQ_ITEM_SV
`define FIFO_SEQ_ITEM_SV

class fifo_seq_item extends uvm_sequence_item;

  // ------------------------------------------------------------
  // Data members
  // ------------------------------------------------------------
  rand bit        wn;           // Write enable
  rand bit        rn;           // Read enable
  rand logic [7:0]  data_in;      // Data to be written
       logic [7:0]  data_out;     // Data read from FIFO
       bit        full;         // FIFO full flag (sampled)
       bit        empty;        // FIFO empty flag (sampled)

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------
  function new(string name = "fifo_seq_item");
    super.new(name);
  endfunction
  // ------------------------------------------------------------
  // UVM Macros
  // ------------------------------------------------------------
  `uvm_object_utils_begin(fifo_seq_item)
    `uvm_field_int(wn,      UVM_ALL_ON)
    `uvm_field_int(rn,      UVM_ALL_ON)
    `uvm_field_int(data_in, UVM_ALL_ON)
    `uvm_field_int(data_out,UVM_ALL_ON)
    `uvm_field_int(full,    UVM_ALL_ON)
    `uvm_field_int(empty,   UVM_ALL_ON)
  `uvm_object_utils_end

  constraint D{ data_in inside {[0:255]};};

  // ------------------------------------------------------------
  // Utility methods for printing
  // ------------------------------------------------------------
  function string convert2string();
    return $sformatf("wn=%0b rn=%0b data_in=%0h data_out=%0h full=%0b empty=%0b",
                     wn, rn, data_in, data_out, full, empty);
  endfunction


endclass : fifo_seq_item

`endif
