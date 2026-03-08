module async_fifo #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 3      // 2^3 = 8 entries
)(
  input  logic                  wclk,
  input  logic                  rclk,
  input  logic                  wrst_n,
  input  logic                  rrst_n,
  input  logic                  w_en,
  input  logic                  r_en,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic                  full,
  output logic                  empty
);

  // ------------------------------------------------------------
  // Internal signals
  // ------------------------------------------------------------
  logic [ADDR_WIDTH:0] wptr_bin, wptr_bin_next;
  logic [ADDR_WIDTH:0] rptr_bin, rptr_bin_next;
  logic [ADDR_WIDTH:0] wptr_gray, wptr_gray_next;
  logic [ADDR_WIDTH:0] rptr_gray, rptr_gray_next;

  logic [ADDR_WIDTH:0] rptr_gray_sync_w1, rptr_gray_sync_w2;
  logic [ADDR_WIDTH:0] wptr_gray_sync_r1, wptr_gray_sync_r2;

  logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

  // ------------------------------------------------------------
  // Write Pointer Logic (Write Clock Domain)
  // ------------------------------------------------------------
  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n)
      wptr_bin <= 0;
    else if (w_en && !full)
      wptr_bin <= wptr_bin + 1;
  end

  // Binary to Gray code conversion
  always_comb begin
    wptr_gray_next = (wptr_bin >> 1) ^ wptr_bin;
  end

  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n)
      wptr_gray <= 0;
    else
      wptr_gray <= wptr_gray_next;
  end

  // ------------------------------------------------------------
  // Read Pointer Logic (Read Clock Domain)
  // ------------------------------------------------------------
  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n)
      rptr_bin <= 0;
    else if (r_en && !empty)
      rptr_bin <= rptr_bin + 1;
  end

  // Binary to Gray code conversion
  always_comb begin
    rptr_gray_next = (rptr_bin >> 1) ^ rptr_bin;
  end

  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n)
      rptr_gray <= 0;
    else
      rptr_gray <= rptr_gray_next;
  end

  // ------------------------------------------------------------
  // FIFO Memory Write
  // ------------------------------------------------------------
  always_ff @(posedge wclk) begin
    if (w_en && !full)
      mem[wptr_bin[ADDR_WIDTH-1:0]] <= data_in;
  end

  // ------------------------------------------------------------
  // FIFO Memory Read
  // ------------------------------------------------------------
  always_ff @(posedge rclk) begin
    if (!rrst_n)
      data_out <= '0;
    else if (r_en && !empty)
      data_out <= mem[rptr_bin[ADDR_WIDTH-1:0]];
  end

  // ------------------------------------------------------------
  // Pointer Synchronization
  // ------------------------------------------------------------
  // Sync read pointer into write clock domain
  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      rptr_gray_sync_w1 <= 0;
      rptr_gray_sync_w2 <= 0;
    end else begin
      rptr_gray_sync_w1 <= rptr_gray;
      rptr_gray_sync_w2 <= rptr_gray_sync_w1;
    end
  end

  // Sync write pointer into read clock domain
  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
      wptr_gray_sync_r1 <= 0;
      wptr_gray_sync_r2 <= 0;
    end else begin
      wptr_gray_sync_r1 <= wptr_gray;
      wptr_gray_sync_r2 <= wptr_gray_sync_r1;
    end
  end

  // ------------------------------------------------------------
  // Full and Empty Flag Generation
  // ------------------------------------------------------------
  // Full: when next write pointer Gray == inverted MSBs of synced read pointer Gray
  always_comb begin
    full = (wptr_gray_next == {~rptr_gray_sync_w2[ADDR_WIDTH:ADDR_WIDTH-1],
                               rptr_gray_sync_w2[ADDR_WIDTH-2:0]});
  end

  // Empty: when synchronized write pointer == read pointer
  always_comb begin
    empty = (wptr_gray_sync_r2 == rptr_gray);
  end

endmodule
