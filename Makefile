.PHONY: alu bin exp gas oob

view-%: lua_build
	cd $* && tectonic -X compile _all_$*.tex && evince _all_$*.pdf

recompile-%: lua_build
	cd $* && tectonic -X compile _all_$*.tex

buildOnGithub-%: lua_build
	cd $* && ../tectonic -X compile _all_$*.tex

alu:          view-alu
blake:        view-blake_data
block_data:   view-block_data
block_hash:   view-block_hash
btc:          view-btc_data
bin:          view-bin
exp:          view-exp
euc:          view-euc
formal:       view-formal
gas:          view-gas
hash_data:    view-hash_data
hash_info:    view-hash_info
hub:          view-hub
lex:          view-lex
logd_data:    view-log_data
logi_info:    view-log_info
mmio:         view-mmio
modexp:       view-modexp_data
mmu:          view-mmu
mxp:          view-mxp
mxp_v3:       view-mxp_v3
oob:          view-oob
prc:   	      view-prc
rlp_addr:     view-rlp_addr
rlp_txn:      view-rlp_txn
rlp_txnrcpt:  view-rlp_txnrcpt
rom:          view-rom
rom_v3:       view-rom_v3
rom_lex:      view-rom_lex
shf:          view-shf
spec:         view-spec
stp:          view-stp
trm:          view-trm
txn_data:     view-txn_data
txn_system:   view-txn_system
wcp:          view-wcp

ralu:          recompile-alu
rblake:        recompile-blake_data
rblock_data:   recompile-block_data
rblock_hash:   recompile-block_hash
rbtc:          recompile-btc_data
rbin:          recompile-bin
rexp:          recompile-exp
reuc:          recompile-euc
rformal:       recompile-formal
rgas:          recompile-gas
rhashd:        recompile-hash_data
rhashi:        recompile-hash_info
rhub:          recompile-hub
rlex:          recompile-lex
rlogd:         recompile-log_data
rlogi:         recompile-log_info
rmmio:         recompile-mmio
rmodexp:       recompile-modexp_data
rmmu:          recompile-mmu
rmxp:          recompile-mxp
rmxp_v3:       recompile-mxp_v3
roob:          recompile-oob
rprc:          recompile-prc
rrlp_addr:     recompile-rlp_addr
rrlp_txn:      recompile-rlp_txn
rrlp_txnrcpt:  recompile-rlp_txnrcpt
rrom:          recompile-rom
rrom_v3:       recompile-rom_v3
rrom_lex:      recompile-rom_lex
rshf:          recompile-shf
rspec:         recompile-spec
rstp:          recompile-stp
rtrm:          recompile-trm
rtxn_data:     recompile-txn_data
rtxn_system:   recompile-txn_system
rwcp:          recompile-wcp

ospec:         buildOnGithub-spec

# ==============================================================================
# Lualatex Generation
# ==============================================================================

# Find all luatex files
LUATEX_FILES=$(shell find * -name "*.lua.tex" -type f)
# Determine target PDFS
LUATEX_PDFS=$(LUATEX_FILES:%.lua.tex=%.pdf)

lua_build: $(LUATEX_PDFS)

%.pdf : %.lua.tex
	$(eval DIR := $(shell dirname "$<"))
	$(eval LUAPDF := $(shell echo "$@" | sed -e "s/\.pdf/\.lua\.pdf/"))
	lualatex --output-directory=$(DIR) "$<"
	mv "$(LUAPDF)" "$@"
	rm $(DIR)/*.log $(DIR)/*.aux

lua_clean:
	rm $(LUATEX_PDFS)

# adding e.g. 
# alias pdf='make -C ~/Documents/latex/zk-evm-notes/'
# (or whatever your path is to the zkevm-notes folder) to ~/.bashrc
# allows one to execute commands like 'pdf oob' to view the oob module pdf from anywhere.
