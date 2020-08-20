module ctrl(
        input                   clk,
        input                   reset,
        input                   init_en_2,
        input                   init_done,
        input                   for_load_done,
        input                   for_done,
        input                   for_op_done,
        input                   back_load_done,
        input                   back_done,
        output reg              init_en,
        output reg              for_en,
        output reg              for_load_en,
        output reg              back_en,
        output reg              back_load_en,
        output reg              sti_rd,
        output reg              res_wr,
        output reg              res_rd
        );

        parameter IDLE = 3'b000,  INIT = 3'b001, LOAD = 3'b010, FOR = 3'b011, BACK = 3'b100;
        reg [2:0] cstate, nstate;
        
        
        always@(posedge clk)begin
                if(!reset)
                        cstate <= 3'b0;
                else
                        cstate <= nstate;
        end
        
        always@*begin
                case(cstate)
                        IDLE:begin
                                if(!reset) nstate = IDLE;
                                else nstate = INIT;
                        end
                        INIT:begin
                                if(init_done)
                                        nstate = LOAD;
                                else
                                        nstate = INIT;
                        end
                        LOAD:begin
                                if(for_load_done)
                                        nstate = FOR;
                                else if(back_load_done)
                                        nstate = BACK;
                                else
                                        nstate = LOAD;
                        end
                        FOR:begin
                                if(for_done)
                                        nstate = LOAD;
                                else
                                        nstate = FOR;
                        end
                        BACK:begin
                                if(back_done)
                                        nstate = LOAD;
                                else
                                        nstate = BACK;
                        end
                        default: nstate = IDLE;
                endcase
        end
        
        always@*begin
                case(cstate)
                        IDLE:begin
                                init_en = 1'b0;
                                for_load_en = 1'b0;
                                for_en = 1'b0;
                                back_load_en = 1'b0;
                                back_en = 1'b0;
                                sti_rd = 1'b0;
                                res_wr = 1'b0;
                                res_rd = 1'b0;
                        end
                        INIT:begin
                                init_en = 1'b1;
                                for_load_en = 1'b0;
                                for_en = 1'b0;
                                back_load_en = 1'b0;
                                back_en = 1'b0;
                                sti_rd = 1'b1;  // have to hold on until pixel values have stored.
                                res_wr = init_en_2;
                                res_rd = 1'b0;
                        end
                        LOAD:begin
                                init_en = 1'b0;
                                for_load_en = (!for_op_done);
                                for_en = 1'b0;
                                back_load_en = for_op_done;
                                back_en = 1'b0;
                                sti_rd = 1'b0;
                                res_wr = 1'b0;
                                res_rd = 1'b1;
                        end
                        FOR:begin
                                init_en = 1'b0;
                                for_load_en = 1'b1;
                                for_en = 1'b1;
                                back_load_en = 1'b0;
                                back_en = 1'b0;
                                sti_rd = 1'b0;
                                res_wr = 1'b1;
                                res_rd = 1'b0;
                        end
                        BACK:begin
                                init_en = 1'b0;
                                for_load_en = 1'b0;
                                for_en = 1'b0;
                                back_load_en = 1'b1;
                                back_en = 1'b1;
                                sti_rd = 1'b0;
                                res_wr = 1'b1;
                                res_rd = 1'b0;
                        end
                        default:begin
                                init_en = 1'b0;
                                for_load_en = 1'b0;
                                for_en = 1'b0;
                                back_load_en = 1'b0;
                                back_en = 1'b0;
                                sti_rd = 1'b0;
                                res_wr = 1'b0;
                                res_rd = 1'b0;
                        end
                endcase
        end
endmodule
                        
