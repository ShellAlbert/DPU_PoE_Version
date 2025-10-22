component ZPLL is
    port(
        clki_i: in std_logic;
        clkop_o: out std_logic;
        clkos_o: out std_logic;
        lock_o: out std_logic
    );
end component;

__: ZPLL port map(
    clki_i=>,
    clkop_o=>,
    clkos_o=>,
    lock_o=>
);
