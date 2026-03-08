//fifo_scoreboard.sv
`ifndef FIFO_SCOREBOARD_SV
`define FIFO_SCOREBOARD_SV

`uvm_analysis_imp_decl(_write)
`uvm_analysis_imp_decl(_read)

class fifo_scoreboard extends uvm_scoreboard;
`uvm_component_utils(fifo_scoreboard)
uvm_analysis_imp_write #(fifo_seq_item, fifo_scoreboard)write_imp;
uvm_analysis_imp_read #(fifo_seq_item, fifo_scoreboard)read_imp;

bit [7:0]expected_data_q[$];
fifo_seq_item cov_pkt;

//COVERAGE
covergroup fifo_coverage;
option.per_instance = 1;

DATA_IN: coverpoint cov_pkt.data_in;
DATA_OUT: coverpoint cov_pkt.data_out;
WRITE_EN: coverpoint cov_pkt.wn;
READ_EN: coverpoint cov_pkt.rn;
FULL_C: coverpoint cov_pkt.full;
EMPTY_C: coverpoint cov_pkt.empty;
WRITE_X_DATA: cross WRITE_EN, DATA_IN;
READ_X_DATA: cross READ_EN, DATA_OUT;
endgroup

//Constructor
function new(string name = "fifo_scoreboard", uvm_component parent = null);
super.new(name, parent);
write_imp = new("write_imp", this);
read_imp = new("read_imp", this);
fifo_coverage = new();
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

function void write_write(fifo_seq_item t);

  // -----------------------------
  // Functional behavior (UNCHANGED)
  // -----------------------------
  if (t.wn && !t.full) begin
    expected_data_q.push_back(t.data_in);
    `uvm_info("SCOREBOARD",
              $sformatf("WRITE Captured: Data=0x%0h | Qsize=%0d",
                        t.data_in, expected_data_q.size()),
              UVM_LOW)
  end
  else if (t.wn && t.full) begin
    // Illegal write attempt
    `uvm_warning("SCOREBOARD", "WRITE attempted while FIFO is FULL")
  end

  // -----------------------------
  // Coverage sampling (SAFE CLONE)
  // -----------------------------
  cov_pkt = fifo_seq_item::type_id::create("cov_pkt");
  cov_pkt.copy(t);                // Clone transaction
  fifo_coverage.sample();

endfunction

function void write_read(fifo_seq_item t);
  bit [7:0] expected_data;

  // -----------------------------
  // Functional behavior (UNCHANGED)
  // -----------------------------
  if (t.rn && !t.empty) begin
    if (expected_data_q.size() == 0) begin
      `uvm_error("SCOREBOARD", "Read occurred but expected queue is EMPTY")
    end
    else begin
      expected_data = expected_data_q.pop_front();

      if (t.data_out === expected_data)
        `uvm_info("SCOREBOARD",
                  $sformatf("MATCH: Expected=0x%0h Got=0x%0h",
                            expected_data, t.data_out),
                  UVM_LOW)
      else
        `uvm_error("SCOREBOARD",
                   $sformatf("MISMATCH: Expected=0x%0h Got=0x%0h",
                             expected_data, t.data_out))
    end
  end
  else if (t.rn && t.empty) begin
    // Illegal read attempt
    `uvm_warning("SCOREBOARD", "READ attempted while FIFO is EMPTY")
  end

  // -----------------------------
  // Coverage sampling (SAFE CLONE)
  // -----------------------------
  cov_pkt = fifo_seq_item::type_id::create("cov_pkt");
  cov_pkt.copy(t);                // Clone transaction
  fifo_coverage.sample();

endfunction

  function void display_coverage();
 $display("----------------------------------------------------------------");
 $display("Overall Coverage:                                               %0.2f%%", $get_coverage());
 $display("Coverage of Covergroup 'FIFO Coverage':                         %0.2f%%", fifo_coverage.get_coverage());
 $display("Coverage of Covergroup 'DATA_IN' = %0f", fifo_coverage.DATA_IN.get_coverage());
 $display("Coverage of Covergroup 'WRITE_EN' = %0f", fifo_coverage.WRITE_EN.get_coverage());
 $display("Coverage of Covergroup 'READ_EN' = %0f", fifo_coverage.READ_EN.get_coverage());
 $display("Coverage of Covergroup 'FULL_C' = %0f", fifo_coverage.FULL_C.get_coverage());
 $display("Coverage of Covergroup 'EMPTY_C' = %0f", fifo_coverage.EMPTY_C.get_coverage());
 $display("----------------------------------------------------------------");
  endfunction
 endclass
 `endif
 
 
