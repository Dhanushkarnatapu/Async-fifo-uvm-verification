// fifo_if.sv
// Interface for an asynchronous FIFO (separate write/read clocks & resets)
timeunit 1ns;
timeprecision 1ps;
interface fifo_if (
  input  logic wclk,     // write clock
  input  logic rclk,     // read clock
  input  logic wrst_n,   // active-low write-side reset
  input  logic rrst_n    // active-low read-side reset
);

  // FIFO functional signals (shared)
  logic                  wn;        // write enable (driven by producer/driver)
  logic                  rn;        // read enable  (driven by consumer/driver)
  logic [7:0]            data_in;   // data written into FIFO (write domain)
  logic [7:0]            data_out;  // data read from FIFO  (read domain)
  logic                  full;      // FIFO full flag (driven by design)
  logic                  empty;     // FIFO empty flag (driven by design)

  ////////////////////////////////////////////////////////////////////////////
  // Clocking blocks
  //
  // For asynchronous FIFOs we provide separate clocking blocks for the write
  // domain and the read domain. This lets driver/monitor sample and drive
  // signals synchronously to the correct clock, and avoids bus-racing.
  ////////////////////////////////////////////////////////////////////////////

  // --- write-side clocking (for driving writes and sampling 'full') ---
  clocking wb_cb @(posedge wclk);
    // avoid races: sample inputs a small delta after the active edge
    default input #1 output #1;

    // Driver (testbench) will drive write-side signals via this clocking:
    output wn;
    output data_in;

    // The DUT drives status visible to the write side; driver will sample:
    input  full;
  endclocking

  // --- read-side clocking (for driving reads and sampling 'empty' & data_out) ---
  clocking rb_cb @(posedge rclk);
    default input #1 output #1;

    // Driver (testbench) will drive read enable via this clocking:
    output rn;

    // Monitor/driver will sample these from DUT on read clock:
    input  empty;
    input  data_out;
  endclocking

  // --- monitor clocking(s) ---
  // Monitor is passive: it only samples. Provide both clockings for convenience.
  clocking mon_w_cb @(posedge wclk);
    default input #1 output #1;
    // sample write-side activity (wn, data_in, full)
    input wn;
    input data_in;
    input full;
  endclocking

  clocking mon_r_cb @(posedge rclk);
    default input #1 output #1;
    // sample read-side activity (rn, data_out, empty)
    input rn;
    input data_out;
    input empty;
  endclocking

  ////////////////////////////////////////////////////////////////////////////
  // Modports: give a clean API to UVM components
  //
  // DRIVER_WR: driver methods that operate in the write domain (drive wn/data_in)
  // DRIVER_RD: driver methods that operate in the read domain (drive rn)
  // MONITOR_WR/MONITOR_RD: monitors that sample signals in their respective domains
  // TOP: for connecting the DUT in the top module (DUT uses plain signals)
  ////////////////////////////////////////////////////////////////////////////
  modport DRIVER_WR  (clocking wb_cb,  input  wclk, wrst_n);   // write-side driver
  modport DRIVER_RD  (clocking rb_cb,  input  rclk, rrst_n);   // read-side driver
  modport MONITOR_WR (clocking mon_w_cb, input wclk, wrst_n);  // write-side monitor
  modport MONITOR_RD (clocking mon_r_cb, input rclk, rrst_n);  // read-side monitor

  // Top-level connection for DUT: DUT will see raw signals (no clocking)
  // (Some prefer a TOP modport that exposes signals; exposing everything here)
  modport TOP (input wclk, input rclk, input wrst_n, input rrst_n,
               input wn, input rn, input data_in, output data_out,
               output full, output empty);

endinterface
