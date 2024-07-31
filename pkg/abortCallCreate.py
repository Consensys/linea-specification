"""
e.g.:

\newcommand{\oogxSc}{\texttt{outOfGasException}} % snail case name
\newcommand{\oogx}{\col{OOGX}}
\newcommand{\oogxFull}{\col{OUT\_OF\_GAS\_EXCEPTION}}

"""


exceptions = {
	# aborting conditions
	"csd": "call Stack Depth",
	"bal": "insufficient Balance",
	"prec": "precompile Failure Condition",
	"dead": "account Isnt Dead",
}

def exception_macros(s):

	f = exceptions[s]
	fsc = f.replace(" ", "")			# f in snail case
	fcu = f.replace(" ", "\\_").upper() # f capitalized, underscores
	S = s[0].upper() + s[1:]

	res = f"% {f} abort columns:\n"
	res += len(res) * "%"
	res += "\n\n"
	res += f"\\newcommand{{\\{s}AbortSH}}{{\\texttt{{{fsc}Abort}}}} % short hand for the snail case name\n"
	res += f"\\newcommand{{\\{s}ABORT}}{{\\col{{{fcu}\\_ABORT}}}}\n"
	res += f"\\newcommand{{\\{s}Abort}}{{\\col{{{s.upper()}ABORT}}}}\n"
	res += "\n\n\n"

	return res


def all_commands():

	res = ""
	res += "% automaticlaly generated via \"python3 abortCallCreate.py > abort.sty\"\n\n\n"

	for name in exceptions:
		res += exception_macros(name)

	print(res)

all_commands()