//
// Created with the ESP Memory Generator
//
// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// @author Paolo Mantovani <paolo@cs.columbia.edu>
//

`timescale  1 ps / 1 ps

module vitdodec_plm_block_in_dma32(
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
    D2,
    WE2,
    WEM2,
    CE3,
    A3,
    D3,
    WE3,
    WEM3,
    CE4,
    A4,
    Q4
  );
  input CLK;
  input CE0;
  input [14:0] A0;
  input [7:0] D0;
  input WE0;
  input [7:0] WEM0;
  input CE1;
  input [14:0] A1;
  input [7:0] D1;
  input WE1;
  input [7:0] WEM1;
  input CE2;
  input [14:0] A2;
  input [7:0] D2;
  input WE2;
  input [7:0] WEM2;
  input CE3;
  input [14:0] A3;
  input [7:0] D3;
  input WE3;
  input [7:0] WEM3;
  input CE4;
  input [14:0] A4;
  output [7:0] Q4;
  genvar d, h, v, hh;

  reg               bank_CE  [0:0][1:0][6:0][0:0][1:0];
  reg        [10:0] bank_A   [0:0][1:0][6:0][0:0][1:0];
  reg         [7:0] bank_D   [0:0][1:0][6:0][0:0][1:0];
  reg               bank_WE  [0:0][1:0][6:0][0:0][1:0];
  reg         [7:0] bank_WEM [0:0][1:0][6:0][0:0][1:0];
  wire        [7:0] bank_Q   [0:0][1:0][6:0][0:0][1:0];
  wire        [0:0] ctrld    [4:4];
  wire        [0:0] ctrlh    [4:0];
  wire        [2:0] ctrlv    [4:0];
  reg         [0:0] seld     [4:4];
  reg         [0:0] selh     [4:4];
  reg         [2:0] selv     [4:4];
// synthesis translate_off
// synopsys translate_off
  integer check_bank_access [0:0][1:0][6:0][0:0][1:0];

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

  assign ctrld[4] = 0;
  assign ctrlh[0] = A0[0:0];
  assign ctrlh[1] = A1[0:0];
  assign ctrlh[2] = A2[0:0];
  assign ctrlh[3] = A3[0:0];
  assign ctrlh[4] = A4[0:0];
  assign ctrlv[0] = A0[14:12];
  assign ctrlv[1] = A1[14:12];
  assign ctrlv[2] = A2[14:12];
  assign ctrlv[3] = A3[14:12];
  assign ctrlv[4] = A4[14:12];

  always @(posedge CLK) begin
    seld[4] <= ctrld[4];
    selh[4] <= ctrlh[4];
    selv[4] <= ctrlv[4];
  end

  generate
  for (h = 0; h < 2; h = h + 1) begin : gen_ctrl_hbanks
    for (v = 0; v < 7; v = v + 1) begin : gen_ctrl_vbanks
      for (hh = 0; hh < 1; hh = hh + 1) begin : gen_ctrl_hhbanks

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

          /** Handle 4w:0r **/
          // Duplicated bank set 0
            if (ctrlh[0] == h && ctrlv[0] == v && CE0 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(0, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE0;
                bank_A[0][h][v][hh][0]   = A0[11:1];
              if (hh != 0) begin
                bank_D[0][h][v][hh][0]   = D0[8 * (hh + 1) - 1:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[8 * (hh + 1) - 1:8 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D0[7 + 8 * hh:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[7 + 8 * hh:8 * hh];
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
                bank_A[0][h][v][hh][1]   = A1[11:1];
              if (hh != 0) begin
                bank_D[0][h][v][hh][1]   = D1[8 * (hh + 1) - 1:8 * hh];
                bank_WEM[0][h][v][hh][1] = WEM1[8 * (hh + 1) - 1:8 * hh];
              end
              else begin
                bank_D[0][h][v][hh][1]   = D1[7 + 8 * hh:8 * hh];
                bank_WEM[0][h][v][hh][1] = WEM1[7 + 8 * hh:8 * hh];
              end
                bank_WE[0][h][v][hh][1]  = WE1;
            end
            if (ctrlh[2] == h && ctrlv[2] == v && CE2 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(2, 0, h, v, hh, 1);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][1]  = CE2;
                bank_A[0][h][v][hh][1]   = A2[11:1];
              if (hh != 0) begin
                bank_D[0][h][v][hh][1]   = D2[8 * (hh + 1) - 1:8 * hh];
                bank_WEM[0][h][v][hh][1] = WEM2[8 * (hh + 1) - 1:8 * hh];
              end
              else begin
                bank_D[0][h][v][hh][1]   = D2[7 + 8 * hh:8 * hh];
                bank_WEM[0][h][v][hh][1] = WEM2[7 + 8 * hh:8 * hh];
              end
                bank_WE[0][h][v][hh][1]  = WE2;
            end
            if (ctrlh[3] == h && ctrlv[3] == v && CE3 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(3, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE3;
                bank_A[0][h][v][hh][0]   = A3[11:1];
              if (hh != 0) begin
                bank_D[0][h][v][hh][0]   = D3[8 * (hh + 1) - 1:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM3[8 * (hh + 1) - 1:8 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D3[7 + 8 * hh:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM3[7 + 8 * hh:8 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE3;
            end

          /** Handle 0w:1r **/
          // Always choose duplicated bank set 0
            if (ctrlh[4] == h && ctrlv[4] == v && CE4 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(4, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE4;
                bank_A[0][h][v][hh][0]   = A4[11:1];
            end

        end

      end
    end
  end
  endgenerate

  generate
  for (hh = 0; hh < 1; hh = hh + 1) begin : gen_q_assign_hhbanks
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_4 
       assign Q4[7:8 * hh] = bank_Q[seld[4]][selh[4]][selv[4]][hh][0][7:0];
    end else begin : gen_q_assign_hhbanks_others_4 
      assign Q4[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[4]][selh[4]][selv[4]][hh][0];
    end
  end
  endgenerate

  generate
  for (d = 0; d < 1; d = d + 1) begin : gen_wires_dbanks
    for (h = 0; h < 2; h = h + 1) begin : gen_wires_hbanks
      for (v = 0; v < 7; v = v + 1) begin : gen_wires_vbanks
        for (hh = 0; hh < 1; hh = hh + 1) begin : gen_wires_hhbanks

          BRAM_2048x8 bank_i(
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
