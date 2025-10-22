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
parameter CFG_REG_MAX_NUM=312;

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
            0:begin {oRegAddr,oRegData}<={OV5640_SCCB_SYSTEM_CTRL1, 8'h11}; end
            1:begin {oRegAddr,oRegData}<={OV5640_SYSTEM_CTROL0, 8'h82}; end
            2:begin {oRegAddr,oRegData}<={OV5640_SCCB_SYSTEM_CTRL1, 8'h03}; end
            3:begin {oRegAddr,oRegData}<={16'h3630, 8'h36}; end
            4:begin {oRegAddr,oRegData}<={16'h3631, 8'h0e}; end
            5:begin {oRegAddr,oRegData}<={16'h3632, 8'he2}; end
            6:begin {oRegAddr,oRegData}<={16'h3633, 8'h12}; end
            7:begin {oRegAddr,oRegData}<={16'h3621, 8'he0}; end
            8:begin {oRegAddr,oRegData}<={16'h3704, 8'ha0}; end
            9:begin {oRegAddr,oRegData}<={16'h3703, 8'h5a}; end
            10:begin {oRegAddr,oRegData}<={16'h3715, 8'h78}; end
            11:begin {oRegAddr,oRegData}<={16'h3717, 8'h01}; end
            12:begin {oRegAddr,oRegData}<={16'h370b, 8'h60}; end
            13:begin {oRegAddr,oRegData}<={16'h3705, 8'h1a}; end
            14:begin {oRegAddr,oRegData}<={16'h3905, 8'h02}; end
            15:begin {oRegAddr,oRegData}<={16'h3906, 8'h10}; end
            16:begin {oRegAddr,oRegData}<={16'h3901, 8'h0a}; end
            17:begin {oRegAddr,oRegData}<={16'h3731, 8'h12}; end
            18:begin {oRegAddr,oRegData}<={16'h3600, 8'h08}; end
            19:begin {oRegAddr,oRegData}<={16'h3601, 8'h33}; end
            20:begin {oRegAddr,oRegData}<={16'h302d, 8'h60}; end
            21:begin {oRegAddr,oRegData}<={16'h3620, 8'h52}; end
            22:begin {oRegAddr,oRegData}<={16'h371b, 8'h20}; end
            23:begin {oRegAddr,oRegData}<={16'h471c, 8'h50}; end
            24:begin {oRegAddr,oRegData}<={OV5640_AEC_CTRL13, 8'h43}; end
            25:begin {oRegAddr,oRegData}<={OV5640_AEC_GAIN_CEILING_HIGH, 8'h00}; end
            26:begin {oRegAddr,oRegData}<={OV5640_AEC_GAIN_CEILING_LOW, 8'hf8}; end
            27:begin {oRegAddr,oRegData}<={16'h3635, 8'h13}; end
            28:begin {oRegAddr,oRegData}<={16'h3636, 8'h03}; end
            29:begin {oRegAddr,oRegData}<={16'h3634, 8'h40}; end
            30:begin {oRegAddr,oRegData}<={16'h3622, 8'h01}; end
            31:begin {oRegAddr,oRegData}<={OV5640_5060HZ_CTRL01, 8'h34}; end
            32:begin {oRegAddr,oRegData}<={OV5640_5060HZ_CTRL04, 8'h28}; end
            33:begin {oRegAddr,oRegData}<={OV5640_5060HZ_CTRL05, 8'h98}; end
            34:begin {oRegAddr,oRegData}<={OV5640_LIGHTMETER1_TH_HIGH, 8'h00}; end
            35:begin {oRegAddr,oRegData}<={OV5640_LIGHTMETER1_TH_LOW, 8'h00}; end
            36:begin {oRegAddr,oRegData}<={OV5640_LIGHTMETER2_TH_HIGH, 8'h01}; end
            37:begin {oRegAddr,oRegData}<={OV5640_LIGHTMETER2_TH_LOW, 8'h2c}; end
            38:begin {oRegAddr,oRegData}<={OV5640_SAMPLE_NUMBER_HIGH, 8'h9c}; end
            39:begin {oRegAddr,oRegData}<={OV5640_SAMPLE_NUMBER_LOW, 8'h40}; end
            40:begin {oRegAddr,oRegData}<={OV5640_TIMING_TC_REG20, 8'h06}; end
            41:begin {oRegAddr,oRegData}<={OV5640_TIMING_TC_REG21, 8'h00}; end
            42:begin {oRegAddr,oRegData}<={OV5640_TIMING_X_INC, 8'h31}; end
            43:begin {oRegAddr,oRegData}<={OV5640_TIMING_Y_INC, 8'h31}; end
            44:begin {oRegAddr,oRegData}<={OV5640_TIMING_HS_HIGH, 8'h00}; end
            45:begin {oRegAddr,oRegData}<={OV5640_TIMING_HS_LOW, 8'h00}; end
            46:begin {oRegAddr,oRegData}<={OV5640_TIMING_VS_HIGH, 8'h00}; end
            47:begin {oRegAddr,oRegData}<={OV5640_TIMING_VS_LOW, 8'h04}; end
            48:begin {oRegAddr,oRegData}<={OV5640_TIMING_HW_HIGH, 8'h0a}; end
            49:begin {oRegAddr,oRegData}<={OV5640_TIMING_HW_LOW, 8'h3f}; end
            50:begin {oRegAddr,oRegData}<={OV5640_TIMING_VH_HIGH, 8'h07}; end
            51:begin {oRegAddr,oRegData}<={OV5640_TIMING_VH_LOW, 8'h9b}; end
            52:begin {oRegAddr,oRegData}<={OV5640_TIMING_DVPHO_HIGH, 8'h03}; end
            53:begin {oRegAddr,oRegData}<={OV5640_TIMING_DVPHO_LOW, 8'h20}; end
            54:begin {oRegAddr,oRegData}<={OV5640_TIMING_DVPVO_HIGH, 8'h02}; end
            55:begin {oRegAddr,oRegData}<={OV5640_TIMING_DVPVO_LOW, 8'h58}; end
            /* For 800x480 resolution: OV5640_TIMING_HTS<=0x790, OV5640_TIMING_VTS<=0x440 */
            56:begin {oRegAddr,oRegData}<={OV5640_TIMING_HTS_HIGH, 8'h07}; end
            57:begin {oRegAddr,oRegData}<={OV5640_TIMING_HTS_LOW, 8'h90}; end
            58:begin {oRegAddr,oRegData}<={OV5640_TIMING_VTS_HIGH, 8'h04}; end
            59:begin {oRegAddr,oRegData}<={OV5640_TIMING_VTS_LOW, 8'h40}; end
            60:begin {oRegAddr,oRegData}<={OV5640_TIMING_HOFFSET_HIGH, 8'h00}; end
            61:begin {oRegAddr,oRegData}<={OV5640_TIMING_HOFFSET_LOW, 8'h10}; end
            62:begin {oRegAddr,oRegData}<={OV5640_TIMING_VOFFSET_HIGH, 8'h00}; end
            63:begin {oRegAddr,oRegData}<={OV5640_TIMING_VOFFSET_LOW, 8'h06}; end
            64:begin {oRegAddr,oRegData}<={16'h3618, 8'h00}; end
            65:begin {oRegAddr,oRegData}<={16'h3612, 8'h29}; end
            66:begin {oRegAddr,oRegData}<={16'h3708, 8'h64}; end
            67:begin {oRegAddr,oRegData}<={16'h3709, 8'h52}; end
            68:begin {oRegAddr,oRegData}<={16'h370c, 8'h03}; end
            69:begin {oRegAddr,oRegData}<={OV5640_AEC_CTRL02, 8'h03}; end
            70:begin {oRegAddr,oRegData}<={OV5640_AEC_CTRL03, 8'hd8}; end
            71:begin {oRegAddr,oRegData}<={OV5640_AEC_B50_STEP_HIGH, 8'h01}; end
            72:begin {oRegAddr,oRegData}<={OV5640_AEC_B50_STEP_LOW, 8'h27}; end
            73:begin {oRegAddr,oRegData}<={OV5640_AEC_B60_STEP_HIGH, 8'h00}; end
            74:begin {oRegAddr,oRegData}<={OV5640_AEC_B60_STEP_LOW, 8'hf6}; end
            75:begin {oRegAddr,oRegData}<={OV5640_AEC_CTRL0E, 8'h03}; end
            76:begin {oRegAddr,oRegData}<={OV5640_AEC_CTRL0D, 8'h04}; end
            77:begin {oRegAddr,oRegData}<={OV5640_AEC_MAX_EXPO_HIGH, 8'h03}; end
            78:begin {oRegAddr,oRegData}<={OV5640_AEC_MAX_EXPO_LOW, 8'hd8}; end
            79:begin {oRegAddr,oRegData}<={OV5640_BLC_CTRL01, 8'h02}; end
            80:begin {oRegAddr,oRegData}<={OV5640_BLC_CTRL04, 8'h02}; end
            81:begin {oRegAddr,oRegData}<={OV5640_SYSREM_RESET00, 8'h00}; end
            82:begin {oRegAddr,oRegData}<={OV5640_SYSREM_RESET02, 8'h1c}; end
            83:begin {oRegAddr,oRegData}<={OV5640_CLOCK_ENABLE00, 8'hff}; end
            84:begin {oRegAddr,oRegData}<={OV5640_CLOCK_ENABLE02, 8'hc3}; end
            85:begin {oRegAddr,oRegData}<={OV5640_MIPI_CONTROL00, 8'h58}; end
            86:begin {oRegAddr,oRegData}<={16'h302e, 8'h00}; end
            87:begin {oRegAddr,oRegData}<={OV5640_POLARITY_CTRL, 8'h22}; end
            88:begin {oRegAddr,oRegData}<={OV5640_FORMAT_CTRL00, 8'h6F}; end
            89:begin {oRegAddr,oRegData}<={OV5640_FORMAT_MUX_CTRL, 8'h01}; end
            //001: JPEG mode 1.
            //010: JPEG mode 2.
            //011: JPEG mode 3.
            //100: JPEG mode 4.
            //101: JPEG mode 5.
            //110: JPEG mode 6.
            90:begin {oRegAddr,oRegData}<={OV5640_JPG_MODE_SELECT, 8'h01}; end
            91:begin {oRegAddr,oRegData}<={OV5640_JPEG_CTRL07, 8'h04}; end
            92:begin {oRegAddr,oRegData}<={16'h440e, 8'h00}; end
            93:begin {oRegAddr,oRegData}<={16'h460b, 8'h35}; end
            94:begin {oRegAddr,oRegData}<={16'h460c, 8'h23}; end
            95:begin {oRegAddr,oRegData}<={OV5640_PCLK_PERIOD, 8'h22}; end
            96:begin {oRegAddr,oRegData}<={16'h3824, 8'h02}; end
            97:begin {oRegAddr,oRegData}<={OV5640_ISP_CONTROL00, 8'ha7}; end
            98:begin {oRegAddr,oRegData}<={OV5640_ISP_CONTROL01, 8'ha3}; end
            99:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL00, 8'hff}; end
            100:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL01, 8'hf2}; end
            101:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL02, 8'h00}; end
            102:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL03, 8'h14}; end
            103:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL04, 8'h25}; end
            104:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL05, 8'h24}; end
            105:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL06, 8'h09}; end
            106:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL07, 8'h09}; end
            107:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL08, 8'h09}; end
            108:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL09, 8'h75}; end
            109:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL10, 8'h54}; end
            110:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL11, 8'he0}; end
            111:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL12, 8'hb2}; end
            112:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL13, 8'h42}; end
            113:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL14, 8'h3d}; end
            114:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL15, 8'h56}; end
            115:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL16, 8'h46}; end
            116:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL17, 8'hf8}; end
            117:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL18, 8'h04}; end
            118:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL19, 8'h70}; end
            119:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL20, 8'hf0}; end
            120:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL21, 8'hf0}; end
            121:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL22, 8'h03}; end
            122:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL23, 8'h01}; end
            123:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL24, 8'h04}; end
            124:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL25, 8'h12}; end
            125:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL26, 8'h04}; end
            126:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL27, 8'h00}; end
            127:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL28, 8'h06}; end
            128:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL29, 8'h82}; end
            129:begin {oRegAddr,oRegData}<={OV5640_AWB_CTRL30, 8'h38}; end
            130:begin {oRegAddr,oRegData}<={OV5640_CMX1, 8'h1e}; end
            131:begin {oRegAddr,oRegData}<={OV5640_CMX2, 8'h5b}; end
            132:begin {oRegAddr,oRegData}<={OV5640_CMX3, 8'h08}; end
            133:begin {oRegAddr,oRegData}<={OV5640_CMX4, 8'h0a}; end
            134:begin {oRegAddr,oRegData}<={OV5640_CMX5, 8'h7e}; end
            135:begin {oRegAddr,oRegData}<={OV5640_CMX6, 8'h88}; end
            136:begin {oRegAddr,oRegData}<={OV5640_CMX7, 8'h7c}; end
            137:begin {oRegAddr,oRegData}<={OV5640_CMX8, 8'h6c}; end
            138:begin {oRegAddr,oRegData}<={OV5640_CMX9, 8'h10}; end
            139:begin {oRegAddr,oRegData}<={OV5640_CMXSIGN_HIGH, 8'h01}; end
            140:begin {oRegAddr,oRegData}<={OV5640_CMXSIGN_LOW, 8'h98}; end
            141:begin {oRegAddr,oRegData}<={OV5640_CIP_SHARPENMT_TH1, 8'h08}; end
            142:begin {oRegAddr,oRegData}<={OV5640_CIP_SHARPENMT_TH2, 8'h30}; end
            143:begin {oRegAddr,oRegData}<={OV5640_CIP_SHARPENMT_OFFSET1, 8'h10}; end
            144:begin {oRegAddr,oRegData}<={OV5640_CIP_SHARPENMT_OFFSET2, 8'h00}; end
            145:begin {oRegAddr,oRegData}<={OV5640_CIP_DNS_TH1, 8'h08}; end
            146:begin {oRegAddr,oRegData}<={OV5640_CIP_DNS_TH2, 8'h30}; end
            147:begin {oRegAddr,oRegData}<={OV5640_CIP_DNS_OFFSET1, 8'h08}; end
            148:begin {oRegAddr,oRegData}<={OV5640_CIP_DNS_OFFSET2, 8'h16}; end
            149:begin {oRegAddr,oRegData}<={OV5640_CIP_CTRL, 8'h08}; end
            150:begin {oRegAddr,oRegData}<={OV5640_CIP_SHARPENTH_TH1, 8'h30}; end
            151:begin {oRegAddr,oRegData}<={OV5640_CIP_SHARPENTH_TH2, 8'h04}; end
            152:begin {oRegAddr,oRegData}<={OV5640_CIP_SHARPENTH_OFFSET1, 8'h06}; end
            153:begin {oRegAddr,oRegData}<={OV5640_GAMMA_CTRL00, 8'h01}; end
            154:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST00, 8'h08}; end
            155:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST01, 8'h14}; end
            156:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST02, 8'h28}; end
            157:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST03, 8'h51}; end
            158:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST04, 8'h65}; end
            159:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST05, 8'h71}; end
            160:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST06, 8'h7d}; end
            161:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST07, 8'h87}; end
            162:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST08, 8'h91}; end
            163:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST09, 8'h9a}; end
            164:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST0A, 8'haa}; end
            165:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST0B, 8'hb8}; end
            166:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST0C, 8'hcd}; end
            167:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST0D, 8'hdd}; end
            168:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST0E, 8'hea}; end
            169:begin {oRegAddr,oRegData}<={OV5640_GAMMA_YST0F, 8'h1d}; end
            170:begin {oRegAddr,oRegData}<={OV5640_SDE_CTRL0, 8'h02}; end
            171:begin {oRegAddr,oRegData}<={OV5640_SDE_CTRL3, 8'h40}; end
            172:begin {oRegAddr,oRegData}<={OV5640_SDE_CTRL4, 8'h10}; end
            173:begin {oRegAddr,oRegData}<={OV5640_SDE_CTRL9, 8'h10}; end
            174:begin {oRegAddr,oRegData}<={OV5640_SDE_CTRL10, 8'h00}; end
            175:begin {oRegAddr,oRegData}<={OV5640_SDE_CTRL11, 8'hf8}; end
            176:begin {oRegAddr,oRegData}<={OV5640_GMTRX00, 8'h23}; end
            177:begin {oRegAddr,oRegData}<={OV5640_GMTRX01, 8'h14}; end
            178:begin {oRegAddr,oRegData}<={OV5640_GMTRX02, 8'h0f}; end
            179:begin {oRegAddr,oRegData}<={OV5640_GMTRX03, 8'h0f}; end
            180:begin {oRegAddr,oRegData}<={OV5640_GMTRX04, 8'h12}; end
            181:begin {oRegAddr,oRegData}<={OV5640_GMTRX05, 8'h26}; end
            182:begin {oRegAddr,oRegData}<={OV5640_GMTRX10, 8'h0c}; end
            183:begin {oRegAddr,oRegData}<={OV5640_GMTRX11, 8'h08}; end
            184:begin {oRegAddr,oRegData}<={OV5640_GMTRX12, 8'h05}; end
            185:begin {oRegAddr,oRegData}<={OV5640_GMTRX13, 8'h05}; end
            186:begin {oRegAddr,oRegData}<={OV5640_GMTRX14, 8'h08}; end
            187:begin {oRegAddr,oRegData}<={OV5640_GMTRX15, 8'h0d}; end
            188:begin {oRegAddr,oRegData}<={OV5640_GMTRX20, 8'h08}; end
            189:begin {oRegAddr,oRegData}<={OV5640_GMTRX21, 8'h03}; end
            190:begin {oRegAddr,oRegData}<={OV5640_GMTRX22, 8'h00}; end
            191:begin {oRegAddr,oRegData}<={OV5640_GMTRX23, 8'h00}; end
            192:begin {oRegAddr,oRegData}<={OV5640_GMTRX24, 8'h03}; end
            193:begin {oRegAddr,oRegData}<={OV5640_GMTRX25, 8'h09}; end
            194:begin {oRegAddr,oRegData}<={OV5640_GMTRX30, 8'h07}; end
            195:begin {oRegAddr,oRegData}<={OV5640_GMTRX31, 8'h03}; end
            196:begin {oRegAddr,oRegData}<={OV5640_GMTRX32, 8'h00}; end
            197:begin {oRegAddr,oRegData}<={OV5640_GMTRX33, 8'h01}; end
            198:begin {oRegAddr,oRegData}<={OV5640_GMTRX34, 8'h03}; end
            199:begin {oRegAddr,oRegData}<={OV5640_GMTRX35, 8'h08}; end
            200:begin {oRegAddr,oRegData}<={OV5640_GMTRX40, 8'h0d}; end
            201:begin {oRegAddr,oRegData}<={OV5640_GMTRX41, 8'h08}; end
            202:begin {oRegAddr,oRegData}<={OV5640_GMTRX42, 8'h05}; end
            203:begin {oRegAddr,oRegData}<={OV5640_GMTRX43, 8'h06}; end
            204:begin {oRegAddr,oRegData}<={OV5640_GMTRX44, 8'h08}; end
            205:begin {oRegAddr,oRegData}<={OV5640_GMTRX45, 8'h0e}; end
            206:begin {oRegAddr,oRegData}<={OV5640_GMTRX50, 8'h29}; end
            207:begin {oRegAddr,oRegData}<={OV5640_GMTRX51, 8'h17}; end
            208:begin {oRegAddr,oRegData}<={OV5640_GMTRX52, 8'h11}; end
            209:begin {oRegAddr,oRegData}<={OV5640_GMTRX53, 8'h11}; end
            210:begin {oRegAddr,oRegData}<={OV5640_GMTRX54, 8'h15}; end
            211:begin {oRegAddr,oRegData}<={OV5640_GMTRX55, 8'h28}; end
            212:begin {oRegAddr,oRegData}<={OV5640_BRMATRX00, 8'h46}; end
            213:begin {oRegAddr,oRegData}<={OV5640_BRMATRX01, 8'h26}; end
            214:begin {oRegAddr,oRegData}<={OV5640_BRMATRX02, 8'h08}; end
            215:begin {oRegAddr,oRegData}<={OV5640_BRMATRX03, 8'h26}; end
            216:begin {oRegAddr,oRegData}<={OV5640_BRMATRX04, 8'h64}; end
            217:begin {oRegAddr,oRegData}<={OV5640_BRMATRX05, 8'h26}; end
            218:begin {oRegAddr,oRegData}<={OV5640_BRMATRX06, 8'h24}; end
            219:begin {oRegAddr,oRegData}<={OV5640_BRMATRX07, 8'h22}; end
            220:begin {oRegAddr,oRegData}<={OV5640_BRMATRX08, 8'h24}; end
            221:begin {oRegAddr,oRegData}<={OV5640_BRMATRX09, 8'h24}; end
            222:begin {oRegAddr,oRegData}<={OV5640_BRMATRX20, 8'h06}; end
            223:begin {oRegAddr,oRegData}<={OV5640_BRMATRX21, 8'h22}; end
            224:begin {oRegAddr,oRegData}<={OV5640_BRMATRX22, 8'h40}; end
            225:begin {oRegAddr,oRegData}<={OV5640_BRMATRX23, 8'h42}; end
            226:begin {oRegAddr,oRegData}<={OV5640_BRMATRX24, 8'h24}; end
            227:begin {oRegAddr,oRegData}<={OV5640_BRMATRX30, 8'h26}; end
            228:begin {oRegAddr,oRegData}<={OV5640_BRMATRX31, 8'h24}; end
            229:begin {oRegAddr,oRegData}<={OV5640_BRMATRX32, 8'h22}; end
            230:begin {oRegAddr,oRegData}<={OV5640_BRMATRX33, 8'h22}; end
            231:begin {oRegAddr,oRegData}<={OV5640_BRMATRX34, 8'h26}; end
            232:begin {oRegAddr,oRegData}<={OV5640_BRMATRX40, 8'h44}; end
            233:begin {oRegAddr,oRegData}<={OV5640_BRMATRX41, 8'h24}; end
            234:begin {oRegAddr,oRegData}<={OV5640_BRMATRX42, 8'h26}; end
            235:begin {oRegAddr,oRegData}<={OV5640_BRMATRX43, 8'h28}; end
            236:begin {oRegAddr,oRegData}<={OV5640_BRMATRX44, 8'h42}; end
            237:begin {oRegAddr,oRegData}<={OV5640_LENC_BR_OFFSET, 8'hce}; end
            238:begin {oRegAddr,oRegData}<={16'h5025, 8'h00}; end
            239:begin {oRegAddr,oRegData}<={OV5640_AEC_CTRL0F, 8'h30}; end
            240:begin {oRegAddr,oRegData}<={OV5640_AEC_CTRL10, 8'h28}; end
            241:begin {oRegAddr,oRegData}<={OV5640_AEC_CTRL1B, 8'h30}; end
            242:begin {oRegAddr,oRegData}<={OV5640_AEC_CTRL1E, 8'h26}; end
            243:begin {oRegAddr,oRegData}<={OV5640_AEC_CTRL11, 8'h60}; end
            244:begin {oRegAddr,oRegData}<={OV5640_AEC_CTRL1F, 8'h14}; end
            245:begin {oRegAddr,oRegData}<={OV5640_SYSTEM_CTROL0, 8'h02}; end

            //Enable DVP(Digital Video Port) Mode: Parallel Data Output.
            /* Configure the IO Pad, output FREX/VSYNC/HREF/PCLK/D[9:2]/GPIO0/GPIO1 */
            246:begin {oRegAddr,oRegData}<={OV5640_PAD_OUTPUT_ENABLE01, 8'hFF}; end
            247:begin {oRegAddr,oRegData}<={OV5640_PAD_OUTPUT_ENABLE02, 8'hF3}; end
            248:begin {oRegAddr,oRegData}<={16'h302e, 8'h00}; end
            /* Unknown DVP control configuration */
            249:begin {oRegAddr,oRegData}<={16'h471c, 8'h50}; end
            250:begin {oRegAddr,oRegData}<={OV5640_MIPI_CONTROL00, 8'h58}; end
            /* Timing configuration */
            251:begin {oRegAddr,oRegData}<={OV5640_SC_PLL_CONTRL0, 8'h18}; end
            252:begin {oRegAddr,oRegData}<={OV5640_SC_PLL_CONTRL1, 8'h41}; end
            253:begin {oRegAddr,oRegData}<={OV5640_SC_PLL_CONTRL2, 8'h60}; end
            254:begin {oRegAddr,oRegData}<={OV5640_SC_PLL_CONTRL3, 8'h13}; end
            255:begin {oRegAddr,oRegData}<={OV5640_SYSTEM_ROOT_DIVIDER, 8'h01}; end

            //OV5640_SetResolution.
            /* Initialization sequence for WVGA resolution (800x480)*/
            256:begin {oRegAddr,oRegData}<={OV5640_TIMING_DVPHO_HIGH, 8'h03}; end
            257:begin {oRegAddr,oRegData}<={OV5640_TIMING_DVPHO_LOW, 8'h20}; end
            258:begin {oRegAddr,oRegData}<={OV5640_TIMING_DVPVO_HIGH, 8'h01}; end
            259:begin {oRegAddr,oRegData}<={OV5640_TIMING_DVPVO_LOW, 8'hE0}; end
            
            //Set OV5640 camera Pixel Format.
            /* Initialization sequence for JPEG format */
            /*  SET PIXEL FORMAT: JPEG */
            260:begin {oRegAddr,oRegData}<={OV5640_FORMAT_CTRL00, 8'h30}; end
            261:begin {oRegAddr,oRegData}<={OV5640_FORMAT_MUX_CTRL, 8'h00}; end
            //read-modify-write, OV5640_TIMING_TC_REG21
            //read-modify-write, OV5640_SYSREM_RESET02
            //read-modify-write, OV5640_CLOCK_ENABLE02
            
            //Set OV5640 camera PCLK, HREF and VSYNC Polarities.
            //tmp = (uint8_t)(PclkPolarity << 5U) | (HrefPolarity << 1U) | VsyncPolarity;
            //OV5640_POLARITY_PCLK_HIGH, OV5640_POLARITY_HREF_HIGH,OV5640_POLARITY_VSYNC_HIGH
            262:begin {oRegAddr,oRegData}<={OV5640_POLARITY_CTRL, 8'h21}; end

            //Once set following registers, Reveal can't capture VSYNC,HSYNC,PCLK!!!!!WHY?????
            //Timing Control.
            //bit[5]: JPEG enable. 0x1C=0001_1100
            //Write 0x3C(0011_1100) will cause DVP no output.
            //263:begin {oRegAddr,oRegData}<={OV5640_TIMING_TC_REG21, 8'h3C}; end
            //Reset JPEG, Reset JFIFO, Reset SFIFO.
            //264:begin {oRegAddr,oRegData}<={OV5640_SYSREM_RESET02, 8'hFF}; end
            //bit[5]: Enable JPEGx2 Clock.
            //bit[3]: Enable JPEG clock.
            //264:begin {oRegAddr,oRegData}<={OV5640_CLOCK_ENABLE02, 8'hFF}; end
            
            // JPEG, 2592x1944 fixed size, 15fps
            // Input clock = 24Mhz, PCLK = 48 MHz
            //263:begin {oRegAddr,oRegData}<={16'h3035, 8'h11}; end // PLL 
            //264:begin {oRegAddr,oRegData}<={16'h3036, 8'h69}; end // PLL 
            //PCLK=12MHz.
            263:begin {oRegAddr,oRegData}<={16'h3035, 8'h41}; end // PLL 
            264:begin {oRegAddr,oRegData}<={16'h3036, 8'h60}; end // PLL 
            ///////////////////////////////////////////////////////////////////////////////////
            265:begin {oRegAddr,oRegData}<={16'h3c07, 8'h07}; end // lightmeter 1 threshold[7:0] 
            266:begin {oRegAddr,oRegData}<={16'h3820, 8'h40}; end// flip
            267:begin {oRegAddr,oRegData}<={16'h3821, 8'h26}; end// mirror 
            268:begin {oRegAddr,oRegData}<={16'h3814, 8'h11}; end// timing X inc 
            269:begin {oRegAddr,oRegData}<={16'h3815, 8'h11}; end// timing Y inc 
            270:begin {oRegAddr,oRegData}<={16'h3800, 8'h00}; end// HS 
            271:begin {oRegAddr,oRegData}<={16'h3801, 8'h00}; end// HS 
            272:begin {oRegAddr,oRegData}<={16'h3802, 8'h00}; end// VS 
            273:begin {oRegAddr,oRegData}<={16'h3803, 8'h00}; end// VS 
            274:begin {oRegAddr,oRegData}<={16'h3804, 8'h0a}; end// HW (HE)
            275:begin {oRegAddr,oRegData}<={16'h3805, 8'h3f}; end// HW (HE)
            276:begin {oRegAddr,oRegData}<={16'h3806, 8'h07}; end// VH (VE)
            277:begin {oRegAddr,oRegData}<={16'h3807, 8'h9f}; end// VH (VE)
            278:begin {oRegAddr,oRegData}<={16'h3808, 8'h0a}; end// DVPHO 
            279:begin {oRegAddr,oRegData}<={16'h3809, 8'h20}; end// DVPHO 
            280:begin {oRegAddr,oRegData}<={16'h380a, 8'h07}; end// DVPVO 
            281:begin {oRegAddr,oRegData}<={16'h380b, 8'h98}; end// DVPVO 
            282:begin {oRegAddr,oRegData}<={16'h380c, 8'h0b}; end// HTS 
            283:begin {oRegAddr,oRegData}<={16'h380d, 8'h1c}; end// HTS 
            284:begin {oRegAddr,oRegData}<={16'h380e, 8'h07}; end// VTS 
            285:begin {oRegAddr,oRegData}<={16'h380f, 8'hb0}; end// VTS 
            286:begin {oRegAddr,oRegData}<={16'h3813, 8'h04}; end// timing V offset 
            /*
            wrOV5640Reg(0x3820, 0x43), // Flip
            wrOV5640Reg(0x3821, 0x05), // Mirror
            */
            287:begin {oRegAddr,oRegData}<={16'h3618, 8'h04}; end
            288:begin {oRegAddr,oRegData}<={16'h3612, 8'h2b}; end
            289:begin {oRegAddr,oRegData}<={16'h709, 8'h12}; end
            290:begin {oRegAddr,oRegData}<={16'h370c, 8'h00}; end
            ///banding filters are calculated automatically in camera driver
            //wrOV5640Reg(0x3a02, 0x07); // 60Hz max exposure 
            //wrOV5640Reg(0x3a03, 0xae); // 60Hz max exposure 
            //wrOV5640Reg(0x3a08, 0x01); // B50 step 
            //wrOV5640Reg(0x3a09, 0x27); // B50 step 
            //wrOV5640Reg(0x3a0a, 0x00); // B60 step 
            //wrOV5640Reg(0x3a0b, 0xf6); // B60 step 
            //wrOV5640Reg(0x3a0e, 0x06); // 50Hz max band
            //wrOV5640Reg(0x3a0d, 0x08); // 60Hz max band
            //wrOV5640Reg(0x3a14, 0x07); // 50Hz max exposure 
            //wrOV5640Reg(0x3a15, 0xae); // 50Hz max exposure 
            
            291:begin {oRegAddr,oRegData}<={16'h4300, 8'h31};end//YUV422格式选择
            292:begin {oRegAddr,oRegData}<={16'h501f, 8'h00};end

            293:begin {oRegAddr,oRegData}<={16'h4004, 8'h06};end // BLC line number 
            294:begin {oRegAddr,oRegData}<={16'h3002, 8'h00};end // reset JFIFO, SFIFO, JPG 
            295:begin {oRegAddr,oRegData}<={16'h3006, 8'hff};end // disable clock of JPEG2x, JPEG
            296:begin {oRegAddr,oRegData}<={16'h4713, 8'h01};end // JPEG mode 2
            297:begin {oRegAddr,oRegData}<={16'h4407, 8'h04};end // Quantization sacle 
            298:begin {oRegAddr,oRegData}<={16'h460b, 8'h35};end
            299:begin {oRegAddr,oRegData}<={16'h460c, 8'h22};end
            300:begin {oRegAddr,oRegData}<={16'h4837, 8'h16};end // MIPI global timing 
            301:begin {oRegAddr,oRegData}<={16'h3824, 8'h04};end // PCLK manual divider
            302:begin {oRegAddr,oRegData}<={16'h5001, 8'h83};end // SDE on, CMX on, AWB on
            303:begin {oRegAddr,oRegData}<={16'h3503, 8'h03};end


            304:begin {oRegAddr,oRegData}<={16'h3406, 8'h00};end//环境光模式
            305:begin {oRegAddr,oRegData}<={16'h3400, 8'h04};end
            306:begin {oRegAddr,oRegData}<={16'h3401, 8'h00};end
            307:begin {oRegAddr,oRegData}<={16'h3402, 8'h04};end
            308:begin {oRegAddr,oRegData}<={16'h3403, 8'h00};end
            309:begin {oRegAddr,oRegData}<={16'h3404, 8'h04};end
            310:begin {oRegAddr,oRegData}<={16'h3405, 8'h00};end
            311:begin {oRegAddr,oRegData}<={16'h3212, 8'h13};end // end group 3
            312:begin {oRegAddr,oRegData}<={16'h3212, 8'ha3};end // lanuch group 3
        default:
            begin {oRegAddr,oRegData}<={16'd0, 8'd0}; end
        endcase
    end
end

endmodule
