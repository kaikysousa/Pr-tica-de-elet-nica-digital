library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ULA is 
    Port (
        entrada_a : in  STD_LOGIC_VECTOR(3 downto 0);
        entrada_b : in  STD_LOGIC_VECTOR(3 downto 0);
        seletor_operacao : in  STD_LOGIC_VECTOR(1 downto 0); 
        resultado_final     : out STD_LOGIC_VECTOR(3 downto 0); 
        indicador_overflow  : out STD_LOGIC;                    
        indicador_carry_out : out STD_LOGIC                     
    );
end ULA;

architecture Comportamental of ULA is
    
    signal entrada_a_extendida : signed(4 downto 0);
    signal entrada_b_extendida : signed(4 downto 0);
    
    signal resultado_soma_5bits      : signed(4 downto 0);
    signal resultado_subtracao_5bits : signed(4 downto 0);
    signal resultado_and_bits        : std_logic_vector(3 downto 0);
    signal resultado_or_bits         : std_logic_vector(3 downto 0);

    alias sinal_entrada_a : std_logic is entrada_a(3);
    alias sinal_entrada_b : std_logic is entrada_b(3);
    
begin
    
    entrada_a_extendida <= resize(signed(entrada_a), 5);
    entrada_b_extendida <= resize(signed(entrada_b), 5);

    resultado_soma_5bits      <= entrada_a_extendida + entrada_b_extendida;
    resultado_subtracao_5bits <= entrada_a_extendida - entrada_b_extendida;
    resultado_and_bits        <= entrada_a and entrada_b;
    resultado_or_bits         <= entrada_a or entrada_b;

    process(seletor_operacao, resultado_soma_5bits, resultado_subtracao_5bits, resultado_and_bits, resultado_or_bits, entrada_a, entrada_b)
        variable sinal_resultado_soma : std_logic;
        variable sinal_resultado_sub  : std_logic;
    begin
        indicador_overflow  <= '0';
        indicador_carry_out <= '0';
        resultado_final     <= (others => '0');

        -- CORREÇÃO 1: Acesso direto ao bit (sem std_logic_vector)
        sinal_resultado_soma := resultado_soma_5bits(3);
        sinal_resultado_sub  := resultado_subtracao_5bits(3);

        case seletor_operacao is
            when "00" => -- SOMA
                -- Aqui mantemos a conversão apenas no slice (3 downto 0), pois estamos jogando num vector
                resultado_final     <= std_logic_vector(resultado_soma_5bits(3 downto 0));
                
                -- CORREÇÃO 2: Acesso direto ao bit 4
                indicador_carry_out <= resultado_soma_5bits(4); 
                
                if (sinal_entrada_a = sinal_entrada_b) and (sinal_resultado_soma /= sinal_entrada_a) then
                    indicador_overflow <= '1';
                else
                    indicador_overflow <= '0';
                end if;

            when "01" => -- SUBTRAÇÃO
                resultado_final     <= std_logic_vector(resultado_subtracao_5bits(3 downto 0));
                
                -- CORREÇÃO 3: Acesso direto ao bit 4
                indicador_carry_out <= resultado_subtracao_5bits(4);
                
                if (sinal_entrada_a /= sinal_entrada_b) and (sinal_resultado_sub /= sinal_entrada_a) then
                    indicador_overflow <= '1';
                else
                    indicador_overflow <= '0';
                end if;

            when "10" => -- AND
                resultado_final <= resultado_and_bits;
                
            when "11" => -- OR
                resultado_final <= resultado_or_bits;
            
            when others =>
                resultado_final <= (others => '0');
        end case;
    end process;

end Comportamental;