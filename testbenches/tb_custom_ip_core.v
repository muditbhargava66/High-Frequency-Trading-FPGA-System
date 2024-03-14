`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2024 01:29:42 AM
// Design Name: 
// Module Name: tb_custom_ip_core
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

module tb_custom_ip_core;

  // Parameters
  parameter CLK_PERIOD = 10;  // Clock period in nanoseconds

  // Inputs
  reg clk;
  reg rst_n;
  reg [31:0] s_axis_tdata;
  reg s_axis_tvalid;
  reg m_axis_tready;
  reg [31:0] control_reg;

  // Outputs
  wire s_axis_tready;
  wire [31:0] m_axis_tdata;
  wire m_axis_tvalid;
  wire [31:0] status_reg;

  // Instantiate the custom IP core module
  custom_ip_core dut (
    .clk(clk),
    .rst_n(rst_n),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .control_reg(control_reg),
    .status_reg(status_reg)
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
    s_axis_tdata = 32'h0;
    s_axis_tvalid = 1'b0;
    m_axis_tready = 1'b1;
    control_reg = 32'h0;

    // Reset the module
    #(CLK_PERIOD*2);
    rst_n = 1'b1;

    // Test case 1: Send input data
    #(CLK_PERIOD*2);
    s_axis_tdata = 32'h12345678;
    s_axis_tvalid = 1'b1;
    #(CLK_PERIOD);
    s_axis_tvalid = 1'b0;
    wait(m_axis_tvalid);
    #(CLK_PERIOD);

    // Test case 2: Configure control register
    #(CLK_PERIOD*2);
    control_reg = 32'hABCDEF01;
    #(CLK_PERIOD*2);

    // Test case 3: Send input data with control register configured
    #(CLK_PERIOD*2);
    s_axis_tdata = 32'h87654321;
    s_axis_tvalid = 1'b1;
    #(CLK_PERIOD);
    s_axis_tvalid = 1'b0;
    wait(m_axis_tvalid);
    #(CLK_PERIOD);

    // Test case 4: Check status register
    #(CLK_PERIOD*2);
    $display("Status register: %h", status_reg);
    if (status_reg[7:0] == 8'd1)
      $display("Status register is correct");
    else
      $error("Incorrect status register value");

    // End the simulation
    #(CLK_PERIOD*10);
    $finish;
  end

  // Verify the output data
  always @(posedge clk) begin
    if (m_axis_tvalid) begin
      $display("Output data: %h", m_axis_tdata);
      if (m_axis_tdata == 32'h12345678 + control_reg)
        $display("Output data is correct");
      else
        $error("Incorrect output data");
    end
  end

endmodule