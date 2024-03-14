module top_level (
  input wire clk,
  input wire rst_n,
  // Ethernet interface
  input wire [47:0] eth_rx_data,
  input wire eth_rx_valid,
  output wire eth_rx_ready,
  output wire [47:0] eth_tx_data,
  output wire eth_tx_valid,
  input wire eth_tx_ready,
  // Custom IP core control and status signals
  input wire [31:0] custom_ip_control,
  output wire [31:0] custom_ip_status
);

  // Instantiate the Ethernet layer module
  wire [31:0] eth_to_ip_data;
  wire eth_to_ip_valid;
  wire eth_to_ip_ready;
  wire [31:0] ip_to_eth_data;
  wire ip_to_eth_valid;
  wire ip_to_eth_ready;

  ethernet_layer ethernet_inst (
    .clk(clk),
    .rst_n(rst_n),
    .mac_rx_data(eth_rx_data),
    .mac_rx_valid(eth_rx_valid),
    .mac_rx_ready(eth_rx_ready),
    .mac_tx_data(eth_tx_data),
    .mac_tx_valid(eth_tx_valid),
    .mac_tx_ready(eth_tx_ready),
    .tcp_ip_rx_data(eth_to_ip_data),
    .tcp_ip_rx_valid(eth_to_ip_valid),
    .tcp_ip_rx_ready(eth_to_ip_ready),
    .tcp_ip_tx_data(ip_to_eth_data),
    .tcp_ip_tx_valid(ip_to_eth_valid),
    .tcp_ip_tx_ready(ip_to_eth_ready)
  );

  // Instantiate the IP layer module
  wire [31:0] ip_to_tcp_data;
  wire ip_to_tcp_valid;
  wire ip_to_tcp_ready;
  wire [31:0] tcp_to_ip_data;
  wire tcp_to_ip_valid;
  wire tcp_to_ip_ready;

  ip_layer ip_inst (
    .clk(clk),
    .rst_n(rst_n),
    .eth_rx_data(eth_to_ip_data),
    .eth_rx_valid(eth_to_ip_valid),
    .eth_rx_ready(eth_to_ip_ready),
    .eth_tx_data(ip_to_eth_data),
    .eth_tx_valid(ip_to_eth_valid),
    .eth_tx_ready(ip_to_eth_ready),
    .tcp_rx_data(ip_to_tcp_data),
    .tcp_rx_valid(ip_to_tcp_valid),
    .tcp_rx_ready(ip_to_tcp_ready),
    .tcp_tx_data(tcp_to_ip_data),
    .tcp_tx_valid(tcp_to_ip_valid),
    .tcp_tx_ready(tcp_to_ip_ready)
  );

  // Instantiate the TCP layer module
  wire [31:0] tcp_to_app_data;
  wire tcp_to_app_valid;
  wire tcp_to_app_ready;
  wire [31:0] app_to_tcp_data;
  wire app_to_tcp_valid;
  wire app_to_tcp_ready;

  tcp_layer tcp_inst (
    .clk(clk),
    .rst_n(rst_n),
    .ip_rx_data(ip_to_tcp_data),
    .ip_rx_valid(ip_to_tcp_valid),
    .ip_rx_ready(ip_to_tcp_ready),
    .ip_tx_data(tcp_to_ip_data),
    .ip_tx_valid(tcp_to_ip_valid),
    .ip_tx_ready(tcp_to_ip_ready),
    .app_rx_data(tcp_to_app_data),
    .app_rx_valid(tcp_to_app_valid),
    .app_rx_ready(tcp_to_app_ready),
    .app_tx_data(app_to_tcp_data),
    .app_tx_valid(app_to_tcp_valid),
    .app_tx_ready(app_to_tcp_ready)
  );

  // Instantiate the custom IP core module
  wire [31:0] custom_ip_tx_data;
  wire custom_ip_tx_valid;
  wire custom_ip_tx_ready;
  wire [31:0] custom_ip_rx_data;
  wire custom_ip_rx_valid;
  wire custom_ip_rx_ready;

  custom_ip_core custom_ip_inst (
    .clk(clk),
    .rst_n(rst_n),
    .s_axis_tdata(tcp_to_app_data),
    .s_axis_tvalid(tcp_to_app_valid),
    .s_axis_tready(tcp_to_app_ready),
    .m_axis_tdata(custom_ip_tx_data),
    .m_axis_tvalid(custom_ip_tx_valid),
    .m_axis_tready(custom_ip_tx_ready),
    .control_reg(custom_ip_control),
    .status_reg(custom_ip_status)
  );

  // Instantiate the AXI stream interface module for the custom IP core
  axi_stream_if #(
    .DATA_WIDTH(32),
    .DEST_WIDTH(4),
    .USER_WIDTH(4),
    .ID_WIDTH(4),
    .HAS_STRB(0),
    .HAS_KEEP(0),
    .HAS_LAST(1),
    .HAS_DEST(0),
    .HAS_USER(0),
    .HAS_ID(0)
  ) axi_stream_inst (
    .aclk(clk),
    .aresetn(rst_n),
    .tdata(custom_ip_tx_data),
    .tdest(4'b0),
    .tuser(4'b0),
    .tid(4'b0),
    .tstrb(4'b0),
    .tkeep(4'b0),
    .tlast(1'b1),
    .tvalid(custom_ip_tx_valid),
    .tready(custom_ip_tx_ready)
  );

  // Instantiate the order matching engine module
  order_matching_engine order_matching_inst (
    .clk(clk),
    .rst_n(rst_n),
    .order_data(custom_ip_rx_data),
    .order_valid(custom_ip_rx_valid),
    .trade_data(app_to_tcp_data),
    .trade_valid(app_to_tcp_valid),
    .tcp_rx_data(tcp_to_app_data),
    .tcp_rx_valid(tcp_to_app_valid),
    .tcp_tx_data(custom_ip_tx_data),
    .tcp_tx_valid(custom_ip_tx_valid),
    .s_axis_data(custom_ip_tx_data),
    .s_axis_valid(custom_ip_tx_valid),
    .s_axis_ready(custom_ip_tx_ready),
    .m_axis_data(custom_ip_rx_data),
    .m_axis_valid(custom_ip_rx_valid),
    .m_axis_ready(custom_ip_rx_ready)
  );

endmodule