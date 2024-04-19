//
// Created with the ESP Memory Generator
//
// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// @author Paolo Mantovani <paolo@cs.columbia.edu>
//

`timescale  1 ps / 1 ps

module fft2_plm_block_in_fx32(
    CLK,
    CE0,
    A0,
    D0,
    WE0,
    WEM0,
    CE1,
    A1,
    D1,
    WE1,
    WEM1,
    CE2,
    A2,
    Q2,
    CE3,
    A3,
    Q3
  );
  input CLK;
  input CE0;
  input [14:0] A0;
  input [31:0] D0;
  input WE0;
  input [31:0] WEM0;
  input CE1;
  input [14:0] A1;
  input [31:0] D1;
  input WE1;
  input [31:0] WEM1;
  input CE2;
  input [14:0] A2;
  output [31:0] Q2;
  input CE3;
  input [14:0] A3;
  output [31:0] Q3;
  genvar d, h, v, hh;

  reg               bank_CE  [0:0][0:0][1:0][31:0][1:0];
  reg        [13:0] bank_A   [0:0][0:0][1:0][31:0][1:0];
  reg         [0:0] bank_D   [0:0][0:0][1:0][31:0][1:0];
  reg               bank_WE  [0:0][0:0][1:0][31:0][1:0];
  reg         [0:0] bank_WEM [0:0][0:0][1:0][31:0][1:0];
  wire        [0:0] bank_Q   [0:0][0:0][1:0][31:0][1:0];
  wire        [0:0] ctrld    [3:2];
  wire        [0:0] ctrlh    [3:0];
  wire        [0:0] ctrlv    [3:0];
  reg         [0:0] seld     [3:2];
  reg         [0:0] selh     [3:2];
  reg         [0:0] selv     [3:2];
// synthesis translate_off
// synopsys translate_off
  integer check_bank_access [0:0][0:0][1:0][31:0][1:0];

  task check_access;
    input integer iface;
    input integer d;
    input integer h;
    input integer v;
    input integer hh;
    input integer p;
  begin
    if ((check_bank_access[d][h][v][hh][p] != -1) &&
        (check_bank_access[d][h][v][hh][p] != iface)) begin
      $display("ASSERTION FAILED in %m: port conflict on bank", h, "h", v, "v", hh, "hh", " for port", p, " involving interfaces", check_bank_access[d][h][v][hh][p], iface);
      $finish;
    end
    else begin
      check_bank_access[d][h][v][hh][p] = iface;
    end
  end
  endtask
// synopsys translate_on
// synthesis translate_on

  assign ctrld[2] = 0;
  assign ctrld[3] = 0;
  assign ctrlh[0] = 0;
  assign ctrlh[1] = 0;
  assign ctrlh[2] = 0;
  assign ctrlh[3] = 0;
  assign ctrlv[0] = A0[14:14];
  assign ctrlv[1] = A1[14:14];
  assign ctrlv[2] = A2[14:14];
  assign ctrlv[3] = A3[14:14];

  always @(posedge CLK) begin
    seld[2] <= ctrld[2];
    selh[2] <= ctrlh[2];
    selv[2] <= ctrlv[2];
    seld[3] <= ctrld[3];
    selh[3] <= ctrlh[3];
    selv[3] <= ctrlv[3];
  end

  generate
  for (h = 0; h < 1; h = h + 1) begin : gen_ctrl_hbanks
    for (v = 0; v < 2; v = v + 1) begin : gen_ctrl_vbanks
      for (hh = 0; hh < 32; hh = hh + 1) begin : gen_ctrl_hhbanks

        always @(*) begin : handle_ops

// synthesis translate_off
// synopsys translate_off
          // Prevent assertions to trigger with false positive
          # 1
// synopsys translate_on
// synthesis translate_on

          /** Default **/
// synthesis translate_off
// synopsys translate_off
          check_bank_access[0][h][v][hh][0] = -1;
// synopsys translate_on
// synthesis translate_on
          bank_CE[0][h][v][hh][0]  = 0;
          bank_A[0][h][v][hh][0]   = 0;
          bank_D[0][h][v][hh][0]   = 0;
          bank_WE[0][h][v][hh][0]  = 0;
          bank_WEM[0][h][v][hh][0] = 0;
// synthesis translate_off
// synopsys translate_off
          check_bank_access[0][h][v][hh][1] = -1;
// synopsys translate_on
// synthesis translate_on
          bank_CE[0][h][v][hh][1]  = 0;
          bank_A[0][h][v][hh][1]   = 0;
          bank_D[0][h][v][hh][1]   = 0;
          bank_WE[0][h][v][hh][1]  = 0;
          bank_WEM[0][h][v][hh][1] = 0;

          /** Handle 2w:0r **/
          // Duplicated bank set 0
            if (ctrlh[0] == h && ctrlv[0] == v && CE0 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(0, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE0;
                bank_A[0][h][v][hh][0]   = A0[13:0];
              if (hh != 31) begin
                bank_D[0][h][v][hh][0]   = D0[1 * (hh + 1) - 1:1 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[1 * (hh + 1) - 1:1 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D0[0 + 1 * hh:1 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[0 + 1 * hh:1 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE0;
            end
            if (ctrlh[1] == h && ctrlv[1] == v && CE1 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(1, 0, h, v, hh, 1);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][1]  = CE1;
                bank_A[0][h][v][hh][1]   = A1[13:0];
              if (hh != 31) begin
                bank_D[0][h][v][hh][1]   = D1[1 * (hh + 1) - 1:1 * hh];
                bank_WEM[0][h][v][hh][1] = WEM1[1 * (hh + 1) - 1:1 * hh];
              end
              else begin
                bank_D[0][h][v][hh][1]   = D1[0 + 1 * hh:1 * hh];
                bank_WEM[0][h][v][hh][1] = WEM1[0 + 1 * hh:1 * hh];
              end
                bank_WE[0][h][v][hh][1]  = WE1;
            end

          /** Handle 0w:2r **/
          // Always choose duplicated bank set 0
            if (ctrlh[2] == h && ctrlv[2] == v && CE2 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(2, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE2;
                bank_A[0][h][v][hh][0]   = A2[13:0];
            end
            if (ctrlh[3] == h && ctrlv[3] == v && CE3 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(3, 0, h, v, hh, 1);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][1]  = CE3;
                bank_A[0][h][v][hh][1]   = A3[13:0];
            end

        end

      end
    end
  end
  endgenerate

  generate
  for (hh = 0; hh < 32; hh = hh + 1) begin : gen_q_assign_hhbanks
    if (hh == 31 && (hh + 1) * 1 > 32) begin : gen_q_assign_hhbanks_last_2 
       assign Q2[31:1 * hh] = bank_Q[seld[2]][selh[2]][selv[2]][hh][0][0:0];
    end else begin : gen_q_assign_hhbanks_others_2 
      assign Q2[1 * (hh + 1) - 1:1 * hh] = bank_Q[seld[2]][selh[2]][selv[2]][hh][0];
    end
    if (hh == 31 && (hh + 1) * 1 > 32) begin : gen_q_assign_hhbanks_last_3 
       assign Q3[31:1 * hh] = bank_Q[seld[3]][selh[3]][selv[3]][hh][1][0:0];
    end else begin : gen_q_assign_hhbanks_others_3 
      assign Q3[1 * (hh + 1) - 1:1 * hh] = bank_Q[seld[3]][selh[3]][selv[3]][hh][1];
    end
  end
  endgenerate

  generate
  for (d = 0; d < 1; d = d + 1) begin : gen_wires_dbanks
    for (h = 0; h < 1; h = h + 1) begin : gen_wires_hbanks
      for (v = 0; v < 2; v = v + 1) begin : gen_wires_vbanks
        for (hh = 0; hh < 32; hh = hh + 1) begin : gen_wires_hhbanks

          BRAM_16384x1 bank_i(
              .CLK(CLK),
              .CE0(bank_CE[d][h][v][hh][0]),
              .A0(bank_A[d][h][v][hh][0]),
              .D0(bank_D[d][h][v][hh][0]),
              .WE0(bank_WE[d][h][v][hh][0]),
              .WEM0(bank_WEM[d][h][v][hh][0]),
              .Q0(bank_Q[d][h][v][hh][0]),
              .CE1(bank_CE[d][h][v][hh][1]),
              .A1(bank_A[d][h][v][hh][1]),
              .D1(bank_D[d][h][v][hh][1]),
              .WE1(bank_WE[d][h][v][hh][1]),
              .WEM1(bank_WEM[d][h][v][hh][1]),
              .Q1(bank_Q[d][h][v][hh][1])
            );

// synthesis translate_off
// synopsys translate_off
            always @(posedge CLK) begin
              if ((bank_CE[d][h][v][hh][0] & bank_CE[d][h][v][hh][1]) &&
                  (bank_WE[d][h][v][hh][0] | bank_WE[d][h][v][hh][1]) &&
                  (bank_A[d][h][v][hh][0] == bank_A[d][h][v][hh][1])) begin
                $display("ASSERTION FAILED in %m: address conflict on bank", h, "h", v, "v", hh, "hh");
                $finish;
              end
            end
// synopsys translate_on
// synthesis translate_on

        end
      end
    end
  end
  endgenerate

endmodule
