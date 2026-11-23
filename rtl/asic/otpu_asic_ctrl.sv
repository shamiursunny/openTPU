// ASIC-side AXI4-Lite control wrapper for otpu_asic_top.
// This is a minimal V1 control contract, not a PCIe endpoint or a complete chip top.
module otpu_asic_ctrl #(
  parameter int D = 128,
  parameter int MCOLS = 4,
  parameter int LANES = 8
) (
  input  logic clk,
  input  logic rst,                 // synchronous, active high
  input  logic mem_ready,
  input  logic mem_error,
  input  logic halted,
  input  logic core_error,
  input  logic ld_busy,
  input  logic wr_idle,
  input  logic wait_to,
  input  logic a_inval,
  input  logic [31:0] icount,

  input  logic [11:0] s_awaddr,
  input  logic s_awvalid,
  output logic s_awready,
  input  logic [31:0] s_wdata,
  input  logic [3:0] s_wstrb,
  input  logic s_wvalid,
  output logic s_wready,
  output logic [1:0] s_bresp,
  output logic s_bvalid,
  input  logic s_bready,

  input  logic [11:0] s_araddr,
  input  logic s_arvalid,
  output logic s_arready,
  output logic [31:0] s_rdata,
  output logic [1:0] s_rresp,
  output logic s_rvalid,
  input  logic s_rready,

  output logic sys_rst,
  output logic run_rst,
  output logic ld_start,
  output logic [31:0] ld_addr,
  output logic [31:0] ld_n,
  output logic [7:0][31:0] rinit
);
  localparam logic [31:0] ID_VALUE = 32'h4f545055;
  localparam logic [31:0] VERSION_VALUE = {D[15:0], MCOLS[7:0], LANES[7:0]};

  logic aw_pending, w_pending;
  logic [11:0] awaddr_q;
  logic [31:0] wdata_q;
  logic [3:0] wstrb_q;
  logic ctrl_error;
  logic aw_take, w_take, have_aw, have_w;
  logic [11:0] write_addr;
  logic [31:0] write_data;
  logic [3:0] write_strb;
  logic [31:0] read_mux;
  logic [1:0] read_resp;
  logic [31:0] ctrl_read;

  function automatic logic [31:0] byte_merge(
    input logic [31:0] old_value,
    input logic [31:0] new_value,
    input logic [3:0] strobe
  );
    logic [31:0] value;
    value = old_value;
    for (int i = 0; i < 4; i++)
      if (strobe[i]) value[i*8 +: 8] = new_value[i*8 +: 8];
    return value;
  endfunction

  assign s_awready = !aw_pending && !s_bvalid;
  assign s_wready  = !w_pending && !s_bvalid;
  assign aw_take = s_awvalid && s_awready;
  assign w_take  = s_wvalid && s_wready;
  assign have_aw = aw_pending || aw_take;
  assign have_w  = w_pending || w_take;
  assign write_addr = aw_pending ? awaddr_q : s_awaddr;
  assign write_data = w_pending ? wdata_q : s_wdata;
  assign write_strb = w_pending ? wstrb_q : s_wstrb;

  assign s_arready = !s_rvalid;
  assign ctrl_read = {31'b0, !run_rst};

  always_comb begin
    read_mux = 32'b0;
    read_resp = 2'b00;
    case (s_araddr)
      12'h000: read_mux = ID_VALUE;
      12'h004: read_mux = VERSION_VALUE;
      12'h008: read_mux = ctrl_read;
      12'h00c: read_mux = {23'b0, a_inval, mem_error, wait_to,
                           !run_rst, mem_ready, wr_idle, ld_busy,
                           (core_error | ctrl_error), halted};
      12'h010: read_mux = ld_addr;
      12'h014: read_mux = ld_n;
      12'h018: read_mux = icount;
      default: begin
        if (s_araddr >= 12'h060 && s_araddr <= 12'h07c &&
            s_araddr[1:0] == 2'b00)
          read_mux = rinit[s_araddr[4:2]];
        else begin
          read_mux = 32'b0;
          read_resp = 2'b11; // DECERR
        end
      end
    endcase
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      sys_rst <= 1'b1;
      run_rst <= 1'b1;
      ld_start <= 1'b0;
      ld_addr <= 32'b0;
      ld_n <= 32'b0;
      rinit <= '0;
      aw_pending <= 1'b0;
      w_pending <= 1'b0;
      awaddr_q <= '0;
      wdata_q <= '0;
      wstrb_q <= '0;
      s_bresp <= 2'b00;
      s_bvalid <= 1'b0;
      s_rdata <= 32'b0;
      s_rresp <= 2'b00;
      s_rvalid <= 1'b0;
      ctrl_error <= 1'b0;
    end else begin
      sys_rst <= 1'b0;
      ld_start <= 1'b0;

      if (s_bvalid && s_bready) s_bvalid <= 1'b0;
      if (s_rvalid && s_rready) s_rvalid <= 1'b0;
      if (aw_take) begin aw_pending <= 1'b1; awaddr_q <= s_awaddr; end
      if (w_take) begin
        w_pending <= 1'b1;
        wdata_q <= s_wdata;
        wstrb_q <= s_wstrb;
      end

      if (have_aw && have_w && !s_bvalid) begin
        aw_pending <= 1'b0;
        w_pending <= 1'b0;
        s_bvalid <= 1'b1;
        s_bresp <= 2'b00;
        if (write_addr[1:0] != 2'b00) begin
          s_bresp <= 2'b11;
        end else begin
          case (write_addr)
            12'h008: begin
              if (write_strb[0]) begin
                if (write_data[0]) begin
                  if (write_data[1] || !mem_ready || ld_busy || mem_error) begin
                    ctrl_error <= 1'b1;
                    s_bresp <= 2'b10; // SLVERR
                  end else run_rst <= 1'b0;
                end else begin
                  run_rst <= 1'b1;
                  if (write_data[1]) begin
                    if (mem_ready && !ld_busy && !mem_error) ld_start <= 1'b1;
                    else begin ctrl_error <= 1'b1; s_bresp <= 2'b10; end
                  end
                end
                if (write_data[2]) begin
                  ctrl_error <= 1'b1;
                  s_bresp <= 2'b10; // counter clear is not implemented by this ASIC block
                end
              end
            end
            12'h010: ld_addr <= byte_merge(ld_addr, write_data, write_strb);
            12'h014: ld_n <= byte_merge(ld_n, write_data, write_strb);
            default: begin
              if (write_addr >= 12'h060 && write_addr <= 12'h07c &&
                  write_addr[1:0] == 2'b00)
                rinit[write_addr[4:2]] <= byte_merge(rinit[write_addr[4:2]],
                                                       write_data, write_strb);
              else s_bresp <= 2'b11; // DECERR
            end
          endcase
        end
      end

      if (s_arvalid && s_arready) begin
        s_rdata <= read_mux;
        s_rresp <= read_resp;
        s_rvalid <= 1'b1;
      end
    end
  end
endmodule
