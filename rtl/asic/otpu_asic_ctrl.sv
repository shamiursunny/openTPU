// ASIC-side AXI4-Lite control block for otpu_asic_top.
// BAR register semantics follow otpu_ctrl register map v5 for implemented counters/status.
module otpu_asic_ctrl #(
  parameter int D=128, MCOLS=4, LANES=8,
  parameter int ACT_BLOCKS=128, ACT_ROWS=8,
  parameter int TMEM_WORDS=65536, IMEM_WORDS=32768,
  parameter int MXU_IMPL=2, TMEM_IMPL=3, VPU_CL=2, ULANES=8,
  parameter bit HAS_DSTEP=1'b1, SEQ_WC=1'b1, ICACHE=1'b0,
  parameter bit HOSTCAL=1'b0, CHASH=1'b0, PAIR=1'b1, HAS_TEMP=1'b0, HAS_I2C=1'b0,
  parameter int PQ_WIN=1024, TRACE_DEPTH=0,
  parameter int CORE_KHZ=0, DDR_MTS=0, PLATFORM=256,
  parameter logic [31:0] BUILD_ID=32'b0, ARCH_HASH=32'b0
) (
  input logic clk, rst,
  input logic [1:0] mem_calib,
  input logic mem_error, ecc_ded,
  input logic halted, core_error, ld_busy, wr_idle, wait_to, a_inval,
  input logic [31:0] icount,
  input logic a_req, a_we, a_rdy, b_req, b_rdy, b_we, sw_req, sw_rdy,

  input logic [11:0] s_awaddr,
  input logic s_awvalid,
  output logic s_awready,
  input logic [31:0] s_wdata,
  input logic [3:0] s_wstrb,
  input logic s_wvalid,
  output logic s_wready,
  output logic [1:0] s_bresp,
  output logic s_bvalid,
  input logic s_bready,
  input logic [11:0] s_araddr,
  input logic s_arvalid,
  output logic s_arready,
  output logic [31:0] s_rdata,
  output logic [1:0] s_rresp,
  output logic s_rvalid,
  input logic s_rready,

  output logic sys_rst, run_rst, ld_start,
  output logic [31:0] ld_addr, ld_n,
  output logic [7:0][31:0] rinit
);
  localparam logic [31:0] ID_VALUE = 32'h4f545055;
  localparam logic [31:0] VERSION_VALUE = {D[15:0], MCOLS[7:0], LANES[7:0]};
  localparam logic [31:0] REGMAP_VALUE = 32'd5;
  localparam logic [7:0] PQ_LOG2 = $clog2(PQ_WIN);
  localparam logic [7:0] TRACE_LOG2 = TRACE_DEPTH != 0 ? $clog2(TRACE_DEPTH) : 8'd0;
  localparam logic [31:0] CAPS_VALUE = {
    1'b1, 1'b1, 1'b1, 1'b0, HOSTCAL, HAS_DSTEP, 2'd3,
    PQ_LOG2, TRACE_LOG2, CHASH, HAS_DSTEP, PAIR, 1'b1,
    (DDR_MTS != 0), HAS_I2C, HAS_TEMP, (TRACE_DEPTH != 0)
  };
  localparam logic [31:0] CAPS2_VALUE = ICACHE ? 32'h00001000 : 32'b0;
  localparam logic [31:0] CFG_UARCH_VALUE =
      {3'b0, ICACHE, 3'b0, SEQ_WC, ULANES[7:0], VPU_CL[7:0],
       TMEM_IMPL[3:0], MXU_IMPL[3:0]};
  logic mem_ready;
  logic aw_pending, w_pending, ctrl_error, load_inflight, load_seen_busy;
  logic [11:0] awaddr_q;
  logic [31:0] wdata_q;
  logic [3:0] wstrb_q;
  logic aw_take, w_take, have_aw, have_w;
  logic [11:0] write_addr;
  logic [31:0] write_data, read_mux, scratch;
  logic [3:0] write_strb;
  logic [1:0] read_resp;
  logic [63:0] cycle_count;
  logic [31:0] b_rd_count, b_wr_count, a_rd_count, sw_wr_count, b_stall_count;

  function automatic logic [31:0] byte_merge(
    input logic [31:0] old_value, input logic [31:0] new_value,
    input logic [3:0] strobe
  );
    logic [31:0] value;
    value = old_value;
    for (int i=0; i<4; i++)
      if (strobe[i]) value[i*8 +: 8] = new_value[i*8 +: 8];
    return value;
  endfunction

  assign mem_ready = &mem_calib;
  assign s_awready = !aw_pending && !s_bvalid;
  assign s_wready = !w_pending && !s_bvalid;
  assign aw_take = s_awvalid && s_awready;
  assign w_take = s_wvalid && s_wready;
  assign have_aw = aw_pending || aw_take;
  assign have_w = w_pending || w_take;
  assign write_addr = aw_pending ? awaddr_q : s_awaddr;
  assign write_data = w_pending ? wdata_q : s_wdata;
  assign write_strb = w_pending ? wstrb_q : s_wstrb;
  assign s_arready = !s_rvalid;

  always_comb begin
    read_mux = 32'b0;
    read_resp = 2'b00;
    case (s_araddr)
      12'h000: read_mux = ID_VALUE;
      12'h004: read_mux = VERSION_VALUE;
      12'h008: read_mux = {31'b0, !run_rst};
      12'h00c: read_mux = {22'b0, ecc_ded, wait_to, !run_rst,
                           mem_calib[1], mem_calib[0], mem_error, wr_idle,
                           (ld_busy | load_inflight), (core_error | ctrl_error), halted};
      12'h010: read_mux = ld_addr;
      12'h014: read_mux = ld_n;
      12'h018: read_mux = cycle_count[31:0];
      12'h01c: read_mux = cycle_count[63:32];
      12'h020: read_mux = icount;
      12'h024: read_mux = b_rd_count;
      12'h028: read_mux = b_wr_count;
      12'h02c: read_mux = a_rd_count;
      12'h030: read_mux = sw_wr_count;
      12'h034: read_mux = b_stall_count;
      12'h038: read_mux = scratch;
      12'h03c: read_mux = REGMAP_VALUE;
      12'h040: read_mux = CAPS_VALUE;
      12'h044: read_mux = CORE_KHZ;
      12'h048: read_mux = BUILD_ID;
      12'h054: read_mux = DDR_MTS;
      12'h058: read_mux = ACT_ROWS;
      12'h05c: read_mux = CAPS2_VALUE;
      12'h080: read_mux = 32'd1;
      12'h084: read_mux = TMEM_WORDS;
      12'h088: read_mux = IMEM_WORDS;
      12'h08c: read_mux = ACT_BLOCKS;
      12'h090: read_mux = 32'b0; // external memory topology not selected at the ASIC block boundary
      12'h094: read_mux = CFG_UARCH_VALUE;
      12'h098: read_mux = PLATFORM;
      12'h09c: read_mux = ARCH_HASH;
      default: begin
        if (s_araddr >= 12'h060 && s_araddr <= 12'h07c && s_araddr[1:0] == 2'b00)
          read_mux = rinit[s_araddr[4:2]];
        else begin read_mux = 32'b0; read_resp = 2'b11; end
      end
    endcase
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      sys_rst <= 1'b1; run_rst <= 1'b1; ld_start <= 1'b0;
      ld_addr <= '0; ld_n <= '0; rinit <= '0; scratch <= '0;
      aw_pending <= 1'b0; w_pending <= 1'b0; awaddr_q <= '0;
      load_inflight <= 1'b0; load_seen_busy <= 1'b0;
      wdata_q <= '0; wstrb_q <= '0; s_bresp <= 2'b00; s_bvalid <= 1'b0;
      s_rdata <= '0; s_rresp <= 2'b00; s_rvalid <= 1'b0; ctrl_error <= 1'b0;
      cycle_count <= '0; b_rd_count <= '0; b_wr_count <= '0;
      a_rd_count <= '0; sw_wr_count <= '0; b_stall_count <= '0;
    end else begin
      sys_rst <= 1'b0;
      ld_start <= 1'b0;
      // Fail closed if a memory channel loses calibration or reports a fatal error.
      if (!run_rst && (!mem_ready || mem_error || ecc_ded)) begin
        run_rst <= 1'b1;
        ctrl_error <= 1'b1;
      end
      if ((load_inflight || ld_busy) && (!mem_ready || mem_error || ecc_ded)) begin
        sys_rst <= 1'b1;
        load_inflight <= 1'b0;
        load_seen_busy <= 1'b0;
        ctrl_error <= 1'b1;
      end
      if (load_inflight && ld_busy) load_seen_busy <= 1'b1;
      if (load_inflight && load_seen_busy && !ld_busy) begin
        load_inflight <= 1'b0;
        load_seen_busy <= 1'b0;
      end
      if (s_bvalid && s_bready) s_bvalid <= 1'b0;
      if (s_rvalid && s_rready) s_rvalid <= 1'b0;
      if (aw_take) begin aw_pending <= 1'b1; awaddr_q <= s_awaddr; end
      if (w_take) begin w_pending <= 1'b1; wdata_q <= s_wdata; wstrb_q <= s_wstrb; end

      if (!run_rst && !halted) cycle_count <= cycle_count + 1'b1;
      if (b_req && b_rdy) begin
        if (b_we) b_wr_count <= b_wr_count + 1'b1;
        else b_rd_count <= b_rd_count + 1'b1;
      end
      if (a_req && a_rdy && !a_we) a_rd_count <= a_rd_count + 1'b1;
      if (sw_req && sw_rdy) sw_wr_count <= sw_wr_count + 1'b1;
      if (b_req && !b_rdy) b_stall_count <= b_stall_count + 1'b1;

      if (have_aw && have_w && !s_bvalid) begin
        aw_pending <= 1'b0; w_pending <= 1'b0;
        s_bvalid <= 1'b1; s_bresp <= 2'b00;
        if (write_addr[1:0] != 2'b00) s_bresp <= 2'b11;
        else case (write_addr)
          12'h008: if (write_strb[0]) begin
            // Validate the whole command before applying any side effects.
            if ((write_data[0] && write_data[1]) ||
                (write_data[0] && (!mem_ready || !wr_idle || ld_busy || load_inflight || mem_error || ecc_ded)) ||
                (!write_data[0] && write_data[1] &&
                 (!run_rst || !mem_ready || !wr_idle || ld_busy || load_inflight || mem_error || ecc_ded))) begin
              ctrl_error <= 1'b1;
              s_bresp <= 2'b10;
            end else begin
              if (write_data[2]) begin
                ctrl_error <= (!mem_ready || mem_error || ecc_ded);
                cycle_count <= '0; b_rd_count <= '0; b_wr_count <= '0;
                a_rd_count <= '0; sw_wr_count <= '0; b_stall_count <= '0;
              end
              if (write_data[0]) begin
                run_rst <= 1'b0;
                cycle_count <= '0;
              end else begin
                run_rst <= 1'b1;
                if (write_data[1]) begin
                  ld_start <= 1'b1;
                  load_inflight <= 1'b1;
                  load_seen_busy <= 1'b0;
                end
              end
            end
          end
          12'h010: ld_addr <= byte_merge(ld_addr, write_data, write_strb);
          12'h014: ld_n <= byte_merge(ld_n, write_data, write_strb);
          12'h038: scratch <= byte_merge(scratch, write_data, write_strb);
          default: begin
            if (write_addr >= 12'h060 && write_addr <= 12'h07c && write_addr[1:0] == 2'b00)
              rinit[write_addr[4:2]] <= byte_merge(rinit[write_addr[4:2]], write_data, write_strb);
            else s_bresp <= 2'b11;
          end
        endcase
      end

      if (s_arvalid && s_arready) begin
        s_rdata <= read_mux; s_rresp <= read_resp; s_rvalid <= 1'b1;
      end
    end
  end
endmodule
