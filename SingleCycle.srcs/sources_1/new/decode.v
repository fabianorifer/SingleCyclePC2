module decode (
    Op,
    Funct,
    Rd,
    FlagW,
    PCS,
    RegW,
    MemW,
    MemtoReg,
    ALUSrc,
    ImmSrc,
    RegSrc,
    ALUControl,
    ByteLoad
);
    input wire [1:0] Op;
    input wire [5:0] Funct;
    input wire [3:0] Rd;
    output reg [1:0] FlagW;
    output wire PCS;
    output wire RegW;
    output wire MemW;
    output wire MemtoReg;
    output wire ALUSrc;
    output wire [1:0] ImmSrc;
    output wire [1:0] RegSrc;
    output reg [2:0] ALUControl;
    output wire ByteLoad;

    reg [9:0] controls;
    wire Branch;
    wire ALUOp;

    always @(*) begin
        casex (Op)
            2'b00:
                if(Funct == 6'b010011) // registro -teq
                    controls = 10'b0000000001; //asignar signals
                else if(Funct == 6'b110011) //asignar signals
                    controls = 10'b0000100001;
                else if(Funct == 6'b010001) // registro -tst
                    controls = 10'b0000000001; // asignacion signals
                else if(Funct == 6'b110001) //immediate
                    controls = 10'b0000100001; //asignacion signals
        
        
                else if (Funct[5])
                    controls = 10'b0000101001; 
                else
                    controls = 10'b0000001001;
            2'b01:
                if (Funct[0])
                    controls = 10'b0001111000; 
                else
                    controls = 10'b1001110100;
            2'b10:
                controls = 10'b0110100010;
            default:
                controls = 10'bxxxxxxxxxx;
        endcase
    end

    assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;

    always @(*) begin
        if (ALUOp) begin
            case (Funct[4:1])
                4'b0100: ALUControl = 3'b000; // add
                4'b0010: ALUControl = 3'b001; // sub
                4'b0000: ALUControl = 3'b010; // and
                4'b1100: ALUControl = 3'b011; // orr
                4'b0001: ALUControl = 3'b100; // eor
                4'b1101: ALUControl = 3'b101; // mov
                4'b1000: begin
                    ALUControl = 3'b010; // tst-and
                    FlagW = 2'b10;
                    end
                4'b1001: begin
                    ALUControl = 3'b100;
                    FlagW = 2'b10;
                    end
                default: ALUControl = 3'bxxx;
            endcase

            FlagW[1] = Funct[0];
            FlagW[0] = Funct[0] & (
                (ALUControl == 3'b000) | 
                (ALUControl == 3'b001) | 
                (ALUControl == 3'b101)
            );
        end
        else begin
            ALUControl = 3'b000;
            FlagW = 2'b00;
        end
    end

    assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
    assign ByteLoad = (Op == 2'b01 && Funct[5] == 1'b1 && Funct[3] == 1'b1);

endmodule
