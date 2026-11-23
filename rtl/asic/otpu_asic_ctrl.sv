// ASIC-side AXI4-Lite control block for otpu_asic_top.
// BAR register semantics follow otpu_ctrl register map v5 for implemented counters/status.
module otpu_asic_ctrl #(
  parameter int D = 128,
  parameter int MCOLS = 4,
  parameter int LANES = 8
) (
  input logic clk, rst,
  input logic [1:0] mem_calib,
  input logic mem_error, ecc_ded,
  input logic halted, core_error, ld_busy, wr_idle, wait_to, a_inval,
  input logic [31:0] icount,
  input logic a_req, a_rdy, b_req, b_rdy, b_we, sw_req, sw_rdy,

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
  logic mem_ready;
  logic aw_pending, w_pending, ctrl_error;
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
                           ld_busy, (core_error | ctrl_error), halted};
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
      wdata_q <= '0; wstrb_q <= '0; s_bresp <= 2'b00; s_bvalid <= 1'b0;
      s_rdata <= '0; s_rresp <= 2'b00; s_rvalid <= 1'b0; ctrl_error <= 1'b0;
      cycle_count <= '0; b_rd_count <= '0; b_wr_count <= '0;
      a_rd_count <= '0; sw_wr_count <= '0; b_stall_count <= '0;
    end else begin
      sys_rst <= 1'b0;
      ld_start <= 1'b0;
      if (s_bvalid && s_bready) s_bvalid <= 1'b0;
      if (s_rvalid && s_rready) s_rvalid <= 1'b0;
      if (aw_take) begin aw_pending <= 1'b1; awaddr_q <= s_awaddr; end
      if (w_take) begin w_pending <= 1'b1; wdata_q <= s_wdata; wstrb_q <= s_wstrb; end

      if (!run_rst && !halted) cycle_count <= cycle_count + 1'b1;
      if (b_req && b_rdy) begin
        if (b_we) b_wr_count <= b_wr_count + 1'b1;
        else b_rd_count <= b_rd_count + 1'b1;
      end
      if (a_req && a_rdy) a_rd_count <= a_rd_count + 1'b1;
      if (sw_req && sw_rdy) sw_wr_count <= sw_wr_count + 1'b1;
      if (b_req && !b_rdy) b_stall_count <= b_stall_count + 1'b1;

      if (have_aw && have_w && !s_bvalid) begin
        aw_pending <= 1'b0; w_pending <= 1'b0;
        s_bvalid <= 1'b1; s_bresp <= 2'b00;
        if (write_addr[1:0] != 2'b00) s_bresp <= 2'b11;
        else case (write_addr)
          12'h008: if (write_strb[0]) begin
            if (write_data[2]) begin
              ctrl_error <= 1'b0;
              cycle_count <= '0; b_rd_count <= '0; b_wr_count <= '0;
              a_rd_count <= '0; sw_wr_count <= '0; b_stall_count <= '0;
            end
            if (write_data[0] && write_data[1]) begin
              ctrl_error <= 1'b1; s_bresp <= 2'b10;
            end else if (write_data[0]) begin
              if (!mem_ready || ld_busy || mem_error) begin
                ctrl_error <= 1'b1; s_bresp <= 2'b10;
              end else begin run_rst <= 1'b0; cycle_count <= '0; end
            end else begin
              run_rst <= 1'b1;
              if (write_data[1]) begin
                if (mem_ready && !ld_busy && !mem_error) ld_start <= 1'b1;
                else begin ctrl_error <= 1'b1; s_bresp <= 2'b10; end
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
