"""
e.g.:

\newcommand{\oogxSc}{\texttt{outOfGasException}} % snail case name
\newcommand{\oogx}{\col{OOGX}}
\newcommand{\oogxFull}{\col{OUT\_OF\_GAS\_EXCEPTION}}

"""


exceptions = {
	"oog": "out Of Gas",
	"opc": "invalid Opcode",
	"su": "stack Underflow",
	"so": "stack Overflow",
	"st": "stack",
	"rdc": "return Data Copy",
	"jump": "invalid Jump",
	"static": "static Context",
	"sstore": "sstore Gas",
	# invalid first byte of bytecode to deploy
	# https://github.com/ethereum/execution-specs/blob/9aeb242ea757cdc2234beb2cf37a61aecbbf0687/src/ethereum/shanghai/vm/exceptions.py
	"icp": "invalid Code Prefix",
	# not quite an exception
	"maxcs": "max Code Size",
	# aborting condition or so ...
	"csd": "call Stack Overflow",
	"bal": "insufficient Balance",
	"rev": "revert",
	"mxp": "memory Expansion",
	"gen": "general",
	"oob": "out Of Bounds",
}

def exception_macros(s):

	f = exceptions[s]
	fsc = f.replace(" ", "")			# f in snail case
	fcu = f.replace(" ", "\\_").upper() # f capitalized, underscores
	S = s[0].upper() + s[1:]

	res = f"% {f} exception columns:\n"
	res += len(res) * "%"
	res += "\n\n"
	res += f"\\newcommand{{\\{s}xSH}}{{\\texttt{{{fsc}Exception}}}} % short hand for the snail case name\n"
	res += f"\\newcommand{{\\{s}X}}{{\\col{{{fcu}\\_EXCEPTION}}}}\n"
	res += f"\\newcommand{{\\{s}x}}{{\\col{{{s.upper()}X}}}}\n"
	res += f"\\newcommand{{\\stack{S}x}}{{\\stackSignifier\\{s}x}}\n"
	res += f"\\newcommand{{\\dec{s}x}}{{\\decoded{{\\{s}x}}}}\n"
	res += f"\\newcommand{{\\i{s}X}}{{\\imported{{\\{s}X}}}}\n"
	res += f"\\newcommand{{\\i{s}x}}{{\\imported{{\\{s}x}}}}\n"
	res += "\n\n\n"

	return res


def all_commands():

	res = ""
	res += "% automaticlaly generated via \"python3 exceptions.py > exceptions.sty\"\n\n\n"

	for name in exceptions:
		res += exception_macros(name)

	print(res)

all_commands()
