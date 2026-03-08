// fifo_sequencer.sv
// UVM Sequencer for Asynchronous FIFO
`ifndef FIFO_SEQUENCER_SV
`define FIFO_SEQUENCER_SV

class fifo_sequencer extends uvm_sequencer #(fifo_seq_item);
`uvm_component_utils(fifo_sequencer)
  function new(string name = "fifo_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Build phase: fifo_sequencer created successfully", UVM_LOW)
  endfunction
endclass : fifo_sequencer

`endif
