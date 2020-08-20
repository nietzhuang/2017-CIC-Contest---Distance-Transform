module init(
        input                   clk,
        input                   reset,
        input                   init_en,
        input                   for_en,
        output  reg             init_en_2,
        output                  init_done,
        output  reg     [9:0]   sti_addr ,
        input           [15:0]  sti_di,
        output  reg     [13:0]  res_addr_init ,
        output  reg     [7:0]   res_do_init
        );

        reg [9:0]       cnt_sti;  // count number of original image data.
        reg [3:0]       cnt_ini;  // count number of pixels of current sti_in.
        reg [13:0]      cnt_res;  // count number of result data input to res_ROM.
        reg             sti_tmp15;


        assign  init_done = (cnt_res == 14'h3FFF);
        
        //Initialize
        always@(posedge clk)begin
                if(!reset)
                        cnt_ini <= 4'd15;
                else if(init_en)
                        cnt_ini <= cnt_ini - 1;  // count down.
        end

        always@(posedge clk)begin
                if(!reset)
                        cnt_sti <= 10'b0;
                else if(init_en && (cnt_ini == 4'd0))
                        cnt_sti <= cnt_sti + 1;
        end

        always@*begin
                if(init_en)
                        sti_addr = cnt_sti;
                else
                        sti_addr = 10'd0;
        end

        always@(posedge clk)begin
                if(init_en)
                        sti_tmp15 <= sti_di[0];
        end
        
        //Initial output to res_RAM.
        always@(posedge clk)begin
                init_en_2 <= init_en;
        end

        always@(posedge clk)begin
                if(!reset)
                        cnt_res <= 14'b0;
                else if(init_en_2)
                        cnt_res <= cnt_res + 1;
        end

        always@*begin
                res_addr_init = cnt_res;
        end

        always@*begin
                if(init_en_2)begin
                        if(cnt_ini == 4'hF)
                                res_do_init = 8'h00 | sti_tmp15;  // fix the sti_addr mismatch problem.
                        else
                                res_do_init = 8'h00 | sti_di[cnt_ini+1];  // write to ROM delay one cycle to read RAM.
                end
                else
                        res_do_init = 8'h00;
        end
endmodule
        
