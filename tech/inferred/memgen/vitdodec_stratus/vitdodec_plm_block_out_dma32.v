//
// Created with the ESP Memory Generator
//
// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// @author Paolo Mantovani <paolo@cs.columbia.edu>
//

`timescale  1 ps / 1 ps

module vitdodec_plm_block_out_dma32(
    CLK,
    CE0,
    A0,
    D0,
    WE0,
    WEM0,
    CE1,
    A1,
    Q1,
    CE2,
    A2,
    Q2,
    CE3,
    A3,
    Q3,
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
  output [7:0] Q1;
  input CE2;
  input [14:0] A2;
  output [7:0] Q2;
  input CE3;
  input [14:0] A3;
  output [7:0] Q3;
  input CE4;
  input [14:0] A4;
  output [7:0] Q4;
  genvar d, h, v, hh;

  reg               bank_CE  [0:0][3:0][2:0][0:0][0:0];
  reg        [10:0] bank_A   [0:0][3:0][2:0][0:0][0:0];
  reg         [7:0] bank_D   [0:0][3:0][2:0][0:0][0:0];
  reg               bank_WE  [0:0][3:0][2:0][0:0][0:0];
  reg         [7:0] bank_WEM [0:0][3:0][2:0][0:0][0:0];
  wire        [7:0] bank_Q   [0:0][3:0][2:0][0:0][0:0];
  wire        [0:0] ctrld    [4:1];
  wire        [1:0] ctrlh    [4:0];
  wire        [1:0] ctrlv    [4:0];
  reg         [0:0] seld     [4:1];
  reg         [1:0] selh     [4:1];
  reg         [1:0] selv     [4:1];
// synthesis translate_off
// synopsys translate_off
  integer check_bank_access [0:0][3:0][2:0][0:0][0:0];

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

  assign ctrld[1] = 0;
  assign ctrld[2] = 0;
  assign ctrld[3] = 0;
  assign ctrld[4] = 0;
  assign ctrlh[0] = A0[1:0];
  assign ctrlh[1] = A1[1:0];
  assign ctrlh[2] = A2[1:0];
  assign ctrlh[3] = A3[1:0];
  assign ctrlh[4] = A4[1:0];
  assign ctrlv[0] = A0[14:13];
  assign ctrlv[1] = A1[14:13];
  assign ctrlv[2] = A2[14:13];
  assign ctrlv[3] = A3[14:13];
  assign ctrlv[4] = A4[14:13];

  always @(posedge CLK) begin
    seld[1] <= ctrld[1];
    selh[1] <= ctrlh[1];
    selv[1] <= ctrlv[1];
    seld[2] <= ctrld[2];
    selh[2] <= ctrlh[2];
    selv[2] <= ctrlv[2];
    seld[3] <= ctrld[3];
    selh[3] <= ctrlh[3];
    selv[3] <= ctrlv[3];
    seld[4] <= ctrld[4];
    selh[4] <= ctrlh[4];
    selv[4] <= ctrlv[4];
  end

  generate
  for (h = 0; h < 4; h = h + 1) begin : gen_ctrl_hbanks
    for (v = 0; v < 3; v = v + 1) begin : gen_ctrl_vbanks
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

          /** Handle 1w:0r **/
          // Duplicated bank set 0
            if (ctrlh[0] == h && ctrlv[0] == v && CE0 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(0, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE0;
                bank_A[0][h][v][hh][0]   = A0[12:2];
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

          /** Handle 0w:4r **/
          // Always choose duplicated bank set 0
            if (ctrlh[1] == h && ctrlv[1] == v && CE1 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(1, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE1;
                bank_A[0][h][v][hh][0]   = A1[12:2];
            end
            if (ctrlh[2] == h && ctrlv[2] == v && CE2 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(2, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE2;
                bank_A[0][h][v][hh][0]   = A2[12:2];
            end
            if (ctrlh[3] == h && ctrlv[3] == v && CE3 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(3, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE3;
                bank_A[0][h][v][hh][0]   = A3[12:2];
            end
            if (ctrlh[4] == h && ctrlv[4] == v && CE4 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(4, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE4;
                bank_A[0][h][v][hh][0]   = A4[12:2];
            end

        end

      end
    end
  end
  endgenerate

  generate
  for (hh = 0; hh < 1; hh = hh + 1) begin : gen_q_assign_hhbanks
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_1 
       assign Q1[7:8 * hh] = bank_Q[seld[1]][selh[1]][selv[1]][hh][0][7:0];
    end else begin : gen_q_assign_hhbanks_others_1 
      assign Q1[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[1]][selh[1]][selv[1]][hh][0];
    end
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_2 
       assign Q2[7:8 * hh] = bank_Q[seld[2]][selh[2]][selv[2]][hh][0][7:0];
    end else begin : gen_q_assign_hhbanks_others_2 
      assign Q2[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[2]][selh[2]][selv[2]][hh][0];
    end
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_3 
       assign Q3[7:8 * hh] = bank_Q[seld[3]][selh[3]][selv[3]][hh][0][7:0];
    end else begin : gen_q_assign_hhbanks_others_3 
      assign Q3[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[3]][selh[3]][selv[3]][hh][0];
    end
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_4 
       assign Q4[7:8 * hh] = bank_Q[seld[4]][selh[4]][selv[4]][hh][0][7:0];
    end else begin : gen_q_assign_hhbanks_others_4 
      assign Q4[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[4]][selh[4]][selv[4]][hh][0];
    end
  end
  endgenerate

  generate
  for (d = 0; d < 1; d = d + 1) begin : gen_wires_dbanks
    for (h = 0; h < 4; h = h + 1) begin : gen_wires_hbanks
      for (v = 0; v < 3; v = v + 1) begin : gen_wires_vbanks
        for (hh = 0; hh < 1; hh = hh + 1) begin : gen_wires_hhbanks

          sram_behav bank_i(
	       parameter DATA_WIDTH  = 8,
	       parameter NUM_WORDS =  2048,
              .clk_i(CLK),
              .req_i(bank_CE[d][h][v][hh][0]),
              .addr_i(bank_A[d][h][v][hh][0]),
              .wdata_i(bank_D[d][h][v][hh][0]),
              .we_i(bank_WE[d][h][v][hh][0]),
              .be_i(bank_WEM[d][h][v][hh][0]),
              .rdata_o(bank_Q[d][h][v][hh][0])
            );

        end
      end
    end
  end
  endgenerate

endmodule
