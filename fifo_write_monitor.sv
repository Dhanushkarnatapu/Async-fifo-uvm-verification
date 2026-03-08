// fifo_write_monitor.sv
`ifndef FIFO_WRITE_MONITOR_SV
`define FIFO_WRITE_MONITOR_SV

class fifo_write_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_write_monitor)
  virtual fifo_if vif;
  uvm_analysis_port #(fifo_seq_item) item_collected_port;

  function new(string name="fifo_write_monitor", uvm_component parent=null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Virtual interface not found for write monitor")
    else
      `uvm_info(get_type_name(), "Write interface connected successfully", UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Starting Write Monitor run_phase", UVM_LOW)
    forever begin
        fifo_seq_item item;

        // Wait for a write clock edge
        @(vif.mon_w_cb);

        if(vif.mon_w_cb.wn) begin
            item = fifo_seq_item::type_id::create("mon_item");
            item.wn = vif.mon_w_cb.wn;
            item.data_in = vif.mon_w_cb.data_in;
            item.full = vif.mon_w_cb.full;
            item_collected_port.write(item);

            // Logging
            `uvm_info("WRITE_MONITOR", 
                      $sformatf("Observed WRITE: Data=0x%0h Full=%0b", 
                                item.data_in, item.full), 
                      UVM_MEDIUM)
        end
    end
  endtask
endclass : fifo_write_monitor

`endif
