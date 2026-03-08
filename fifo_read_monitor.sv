//fifo_read_monitor.sv
`ifndef FIFO_READ_MONITOR_SV
`define FIFO_READ_MONITOR_SV

class fifo_read_monitor extends uvm_monitor;
`uvm_component_utils(fifo_read_monitor)

virtual fifo_if vif;
uvm_analysis_port #(fifo_seq_item) item_collected_port;

function new(string name = "fifo_read_monitor", uvm_component parent = null);
  super.new(name, parent);
  item_collected_port = new("item_collected_port", this);
endfunction

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
    `uvm_fatal(get_type_name(),"Virtual Interface not found for read monitor")
  else    `uvm_info(get_type_name(),"Read Interface Connected successfully", UVM_LOW);
endfunction

virtual task run_phase(uvm_phase phase);
  `uvm_info(get_type_name(),"Starting read monitor run phase", UVM_LOW)

  forever begin
    // Wait for read clock edge
    @(vif.mon_r_cb);

    if(vif.mon_r_cb.rn) begin
      fifo_seq_item item = fifo_seq_item::type_id::create("mon_item");
      item.rn       = vif.mon_r_cb.rn;
      item.data_out = vif.mon_r_cb.data_out;
      item.empty    = vif.mon_r_cb.empty;

      // Send transaction to analysis port
      item_collected_port.write(item);

      // Logging
      `uvm_info("READ_MONITOR", $sformatf("Observed READ: Data=0x%0h Empty=%0b", item.data_out, item.empty), UVM_MEDIUM)
    end
  end
endtask
endclass: fifo_read_monitor
`endif
