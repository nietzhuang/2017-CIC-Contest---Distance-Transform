module backward(
        input                   clk,
        input                   reset,
        input                   back_load_en,
        input                   back_en,
        output                  back_load_done,
        output                  back_done,
        output                  done,
        output  reg     [13:0]  res_addr_back,
        output  reg     [7:0]   res_do_back,
        input           [7:0]   res_di
        );

        reg [13:0]      cur;   // the current pixel.
        reg [2:0]       cnt_back;  // count 0 to 4 is load phase, count 5 to 6 is output phase.
        reg [7:0]       pixel_tmp[4:0];
        reg             back_op_done;

        reg [7:0]      min_tmp0, min_tmp1, min_tmp2, back_out;


        assign pass = (cur[6:0] == 7'b0) || (cur[6:0] == 7'h7F);
        assign back_load_done = (cnt_back == 4'd4);
        assign back_done = (cnt_back == 3'd5);
        assign done = back_op_done;
                
        always@(posedge clk)begin
                if(!reset)
                        cur <= 14'h3F7E;  // start from pixel 16254.
                else if(pass || (back_load_en && back_done))
                        cur <= cur - 1;
        end

        always@(posedge clk)begin
                if(!reset)
                        cnt_back <= 3'd0;
                else if(pass || (cnt_back == 3'd6))
                        cnt_back <= 3'd0;
                else if((!pass) && back_load_en && (!back_op_done))
                        cnt_back <= cnt_back + 1;
        end

        always@(posedge clk)begin
                if(!reset)
                        back_op_done <= 1'b0;
                else if(cur == 14'h0001)
                        back_op_done <= 1'b1;
        end

        always@*begin
                case(cnt_back)
                        3'd0: res_addr_back = cur;
                        3'd1: res_addr_back = cur + 1;
                        3'd2: res_addr_back = cur + 127;
                        3'd3: res_addr_back = cur + 128;
                        3'd4: res_addr_back = cur + 129;
                        3'd5: res_addr_back = cur;  // backward output address.
                        default: res_addr_back = 14'd0;
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
                else if(back_load_en && (!back_op_done))
                        pixel_tmp[cnt_back] <= res_di;
        end

        always@*begin
                if(cnt_back == 3'd5)begin
                        min_tmp0 = (pixel_tmp[0] <= (pixel_tmp[1]+1))? pixel_tmp[0] : (pixel_tmp[1] + 1);
                        min_tmp1 = ((pixel_tmp[2]+1) <= (pixel_tmp[3]+1))? (pixel_tmp[2]+1) : (pixel_tmp[3]+1);
                        min_tmp2 = ((pixel_tmp[4]+1) <= min_tmp1)? (pixel_tmp[4]+1) : min_tmp1;
                        back_out = (min_tmp0 <= min_tmp2)? min_tmp0 : min_tmp2;
                end
                else begin
                        min_tmp0 = 7'd0;
                        min_tmp1 = 7'd0;
                        min_tmp2 = 7'd0;
                        back_out = 7'd0;
                end
        end

        always@*begin
                if(cnt_back >= 3'd5)
                        res_do_back = back_out;
                else
                        res_do_back = 7'd0;
        end
endmodule
