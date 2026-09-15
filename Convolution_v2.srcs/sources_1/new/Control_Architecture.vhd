library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Control_Architecture is
    Port (
        clk, selector, T_valid_in, T_ready_in : in std_logic;
        Bus_valid_Size : in std_logic_vector(2 downto 0);
        Padding, kernel, Stride : in std_logic_vector(1 downto 0);    
        rst_RPS, CAP_RPS, SEL, T_ready_out : out std_logic;
        rst_RSP, CAP_RSP, EN_2, T_valid_out : out std_logic;        
        SR_Capture, EN_1, clk_EN_1 : buffer std_logic;
        AdderTree_Enable : out std_logic
    );
end Control_Architecture;

architecture Behavioral of Control_Architecture is
signal VALID_OUT, WAIT_0, clk_WAIT_0 : std_logic;

begin
    clk_WAIT_0 <= clk nand WAIT_0; 

    CBI : entity work.Control_Bus_in
    generic map(
        kernel_size => 27,
        matriz_size => 128
    )
    port map(
        clk => clk_WAIT_0,
        selector => selector,
        T_valid => T_valid_in,
        Bus_valid_Size => Bus_valid_Size,
        Padding => Padding,
        rst => rst_RPS,
        CAP => CAP_RPS,
        EN_1 => EN_1,
        SEL => SEL,
        T_ready => T_ready_out
    );
    
    clk_EN_1 <= clk and EN_1; 
    
    VD : entity work.Valid_Data
    generic map(
        DELAY_AdderTree_Enable => 1,
        DELAY_VALID_OUT => 7
    )
    port map(
        clk => clk_EN_1,
        Bus_valid_Size => Bus_valid_Size,
        kernel => kernel,
        Stride => Stride,
        Padding => Padding,
        SR_Capture => SR_Capture,
        AdderTree_Enable => AdderTree_Enable,
        VALID_OUT => VALID_OUT
    );  
    
    CBO : entity work.Control_Bus_out
    port map(
        clk => clk,
        VALID_OUT => VALID_OUT,
        T_ready => T_ready_in,        
        Bus_valid_Size => Bus_valid_Size,
        Padding => Padding,
        kernel => kernel,
        Stride => Stride,        
        rst => rst_RSP,
        CAP => CAP_RSP,
        EN_2 => EN_2,
        T_valid => T_valid_out,
        WAIT_0 => WAIT_0      
    ); 
    
      

end Behavioral;
