// fifo_read_driver.sv
`ifndef FIFO_READ_DRIVER_SV
`define FIFO_READ_DRIVER_SV

class fifo_read_driver extends uvm_driver#(fifo_seq_item);
`uvm_component_utils(fifo_read_driver)

virtual fifo_if vif;

function new(string name = "fifo_read_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual fifo_if)::get(this,"","vif",vif))
    `uvm_fatal(get_type_name(),"Virtual Interface is not found for read driver")
  else
    `uvm_info(get_type_name(),"Read Interface connected successfully",UVM_LOW)
endfunction

virtual task run_phase(uvm_phase phase);
  `uvm_info(get_type_name(),"Starting Read Driver Run phase", UVM_LOW)
  vif.rb_cb.rn <=0;
  forever begin
    fifo_seq_item seq_item;
    // Get next item from sequencer
    seq_item_port.get_next_item(seq_item);

    // Only drive read when rn is set
    if(seq_item.rn) begin
      drive_read(seq_item);
    end
    else begin
      `uvm_info("READ_DRIVER", "Idle transaction (rn=0)", UVM_HIGH)
    end

    // Mark Item Done
    seq_item_port.item_done();

    // Wait for next read clock
    @(vif.rb_cb);
  end
endtask

virtual task drive_read(fifo_seq_item seq_item);
  @(vif.rb_cb); // wait for read clock edge

  if(!vif.rb_cb.empty) begin
    vif.rb_cb.rn <= 1'b1;
    `uvm_info("READ_DRIVER", "Read request Issued", UVM_MEDIUM)
  end
  else begin
    `uvm_warning("READ_DRIVER", "FIFO-empty Read Skipped")
    vif.rb_cb.rn <= 0;
  end

  @(vif.rb_cb);
  vif.rb_cb.rn <= 0;

  // Sample read data
  @(vif.rb_cb);
  seq_item.data_out = vif.rb_cb.data_out;
  `uvm_info("READ_DRIVER", $sformatf("READ: Data=0x%0h", seq_item.data_out), UVM_MEDIUM)
endtask
endclass: fifo_read_driver
`endif
