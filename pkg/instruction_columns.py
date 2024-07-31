"""
e.g.:

\newcommand{\callFLAG}{\col{CALL\_FLAG}}
\newcommand{\callFlag}{\col{CALL}\flag}
\newcommand{\decCallFlag}{\decoded{\callFlag}}
\newcommand{\iCallFlag}{\imported{\decCallFlag}}
\newcommand{\idecCallFlag}{\imported{\decCallFlag}}

"""

instructions = {
	"call": "call",
	"copy": "copy",
	"create": "create",
	"CDC": "CALLDATACOPY",
	"CDL": "CALLDATALOAD",
	"halt": "halting",
	# "invalid": "invalid",
	"jump": "jump",
	"push": "push",
	"RDC": "RETURNDATACOPY",
	"return": "return",
	"revert": "revert",
	"selfDestruct": "SELFDESTRUCT",
	}

def new_commands(s):

	full = instructions[s].upper()

	m = s.lower() 				# m <> moniker
	M = m[0].upper() + m[1:]	# M <> Moniker

	res = "% " + s + " columns:\n"
	res += (2 + len(s) + len(" columns:")) * "%" + "\n\n"
	res += "\\newcommand{\\" + m + "FLAG}{\\col{" + full + "\\_FLAG}}\n"
	res += "\\newcommand{\\" + m + "Flag}{\\col{" + s.upper() + "}\\flag}\n"
	res += f"\\newcommand{{\\stackDec{s.capitalize()}Flag}}{{\\stackInstructionDecodedColumn{{\\{m}Flag}}}}\n"
	res += "\\newcommand{\\i" + M + "Flag}{\\imported{\\dec" + M + "Flag}}\n"
	res += "\\newcommand{\\idec" + M + "Flag}{\\imported{\\dec" + M + "Flag}}\n"
	res += "\n\n"

	return res


def all_commands():

	res = ""
	res += "% automaticlaly generated via \"python3 instruction_columns.py > instruction_flags.sty\"\n"
	res += "% yes, \\iBlaFlag and \\idecBlaFlag define the same macro.\n\n\n"

	for name in instructions:
		res += new_commands(name)

	print(res)

all_commands()
