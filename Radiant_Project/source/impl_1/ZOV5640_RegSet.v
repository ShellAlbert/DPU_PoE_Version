`include "ZPortableDefine.v"

//Naming Rules:
//XXXX_i:  internal registers.
//iXXXXX:  external input signals.
//oXXXX:   output to external signals.
//ioXXX:   bi-directional signals.
module ZOV5640_RegSet(
    input wire iClk,
    input wire iRstN,
    input wire iEn,

    input wire [15:0] iIndex,
    output reg [15:0] oRegAddr,
    output reg [7:0] oRegData
);

`include "ZOV5640_RegAddr.v"

//How many registers need to be configured. 
parameter CFG_REG_MAX_NUM=249;

//https://gitee.com/mirros_STMicroelectronics/stm32-ov5640
//since combinational logic can't support concatenation output, 
//so we use synchronous clock here.
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
    {oRegAddr,oRegData}<={16'd0, 8'd0};
end
else begin
    if(iEn) begin
        case(iIndex)
            0:begin {oRegAddr,oRegData}<={OV5640_SCCB_SYSTEM_CTRL1, 8'h11}; end //0x3103=0x11.
            // 24MHz input clock, 24MHz PCLK
            1:begin {oRegAddr,oRegData}<={16'h3103, 8'h11};end // system clock from pad, bit[1]
            2:begin {oRegAddr,oRegData}<={16'h3008, 8'h82};end // software reset, bit[7]0x3008, 0x42, // software power down, bit[6]
            3:begin {oRegAddr,oRegData}<={16'h3103, 8'h03};end // system clock from PLL, bit[1]
            4:begin {oRegAddr,oRegData}<={16'h3017, 8'hff};end // FREX, Vsync, HREF, PCLK, D[9:6] output enable
            5:begin {oRegAddr,oRegData}<={16'h3018, 8'hff};end // D[5:0], GPIO[1:0] output enable
            6:begin {oRegAddr,oRegData}<={16'h3034, 8'h1a};end // MIPI 10-bit
            7:begin {oRegAddr,oRegData}<={16'h3037, 8'h13};end // PLL root divider, bit[4], PLL pre-divider, bit[3:0]
            8:begin {oRegAddr,oRegData}<={16'h3108, 8'h01};end // PCLK root divider, bit[5:4], SCLK2x root divider, bit[3:2]

            // SCLK root};enddivider, bit[1:0]
            9:begin  {oRegAddr,oRegData}<={16'h3630, 8'h36};end
            10:begin {oRegAddr,oRegData}<={16'h3631, 8'h0e};end
            11:begin {oRegAddr,oRegData}<={16'h3632, 8'he2};end
            12:begin {oRegAddr,oRegData}<={16'h3633, 8'h12};end
            13:begin {oRegAddr,oRegData}<={16'h3621, 8'he0};end
            14:begin {oRegAddr,oRegData}<={16'h3704, 8'ha0};end
            15:begin {oRegAddr,oRegData}<={16'h3703, 8'h5a};end
            16:begin {oRegAddr,oRegData}<={16'h3715, 8'h78};end
            17:begin {oRegAddr,oRegData}<={16'h3717, 8'h01};end
            18:begin {oRegAddr,oRegData}<={16'h370b, 8'h60};end
            19:begin {oRegAddr,oRegData}<={16'h3705, 8'h1a};end
            20:begin {oRegAddr,oRegData}<={16'h3905, 8'h02};end
            21:begin {oRegAddr,oRegData}<={16'h3906, 8'h10};end
            22:begin {oRegAddr,oRegData}<={16'h3901, 8'h0a};end
            23:begin {oRegAddr,oRegData}<={16'h3731, 8'h12};end
            24:begin {oRegAddr,oRegData}<={16'h3600, 8'h08};end // VCM control
            25:begin {oRegAddr,oRegData}<={16'h3601, 8'h33};end // VCM control
            26:begin {oRegAddr,oRegData}<={16'h302d, 8'h60};end // system control
            27:begin {oRegAddr,oRegData}<={16'h3620, 8'h52};end
            28:begin {oRegAddr,oRegData}<={16'h371b, 8'h20};end
            29:begin {oRegAddr,oRegData}<={16'h471c, 8'h50};end
            30:begin {oRegAddr,oRegData}<={16'h3a13, 8'h43};end // pre-gain = 1.047x
            31:begin {oRegAddr,oRegData}<={16'h3a18, 8'h00};end // gain ceiling
            32:begin {oRegAddr,oRegData}<={16'h3a19, 8'hf8};end // gain ceiling = 15.5x
            33:begin {oRegAddr,oRegData}<={16'h3635, 8'h13};end
            34:begin {oRegAddr,oRegData}<={16'h3636, 8'h03};end
            35:begin {oRegAddr,oRegData}<={16'h3634, 8'h40};end
            36:begin {oRegAddr,oRegData}<={16'h3622, 8'h01};end
            // 50/60Hz d};endtection 50/60Hz 灯光条纹过滤
            37:begin {oRegAddr,oRegData}<={16'h3c01, 8'h34};end // Band auto, bit[7]
            38:begin {oRegAddr,oRegData}<={16'h3c04, 8'h28};end // threshold low sum
            39:begin {oRegAddr,oRegData}<={16'h3c05, 8'h98};end // threshold high sum
            40:begin {oRegAddr,oRegData}<={16'h3c06, 8'h00};end // light meter 1 threshold[15:8]
            41:begin {oRegAddr,oRegData}<={16'h3c07, 8'h08};end // light meter 1 threshold[7:0]
            42:begin {oRegAddr,oRegData}<={16'h3c08, 8'h00};end // light meter 2 threshold[15:8]
            43:begin {oRegAddr,oRegData}<={16'h3c09, 8'h1c};end // light meter 2 threshold[7:0]
            44:begin {oRegAddr,oRegData}<={16'h3c0a, 8'h9c};end // sample number[15:8]
            45:begin {oRegAddr,oRegData}<={16'h3c0b, 8'h40};end // sample number[7:0]
            46:begin {oRegAddr,oRegData}<={16'h3810, 8'h00};end // Timing Hoffset[11:8]
            47:begin {oRegAddr,oRegData}<={16'h3811, 8'h10};end // Timing Hoffset[7:0]
            48:begin {oRegAddr,oRegData}<={16'h3812, 8'h00};end // Timing Voffset[10:8]
            49:begin {oRegAddr,oRegData}<={16'h3708, 8'h64};end
            50:begin {oRegAddr,oRegData}<={16'h4001, 8'h02};end // BLC start from line 2
            51:begin {oRegAddr,oRegData}<={16'h4005, 8'h1a};end // BLC always update
            52:begin {oRegAddr,oRegData}<={16'h3000, 8'h00};end // enable blocks
            53:begin {oRegAddr,oRegData}<={16'h3004, 8'hff};end // enable clocks
            54:begin {oRegAddr,oRegData}<={16'h300e, 8'h58};end // MIPI power down, DVP enable
            55:begin {oRegAddr,oRegData}<={16'h302e, 8'h00};end
            56:begin {oRegAddr,oRegData}<={16'h4300, 8'h30};end // YUV 422, YUYV
            57:begin {oRegAddr,oRegData}<={16'h501f, 8'h00};end // YUV 422 
            58:begin {oRegAddr,oRegData}<={16'h440e, 8'h00};end
            59:begin {oRegAddr,oRegData}<={16'h5000, 8'ha7};end // Lenc on, raw gamma on, BPC on, WPC on, CIP on
            // AEC targe};end 自动曝光控制
            60:begin {oRegAddr,oRegData}<={16'h3a0f, 8'h30};end // stable range in high
            61:begin {oRegAddr,oRegData}<={16'h3a10, 8'h28};end // stable range in low
            62:begin {oRegAddr,oRegData}<={16'h3a1b, 8'h30};end // stable range out high
            63:begin {oRegAddr,oRegData}<={16'h3a1e, 8'h26};end // stable range out low
            64:begin {oRegAddr,oRegData}<={16'h3a11, 8'h60};end // fast zone high
            65:begin {oRegAddr,oRegData}<={16'h3a1f, 8'h14};end // fast zone low
            // Lens corr};endction for ? 镜头补偿
            66:begin {oRegAddr,oRegData}<={16'h5800, 8'h23};end
            67:begin {oRegAddr,oRegData}<={16'h5801, 8'h14};end
            68:begin {oRegAddr,oRegData}<={16'h5802, 8'h0f};end
            69:begin {oRegAddr,oRegData}<={16'h5803, 8'h0f};end
            70:begin {oRegAddr,oRegData}<={16'h5804, 8'h12};end
            71:begin {oRegAddr,oRegData}<={16'h5805, 8'h26};end
            72:begin {oRegAddr,oRegData}<={16'h5806, 8'h0c};end
            73:begin {oRegAddr,oRegData}<={16'h5807, 8'h08};end
            74:begin {oRegAddr,oRegData}<={16'h5808, 8'h05};end
            75:begin {oRegAddr,oRegData}<={16'h5809, 8'h05};end
            76:begin {oRegAddr,oRegData}<={16'h580a, 8'h08};end

            77:begin {oRegAddr,oRegData}<={16'h580b, 8'h0d};end
            78:begin {oRegAddr,oRegData}<={16'h580c, 8'h08};end
            79:begin {oRegAddr,oRegData}<={16'h580d, 8'h03};end
            80:begin {oRegAddr,oRegData}<={16'h580e, 8'h00};end
            81:begin {oRegAddr,oRegData}<={16'h580f, 8'h00};end
            82:begin {oRegAddr,oRegData}<={16'h5810, 8'h03};end
            83:begin {oRegAddr,oRegData}<={16'h5811, 8'h09};end
            84:begin {oRegAddr,oRegData}<={16'h5812, 8'h07};end
            85:begin {oRegAddr,oRegData}<={16'h5813, 8'h03};end
            86:begin {oRegAddr,oRegData}<={16'h5814, 8'h00};end
            87:begin {oRegAddr,oRegData}<={16'h5815, 8'h01};end
            88:begin {oRegAddr,oRegData}<={16'h5816, 8'h03};end
            89:begin {oRegAddr,oRegData}<={16'h5817, 8'h08};end
            90:begin {oRegAddr,oRegData}<={16'h5818, 8'h0d};end
            91:begin {oRegAddr,oRegData}<={16'h5819, 8'h08};end
            92:begin {oRegAddr,oRegData}<={16'h581a, 8'h05};end
            93:begin {oRegAddr,oRegData}<={16'h581b, 8'h06};end
            94:begin {oRegAddr,oRegData}<={16'h581c, 8'h08};end
            95:begin {oRegAddr,oRegData}<={16'h581d, 8'h0e};end
            96:begin {oRegAddr,oRegData}<={16'h581e, 8'h29};end
            97:begin {oRegAddr,oRegData}<={16'h581f, 8'h17};end
            98:begin {oRegAddr,oRegData}<={16'h5820, 8'h11};end
            99:begin {oRegAddr,oRegData}<={16'h5821, 8'h11};end
            100:begin {oRegAddr,oRegData}<={16'h5822, 8'h15};end
            101:begin {oRegAddr,oRegData}<={16'h5823, 8'h28};end
            102:begin {oRegAddr,oRegData}<={16'h5824, 8'h46};end
            103:begin {oRegAddr,oRegData}<={16'h5825, 8'h26};end
            104:begin {oRegAddr,oRegData}<={16'h5826, 8'h08};end
            105:begin {oRegAddr,oRegData}<={16'h5827, 8'h26};end
            106:begin {oRegAddr,oRegData}<={16'h5828, 8'h64};end
            107:begin {oRegAddr,oRegData}<={16'h5829, 8'h26};end
            108:begin {oRegAddr,oRegData}<={16'h582a, 8'h24};end
            109:begin {oRegAddr,oRegData}<={16'h582b, 8'h22};end
            110:begin {oRegAddr,oRegData}<={16'h582c, 8'h24};end
            111:begin {oRegAddr,oRegData}<={16'h582d, 8'h24};end
            112:begin {oRegAddr,oRegData}<={16'h582e, 8'h06};end
            113:begin {oRegAddr,oRegData}<={16'h582f, 8'h22};end
            114:begin {oRegAddr,oRegData}<={16'h5830, 8'h40};end
            115:begin {oRegAddr,oRegData}<={16'h5831, 8'h42};end
            116:begin {oRegAddr,oRegData}<={16'h5832, 8'h24};end
            117:begin {oRegAddr,oRegData}<={16'h5833, 8'h26};end
            118:begin {oRegAddr,oRegData}<={16'h5834, 8'h24};end
            119:begin {oRegAddr,oRegData}<={16'h5835, 8'h22};end
            120:begin {oRegAddr,oRegData}<={16'h5836, 8'h22};end
            121:begin {oRegAddr,oRegData}<={16'h5837, 8'h26};end
            122:begin {oRegAddr,oRegData}<={16'h5838, 8'h44};end
            123:begin {oRegAddr,oRegData}<={16'h5839, 8'h24};end
            124:begin {oRegAddr,oRegData}<={16'h583a, 8'h26};end
            125:begin {oRegAddr,oRegData}<={16'h583b, 8'h28};end
            126:begin {oRegAddr,oRegData}<={16'h583c, 8'h42};end
            127:begin {oRegAddr,oRegData}<={16'h583d, 8'hce};end // lenc BR offset
            // AWB 自动白平衡
            128:begin {oRegAddr,oRegData}<={16'h5180, 8'hff};end // AWB B block
            129:begin {oRegAddr,oRegData}<={16'h5181, 8'hf2};end // AWB control
            130:begin {oRegAddr,oRegData}<={16'h5182, 8'h00};end // [7:4] max local counter, [3:0] max fast counter
            131:begin {oRegAddr,oRegData}<={16'h5183, 8'h14};end // AWB advanced
            132:begin {oRegAddr,oRegData}<={16'h5184, 8'h25};end
            133:begin {oRegAddr,oRegData}<={16'h5185, 8'h24};end
            134:begin {oRegAddr,oRegData}<={16'h5186, 8'h09};end
            135:begin {oRegAddr,oRegData}<={16'h5187, 8'h09};end
            136:begin {oRegAddr,oRegData}<={16'h5188, 8'h09};end
            137:begin {oRegAddr,oRegData}<={16'h5189, 8'h75};end
            138:begin {oRegAddr,oRegData}<={16'h518a, 8'h54};end
            139:begin {oRegAddr,oRegData}<={16'h518b, 8'he0};end
            140:begin {oRegAddr,oRegData}<={16'h518c, 8'hb2};end
            141:begin {oRegAddr,oRegData}<={16'h518d, 8'h42};end
            142:begin {oRegAddr,oRegData}<={16'h518e, 8'h3d};end
            143:begin {oRegAddr,oRegData}<={16'h518f, 8'h56};end
            144:begin {oRegAddr,oRegData}<={16'h5190, 8'h46};end
            145:begin {oRegAddr,oRegData}<={16'h5191, 8'hf8};end // AWB top limit
            146:begin {oRegAddr,oRegData}<={16'h5192, 8'h04};end // AWB bottom limit
            147:begin {oRegAddr,oRegData}<={16'h5193, 8'h70};end // red limit
            148:begin {oRegAddr,oRegData}<={16'h5194, 8'hf0};end // green limit
            149:begin {oRegAddr,oRegData}<={16'h5195, 8'hf0};end // blue limit
            150:begin {oRegAddr,oRegData}<={16'h5196, 8'h03};end // AWB control
            151:begin {oRegAddr,oRegData}<={16'h5197, 8'h01};end // local limit
            152:begin {oRegAddr,oRegData}<={16'h5198, 8'h04};end
            153:begin {oRegAddr,oRegData}<={16'h5199, 8'h12};end
            154:begin {oRegAddr,oRegData}<={16'h519a, 8'h04};end
            155:begin {oRegAddr,oRegData}<={16'h519b, 8'h00};end
            156:begin {oRegAddr,oRegData}<={16'h519c, 8'h06};end
            157:begin {oRegAddr,oRegData}<={16'h519d, 8'h82};end
            158:begin {oRegAddr,oRegData}<={16'h519e, 8'h38};end // AWB control
            // Gamma 伽};end曲线
            159:begin {oRegAddr,oRegData}<={16'h5480, 8'h01};end // Gamma bias plus on, bit[0]
            160:begin {oRegAddr,oRegData}<={16'h5481, 8'h08};end
            161:begin {oRegAddr,oRegData}<={16'h5482, 8'h14};end
            162:begin {oRegAddr,oRegData}<={16'h5483, 8'h28};end
            163:begin {oRegAddr,oRegData}<={16'h5484, 8'h51};end
            164:begin {oRegAddr,oRegData}<={16'h5485, 8'h65};end
            165:begin {oRegAddr,oRegData}<={16'h5486, 8'h71};end
            166:begin {oRegAddr,oRegData}<={16'h5487, 8'h7d};end
            167:begin {oRegAddr,oRegData}<={16'h5488, 8'h87};end
            168:begin {oRegAddr,oRegData}<={16'h5489, 8'h91};end
            169:begin {oRegAddr,oRegData}<={16'h548a, 8'h9a};end
            170:begin {oRegAddr,oRegData}<={16'h548b, 8'haa};end
            171:begin {oRegAddr,oRegData}<={16'h548c, 8'hb8};end
            172:begin {oRegAddr,oRegData}<={16'h548d, 8'hcd};end
            173:begin {oRegAddr,oRegData}<={16'h548e, 8'hdd};end
            174:begin {oRegAddr,oRegData}<={16'h548f, 8'hea};end
            175:begin {oRegAddr,oRegData}<={16'h5490, 8'h1d};end
            // color mat};endix 色彩矩阵	16'h
            176:begin {oRegAddr,oRegData}<={16'h5381, 8'h1e};end // CMX1 for Y
            177:begin {oRegAddr,oRegData}<={16'h5382, 8'h5b};end // CMX2 for Y
            178:begin {oRegAddr,oRegData}<={16'h5383, 8'h08};end // CMX3 for Y
            179:begin {oRegAddr,oRegData}<={16'h5384, 8'h0a};end // CMX4 for U
            180:begin {oRegAddr,oRegData}<={16'h5385, 8'h7e};end // CMX5 for U
            181:begin {oRegAddr,oRegData}<={16'h5386, 8'h88};end // CMX6 for U
            182:begin {oRegAddr,oRegData}<={16'h5387, 8'h7c};end // CMX7 for V
            183:begin {oRegAddr,oRegData}<={16'h5388, 8'h6c};end // CMX8 for V
            184:begin {oRegAddr,oRegData}<={16'h5389, 8'h10};end // CMX9 for V
            185:begin {oRegAddr,oRegData}<={16'h538a, 8'h01};end // sign[9]
            186:begin {oRegAddr,oRegData}<={16'h538b, 8'h98};end // sign[8:1]
            // UV adjust};endUV 色彩饱和度调整
            187:begin {oRegAddr,oRegData}<={16'h5580, 8'h06};end // saturation on, bit[1]
            188:begin {oRegAddr,oRegData}<={16'h5583, 8'h40};end
            189:begin {oRegAddr,oRegData}<={16'h5584, 8'h10};end 
            190:begin {oRegAddr,oRegData}<={16'h5589, 8'h10};end
            191:begin {oRegAddr,oRegData}<={16'h558a, 8'h00};end
            192:begin {oRegAddr,oRegData}<={16'h558b, 8'hf8};end
            193:begin {oRegAddr,oRegData}<={16'h501d, 8'h40};end // enable manual offset of contrast
            // CIP 锐化};end降噪
            194:begin {oRegAddr,oRegData}<={16'h5300, 8'h08};end // CIP sharpen MT threshold 1
            195:begin {oRegAddr,oRegData}<={16'h5301, 8'h30};end // CIP sharpen MT threshold 2
            196:begin {oRegAddr,oRegData}<={16'h5302, 8'h10};end // CIP sharpen MT offset 1
            197:begin {oRegAddr,oRegData}<={16'h5303, 8'h00};end // CIP sharpen MT offset 2
            198:begin {oRegAddr,oRegData}<={16'h5304, 8'h08};end // CIP DNS threshold 1
            199:begin {oRegAddr,oRegData}<={16'h5305, 8'h30};end // CIP DNS threshold 2
            200:begin {oRegAddr,oRegData}<={16'h5306, 8'h08};end // CIP DNS offset 1
            201:begin {oRegAddr,oRegData}<={16'h5307, 8'h16};end // CIP DNS offset 2
            202:begin {oRegAddr,oRegData}<={16'h5309, 8'h08};end // CIP sharpen TH threshold 1
            203:begin {oRegAddr,oRegData}<={16'h530a, 8'h30};end // CIP sharpen TH threshold 2
            204:begin {oRegAddr,oRegData}<={16'h530b, 8'h04};end // CIP sharpen TH offset 1
            205:begin {oRegAddr,oRegData}<={16'h530c, 8'h06};end // CIP sharpen TH offset 2
            206:begin {oRegAddr,oRegData}<={16'h5025, 8'h00};end
            207:begin {oRegAddr,oRegData}<={16'h4740, 8'h21};end
            208:begin {oRegAddr,oRegData}<={16'h3008, 8'h02};end // wake up from standby, bit[6]
            ///////////////////////////////////////////////////////////////////////////////////////
            //640x480,JPEG.
            // 209:begin {oRegAddr,oRegData}<={16'h3035, 8'h21};end
            // 210:begin {oRegAddr,oRegData}<={16'h3036, 8'h69};end // 22fps 0x46//15fps
            // 211:begin {oRegAddr,oRegData}<={16'h3c07, 8'h07};end // lightmeter 1 threshold[7:0] 
            // 212:begin {oRegAddr,oRegData}<={16'h3820, 8'h46};end // flip
            // 213:begin {oRegAddr,oRegData}<={16'h3821, 8'h20};end // mirror									 
            // 214:begin {oRegAddr,oRegData}<={16'h3814, 8'h31};end // timing X inc 11
            // 215:begin {oRegAddr,oRegData}<={16'h3815, 8'h31};end // timing Y inc 11
            // 216:begin {oRegAddr,oRegData}<={16'h3800, 8'h00};end // HS 
            // 217:begin {oRegAddr,oRegData}<={16'h3801, 8'h00};end // HS 
            // 218:begin {oRegAddr,oRegData}<={16'h3802, 8'h00};end // VS 
            // 219:begin {oRegAddr,oRegData}<={16'h3803, 8'h04};end // VS   
            // 220:begin {oRegAddr,oRegData}<={16'h3804, 8'h0a};end // HW (HE)		//
            // 221:begin {oRegAddr,oRegData}<={16'h3805, 8'h3f};end // HW (HE)
            // 222:begin {oRegAddr,oRegData}<={16'h3806, 8'h07};end // VH (VE)		//
            // 223:begin {oRegAddr,oRegData}<={16'h3807, 8'h9b};end // VH (VE) 
            // 224:begin {oRegAddr,oRegData}<={16'h4300, 8'h30};end // YUV 422, YUYV
            // 225:begin {oRegAddr,oRegData}<={16'h501f, 8'h00};end // YUV 422 
            
            // 226:begin {oRegAddr,oRegData}<={16'h3808, 8'h02};end // DVPHO 	   
            // 227:begin {oRegAddr,oRegData}<={16'h3809, 8'h80};end // DVPHO 
            // 228:begin {oRegAddr,oRegData}<={16'h380a, 8'h01};end // DVPVO 		
            // 229:begin {oRegAddr,oRegData}<={16'h380b, 8'he0};end // DVPVO
            // 230:begin {oRegAddr,oRegData}<={16'h380c, 8'h07};end // HTS		
            // 231:begin {oRegAddr,oRegData}<={16'h380d, 8'h68};end // HTS   
            // 232:begin {oRegAddr,oRegData}<={16'h380e, 8'h03};end // VTS 		
            // 233:begin {oRegAddr,oRegData}<={16'h380f, 8'hd8};end // VTS 	
            // 234:begin {oRegAddr,oRegData}<={16'h3813, 8'h06};end // timing V offset   
            // 235:begin {oRegAddr,oRegData}<={16'h3618, 8'h00};end //
            // 236:begin {oRegAddr,oRegData}<={16'h3612, 8'h29};end //
            // 237:begin {oRegAddr,oRegData}<={16'h3709, 8'h52};end //
            // 238:begin {oRegAddr,oRegData}<={16'h370c, 8'h03};end //
            // 239:begin {oRegAddr,oRegData}<={16'h4004, 8'h02};end // BLC line number  
            // 240:begin {oRegAddr,oRegData}<={16'h3002, 8'h00};end // enable JFIFO, SFIFO, JPG 
            // 241:begin {oRegAddr,oRegData}<={16'h3006, 8'hff};end // enable clock of JPEG2x, JPEG
            // 242:begin {oRegAddr,oRegData}<={16'h4713, 8'h01};end // JPEG mode 1
            // 243:begin {oRegAddr,oRegData}<={16'h4407, 8'h04};end // Quantization sacle 
            
            // 244:begin {oRegAddr,oRegData}<={16'h440a, 8'h4e};end
            
            // 245:begin {oRegAddr,oRegData}<={16'h460b, 8'h35};end
            // 246:begin {oRegAddr,oRegData}<={16'h460c, 8'h22};end
            // 247:begin {oRegAddr,oRegData}<={16'h4837, 8'h16};end // MIPI global timing 
            // 248:begin {oRegAddr,oRegData}<={16'h3824, 8'h02};end // PCLK manual divider		 
            // 249:begin {oRegAddr,oRegData}<={16'h5001, 8'hA3};end // SDE on, scaling on, CMX on, AWB on 
            // 250:begin {oRegAddr,oRegData}<={16'h3503, 8'h00};end // AEC/AGC on 打开自动曝光

            /////////////////////////////////////////////////////////////
            //1600*1200,JPEG.
            // Input clock = 24Mhz
            209:begin {oRegAddr,oRegData}<={16'h3035, 8'h21};end // PLL  
            210:begin {oRegAddr,oRegData}<={16'h3036, 8'h69};end // PLL 
            211:begin {oRegAddr,oRegData}<={16'h3c07, 8'h07};end // lightmeter 1 threshold[7:0] 
            212:begin {oRegAddr,oRegData}<={16'h3820, 8'h46};end // flip
            213:begin {oRegAddr,oRegData}<={16'h3821, 8'h20};end // mirror									 
            214:begin {oRegAddr,oRegData}<={16'h3814, 8'h11};end // timing X inc 
            215:begin {oRegAddr,oRegData}<={16'h3815, 8'h11};end // timing Y inc 
            216:begin {oRegAddr,oRegData}<={16'h3800, 8'h00};end // HS 
            217:begin {oRegAddr,oRegData}<={16'h3801, 8'h00};end // HS 
            218:begin {oRegAddr,oRegData}<={16'h3802, 8'h00};end // VS 
            219:begin {oRegAddr,oRegData}<={16'h3803, 8'h00};end // VS 
            220:begin {oRegAddr,oRegData}<={16'h3804, 8'h0a};end // HW (HE)		//
            221:begin {oRegAddr,oRegData}<={16'h3805, 8'h3f};end // HW (HE)
            222:begin {oRegAddr,oRegData}<={16'h3806, 8'h07};end // VH (VE)		//
            223:begin {oRegAddr,oRegData}<={16'h3807, 8'h9f};end // VH (VE)

            224:begin {oRegAddr,oRegData}<={16'h4300, 8'h30};end // YUV 422, YUYV
            225:begin {oRegAddr,oRegData}<={16'h501f, 8'h00};end // YUV 422 

            226:begin {oRegAddr,oRegData}<={16'h3808, 8'h06};end // DVPHO 	   
            227:begin {oRegAddr,oRegData}<={16'h3809, 8'h40};end // DVPHO 
            228:begin {oRegAddr,oRegData}<={16'h380a, 8'h04};end // DVPVO 		
            229:begin {oRegAddr,oRegData}<={16'h380b, 8'hb0};end // DVPVO

            230:begin {oRegAddr,oRegData}<={16'h380c, 8'h0b};end // HTS 		//
            231:begin {oRegAddr,oRegData}<={16'h380d, 8'h1c};end // HTS 
            232:begin {oRegAddr,oRegData}<={16'h380e, 8'h07};end // VTS 		//
            233:begin {oRegAddr,oRegData}<={16'h380f, 8'hb0};end // VTS 
            234:begin {oRegAddr,oRegData}<={16'h3813, 8'h04};end // timing V offset   04
            235:begin {oRegAddr,oRegData}<={16'h3618, 8'h04};end
            236:begin {oRegAddr,oRegData}<={16'h3612, 8'h2b};end
            237:begin {oRegAddr,oRegData}<={16'h3709, 8'h12};end
            238:begin {oRegAddr,oRegData}<={16'h370c, 8'h00};end
            239:begin {oRegAddr,oRegData}<={16'h4004, 8'h06};end // BLC line number 
            240:begin {oRegAddr,oRegData}<={16'h3002, 8'h00};end // enable JFIFO, SFIFO, JPG 
            241:begin {oRegAddr,oRegData}<={16'h3006, 8'hff};end // enable clock of JPEG2x, JPEG
            242:begin {oRegAddr,oRegData}<={16'h4713, 8'h01};end // JPEG mode 1
            243:begin {oRegAddr,oRegData}<={16'h4407, 8'h01};end // Quantization sacle 
            244:begin {oRegAddr,oRegData}<={16'h460b, 8'h35};end
            245:begin {oRegAddr,oRegData}<={16'h460c, 8'h22};end
            246:begin {oRegAddr,oRegData}<={16'h4837, 8'h16};end // MIPI global timing 
            247:begin {oRegAddr,oRegData}<={16'h3824, 8'h02};end // PCLK manual divider	
   
            248:begin {oRegAddr,oRegData}<={16'h5001, 8'hA3};end // SDE on, scaling on, CMX on, AWB on 
            249:begin {oRegAddr,oRegData}<={16'h3503, 8'h00};end // AEC/AGC on	 
        default:
            begin {oRegAddr,oRegData}<={16'd0, 8'd0}; end
        endcase
    end
end

endmodule
