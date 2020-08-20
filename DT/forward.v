module forward(
        input                   clk,
        input                   reset,
        input                   for_load_en,
        input                   for_en,
        output                  for_load_done,
        output                  for_done,
        output  reg             for_op_done,
        output  reg     [13:0]  res_addr_for,
        output  reg     [7:0]   res_do_for,
        input           [7:0]   res_di
        );

        reg [13:0]      cur;   // the current pixel.
        reg [2:0]       cnt_for;  // count 0 to 4 is load phase, count 5 to 6 is output phase.
        reg [4:0]       pixel_tmp[7:0];

        reg [13:0]      min_tmp0, min_tmp1, for_out;


        assign pass = (cur[6:0] == 7'b0) || (cur[6:0] == 7'h7F) || (cur>= 14'h3F80) || (for_load_en && (cnt_for == 3'd0) && (res_di == 8'd0));
        assign for_load_done = (cnt_for == 4'd4);
        assign for_done = (cnt_for == 3'd5);
              
        always@(posedge clk)begin
                if(!reset)
                        cur <= 14'd128;  // start from pixel 128.
                else if(pass ||(for_load_en && for_done))

                        cur <= cur + 1;
        end

        always@(posedge clk)begin
                if(!reset)
                        cnt_for <= 3'd0;
                else if(pass || (cnt_for == 3'd6))  // load 5 data, including current pixel which is used to discriminate whether it is object.
                                                     // count 5, to do minimize operation.
                        cnt_for <= 3'd0;
                else if((!pass) && for_load_en && (!for_op_done))
                        cnt_for <= cnt_for + 1;
        end

        always@(posedge clk)begin
                if(!reset)
                        for_op_done <= 1'b0;
                else if(for_load_en && (cur == 14'h3FFF))
                        for_op_done <= 1'b1;  // keep it as flag.
        end

        always@*begin
                case(cnt_for)
                        3'd0: res_addr_for = cur;
                        3'd1: res_addr_for = cur - 14'd129;
                        3'd2: res_addr_for = cur - 14'd128;
                        3'd3: res_addr_for = cur - 14'd127;
                        3'd4: res_addr_for = cur - 14'd1;
                        3'd5: res_addr_for = cur;  // forward output address.
                        default: res_addr_for = 14'd0;
                endcase
        end

        always@(posedge clk)begin
                if(!reset)begin
                        pixel_tmp[0] <= 8'hFF;
                        pixel_tmp[1] <= 8'hFF;
                        pixel_tmp[2] <= 8'hFF;
                        pixel_tmp[3] <= 8'hFF;
                        pixel_tmp[4] <= 8'hFF;
                end
                else if(/*(!pass) && */ for_load_en && (!for_op_done))begin
                        pixel_tmp[cnt_for] <= res_di;
                end
        end

        // Find minimum
        always@*begin
                if(cnt_for == 3'd5)begin
                        min_tmp0 = (pixel_tmp[1] <= pixel_tmp[2])? pixel_tmp[1] : pixel_tmp[2];
                        min_tmp1 = (pixel_tmp[3] <= pixel_tmp[4])? pixel_tmp[3] : pixel_tmp[4];
                        for_out = (min_tmp0 <= min_tmp1)? min_tmp0+1 : min_tmp1+1;
                end
                else begin
                        min_tmp0 = 14'd0;
                        min_tmp1 = 14'd0;
                        for_out = 14'd0;
                end
        end

        // Output the forward pass result.
        always@*begin
                if(cnt_for >= 3'd5)
                        res_do_for = for_out;
                else
                        res_do_for = 14'd0;
        end
endmodule
