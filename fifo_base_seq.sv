// fifo_base_seq.sv
// Base sequence for Asynchronous FIFO Verification
`ifndef FIFO_BASE_SEQ_SV
`define FIFO_BASE_SEQ_SV

class fifo_base_seq extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(fifo_base_seq)
  
  function new(string name = "fifo_base_seq");
    super.new(name);
  endfunction
 
  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Starting Asynchronous FIFO Base Sequence"), UVM_LOW)

    // Run for a fixed number of iterations
    repeat (30) begin
	fifo_seq_item seq_item;
      seq_item = fifo_seq_item::type_id::create("seq_item");
	  start_item(seq_item);
	  assert(seq_item.randomize() with {
	  wn dist {1:= 70, 0:= 30};
	  rn dist {1:= 50, 0:= 50};
	  }) else `uvm_error("SEQ", "Randomization failed")
	  finish_item(seq_item);
	  //Logging
	  if (seq_item.wn && seq_item.rn)
            `uvm_info("BASE_SEQ", $sformatf("[READ + WRITE] Data = 0x%0h", seq_item.data_in), UVM_MEDIUM)
        else if (seq_item.wn)
            `uvm_info("BASE_SEQ", $sformatf("[WRITE] Data = 0x%0h", seq_item.data_in), UVM_MEDIUM)
        else if (seq_item.rn)
        `uvm_info("BASE_SEQ", "[READ] Transaction issued", UVM_MEDIUM) 
      else
        `uvm_info("BASE_SEQ", "[IDLE]", UVM_MEDIUM)
    end
    `uvm_info(get_type_name(), $sformatf("Completed Asynchronous FIFO Base Sequence"), UVM_LOW)
  endtask : body
endclass : fifo_base_seq

        
class fifo_fill_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_fill_seq)

  function new(string name = "fifo_fill_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Starting FIFO FILL sequence", UVM_LOW)

    repeat (20) begin   // More than FIFO depth
      fifo_seq_item seq_item;
      seq_item = fifo_seq_item::type_id::create("seq_item");

      start_item(seq_item);
      seq_item.wn = 1;
      seq_item.rn = 0;
      assert(seq_item.randomize() with {
        data_in inside {[0:255]};
      });
      finish_item(seq_item);
    end

    `uvm_info(get_type_name(), "Completed FIFO FILL sequence", UVM_LOW)
  endtask
endclass

      
class fifo_drain_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_drain_seq)

  function new(string name = "fifo_drain_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Starting FIFO DRAIN sequence", UVM_LOW)

    repeat (20) begin
      fifo_seq_item seq_item;
      seq_item = fifo_seq_item::type_id::create("seq_item");

      start_item(seq_item);
      seq_item.wn = 0;
      seq_item.rn = 1;
      finish_item(seq_item);
    end

    `uvm_info(get_type_name(), "Completed FIFO DRAIN sequence", UVM_LOW)
  endtask
endclass

      
class fifo_simul_rw_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_simul_rw_seq)

  function new(string name = "fifo_simul_rw_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Starting SIMULTANEOUS RW sequence", UVM_LOW)

    repeat (50) begin
      fifo_seq_item seq_item;
      seq_item = fifo_seq_item::type_id::create("seq_item");

      start_item(seq_item);
      seq_item.wn = 1;
      seq_item.rn = 1;
      assert(seq_item.randomize());
      finish_item(seq_item);
    end

    `uvm_info(get_type_name(), "Completed SIMULTANEOUS RW sequence", UVM_LOW)
  endtask
endclass

      
class fifo_illegal_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_illegal_seq)

  function new(string name = "fifo_illegal_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Starting ILLEGAL ACCESS sequence", UVM_LOW)

    repeat (20) begin
      fifo_seq_item seq_item;
      seq_item = fifo_seq_item::type_id::create("seq_item");

      start_item(seq_item);
      // Randomly try illegal ops
      assert(seq_item.randomize() with {
        wn == 1;
        rn == 1;
      });
      finish_item(seq_item);
    end

    `uvm_info(get_type_name(), "Completed ILLEGAL ACCESS sequence", UVM_LOW)
  endtask
endclass

`endif
