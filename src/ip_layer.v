`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2024 01:31:29 AM
// Design Name: 
// Module Name: ip_layer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ip_layer (
  input wire clk,
  input wire rst_n,
  // Ethernet layer interface
  input wire [31:0] eth_rx_data,
  input wire eth_rx_valid,
  output wire eth_rx_ready,
  output wire [31:0] eth_tx_data,
  output wire eth_tx_valid,
  input wire eth_tx_ready,
  // TCP layer interface
  output wire [31:0] tcp_rx_data,
  output wire tcp_rx_valid,
  input wire tcp_rx_ready,
  input wire [31:0] tcp_tx_data,
  input wire tcp_tx_valid,
  output wire tcp_tx_ready
);

  // IP packet parameters
  parameter IP_VERSION = 4'h4;
  parameter IP_IHL = 4'h5;
  parameter IP_TOS = 8'h00;
  parameter IP_TTL = 8'h40;
  parameter IP_PROTOCOL_TCP = 8'h06;
  parameter IP_ADDR_LOCAL = 32'hC0A80001; // 192.168.0.1
  parameter IP_ADDR_REMOTE = 32'hC0A80002; // 192.168.0.2

  // Packet buffers
  reg [31:0] rx_buffer;
  reg rx_buffer_valid;
  reg [31:0] tx_buffer;
  reg tx_buffer_valid;

  // IP layer logic
  always @(posedge clk) begin
    if (!rst_n) begin
      // Reset logic
      rx_buffer_valid <= 0;
      tx_buffer_valid <= 0;
    end else begin
      // Receive packet
      if (eth_rx_valid && eth_rx_ready) begin
        rx_buffer <= eth_rx_data;
        rx_buffer_valid <= 1;
      end else if (tcp_rx_ready) begin
        rx_buffer_valid <= 0;
      end

      // Transmit packet
      if (tcp_tx_valid && tcp_tx_ready) begin
        tx_buffer <= {IP_VERSION, IP_IHL, IP_TOS, tcp_tx_data[15:0], 16'h0000, IP_TTL, IP_PROTOCOL_TCP, 16'h0000, IP_ADDR_LOCAL, IP_ADDR_REMOTE, tcp_tx_data};
        tx_buffer_valid <= 1;
      end else if (eth_tx_ready) begin
        tx_buffer_valid <= 0;
      end
    end
  end

  // Receive path
  assign tcp_rx_data = rx_buffer;
  assign tcp_rx_valid = rx_buffer_valid && (rx_buffer[31:28] == IP_VERSION) && (rx_buffer[27:24] == IP_IHL) && (rx_buffer[23:16] == IP_PROTOCOL_TCP);
  assign eth_rx_ready = !rx_buffer_valid || tcp_rx_ready;

  // Transmit path
  assign eth_tx_data = tx_buffer;
  assign eth_tx_valid = tx_buffer_valid;
  assign tcp_tx_ready = !tx_buffer_valid || eth_tx_ready;

endmodule