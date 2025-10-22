component ZFIFO_DC is
    port(
        wr_clk_i: in std_logic;
        rd_clk_i: in std_logic;
        rst_i: in std_logic;
        rp_rst_i: in std_logic;
        wr_en_i: in std_logic;
        rd_en_i: in std_logic;
        wr_data_i: in std_logic_vector(7 downto 0);
        full_o: out std_logic;
        empty_o: out std_logic;
        rd_data_o: out std_logic_vector(127 downto 0)
    );
end component;

__: ZFIFO_DC port map(
    wr_clk_i=>,
    rd_clk_i=>,
    rst_i=>,
    rp_rst_i=>,
    wr_en_i=>,
    rd_en_i=>,
    wr_data_i=>,
    full_o=>,
    empty_o=>,
    rd_data_o=>
);
