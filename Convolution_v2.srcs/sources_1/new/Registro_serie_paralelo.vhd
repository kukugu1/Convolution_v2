library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Registro_serie_paralelo is
    generic (
        DATA_WIDTH  : integer := 32;
        TOTAL_WIDTH : integer := 4224
    );
    port (
        clk      : in std_logic;
        rst      : in std_logic;
        enable   : in std_logic;
        load     : in std_logic;
        data_in  : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out : out std_logic_vector(TOTAL_WIDTH-1 downto 0)
    );
end entity Registro_serie_paralelo;

architecture Behavioral of Registro_serie_paralelo is
    signal captured_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal shift_reg     : std_logic_vector(TOTAL_WIDTH-1 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                shift_reg <= (others => '0');     
            elsif (load = '1') then
                captured_data <= data_in;   
                if (enable = '1') then
                    shift_reg <= shift_reg(TOTAL_WIDTH-DATA_WIDTH-1 downto 0) & captured_data;
                end if;
            end if;
        end if;
    end process;

    data_out <= shift_reg;
    
end architecture Behavioral;