// fifo_package.sv
`ifndef FIFO_PACKAGE_SV
`define FIFO_PACKAGE_SV

package fifo_package;

  // Include UVM library
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "fifo_seq_item.sv"
  `include "fifo_base_seq.sv"

  `include "fifo_write_driver.sv"
  `include "fifo_write_monitor.sv"
  `include "fifo_read_driver.sv"
  `include "fifo_read_monitor.sv"
  `include "fifo_sequencer.sv"
  `include "fifo_write_agent.sv"
  `include "fifo_read_agent.sv"
  `include "fifo_scoreboard.sv"
  `include "fifo_env.sv"
  `include "fifo_test.sv"

endpackage : fifo_package

`endif
