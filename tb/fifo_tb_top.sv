//fifo_tb_top.sv
`ifndef FIFO_TB_TOP_SV
`define FIFO_TB_TOP_SV
`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fifo_package.sv"

module fifo_tb_top;
  import fifo_package::*;

  // Clock and Reset signals
  logic wclk, rclk;
  logic wrst_n, rrst_n;

  // Interface
  fifo_if fifo_if_inst(.wclk(wclk), .rclk(rclk), .wrst_n(wrst_n), .rrst_n(rrst_n));
  
  // DUT instantiation
  async_fifo #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(3)
  ) dut (
    .wclk(wclk),
    .rclk(rclk),
    .wrst_n(wrst_n),
    .rrst_n(rrst_n),
    .w_en(fifo_if_inst.wn),
    .r_en(fifo_if_inst.rn),
    .data_in(fifo_if_inst.data_in),
    .data_out(fifo_if_inst.data_out),
    .full(fifo_if_inst.full),
    .empty(fifo_if_inst.empty)
  );
  
  // Clock generation
  initial begin
    wclk = 0;
    forever #5 wclk = ~wclk; // 100MHz write clock
  end

  initial begin
    rclk = 0;
    forever #7 rclk = ~rclk; // ~71MHz read clock
  end

  // Reset generation
  initial begin
    wrst_n = 0;
    rrst_n = 0;
    #20 wrst_n = 1;  // release write reset
    #30 rrst_n = 1;  // release read reset
  end

  // Set virtual interface for UVM components
  initial begin
    uvm_config_db#(virtual fifo_if)::set(null, "*", "vif", fifo_if_inst);
  end

  // Run UVM test
  initial begin
    run_test("fifo_test");
  end

endmodule
`endif
