`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2024 01:29:42 AM
// Design Name: 
// Module Name: tb_order_matching_engine
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

module tb_order_matching_engine;

  // Parameters
  parameter CLK_PERIOD = 10;  // Clock period in nanoseconds

  // Inputs
  reg clk;
  reg rst_n;
  reg [31:0] order_data;
  reg order_valid;
  reg [31:0] tcp_rx_data;
  reg tcp_rx_valid;
  reg m_axis_ready;

  // Outputs
  wire [31:0] trade_data;
  wire trade_valid;
  wire [31:0] tcp_tx_data;
  wire tcp_tx_valid;
  wire s_axis_ready;
  wire [31:0] m_axis_data;
  wire m_axis_valid;

  // Instantiate the order matching engine module
  order_matching_engine dut (
    .clk(clk),
    .rst_n(rst_n),
    .order_data(order_data),
    .order_valid(order_valid),
    .trade_data(trade_data),
    .trade_valid(trade_valid),
    .tcp_rx_data(tcp_rx_data),
    .tcp_rx_valid(tcp_rx_valid),
    .tcp_tx_data(tcp_tx_data),
    .tcp_tx_valid(tcp_tx_valid),
    .s_axis_data(m_axis_data),
    .s_axis_valid(m_axis_valid),
    .s_axis_ready(s_axis_ready),
    .m_axis_data(m_axis_data),
    .m_axis_valid(m_axis_valid),
    .m_axis_ready(m_axis_ready)
  );

  // Clock generation
  always begin
    clk = 1'b0;
    #(CLK_PERIOD/2);
    clk = 1'b1;
    #(CLK_PERIOD/2);
  end

  // Testbench stimulus
  initial begin
    // Initialize inputs
    rst_n = 1'b0;
    order_data = 32'h0;
    order_valid = 1'b0;
    tcp_rx_data = 32'h0;
    tcp_rx_valid = 1'b0;
    m_axis_ready = 1'b1;

    // Reset the module
    #(CLK_PERIOD*2);
    rst_n = 1'b1;

    // Test case 1: Send a buy order
    #(CLK_PERIOD*2);
    order_data = {2'b00, 2'b00, 8'h10, 8'h01, 8'h00, 4'h0};  // Buy limit order with price 16 and quantity 1
    order_valid = 1'b1;
    #(CLK_PERIOD);
    order_valid = 1'b0;

    // Test case 2: Send a sell order
    #(CLK_PERIOD*2);
    order_data = {2'b00, 2'b00, 8'h20, 8'h02, 8'h00, 4'h0};  // Sell limit order with price 32 and quantity 2
    order_valid = 1'b1;
    #(CLK_PERIOD);
    order_valid = 1'b0;

    // Test case 3: Send a matching buy order
    #(CLK_PERIOD*2);
    order_data = {2'b00, 2'b00, 8'h20, 8'h02, 8'h00, 4'h0};  // Buy limit order with price 32 and quantity 2
    order_valid = 1'b1;
    #(CLK_PERIOD);
    order_valid = 1'b0;

    // Test case 4: Send a market buy order
    #(CLK_PERIOD*2);
    order_data = {2'b01, 2'b00, 8'h00, 8'h03, 8'h00, 4'h0};  // Buy market order with quantity 3
    order_valid = 1'b1;
    #(CLK_PERIOD);
    order_valid = 1'b0;

    // Test case 5: Send a sell stop order
    #(CLK_PERIOD*2);
    order_data = {2'b10, 2'b00, 8'h30, 8'h04, 8'h40, 4'h0};  // Sell stop order with price 48, quantity 4, and stop price 64
    order_valid = 1'b1;
    #(CLK_PERIOD);
    order_valid = 1'b0;

    // Test case 6: Send a buy trailing stop order
    #(CLK_PERIOD*2);
    order_data = {2'b11, 2'b00, 8'h50, 8'h05, 8'h60, 4'h2};  // Buy trailing stop order with price 80, quantity 5, stop price 96, and trail 2
    order_valid = 1'b1;
    #(CLK_PERIOD);
    order_valid = 1'b0;

    // Test case 7: Receive a TCP packet
    #(CLK_PERIOD*2);
    tcp_rx_data = 32'h12345678;
    tcp_rx_valid = 1'b1;
    #(CLK_PERIOD);
    tcp_rx_valid = 1'b0;

    // End the simulation
    #(CLK_PERIOD*10);
    $finish;
  end

  // Assertion for trade execution
  always @(posedge clk) begin
    if (trade_valid) begin
      $display("Trade executed: price = %d, quantity = %d", trade_data[7:0], trade_data[15:8]);
      if (trade_data[7:0] == 8'h20 && trade_data[15:8] == 8'h02)
        $display("Trade data is correct");
      else
        $error("Incorrect trade data");
    end
  end

  // Assertion for TCP transmit data
  always @(posedge clk) begin
    if (tcp_tx_valid) begin
      $display("TCP transmit data: %h", tcp_tx_data);
      if (tcp_tx_data == {2'b11, 30'h1234567})
        $display("TCP transmit data is correct");
      else
        $error("Incorrect TCP transmit data");
    end
  end

endmodule