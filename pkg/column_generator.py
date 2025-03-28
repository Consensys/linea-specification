full_names = {
	"acc": "account Data",
	"add": "adder",
	"alu": "alu",
	"btc": "block Data",
	"blockHash": "block Hash",
	"bin": "binary",
	"con": "context",
	"exp": "exponent",
	"euc": "euclidean Division",
	"env": "environment",
	"ext": "extended Modular Arithmetic",
	"gas": "gas",
	"hub": "hub",
	"kec": "kec",
	"log": "log Info",
	"mmu": "mmu",
	"mmio": "mmio",
	"mul": "multiplier",
	"mod": "modular Arithmetic",
	"mxp": "memory Expansion",
	"oob": "out Of Bounds",
	"ram": "ram",
	"rom": "rom",
	"shf": "shift",
	"stp": "stipend",
	"sto": "storage",
	"trm": "address Trimming",
	"wcp": "word Comparison",
	"wrm": "warmth",
	# precompiles
	"ecaddD": "ecadd Data",
	"ecaddI": "ecadd Info",
	"ecmulD": "ecmul Data",
	"ecmulI": "ecmul Info",
	"idRD": "identity Return Data",
	# info / data module pairs
	"logInfo": "log Info",
	"logData": "log Data",
	"hashInfo": "hash Info",
	"hashData": "hash Data",
	"modexp": "modexp",
	"blakeData": "blake Data",
	"blake": "blake",
	"ecData": "ec Data",
	"precInfo": "prec Info",
	"txnData": "txn Data",
	"txnComp": "txn Comp",
	"romLex": "rom Lex",
	"shakira": "shakira",
	"ripSha": "rip Sha",
	"blkMdx": "blk Mdx",
	# flags
	"txn": "txn",
	"trans": "trans Storage",
	"stackRam": "stack Ram",
	"machineState": "machine State",
	"pushPop": "push Pop",
	"dup": "dup",
	"swap": "swap",
	"invalid": "invalid",
	# rlp modules
	"rlpAddr": "address Rlp",		# I'm taking out the d for readability
	"rlpTxn": "transaction Rlp",
	"rlpTxnRcpt": "transaction Receipt Rlp",
	# instruction decoder
	"id": "instruction Decoder",
}

def module_list():

	ncols = 3
	ncols_string = "3"

	t = "% automaticlaly generated via \"python3 column_generator.py > ../spec/modules.tex\"\n\n"

	l =  len(full_names)
	s = "\\begin{multicols}{" + ncols_string +"}\n\\begin{enumerate}\n"

	for name in full_names:
		s += "\t\\item $\\" + name + "Mod{}$\n"

	if (l % ncols) != 0:
		for i in range(ncols - (l % ncols)):
			s += "\t\\item[\\vspace{\\fill}]\n"

	s += "\\end{enumerate}\n\\end{multicols}\n"

	print(s)

def UPPER(s):
	s = s.upper()
	return s.replace(" ", "\\_")

def snail(s):
	return s[0].upper() + s[1:]

def three_letter_identifier(short):

	if short == "acc" or short == "log" or short == "exp":
		return "\\newcommand{\\" + short + "Mod}{\\col{" + short.upper() + "}}\n\n"

	# s = ""
	# s += "\\newcommand{\\" + short + "}{\\col{" + short.upper() + "}}\n\n"
	return "\\newcommand{\\" + short + "Mod}{\\col{" + short.upper() + "}}\n\n"

def stamp_columns(short):

	full = full_names[short]
	stamp = "Stamp"

	c = short + stamp
	C = short + stamp.upper()
	ic = "i" + snail(c)
	iC = "i" + snail(C)
	s = ""
	s += "\\newcommand{\\" + C + "}{\\col{" + UPPER(full) + "\\_" + "STAMP" + "}}\n"
	s += "\\newcommand{\\" + c + "}{\\col{" + short.upper() + "}\\stamp}\n"
	s += "\\newcommand{\\" + iC + "}{\\imported{\\" + C + "}}\n"
	s += "\\newcommand{\\" + ic + "}{\\imported{\\" + c + "}}\n"
	s += "\\newcommand{\\" + short + "Rev" + stamp + "}{\\col{" + short.upper() + "}\\stamp\\,\\col{REV}}\n"
	s += "\\newcommand{\\i" + snail(short) + "Rev" + stamp + "}{\\imported{\\" + short + "Rev" + stamp + "}}\n"

	return s


def flag_columns(short):

	full = full_names[short]
	Flag = "Flag"

	c = short + Flag
	C = short + Flag.upper()
	decc = "dec" + snail(c)
	decC = "dec" + snail(C)
	s = ""
	s += "\\newcommand{\\" + C + "}{\\col{" + UPPER(full) + "\\_" + "FLAG" + "}}\n"
	s += "\\newcommand{\\" + c + "}{\\col{" + short.upper() + "}\\" + Flag.lower() + "}\n"
	s += "\\newcommand{\\" + decC + "}{\\decoded{\\" + C + "}}\n"
	s += "\\newcommand{\\" + decc + "}{\\decoded{\\" + c + "}}\n"
	s += "\\newcommand{\\" + "i" + decC + "}{\\imported{\\" + decC + "}}\n"
	s += "\\newcommand{\\" + "i" + decc + "}{\\imported{\\" + decc + "}}\n"

	return s

def selector_columns(short):

	full = full_names[short]
	selector = "Select"

	c = short + selector
	C = short + selector.upper()
	ic = "i" + snail(c)
	iC = "i" + snail(C)
	s = ""
	s += "\\newcommand{\\" + C + "}{\\col{" + UPPER(full) + "\\_" + "SELECTOR" + "}}\n"
	s += "\\newcommand{\\" + c + "}{\\col{" + short.upper() + "}\\" + selector.lower() + "}\n"
	s += "\\newcommand{\\" + iC + "}{\\imported{\\" + C + "}}\n"
	s += "\\newcommand{\\" + ic + "}{\\imported{\\" + c + "}}\n"
	s += f'\\newcommand{{\\stackDec{short[0].upper() + short[1:]}Flag}}{{\\stackInstructionDecodedColumn{{\\{short}Flag}}}}\n'

	return s

def standard_columns_of(s):

	cols = "% " + full_names[s].lower() + " columns:\n"
	cols += (2 + len(full_names[s]) + len(" columns:")) * "%" + "\n\n"
	cols += three_letter_identifier(s)
	cols += stamp_columns(s) + "\n"
	cols += flag_columns(s) + "\n"
	cols += selector_columns(s) + "\n"

	return cols

def all_standard_columns():
	t = "% automaticlaly generated via \"python3 column_generator.py > flags_stamps_selectors.sty\"\n\n"
	for name in full_names:
		t += standard_columns_of(name)

	print(t)

#module_list()

all_standard_columns()
