// fifo_write_driver.sv
// UVM Driver for Write Agent of Asynchronous FIFO
`ifndef FIFO_WRITE_DRIVER_SV
`define FIFO_WRITE_DRIVER_SV

class fifo_write_driver extends uvm_driver #(fifo_seq_item);
  `uvm_component_utils(fifo_write_driver)

  virtual fifo_if vif;

  function new(string name = "fifo_write_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Virtual interface not found for write driver")
    else
      `uvm_info(get_type_name(), "Write interface connected successfully", UVM_LOW)
  endfunction
      
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Starting Write Driver run_phase", UVM_LOW)

    // Initialize signals
    vif.wb_cb.wn      <= 0;
    vif.wb_cb.data_in <= '0;

    forever begin
      fifo_seq_item seq_item;
      // Get next write transaction from sequencer
      seq_item_port.get_next_item(seq_item);

      // Only drive write if wn is set
      if (seq_item.wn) begin
        drive_write(seq_item);
      end
      else begin
        `uvm_info("WRITE_DRIVER", "Idle transaction (wn=0)", UVM_HIGH)
      end
      // Mark item done
      seq_item_port.item_done();
      // Optional: small delay between transactions
      @(posedge vif.wclk);
    end
  endtask : run_phase
    
  virtual task drive_write(fifo_seq_item seq_item);
    @(vif.wb_cb); // Wait for write clock edge
    if (!vif.wb_cb.full) begin
      // Drive write data
      vif.wb_cb.data_in <= seq_item.data_in;
      vif.wb_cb.wn      <= 1'b1;
      `uvm_info("WRITE_DRIVER", $sformatf("WRITE: Data=0x%0h", seq_item.data_in), UVM_MEDIUM)
    end
    else begin
      `uvm_warning("WRITE_DRIVER", "FIFO FULL - write skipped")
      vif.wb_cb.wn <= 0;
    end
    // Deassert write enable on next clock
    @(vif.wb_cb);
    vif.wb_cb.wn <= 0;
  endtask : drive_write

endclass : fifo_write_driver

`endif
