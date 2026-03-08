// fifo_write_agent.sv
`ifndef FIFO_WRITE_AGENT_SV
`define FIFO_WRITE_AGENT_SV

class fifo_write_agent extends uvm_agent;
`uvm_component_utils(fifo_write_agent)

fifo_sequencer sequencer;
fifo_write_driver driver;
fifo_write_monitor monitor;

//Virtual interface
virtual fifo_if vif;

//constructor
function new(string name="fifo_write_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

//Build phase
function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(get_is_active == UVM_ACTIVE)begin
sequencer = fifo_sequencer::type_id::create("sequencer", this);
driver = fifo_write_driver::type_id::create("driver", this);
if(!uvm_config_db#(virtual fifo_if)::get(this,"","vif",vif))
    `uvm_fatal(get_type_name(), "Virtual interface not set for write agent")

driver.vif  = vif;
end 
monitor = fifo_write_monitor::type_id::create("monitor", this);
monitor.vif = vif;
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
if(get_is_active == UVM_ACTIVE)begin
driver.seq_item_port.connect(sequencer.seq_item_export);
end
endfunction
endclass: fifo_write_agent
`endif

