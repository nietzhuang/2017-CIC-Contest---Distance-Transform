`include "ctrl.v"
`include "init.v"
`include "forward.v"
`include "backward.v"

module DT(
        input                   clk,
        input                   reset,
        output                  done,
        output                  sti_rd,
        output  [9:0]           sti_addr,
        input   [15:0]          sti_di,
        output                  res_wr,
        output                  res_rd,
        output  reg [13:0]      res_addr,
        output  reg [7:0]       res_do,
        input   [7:0]           res_di
        );

        wire [7:0] res_do_init, res_do_for, res_do_back;
        wire [13:0] res_addr_init, res_addr_for, res_addr_back;
        wire init_en, init_en_2, load_en, for_load_en, for_en, back_load_en, back_en;
        wire init_done, for_load_done, back_load_done, for_done, for_op_done, back_done;
        
        
        always@*begin
                case({init_en_2, for_en, back_en})
                        3'b100: res_do = res_do_init;
                        3'b010: res_do = res_do_for;
                        3'b001: res_do = res_do_back;
                        default:res_do = 8'd0;
                endcase
        end

        always@*begin
                case({init_en_2, for_load_en, back_load_en})
                        3'b100: res_addr = res_addr_init;
                        3'b010: res_addr = res_addr_for;
                        3'b001: res_addr = res_addr_back;
                        default:res_addr = 14'b0;
                endcase
        end
        
        init u_init(.clk(clk),
                    .reset(reset),
                    .init_en(init_en),
                    .for_en(for_en),
                    .init_done(init_done),
                    .init_en_2(init_en_2),
                    .sti_addr(sti_addr),
                    .sti_di(sti_di),
                    .res_addr_init(res_addr_init),
                    .res_do_init(res_do_init)
                    );

        forward u_for(.clk(clk),
                      .reset(reset),
                      .for_load_en(for_load_en),
                      .for_en(for_en),
                      .for_load_done(for_load_done),
                      .for_done(for_done),
                      .for_op_done(for_op_done),
                      .res_addr_for(res_addr_for),
                      .res_do_for(res_do_for),
                      .res_di(res_di)
                      );
                      
        backward u_back(.clk(clk),
                        .reset(reset),
                        .back_load_en(back_load_en),
                        .back_en(back_en),
                        .back_load_done(back_load_done),
                        .back_done(back_done),
                        .done(done),
                        .res_addr_back(res_addr_back),
                        .res_do_back(res_do_back),
                        .res_di(res_di)
                        );

        ctrl u_ctrl(.clk(clk),
                    .reset(reset),
                    .init_en_2(init_en_2),
                    .init_done(init_done),
                    .for_load_done(for_load_done),
                    .for_done(for_done),
                    .for_op_done(for_op_done),
                    .back_load_done(back_load_done),
                    .back_done(back_done),

                    .init_en(init_en),
                    .for_en(for_en),
                    .for_load_en(for_load_en),
                    .back_en(back_en),
                    .back_load_en(back_load_en),
                    .sti_rd(sti_rd),
                    .res_wr(res_wr),
                    .res_rd(res_rd)
                    );
endmodule

