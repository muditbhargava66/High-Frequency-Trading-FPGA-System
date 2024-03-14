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
    order_data = 32'h80000001;  // Buy order with price 1
    order_valid = 1'b1;
    #(CLK_PERIOD);
    order_valid = 1'b0;

    // Test case 2: Send a sell order
    #(CLK_PERIOD*2);
    order_data = 32'h00000002;  // Sell order with price 2
    order_valid = 1'b1;
    #(CLK_PERIOD);
    order_valid = 1'b0;

    // Test case 3: Send a matching buy order
    #(CLK_PERIOD*2);
    order_data = 32'h80000002;  // Buy order with price 2
    order_valid = 1'b1;
    #(CLK_PERIOD);
    order_valid = 1'b0;

    // Test case 4: Receive a TCP packet
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
        $display("Trade executed: price = %d", trade_data[30:0]);
        if (trade_data[31] == 1'b1 && trade_data[30:0] == 32'd2)
          $display("Trade data is correct");
        else
          $error("Incorrect trade data");
      end
    end
    
    // Assertion for TCP transmit data
    always @(posedge clk) begin
      if (tcp_tx_valid) begin
        $display("TCP transmit data: %h", tcp_tx_data);
        if (tcp_tx_data == 32'h12345678)
          $display("TCP transmit data is correct");
        else
          $error("Incorrect TCP transmit data");
      end
    end

endmodule