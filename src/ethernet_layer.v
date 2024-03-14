module ethernet_layer (
  input wire clk,
  input wire rst_n,
  
  // MAC interface
  output reg [47:0] mac_tx_data,
  output reg mac_tx_valid,
  input wire mac_tx_ready,
  input wire [47:0] mac_rx_data,
  input wire mac_rx_valid,
  output reg mac_rx_ready,
  
  // TCP/IP stack interface
  input wire [31:0] tcp_ip_tx_data,
  input wire tcp_ip_tx_valid,
  output reg tcp_ip_tx_ready,
  output reg [31:0] tcp_ip_rx_data,
  output reg tcp_ip_rx_valid,
  input wire tcp_ip_rx_ready
);

  // Ethernet frame parameters
  parameter PREAMBLE = 64'h55555555555555D5;
  parameter SFD = 8'hD5;
  parameter ETH_TYPE_IPV4 = 16'h0800;
  parameter MAC_ADDR_LOCAL = 48'h000A35000001;
  parameter MAC_ADDR_REMOTE = 48'h000A35000002;

  // Packet buffers
  reg [1023:0] tx_buffer;
  reg [10:0] tx_length;
  reg [1023:0] rx_buffer;
  reg [10:0] rx_length;

  // Ethernet layer logic
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset logic
      tx_length <= 0;
      rx_length <= 0;
      mac_tx_valid <= 0;
      tcp_ip_rx_valid <= 0;
      tcp_ip_tx_ready <= 1;
      mac_rx_ready <= 1;
    end else begin
      // Transmit packet
      if (tcp_ip_tx_valid && tcp_ip_tx_ready) begin
        tx_buffer <= {PREAMBLE, SFD, MAC_ADDR_REMOTE, MAC_ADDR_LOCAL, ETH_TYPE_IPV4, tcp_ip_tx_data};
        tx_length <= 14 + 20 + tcp_ip_tx_data[31:16];
      end

      if (mac_tx_ready && tx_length > 0) begin
        mac_tx_data <= tx_buffer[1023:976];
        mac_tx_valid <= 1;
        tx_buffer <= {tx_buffer[975:0], 48'h0};
        tx_length <= tx_length - 6;
      end else begin
        mac_tx_valid <= 0;
      end

      // Receive packet
      if (mac_rx_valid && mac_rx_ready) begin
        rx_buffer <= {rx_buffer[975:0], mac_rx_data};
        rx_length <= rx_length + 6;
      end

      if (rx_length >= 14 + 20) begin
        if (rx_buffer[1023:976] == MAC_ADDR_LOCAL && rx_buffer[959:944] == ETH_TYPE_IPV4) begin
          tcp_ip_rx_data <= rx_buffer[943:912];
          tcp_ip_rx_valid <= 1;
        end
        rx_buffer <= {rx_buffer[911:0], 112'h0};
        rx_length <= rx_length - 14 - 20;
      end else if (tcp_ip_rx_ready) begin
        tcp_ip_rx_valid <= 0;
      end

      // Update ready signals
      tcp_ip_tx_ready <= (tx_length == 0);
      mac_rx_ready <= (rx_length < 1024 - 6);
    end
  end

endmodule