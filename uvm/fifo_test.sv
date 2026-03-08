//fifo_test.sv
`ifndef FIFO_TEST_SV
`define FIFO_TEST_SV

class fifo_test extends uvm_test;
`uvm_component_utils(fifo_test)

fifo_env env;

function new(string name, uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  env = fifo_env::type_id::create("env", this);
endfunction

task run_phase(uvm_phase phase);

  fifo_fill_seq      fill_seq;
  fifo_drain_seq     drain_seq;
  fifo_simul_rw_seq  rw_seq;
  fifo_illegal_seq   illegal_seq;
  fifo_base_seq      random_seq;
  
  phase.raise_objection(this);

  fill_seq    = fifo_fill_seq::type_id::create("fill_seq");
  drain_seq   = fifo_drain_seq::type_id::create("drain_seq");
  rw_seq      = fifo_simul_rw_seq::type_id::create("rw_seq");
  illegal_seq = fifo_illegal_seq::type_id::create("illegal_seq");
  random_seq  = fifo_base_seq::type_id::create("random_seq");

  fill_seq.start(env.write_agent.sequencer);
  drain_seq.start(env.read_agent.sequencer);
  rw_seq.start(env.write_agent.sequencer);
  rw_seq.start(env.read_agent.sequencer);
  illegal_seq.start(env.write_agent.sequencer);
  random_seq.start(env.write_agent.sequencer);
  random_seq.start(env.read_agent.sequencer);

  phase.drop_objection(this);
endtask


function void end_of_elaboration_phase(uvm_phase phase);
  uvm_top.print_topology();
endfunction
  
function void final_phase(uvm_phase phase);
  fifo_scoreboard sb;
  if ($cast(sb, env.scoreboard))
    sb.display_coverage();
endfunction

endclass
`endif
