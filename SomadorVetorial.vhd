library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SumSubVetorial is
    Port (
        A_i        : in  STD_LOGIC_VECTOR(31 downto 0);
        B_i        : in  STD_LOGIC_VECTOR(31 downto 0);
        mode_i     : in  STD_LOGIC; -- 0 soma / 1 subtrai
        vecSize_i  : in  STD_LOGIC_VECTOR(1 downto 0);
	S_o	   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end SumSubVetorial;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Somador4bits is
    Port (
        A_i, B_i   : in  STD_LOGIC_VECTOR(3 downto 0);
	C0	   : in STD_LOGIC;
	S_o	   : out STD_LOGIC_VECTOR(3 downto 0);
	P, G 	   : out STD_LOGIC
    );
end Somador4bits;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GeradorPropagadorCarry is
    Port (
        G0, G1, G2, G3, P0, P1, P2, P3, C0 : in  STD_LOGIC;
        C1, C2, C3, C4 : out  STD_LOGIC
    );
end GeradorPropagadorCarry;

architecture Behavioral of Somador4bits is

signal G0, G1, G2, G3, P0, P1, P2, P3, C1, C2, C3 : STD_LOGIC;

begin

P0 <= A_i(0) xor B_i(0);
G0 <= A_i(0) and B_i(0);

P1 <= A_i(1) xor B_i(1);
G1 <= A_i(1) and B_i(1);

P2 <= A_i(2) xor B_i(2);
G2 <= A_i(2) and B_i(2);

P3 <= A_i(3) xor B_i(3);
G3 <= A_i(3) and B_i(3);

C1 <= G0 or (P0 and C0);
C2 <= G1 or (P1 and G0) or (P1 and P0 and C0);
C3 <= G2 or (P2 and G1) or (P2 and P1 and G0) or (P2 and P1 and P0 and C0);

P <= P0 and P1 and P2 and P3;
G <= G3 or (P3 and G2) or (P3 and P2 and G1) or (P3 and P2 and P1 and G0) or (P3 and P2 and P1 and P0 and C0);

S_o(0) <= A_i(0) xor B_i(0) xor C0;
S_o(1) <= A_i(1) xor B_i(1) xor C1;
S_o(2) <= A_i(2) xor B_i(2) xor C2;
S_o(3) <= A_i(3) xor B_i(3) xor C3;

end Behavioral;



architecture Behavioral of GeradorPropagadorCarry is

begin

C1 <= G0 or (P0 and C0);
C2 <= G1 or (P1 and G0) or (P1 and P0 and C0);
C3 <= G2 or (P2 and G1) or (P2 and P1 and G0) or (P2 and P1 and P0 and C0);
C4 <= G3 or (P3 and G2) or (P3 and P2 and G1) or (P3 and P2 and P1 and G0) or (P3 and P2 and P1 and P0 and C0);

end Behavioral;



architecture Behavioral of SumSubVetorial is

component GeradorPropagadorCarry
   Port (
        G0, G1, G2, G3, P0, P1, P2, P3, C0 : in  STD_LOGIC;
        C1, C2, C3, C4     : out  STD_LOGIC
    	);
end component;

component Somador4bits is
    Port (
        A_i, B_i   : in  STD_LOGIC_VECTOR(3 downto 0);
	C0	   : in STD_LOGIC;
	S_o	   : out STD_LOGIC_VECTOR(3 downto 0);
	P, G : out STD_LOGIC
    );
end component;

signal B_signed, S_0_sig : STD_LOGIC_VECTOR(31 downto 0);
signal G0_sig, G1_sig, G2_sig, G3_sig, P0_sig, P1_sig, P2_sig, P3_sig, C0_sig, C1_sig, C2_sig, C3_sig, C4_sig : STD_LOGIC;
signal G4_sig, G5_sig, G6_sig, G7_sig, P4_sig, P5_sig, P6_sig, P7_sig, C5_sig, C6_sig, C7_sig, C8_sig : STD_LOGIC;

begin

	process(A_i, B_i, mode_i)
	begin
		if mode_i = '0' then
			B_signed <= B_i;
		else
			B_signed <= not B_i; --o +1 vai ser adicionado como carry in
		end if;
	end process;

SUM1: Somador4bits
    port map (
        	A_i => A_i(3 downto 0),
		B_i => B_signed(3 downto 0),
		C0  => mode_i,
		S_o => S_0_sig(3 downto 0),
		P   => P0_sig,
		G   => G0_sig
    		);

SUM2: Somador4bits
    port map (
        	A_i => A_i(7 downto 4),
		B_i => B_signed(7 downto 4),
		C0  => (C1_sig and (vecSize_i(0) or vecSize_i(1))) or (mode_i and (vecSize_i(0) nor  vecSize_i(1))),
		S_o => S_0_sig(7 downto 4),
		P   => P1_sig,
		G   => G1_sig
    		);

SUM3: Somador4bits
    port map (
        	A_i => A_i(11 downto 8),
		B_i => B_signed(11 downto 8),
		C0  => (C2_sig and vecSize_i(1)) or (mode_i and (not vecSize_i(1))),
		S_o => S_0_sig(11 downto 8),
		P   => P2_sig,
		G   => G2_sig
    		);

SUM4: Somador4bits
    port map (
        	A_i => A_i(15 downto 12),
		B_i => B_signed(15 downto 12),
		C0  => (C3_sig and (vecSize_i(0) or vecSize_i(1))) or (mode_i and (vecSize_i(0) nor  vecSize_i(1))),
		S_o => S_0_sig(15 downto 12),
		P   => P3_sig,
		G   => G3_sig
    		);

SUM5: Somador4bits
    port map (
        	A_i => A_i(19 downto 16),
		B_i => B_signed(19 downto 16),
		C0  => (C4_sig and vecSize_i(0) and vecSize_i(1)) or (mode_i and (vecSize_i(0) nand  vecSize_i(1))),
		S_o => S_0_sig(19 downto 16),
		P   => P4_sig,
		G   => G4_sig
    		);

SUM6: Somador4bits
    port map (
        	A_i => A_i(23 downto 20),
		B_i => B_signed(23 downto 20),
		C0  => (C5_sig and (vecSize_i(0) or vecSize_i(1))) or (mode_i and (vecSize_i(0) nor  vecSize_i(1))),
		S_o => S_0_sig(23 downto 20),
		P   => P5_sig,
		G   => G5_sig
    		);

SUM7: Somador4bits
    port map (
        	A_i => A_i(27 downto 24),
		B_i => B_signed(27 downto 24),
		C0  => (C6_sig and vecSize_i(1)) or (mode_i and (not vecSize_i(1))),
		S_o => S_0_sig(27 downto 24),
		P   => P6_sig,
		G   => G6_sig
    		);

SUM8: Somador4bits
    port map (
        	A_i => A_i(31 downto 28),
		B_i => B_signed(31 downto 28),
		C0  => (C7_sig and (vecSize_i(0) or vecSize_i(1))) or (mode_i and (vecSize_i(0) nor  vecSize_i(1))),
		S_o => S_0_sig(31 downto 28),
		P   => P7_sig,
		G   => G7_sig
    		);

GPC1: GeradorPropagadorCarry
	port map (
		G0 => G0_sig,
		G1 => G1_sig,
		G2 => G2_sig,
		G3 => G3_sig,
		P0 => P0_sig,
		P1 => P1_sig,
		P2 => P2_sig,
		P3 => P3_sig,
		C0 => C0_sig,
		C1 => C1_sig,
		C2 => C2_sig,
		C3 => C3_sig,
		C4 => C4_sig
		);

GPC2: GeradorPropagadorCarry
	port map (
		G0 => G4_sig,
		G1 => G5_sig,
		G2 => G6_sig,
		G3 => G7_sig,
		P0 => P4_sig,
		P1 => P5_sig,
		P2 => P6_sig,
		P3 => P7_sig,
		C0 => C4_sig,
		C1 => C5_sig,
		C2 => C6_sig,
		C3 => C7_sig,
		C4 => C8_sig
		);

S_o <= S_0_sig;

end Behavioral;