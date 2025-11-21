/**
******************************************************************************
* @file    ov5640_reg.h
* @author  MCD Application Team
* @brief   Header of ov5640_reg.c
*
******************************************************************************
* @attention
*
* Copyright (c) 2019-2020 STMicroelectronics.
* All rights reserved.
*
* This software is licensed under terms that can be found in the LICENSE file
* in the root directory of this software component.
* If no LICENSE file comes with this software, it is provided AS-IS.
*
******************************************************************************
*/


/**
* @brief  OV5640 ID
*/
parameter  OV5640_ID                                 =      16'h5640;
/**
* @brief  OV5640 Registers
*/
/* system and IO pad control [=      16'h3000 ~ =      16'h3052]       */
parameter OV5640_SYSREM_RESET00                      =      16'h3000;
parameter OV5640_SYSREM_RESET01                      =      16'h3001;
parameter OV5640_SYSREM_RESET02                      =      16'h3002;
parameter OV5640_SYSREM_RESET03                      =      16'h3003;
parameter OV5640_CLOCK_ENABLE00                      =      16'h3004;
parameter OV5640_CLOCK_ENABLE01                      =      16'h3005;
parameter OV5640_CLOCK_ENABLE02                      =      16'h3006;
parameter OV5640_CLOCK_ENABLE03                      =      16'h3007;
parameter OV5640_SYSTEM_CTROL0                       =      16'h3008;
parameter OV5640_CHIP_ID_HIGH_BYTE                   =      16'h300A;
parameter OV5640_CHIP_ID_LOW_BYTE                    =      16'h300B;
parameter OV5640_MIPI_CONTROL00                      =      16'h300E;
parameter OV5640_PAD_OUTPUT_ENABLE00                 =      16'h3016;
parameter OV5640_PAD_OUTPUT_ENABLE01                 =      16'h3017;
parameter OV5640_PAD_OUTPUT_ENABLE02                 =      16'h3018;
parameter OV5640_PAD_OUTPUT_VALUE00                  =      16'h3019;
parameter OV5640_PAD_OUTPUT_VALUE01                  =      16'h301A;
parameter OV5640_PAD_OUTPUT_VALUE02                  =      16'h301B;
parameter OV5640_PAD_SELECT00                        =      16'h301C;
parameter OV5640_PAD_SELECT01                        =      16'h301D;
parameter OV5640_PAD_SELECT02                        =      16'h301E;
parameter OV5640_CHIP_REVISION                       =      16'h302A;
parameter OV5640_PAD_CONTROL00                       =      16'h301C;
parameter OV5640_SC_PWC                              =      16'h3031;
parameter OV5640_SC_PLL_CONTRL0                      =      16'h3034;
parameter OV5640_SC_PLL_CONTRL1                      =      16'h3035;
parameter OV5640_SC_PLL_CONTRL2                      =      16'h3036;
parameter OV5640_SC_PLL_CONTRL3                      =      16'h3037;
parameter OV5640_SC_PLL_CONTRL4                      =      16'h3038;
parameter OV5640_SC_PLL_CONTRL5                      =      16'h3039;
parameter OV5640_SC_PLLS_CTRL0                       =      16'h303A;
parameter OV5640_SC_PLLS_CTRL1                       =      16'h303B;
parameter OV5640_SC_PLLS_CTRL2                       =      16'h303C;
parameter OV5640_SC_PLLS_CTRL3                       =      16'h303D;
parameter OV5640_IO_PAD_VALUE00                      =      16'h3050;
parameter OV5640_IO_PAD_VALUE01                      =      16'h3051;
parameter OV5640_IO_PAD_VALUE02                      =      16'h3052;

/* SCCB control [=      16'h3100 ~ =      16'h3108]                      */
parameter OV5640_SCCB_ID                             =      16'h3100;
parameter OV5640_SCCB_SYSTEM_CTRL0                   =      16'h3102;
parameter OV5640_SCCB_SYSTEM_CTRL1                   =      16'h3103;
parameter OV5640_SYSTEM_ROOT_DIVIDER                 =      16'h3108;

/* SRB control [=      16'h3200 ~ =      16'h3213]                       */
parameter OV5640_GROUP_ADDR0                         =      16'h3200;
parameter OV5640_GROUP_ADDR1                         =      16'h3201;
parameter OV5640_GROUP_ADDR2                         =      16'h3202;
parameter OV5640_GROUP_ADDR3                         =      16'h3203;
parameter OV5640_SRM_GROUP_ACCESS                    =      16'h3212;
parameter OV5640_SRM_GROUP_STATUS                    =      16'h3213;

/* AWB gain control [=      16'h3400 ~ =      16'h3406]                  */
parameter OV5640_AWB_R_GAIN_MSB                      =      16'h3400;
parameter OV5640_AWB_R_GAIN_LSB                      =      16'h3401;
parameter OV5640_AWB_G_GAIN_MSB                      =      16'h3402;
parameter OV5640_AWB_G_GAIN_LSB                      =      16'h3403;
parameter OV5640_AWB_B_GAIN_MSB                      =      16'h3404;
parameter OV5640_AWB_B_GAIN_LSB                      =      16'h3405;
parameter OV5640_AWB_MANUAL_CONTROL                  =      16'h3406;

/* AEC/AGC control [=      16'h3500 ~ =      16'h350D]                   */
parameter OV5640_AEC_PK_EXPOSURE_19_16               =      16'h3500;
parameter OV5640_AEC_PK_EXPOSURE_HIGH                =      16'h3501;
parameter OV5640_AEC_PK_EXPOSURE_LOW                 =      16'h3502;
parameter OV5640_AEC_PK_MANUAL                       =      16'h3503;
parameter OV5640_AEC_PK_REAL_GAIN_9_8                =      16'h350A;
parameter OV5640_AEC_PK_REAL_GAIN_LOW                =      16'h350B;
parameter OV5640_AEC_PK_VTS_HIGH                     =      16'h350C;
parameter OV5640_AEC_PK_VTS_LOW                      =      16'h350D;

/* VCM control [=      16'h3600 ~ =      16'h3606]                       */
parameter OV5640_VCM_CONTROL_0                       =      16'h3602;
parameter OV5640_VCM_CONTROL_1                       =      16'h3603;
parameter OV5640_VCM_CONTROL_2                       =      16'h3604;
parameter OV5640_VCM_CONTROL_3                       =      16'h3605;
parameter OV5640_VCM_CONTROL_4                       =      16'h3606;

/* timing control [=      16'h3800 ~ =      16'h3821]                   */
parameter OV5640_TIMING_HS_HIGH                      =      16'h3800;
parameter OV5640_TIMING_HS_LOW                       =      16'h3801;
parameter OV5640_TIMING_VS_HIGH                      =      16'h3802;
parameter OV5640_TIMING_VS_LOW                       =      16'h3803;
parameter OV5640_TIMING_HW_HIGH                      =      16'h3804;
parameter OV5640_TIMING_HW_LOW                       =      16'h3805;
parameter OV5640_TIMING_VH_HIGH                      =      16'h3806;
parameter OV5640_TIMING_VH_LOW                       =      16'h3807;
parameter OV5640_TIMING_DVPHO_HIGH                   =      16'h3808;
parameter OV5640_TIMING_DVPHO_LOW                    =      16'h3809;
parameter OV5640_TIMING_DVPVO_HIGH                   =      16'h380A;
parameter OV5640_TIMING_DVPVO_LOW                    =      16'h380B;
parameter OV5640_TIMING_HTS_HIGH                     =      16'h380C;
parameter OV5640_TIMING_HTS_LOW                      =      16'h380D;
parameter OV5640_TIMING_VTS_HIGH                     =      16'h380E;
parameter OV5640_TIMING_VTS_LOW                      =      16'h380F;
parameter OV5640_TIMING_HOFFSET_HIGH                 =      16'h3810;
parameter OV5640_TIMING_HOFFSET_LOW                  =      16'h3811;
parameter OV5640_TIMING_VOFFSET_HIGH                 =      16'h3812;
parameter OV5640_TIMING_VOFFSET_LOW                  =      16'h3813;
parameter OV5640_TIMING_X_INC                        =      16'h3814;
parameter OV5640_TIMING_Y_INC                        =      16'h3815;
parameter OV5640_HSYNC_START_HIGH                    =      16'h3816;
parameter OV5640_HSYNC_START_LOW                     =      16'h3817;
parameter OV5640_HSYNC_WIDTH_HIGH                    =      16'h3818;
parameter OV5640_HSYNC_WIDTH_LOW                     =      16'h3819;
parameter OV5640_TIMING_TC_REG20                     =      16'h3820;
parameter OV5640_TIMING_TC_REG21                     =      16'h3821;

/* AEC/AGC power down domain control [=      16'h3A00 ~ =      16'h325] */
parameter OV5640_AEC_CTRL00                          =      16'h3A00;
parameter OV5640_AEC_CTRL01                          =      16'h3A01;
parameter OV5640_AEC_CTRL02                          =      16'h3A02;
parameter OV5640_AEC_CTRL03                          =      16'h3A03;
parameter OV5640_AEC_CTRL04                          =      16'h3A04;
parameter OV5640_AEC_CTRL05                          =      16'h3A05;
parameter OV5640_AEC_CTRL06                          =      16'h3A06;
parameter OV5640_AEC_CTRL07                          =      16'h3A07;
parameter OV5640_AEC_B50_STEP_HIGH                   =      16'h3A08;
parameter OV5640_AEC_B50_STEP_LOW                    =      16'h3A09;
parameter OV5640_AEC_B60_STEP_HIGH                   =      16'h3A0A;
parameter OV5640_AEC_B60_STEP_LOW                    =      16'h3A0B;
parameter OV5640_AEC_AEC_CTRL0C                      =      16'h3A0C;
parameter OV5640_AEC_CTRL0D                          =      16'h3A0D;
parameter OV5640_AEC_CTRL0E                          =      16'h3A0E;
parameter OV5640_AEC_CTRL0F                          =      16'h3A0F;
parameter OV5640_AEC_CTRL10                          =      16'h3A10;
parameter OV5640_AEC_CTRL11                          =      16'h3A11;
parameter OV5640_AEC_CTRL13                          =      16'h3A13;
parameter OV5640_AEC_MAX_EXPO_HIGH                   =      16'h3A14;
parameter OV5640_AEC_MAX_EXPO_LOW                    =      16'h3A15;
parameter OV5640_AEC_CTRL17                          =      16'h3A17;
parameter OV5640_AEC_GAIN_CEILING_HIGH               =      16'h3A18;
parameter OV5640_AEC_GAIN_CEILING_LOW                =      16'h3A19;
parameter OV5640_AEC_DIFF_MIN                        =      16'h3A1A;
parameter OV5640_AEC_CTRL1B                          =      16'h3A1B;
parameter OV5640_LED_ADD_ROW_HIGH                    =      16'h3A1C;
parameter OV5640_LED_ADD_ROW_LOW                     =      16'h3A1D;
parameter OV5640_AEC_CTRL1E                          =      16'h3A1E;
parameter OV5640_AEC_CTRL1F                          =      16'h3A1F;
parameter OV5640_AEC_CTRL20                          =      16'h3A20;
parameter OV5640_AEC_CTRL21                          =      16'h3A21;
parameter OV5640_AEC_CTRL25                          =      16'h3A25;

/* strobe control [=      16'h3B00 ~ =      16'h3B0C]                     */
parameter OV5640_STROBE_CTRL                         =      16'h3B00;
parameter OV5640_FREX_EXPOSURE02                     =      16'h3B01;
parameter OV5640_FREX_SHUTTER_DLY01                  =      16'h3B02;
parameter OV5640_FREX_SHUTTER_DLY00                  =      16'h3B03;
parameter OV5640_FREX_EXPOSURE01                     =      16'h3B04;
parameter OV5640_FREX_EXPOSURE00                     =      16'h3B05;
parameter OV5640_FREX_CTRL07                         =      16'h3B06;
parameter OV5640_FREX_MODE                           =      16'h3B07;
parameter OV5640_FREX_RQST                           =      16'h3B08;
parameter OV5640_FREX_HREF_DLY                       =      16'h3B09;
parameter OV5640_FREX_RST_LENGTH                     =      16'h3B0A;
parameter OV5640_STROBE_WIDTH_HIGH                   =      16'h3B0B;
parameter OV5640_STROBE_WIDTH_LOW                    =      16'h3B0C;

/* 50/60Hz detector control [=      16'h3C00 ~ =      16'h3C1E]           */
parameter OV5640_5060HZ_CTRL00                       =      16'h3C00;
parameter OV5640_5060HZ_CTRL01                       =      16'h3C01;
parameter OV5640_5060HZ_CTRL02                       =      16'h3C02;
parameter OV5640_5060HZ_CTRL03                       =      16'h3C03;
parameter OV5640_5060HZ_CTRL04                       =      16'h3C04;
parameter OV5640_5060HZ_CTRL05                       =      16'h3C05;
parameter OV5640_LIGHTMETER1_TH_HIGH                 =      16'h3C06;
parameter OV5640_LIGHTMETER1_TH_LOW                  =      16'h3C07;
parameter OV5640_LIGHTMETER2_TH_HIGH                 =      16'h3C08;
parameter OV5640_LIGHTMETER2_TH_LOW                  =      16'h3C09;
parameter OV5640_SAMPLE_NUMBER_HIGH                  =      16'h3C0A;
parameter OV5640_SAMPLE_NUMBER_LOW                   =      16'h3C0B;
parameter OV5640_SIGMA_DELTA_CTRL0C                  =      16'h3C0C;
parameter OV5640_SUM50_BYTE4                         =      16'h3C0D;
parameter OV5640_SUM50_BYTE3                         =      16'h3C0E;
parameter OV5640_SUM50_BYTE2                         =      16'h3C0F;
parameter OV5640_SUM50_BYTE1                         =      16'h3C10;
parameter OV5640_SUM60_BYTE4                         =      16'h3C11;
parameter OV5640_SUM60_BYTE3                         =      16'h3C12;
parameter OV5640_SUM60_BYTE2                         =      16'h3C13;
parameter OV5640_SUM60_BYTE1                         =      16'h3C14;
parameter OV5640_SUM5060_HIGH                        =      16'h3C15;
parameter OV5640_SUM5060_LOW                         =      16'h3C16;
parameter OV5640_BLOCK_CNTR_HIGH                     =      16'h3C17;
parameter OV5640_BLOCK_CNTR_LOW                      =      16'h3C18;
parameter OV5640_B6_HIGH                             =      16'h3C19;
parameter OV5640_B6_LOW                              =      16'h3C1A;
parameter OV5640_LIGHTMETER_OUTPUT_BYTE3             =      16'h3C1B;
parameter OV5640_LIGHTMETER_OUTPUT_BYTE2             =      16'h3C1C;
parameter OV5640_LIGHTMETER_OUTPUT_BYTE1             =      16'h3C1D;
parameter OV5640_SUM_THRESHOLD                       =      16'h3C1E;

/* OTP control [=      16'h3D00 ~ =      16'h3D21]                        */
/* MC control [=      16'h3F00 ~ =      16'h3F0D]                         */
/* BLC control [=      16'h4000 ~ =      16'h4033]                        */
parameter OV5640_BLC_CTRL00                          =      16'h4000;
parameter OV5640_BLC_CTRL01                          =      16'h4001;
parameter OV5640_BLC_CTRL02                          =      16'h4002;
parameter OV5640_BLC_CTRL03                          =      16'h4003;
parameter OV5640_BLC_CTRL04                          =      16'h4004;
parameter OV5640_BLC_CTRL05                          =      16'h4005;

/* frame control [=      16'h4201 ~ =      16'h4202]                      */
parameter OV5640_FRAME_CTRL01                        =      16'h4201;
parameter OV5640_FRAME_CTRL02                        =      16'h4202;

/* format control [=      16'h4300 ~ =      16'h430D]                     */
parameter OV5640_FORMAT_CTRL00                       =      16'h4300;
parameter OV5640_FORMAT_CTRL01                       =      16'h4301;
parameter OV5640_YMAX_VAL_HIGH                       =      16'h4302;
parameter OV5640_YMAX_VAL_LOW                        =      16'h4303;
parameter OV5640_YMIN_VAL_HIGH                       =      16'h4304;
parameter OV5640_YMIN_VAL_LOW                        =      16'h4305;
parameter OV5640_UMAX_VAL_HIGH                       =      16'h4306;
parameter OV5640_UMAX_VAL_LOW                        =      16'h4307;
parameter OV5640_UMIN_VAL_HIGH                       =      16'h4308;
parameter OV5640_UMIN_VAL_LOW                        =      16'h4309;
parameter OV5640_VMAX_VAL_HIGH                       =      16'h430A;
parameter OV5640_VMAX_VAL_LOW                        =      16'h430B;
parameter OV5640_VMIN_VAL_HIGH                       =      16'h430C;
parameter OV5640_VMIN_VAL_LOW                        =      16'h430D;

/* JPEG control [=      16'h4400 ~ =      16'h4431]                       */
parameter OV5640_JPEG_CTRL00                         =      16'h4400;
parameter OV5640_JPEG_CTRL01                         =      16'h4401;
parameter OV5640_JPEG_CTRL02                         =      16'h4402;
parameter OV5640_JPEG_CTRL03                         =      16'h4403;
parameter OV5640_JPEG_CTRL04                         =      16'h4404;
parameter OV5640_JPEG_CTRL05                         =      16'h4405;
parameter OV5640_JPEG_CTRL06                         =      16'h4406;
parameter OV5640_JPEG_CTRL07                         =      16'h4407;
parameter OV5640_JPEG_ISI_CTRL1                      =      16'h4408;
parameter OV5640_JPEG_CTRL09                         =      16'h4409;
parameter OV5640_JPEG_CTRL0A                         =      16'h440A;
parameter OV5640_JPEG_CTRL0B                         =      16'h440B;
parameter OV5640_JPEG_CTRL0C                         =      16'h440C;
parameter OV5640_JPEG_QT_DATA                        =      16'h4410;
parameter OV5640_JPEG_QT_ADDR                        =      16'h4411;
parameter OV5640_JPEG_ISI_DATA                       =      16'h4412;
parameter OV5640_JPEG_ISI_CTRL2                      =      16'h4413;
parameter OV5640_JPEG_LENGTH_BYTE3                   =      16'h4414;
parameter OV5640_JPEG_LENGTH_BYTE2                   =      16'h4415;
parameter OV5640_JPEG_LENGTH_BYTE1                   =      16'h4416;
parameter OV5640_JFIFO_OVERFLOW                      =      16'h4417;

/* VFIFO control [=      16'h4600 ~ =      16'h460D]                      */
parameter OV5640_VFIFO_CTRL00                        =      16'h4600;
parameter OV5640_VFIFO_HSIZE_HIGH                    =      16'h4602;
parameter OV5640_VFIFO_HSIZE_LOW                     =      16'h4603;
parameter OV5640_VFIFO_VSIZE_HIGH                    =      16'h4604;
parameter OV5640_VFIFO_VSIZE_LOW                     =      16'h4605;
parameter OV5640_VFIFO_CTRL0C                        =      16'h460C;
parameter OV5640_VFIFO_CTRL0D                        =      16'h460D;

/* DVP control [=      16'h4709 ~ =      16'h4745]                        */
parameter OV5640_DVP_VSYNC_WIDTH0                    =      16'h4709;
parameter OV5640_DVP_VSYNC_WIDTH1                    =      16'h470A;
parameter OV5640_DVP_VSYNC_WIDTH2                    =      16'h470B;
parameter OV5640_PAD_LEFT_CTRL                       =      16'h4711;
parameter OV5640_PAD_RIGHT_CTRL                      =      16'h4712;
parameter OV5640_JPG_MODE_SELECT                     =      16'h4713;
parameter OV5640_656_DUMMY_LINE                      =      16'h4715;
parameter OV5640_CCIR656_CTRL                        =      16'h4719;
parameter OV5640_HSYNC_CTRL00                        =      16'h471B;
parameter OV5640_DVP_VSYN_CTRL                       =      16'h471D;
parameter OV5640_DVP_HREF_CTRL                       =      16'h471F;
parameter OV5640_VSTART_OFFSET                       =      16'h4721;
parameter OV5640_VEND_OFFSET                         =      16'h4722;
parameter OV5640_DVP_CTRL23                          =      16'h4723;
parameter OV5640_CCIR656_CTRL00                      =      16'h4730;
parameter OV5640_CCIR656_CTRL01                      =      16'h4731;
parameter OV5640_CCIR656_FS                          =      16'h4732;
parameter OV5640_CCIR656_FE                          =      16'h4733;
parameter OV5640_CCIR656_LS                          =      16'h4734;
parameter OV5640_CCIR656_LE                          =      16'h4735;
parameter OV5640_CCIR656_CTRL06                      =      16'h4736;
parameter OV5640_CCIR656_CTRL07                      =      16'h4737;
parameter OV5640_CCIR656_CTRL08                      =      16'h4738;
parameter OV5640_POLARITY_CTRL                       =      16'h4740;
parameter OV5640_TEST_PATTERN                        =      16'h4741;
parameter OV5640_DATA_ORDER                          =      16'h4745;

/* MIPI control [=      16'h4800 ~ =      16'h4837]                       */
parameter OV5640_MIPI_CTRL00                         =      16'h4800;
parameter OV5640_MIPI_CTRL01                         =      16'h4801;
parameter OV5640_MIPI_CTRL05                         =      16'h4805;
parameter OV5640_MIPI_DATA_ORDER                     =      16'h480A;
parameter OV5640_MIN_HS_ZERO_HIGH                    =      16'h4818;
parameter OV5640_MIN_HS_ZERO_LOW                     =      16'h4819;
parameter OV5640_MIN_MIPI_HS_TRAIL_HIGH              =      16'h481A;
parameter OV5640_MIN_MIPI_HS_TRAIL_LOW               =      16'h481B;
parameter OV5640_MIN_MIPI_CLK_ZERO_HIGH              =      16'h481C;
parameter OV5640_MIN_MIPI_CLK_ZERO_LOW               =      16'h481D;
parameter OV5640_MIN_MIPI_CLK_PREPARE_HIGH           =      16'h481E;
parameter OV5640_MIN_MIPI_CLK_PREPARE_LOW            =      16'h481F;
parameter OV5640_MIN_CLK_POST_HIGH                   =      16'h4820;
parameter OV5640_MIN_CLK_POST_LOW                    =      16'h4821;
parameter OV5640_MIN_CLK_TRAIL_HIGH                  =      16'h4822;
parameter OV5640_MIN_CLK_TRAIL_LOW                   =      16'h4823;
parameter OV5640_MIN_LPX_PCLK_HIGH                   =      16'h4824;
parameter OV5640_MIN_LPX_PCLK_LOW                    =      16'h4825;
parameter OV5640_MIN_HS_PREPARE_HIGH                 =      16'h4826;
parameter OV5640_MIN_HS_PREPARE_LOW                  =      16'h4827;
parameter OV5640_MIN_HS_EXIT_HIGH                    =      16'h4828;
parameter OV5640_MIN_HS_EXIT_LOW                     =      16'h4829;
parameter OV5640_MIN_HS_ZERO_UI                      =      16'h482A;
parameter OV5640_MIN_HS_TRAIL_UI                     =      16'h482B;
parameter OV5640_MIN_CLK_ZERO_UI                     =      16'h482C;
parameter OV5640_MIN_CLK_PREPARE_UI                  =      16'h482D;
parameter OV5640_MIN_CLK_POST_UI                     =      16'h482E;
parameter OV5640_MIN_CLK_TRAIL_UI                    =      16'h482F;
parameter OV5640_MIN_LPX_PCLK_UI                     =      16'h4830;
parameter OV5640_MIN_HS_PREPARE_UI                   =      16'h4831;
parameter OV5640_MIN_HS_EXIT_UI                      =      16'h4832;
parameter OV5640_PCLK_PERIOD                         =      16'h4837;

/* ISP frame control [=      16'h4901 ~ =      16'h4902]                  */
parameter OV5640_ISP_FRAME_CTRL01                    =      16'h4901;
parameter OV5640_ISP_FRAME_CTRL02                    =      16'h4902;

/* ISP top control [=      16'h5000 ~ =      16'h5063]                    */
parameter OV5640_ISP_CONTROL00                       =      16'h5000;
parameter OV5640_ISP_CONTROL01                       =      16'h5001;
parameter OV5640_ISP_CONTROL03                       =      16'h5003;
parameter OV5640_ISP_CONTROL05                       =      16'h5005;
parameter OV5640_ISP_MISC0                           =      16'h501D;
parameter OV5640_ISP_MISC1                           =      16'h501E;
parameter OV5640_FORMAT_MUX_CTRL                     =      16'h501F;
parameter OV5640_DITHER_CTRL0                        =      16'h5020;
parameter OV5640_DRAW_WINDOW_CTRL00                  =      16'h5027;
parameter OV5640_DRAW_WINDOW_LEFT_CTRL_HIGH          =      16'h5028;
parameter OV5640_DRAW_WINDOW_LEFT_CTRL_LOW           =      16'h5029;
parameter OV5640_DRAW_WINDOW_RIGHT_CTRL_HIGH         =      16'h502A;
parameter OV5640_DRAW_WINDOW_RIGHT_CTRL_LOW          =      16'h502B;
parameter OV5640_DRAW_WINDOW_TOP_CTRL_HIGH           =      16'h502C;
parameter OV5640_DRAW_WINDOW_TOP_CTRL_LOW            =      16'h502D;
parameter OV5640_DRAW_WINDOW_BOTTOM_CTRL_HIGH        =      16'h502E;
parameter OV5640_DRAW_WINDOW_BOTTOM_CTRL_LOW         =      16'h502F;
parameter OV5640_DRAW_WINDOW_HBW_CTRL_HIGH           =      16'h5030;        /* HBW: Horizontal Boundary Width */
parameter OV5640_DRAW_WINDOW_HBW_CTRL_LOW            =      16'h5031;
parameter OV5640_DRAW_WINDOW_VBW_CTRL_HIGH           =      16'h5032;        /* VBW: Vertical Boundary Width */
parameter OV5640_DRAW_WINDOW_VBW_CTRL_LOW            =      16'h5033;
parameter OV5640_DRAW_WINDOW_Y_CTRL                  =      16'h5034;
parameter OV5640_DRAW_WINDOW_U_CTRL                  =      16'h5035;
parameter OV5640_DRAW_WINDOW_V_CTRL                  =      16'h5036;
parameter OV5640_PRE_ISP_TEST_SETTING1               =      16'h503D;
parameter OV5640_ISP_SENSOR_BIAS_I                   =      16'h5061;
parameter OV5640_ISP_SENSOR_GAIN1_I                  =      16'h5062;
parameter OV5640_ISP_SENSOR_GAIN2_I                  =      16'h5063;

/* AWB control [=      16'h5180 ~ =      16'h51D0]                      */
parameter OV5640_AWB_CTRL00                          =      16'h5180;
parameter OV5640_AWB_CTRL01                          =      16'h5181;
parameter OV5640_AWB_CTRL02                          =      16'h5182;
parameter OV5640_AWB_CTRL03                          =      16'h5183;
parameter OV5640_AWB_CTRL04                          =      16'h5184;
parameter OV5640_AWB_CTRL05                          =      16'h5185;
parameter OV5640_AWB_CTRL06                          =      16'h5186;   /* Advanced AWB control registers: =      16'h5186 ~ =      16'h5190 */
parameter OV5640_AWB_CTRL07                          =      16'h5187;
parameter OV5640_AWB_CTRL08                          =      16'h5188;
parameter OV5640_AWB_CTRL09                          =      16'h5189;
parameter OV5640_AWB_CTRL10                          =      16'h518A;
parameter OV5640_AWB_CTRL11                          =      16'h518B;
parameter OV5640_AWB_CTRL12                          =      16'h518C;
parameter OV5640_AWB_CTRL13                          =      16'h518D;
parameter OV5640_AWB_CTRL14                          =      16'h518E;
parameter OV5640_AWB_CTRL15                          =      16'h518F;
parameter OV5640_AWB_CTRL16                          =      16'h5190;
parameter OV5640_AWB_CTRL17                          =      16'h5191;
parameter OV5640_AWB_CTRL18                          =      16'h5192;
parameter OV5640_AWB_CTRL19                          =      16'h5193;
parameter OV5640_AWB_CTRL20                          =      16'h5194;
parameter OV5640_AWB_CTRL21                          =      16'h5195;
parameter OV5640_AWB_CTRL22                          =      16'h5196;
parameter OV5640_AWB_CTRL23                          =      16'h5197;
parameter OV5640_AWB_CTRL24                          =      16'h5198;
parameter OV5640_AWB_CTRL25                          =      16'h5199;
parameter OV5640_AWB_CTRL26                          =      16'h519A;
parameter OV5640_AWB_CTRL27                          =      16'h519B;
parameter OV5640_AWB_CTRL28                          =      16'h519C;
parameter OV5640_AWB_CTRL29                          =      16'h519D;
parameter OV5640_AWB_CTRL30                          =      16'h519E;
parameter OV5640_AWB_CURRENT_R_GAIN_HIGH             =      16'h519F;
parameter OV5640_AWB_CURRENT_R_GAIN_LOW              =      16'h51A0;
parameter OV5640_AWB_CURRENT_G_GAIN_HIGH             =      16'h51A1;
parameter OV5640_AWB_CURRENT_G_GAIN_LOW              =      16'h51A2;
parameter OV5640_AWB_CURRENT_B_GAIN_HIGH             =      16'h51A3;
parameter OV5640_AWB_CURRENT_B_GAIN_LOW              =      16'h51A4;
parameter OV5640_AWB_AVERAGE_R                       =      16'h51A5;
parameter OV5640_AWB_AVERAGE_G                       =      16'h51A6;
parameter OV5640_AWB_AVERAGE_B                       =      16'h51A7;
parameter OV5640_AWB_CTRL74                          =      16'h5180;

/* CIP control [=      16'h5300 ~ =      16'h530F]                  ;    */
parameter OV5640_CIP_SHARPENMT_TH1                   =      16'h5300;
parameter OV5640_CIP_SHARPENMT_TH2                   =      16'h5301;
parameter OV5640_CIP_SHARPENMT_OFFSET1               =      16'h5302;
parameter OV5640_CIP_SHARPENMT_OFFSET2               =      16'h5303;
parameter OV5640_CIP_DNS_TH1                         =      16'h5304;
parameter OV5640_CIP_DNS_TH2                         =      16'h5305;
parameter OV5640_CIP_DNS_OFFSET1                     =      16'h5306;
parameter OV5640_CIP_DNS_OFFSET2                     =      16'h5307;
parameter OV5640_CIP_CTRL                            =      16'h5308;
parameter OV5640_CIP_SHARPENTH_TH1                   =      16'h5309;
parameter OV5640_CIP_SHARPENTH_TH2                   =      16'h530A;
parameter OV5640_CIP_SHARPENTH_OFFSET1               =      16'h530B;
parameter OV5640_CIP_SHARPENTH_OFFSET2               =      16'h530C;
parameter OV5640_CIP_EDGE_MT_AUTO                    =      16'h530D;
parameter OV5640_CIP_DNS_TH_AUTO                     =      16'h530E;
parameter OV5640_CIP_SHARPEN_TH_AUTO                 =      16'h530F;

/* CMX control [=      16'h5380 ~ =      16'h538B]                  ;    */
parameter OV5640_CMX_CTRL                            =      16'h5380;
parameter OV5640_CMX1                                =      16'h5381;
parameter OV5640_CMX2                                =      16'h5382;
parameter OV5640_CMX3                                =      16'h5383;
parameter OV5640_CMX4                                =      16'h5384;
parameter OV5640_CMX5                                =      16'h5385;
parameter OV5640_CMX6                                =      16'h5386;
parameter OV5640_CMX7                                =      16'h5387;
parameter OV5640_CMX8                                =      16'h5388;
parameter OV5640_CMX9                                =      16'h5389;
parameter OV5640_CMXSIGN_HIGH                        =      16'h538A;
parameter OV5640_CMXSIGN_LOW                         =      16'h538B;

/* gamma control [=      16'h5480 ~ =      16'h5490]                    */
parameter OV5640_GAMMA_CTRL00                        =      16'h5480;
parameter OV5640_GAMMA_YST00                         =      16'h5481;
parameter OV5640_GAMMA_YST01                         =      16'h5482;
parameter OV5640_GAMMA_YST02                         =      16'h5483;
parameter OV5640_GAMMA_YST03                         =      16'h5484;
parameter OV5640_GAMMA_YST04                         =      16'h5485;
parameter OV5640_GAMMA_YST05                         =      16'h5486;
parameter OV5640_GAMMA_YST06                         =      16'h5487;
parameter OV5640_GAMMA_YST07                         =      16'h5488;
parameter OV5640_GAMMA_YST08                         =      16'h5489;
parameter OV5640_GAMMA_YST09                         =      16'h548A;
parameter OV5640_GAMMA_YST0A                         =      16'h548B;
parameter OV5640_GAMMA_YST0B                         =      16'h548C;
parameter OV5640_GAMMA_YST0C                         =      16'h548D;
parameter OV5640_GAMMA_YST0D                         =      16'h548E;
parameter OV5640_GAMMA_YST0E                         =      16'h548F;
parameter OV5640_GAMMA_YST0F                         =      16'h5490;

/* SDE control [=      16'h5580 ~ =      16'h558C]                      */
parameter OV5640_SDE_CTRL0                           =      16'h5580;
parameter OV5640_SDE_CTRL1                           =      16'h5581;
parameter OV5640_SDE_CTRL2                           =      16'h5582;
parameter OV5640_SDE_CTRL3                           =      16'h5583;
parameter OV5640_SDE_CTRL4                           =      16'h5584;
parameter OV5640_SDE_CTRL5                           =      16'h5585;
parameter OV5640_SDE_CTRL6                           =      16'h5586;
parameter OV5640_SDE_CTRL7                           =      16'h5587;
parameter OV5640_SDE_CTRL8                           =      16'h5588;
parameter OV5640_SDE_CTRL9                           =      16'h5589;
parameter OV5640_SDE_CTRL10                          =      16'h558A;
parameter OV5640_SDE_CTRL11                          =      16'h558B;
parameter OV5640_SDE_CTRL12                          =      16'h558C;

/* scale control [=      16'h5600 ~ =      16'h5606]                    */
parameter OV5640_SCALE_CTRL0                         =      16'h5600;
parameter OV5640_SCALE_CTRL1                         =      16'h5601;
parameter OV5640_SCALE_CTRL2                         =      16'h5602;
parameter OV5640_SCALE_CTRL3                         =      16'h5603;
parameter OV5640_SCALE_CTRL4                         =      16'h5604;
parameter OV5640_SCALE_CTRL5                         =      16'h5605;
parameter OV5640_SCALE_CTRL6                         =      16'h5606;


/* AVG control [=      16'h5680 ~ =      16'h56A2]                      */
parameter OV5640_X_START_HIGH                        =      16'h5680;
parameter OV5640_X_START_LOW                         =      16'h5681;
parameter OV5640_Y_START_HIGH                        =      16'h5682;
parameter OV5640_Y_START_LOW                         =      16'h5683;
parameter OV5640_X_WINDOW_HIGH                       =      16'h5684;
parameter OV5640_X_WINDOW_LOW                        =      16'h5685;
parameter OV5640_Y_WINDOW_HIGH                       =      16'h5686;
parameter OV5640_Y_WINDOW_LOW                        =      16'h5687;
parameter OV5640_WEIGHT00                            =      16'h5688;
parameter OV5640_WEIGHT01                            =      16'h5689;
parameter OV5640_WEIGHT02                            =      16'h568A;
parameter OV5640_WEIGHT03                            =      16'h568B;
parameter OV5640_WEIGHT04                            =      16'h568C;
parameter OV5640_WEIGHT05                            =      16'h568D;
parameter OV5640_WEIGHT06                            =      16'h568E;
parameter OV5640_WEIGHT07                            =      16'h568F;
parameter OV5640_AVG_CTRL10                          =      16'h5690;
parameter OV5640_AVG_WIN_00                          =      16'h5691;
parameter OV5640_AVG_WIN_01                          =      16'h5692;
parameter OV5640_AVG_WIN_02                          =      16'h5693;
parameter OV5640_AVG_WIN_03                          =      16'h5694;
parameter OV5640_AVG_WIN_10                          =      16'h5695;
parameter OV5640_AVG_WIN_11                          =      16'h5696;
parameter OV5640_AVG_WIN_12                          =      16'h5697;
parameter OV5640_AVG_WIN_13                          =      16'h5698;
parameter OV5640_AVG_WIN_20                          =      16'h5699;
parameter OV5640_AVG_WIN_21                          =      16'h569A;
parameter OV5640_AVG_WIN_22                          =      16'h569B;
parameter OV5640_AVG_WIN_23                          =      16'h569C;
parameter OV5640_AVG_WIN_30                          =      16'h569D;
parameter OV5640_AVG_WIN_31                          =      16'h569E;
parameter OV5640_AVG_WIN_32                          =      16'h569F;
parameter OV5640_AVG_WIN_33                          =      16'h56A0;
parameter OV5640_AVG_READOUT                         =      16'h56A1;
parameter OV5640_AVG_WEIGHT_SUM                      =      16'h56A2;

/* LENC control [=      16'h5800 ~ =      16'h5849]                     */
parameter OV5640_GMTRX00                             =      16'h5800;
parameter OV5640_GMTRX01                             =      16'h5801;
parameter OV5640_GMTRX02                             =      16'h5802;
parameter OV5640_GMTRX03                             =      16'h5803;
parameter OV5640_GMTRX04                             =      16'h5804;
parameter OV5640_GMTRX05                             =      16'h5805;
parameter OV5640_GMTRX10                             =      16'h5806;
parameter OV5640_GMTRX11                             =      16'h5807;
parameter OV5640_GMTRX12                             =      16'h5808;
parameter OV5640_GMTRX13                             =      16'h5809;
parameter OV5640_GMTRX14                             =      16'h580A;
parameter OV5640_GMTRX15                             =      16'h580B;
parameter OV5640_GMTRX20                             =      16'h580C;
parameter OV5640_GMTRX21                             =      16'h580D;
parameter OV5640_GMTRX22                             =      16'h580E;
parameter OV5640_GMTRX23                             =      16'h580F;
parameter OV5640_GMTRX24                             =      16'h5810;
parameter OV5640_GMTRX25                             =      16'h5811;
parameter OV5640_GMTRX30                             =      16'h5812;
parameter OV5640_GMTRX31                             =      16'h5813;
parameter OV5640_GMTRX32                             =      16'h5814;
parameter OV5640_GMTRX33                             =      16'h5815;
parameter OV5640_GMTRX34                             =      16'h5816;
parameter OV5640_GMTRX35                             =      16'h5817;
parameter OV5640_GMTRX40                             =      16'h5818;
parameter OV5640_GMTRX41                             =      16'h5819;
parameter OV5640_GMTRX42                             =      16'h581A;
parameter OV5640_GMTRX43                             =      16'h581B;
parameter OV5640_GMTRX44                             =      16'h581C;
parameter OV5640_GMTRX45                             =      16'h581D;
parameter OV5640_GMTRX50                             =      16'h581E;
parameter OV5640_GMTRX51                             =      16'h581F;
parameter OV5640_GMTRX52                             =      16'h5820;
parameter OV5640_GMTRX53                             =      16'h5821;
parameter OV5640_GMTRX54                             =      16'h5822;
parameter OV5640_GMTRX55                             =      16'h5823;
parameter OV5640_BRMATRX00                           =      16'h5824;
parameter OV5640_BRMATRX01                           =      16'h5825;
parameter OV5640_BRMATRX02                           =      16'h5826;
parameter OV5640_BRMATRX03                           =      16'h5827;
parameter OV5640_BRMATRX04                           =      16'h5828;
parameter OV5640_BRMATRX05                           =      16'h5829;
parameter OV5640_BRMATRX06                           =      16'h582A;
parameter OV5640_BRMATRX07                           =      16'h582B;
parameter OV5640_BRMATRX08                           =      16'h582C;
parameter OV5640_BRMATRX09                           =      16'h582D;
parameter OV5640_BRMATRX20                           =      16'h582E;
parameter OV5640_BRMATRX21                           =      16'h582F;
parameter OV5640_BRMATRX22                           =      16'h5830;
parameter OV5640_BRMATRX23                           =      16'h5831;
parameter OV5640_BRMATRX24                           =      16'h5832;
parameter OV5640_BRMATRX30                           =      16'h5833;
parameter OV5640_BRMATRX31                           =      16'h5834;
parameter OV5640_BRMATRX32                           =      16'h5835;
parameter OV5640_BRMATRX33                           =      16'h5836;
parameter OV5640_BRMATRX34                           =      16'h5837;
parameter OV5640_BRMATRX40                           =      16'h5838;
parameter OV5640_BRMATRX41                           =      16'h5839;
parameter OV5640_BRMATRX42                           =      16'h583A;
parameter OV5640_BRMATRX43                           =      16'h583B;
parameter OV5640_BRMATRX44                           =      16'h583C;
parameter OV5640_LENC_BR_OFFSET                      =      16'h583D;
parameter OV5640_MAX_GAIN                            =      16'h583E;
parameter OV5640_MIN_GAIN                            =      16'h583F;
parameter OV5640_MIN_Q                               =      16'h5840;
parameter OV5640_LENC_CTRL59                         =      16'h5841;
parameter OV5640_BR_HSCALE_HIGH                      =      16'h5842;
parameter OV5640_BR_HSCALE_LOW                       =      16'h5843;
parameter OV5640_BR_VSCALE_HIGH                      =      16'h5844;
parameter OV5640_BR_VSCALE_LOW                       =      16'h5845;
parameter OV5640_G_HSCALE_HIGH                       =      16'h5846;
parameter OV5640_G_HSCALE_LOW                        =      16'h5847;
parameter OV5640_G_VSCALE_HIGH                       =      16'h5848;
parameter OV5640_G_VSCALE_LOW                        =      16'h5849;

/* AFC control [=      16'h6000 ~ =      16'h603F]                      */
parameter OV5640_AFC_CTRL00                          =      16'h6000;
parameter OV5640_AFC_CTRL01                          =      16'h6001;
parameter OV5640_AFC_CTRL02                          =      16'h6002;
parameter OV5640_AFC_CTRL03                          =      16'h6003;
parameter OV5640_AFC_CTRL04                          =      16'h6004;
parameter OV5640_AFC_CTRL05                          =      16'h6005;
parameter OV5640_AFC_CTRL06                          =      16'h6006;
parameter OV5640_AFC_CTRL07                          =      16'h6007;
parameter OV5640_AFC_CTRL08                          =      16'h6008;
parameter OV5640_AFC_CTRL09                          =      16'h6009;
parameter OV5640_AFC_CTRL10                          =      16'h600A;
parameter OV5640_AFC_CTRL11                          =      16'h600B;
parameter OV5640_AFC_CTRL12                          =      16'h600C;
parameter OV5640_AFC_CTRL13                          =      16'h600D;
parameter OV5640_AFC_CTRL14                          =      16'h600E;
parameter OV5640_AFC_CTRL15                          =      16'h600F;
parameter OV5640_AFC_CTRL16                          =      16'h6010;
parameter OV5640_AFC_CTRL17                          =      16'h6011;
parameter OV5640_AFC_CTRL18                          =      16'h6012;
parameter OV5640_AFC_CTRL19                          =      16'h6013;
parameter OV5640_AFC_CTRL20                          =      16'h6014;
parameter OV5640_AFC_CTRL21                          =      16'h6015;
parameter OV5640_AFC_CTRL22                          =      16'h6016;
parameter OV5640_AFC_CTRL23                          =      16'h6017;
parameter OV5640_AFC_CTRL24                          =      16'h6018;
parameter OV5640_AFC_CTRL25                          =      16'h6019;
parameter OV5640_AFC_CTRL26                          =      16'h601A;
parameter OV5640_AFC_CTRL27                          =      16'h601B;
parameter OV5640_AFC_CTRL28                          =      16'h601C;
parameter OV5640_AFC_CTRL29                          =      16'h601D;
parameter OV5640_AFC_CTRL30                          =      16'h601E;
parameter OV5640_AFC_CTRL31                          =      16'h601F;
parameter OV5640_AFC_CTRL32                          =      16'h6020;
parameter OV5640_AFC_CTRL33                          =      16'h6021;
parameter OV5640_AFC_CTRL34                          =      16'h6022;
parameter OV5640_AFC_CTRL35                          =      16'h6023;
parameter OV5640_AFC_CTRL36                          =      16'h6024;
parameter OV5640_AFC_CTRL37                          =      16'h6025;
parameter OV5640_AFC_CTRL38                          =      16'h6026;
parameter OV5640_AFC_CTRL39                          =      16'h6027;
parameter OV5640_AFC_CTRL40                          =      16'h6028;
parameter OV5640_AFC_CTRL41                          =      16'h6029;
parameter OV5640_AFC_CTRL42                          =      16'h602A;
parameter OV5640_AFC_CTRL43                          =      16'h602B;
parameter OV5640_AFC_CTRL44                          =      16'h602C;
parameter OV5640_AFC_CTRL45                          =      16'h602D;
parameter OV5640_AFC_CTRL46                          =      16'h602E;
parameter OV5640_AFC_CTRL47                          =      16'h602F;
parameter OV5640_AFC_CTRL48                          =      16'h6030;
parameter OV5640_AFC_CTRL49                          =      16'h6031;
parameter OV5640_AFC_CTRL50                          =      16'h6032;
parameter OV5640_AFC_CTRL51                          =      16'h6033;
parameter OV5640_AFC_CTRL52                          =      16'h6034;
parameter OV5640_AFC_CTRL53                          =      16'h6035;
parameter OV5640_AFC_CTRL54                          =      16'h6036;
parameter OV5640_AFC_CTRL55                          =      16'h6037;
parameter OV5640_AFC_CTRL56                          =      16'h6038;
parameter OV5640_AFC_CTRL57                          =      16'h6039;
parameter OV5640_AFC_CTRL58                          =      16'h603A;
parameter OV5640_AFC_CTRL59                          =      16'h603B;
parameter OV5640_AFC_CTRL60                          =      16'h603C;
parameter OV5640_AFC_READ58                          =      16'h603D;
parameter OV5640_AFC_READ59                          =      16'h603E;
parameter OV5640_AFC_READ60                          =      16'h603F;
  
////////////////////////////////////////////////////////////////////////////////

/**
  * @brief  OV5640 Features Parameters
  */
/* Camera resolutions */
parameter OV5640_R160x120                 =   8'h00;   /* QQVGA Resolution           */
parameter OV5640_R320x240                 =   8'h01;   /* QVGA Resolution            */
parameter OV5640_R480x272                 =   8'h02;   /* 48=   8'h272 Resolution         */
parameter OV5640_R640x480                 =   8'h03;   /* VGA Resolution             */
parameter OV5640_R800x480                 =   8'h04;   /* WVGA Resolution            */

/* Camera Pixel Format */
parameter OV5640_RGB565                   =   8'h00;   /* Pixel Format RGB565        */
parameter OV5640_RGB888                   =   8'h01;   /* Pixel Format RGB888        */
parameter OV5640_YUV422                   =   8'h02;   /* Pixel Format YUV422        */
parameter OV5640_Y8                       =   8'h07;   /* Pixel Format Y8            */
parameter OV5640_JPEG                     =   8'h08;   /* Compressed format JPEG          */

/* Polarity */
parameter OV5640_POLARITY_PCLK_LOW        =   8'h00; /* Signal Active Low          */
parameter OV5640_POLARITY_PCLK_HIGH       =   8'h01; /* Signal Active High         */
parameter OV5640_POLARITY_HREF_LOW        =   8'h00; /* Signal Active Low          */
parameter OV5640_POLARITY_HREF_HIGH       =   8'h01; /* Signal Active High         */
parameter OV5640_POLARITY_VSYNC_LOW       =   8'h00; /* Signal Active Low          */
parameter OV5640_POLARITY_VSYNC_HIGH      =   8'h01; /* Signal Active High         */

/* Mirror/Flip */
parameter OV5640_MIRROR_FLIP_NONE         =   8'h00;   /* Set camera normal mode     */
parameter OV5640_FLIP                     =   8'h01;   /* Set camera flip config     */
parameter OV5640_MIRROR                   =   8'h02;   /* Set camera mirror config   */
parameter OV5640_MIRROR_FLIP              =   8'h03;   /* Set camera mirror and flip */

/* Zoom */
parameter OV5640_ZOOM_x8                  =   8'h00;   /* Set zoom to x8             */
parameter OV5640_ZOOM_x4                  =   8'h11;   /* Set zoom to x4             */
parameter OV5640_ZOOM_x2                  =   8'h22;   /* Set zoom to x2             */
parameter OV5640_ZOOM_x1                  =   8'h44;   /* Set zoom to x1             */

/* Special Effect */
parameter OV5640_COLOR_EFFECT_NONE        =   8'h00;   /* No effect                  */
parameter OV5640_COLOR_EFFECT_BLUE        =   8'h01;   /* Blue effect                */
parameter OV5640_COLOR_EFFECT_RED         =   8'h02;   /* Red effect                 */
parameter OV5640_COLOR_EFFECT_GREEN       =   8'h04;   /* Green effect               */
parameter OV5640_COLOR_EFFECT_BW          =   8'h08;   /* Black and White effect     */
parameter OV5640_COLOR_EFFECT_SEPIA       =   8'h10;   /* Sepia effect               */
parameter OV5640_COLOR_EFFECT_NEGATIVE    =   8'h20;   /* Negative effect            */


/* Light Mode */
parameter OV5640_LIGHT_AUTO               =   8'h00;   /* Light Mode Auto            */
parameter OV5640_LIGHT_SUNNY              =   8'h01;   /* Light Mode Sunny           */
parameter OV5640_LIGHT_OFFICE             =   8'h02;   /* Light Mode Office          */
parameter OV5640_LIGHT_HOME               =   8'h04;   /* Light Mode Home            */
parameter OV5640_LIGHT_CLOUDY             =   8'h08;   /* Light Mode Claudy          */

/* Night Mode */
parameter NIGHT_MODE_DISABLE              =   8'h00;   /* Disable night mode         */
parameter NIGHT_MODE_ENABLE               =   8'h01;   /* Enable night mode          */

/* Colorbar Mode */
parameter COLORBAR_MODE_DISABLE           =   8'h00;   /* Disable colorbar mode      */
parameter COLORBAR_MODE_ENABLE            =   8'h01;   /* 8 bars W/Y/C/G/M/R/B/Bl    */
parameter COLORBAR_MODE_GRADUALV          =   8'h02;   /* Gradual vertical colorbar  */

/* Pixel Clock */
parameter OV5640_PCLK_7M                  =   8'h00;   /* Pixel Clock set to 7Mhz    */
parameter OV5640_PCLK_8M                  =   8'h01;   /* Pixel Clock set to 8Mhz    */
parameter OV5640_PCLK_9M                  =   8'h02;   /* Pixel Clock set to 9Mhz    */
parameter OV5640_PCLK_12M                 =   8'h04;   /* Pixel Clock set to 12Mhz   */
parameter OV5640_PCLK_24M                 =   8'h08;   /* Pixel Clock set to 24Mhz   */
parameter OV5640_PCLK_48M                 =   8'h09;   /* Pixel Clock set to 48MHz   */

/* Mode */
parameter PARALLEL_MODE                   =   8'h00;   /* Parallel Interface Mode */
parameter SERIAL_MODE                     =   8'h01;   /* Serial Interface Mode   */

