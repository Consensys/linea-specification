# rlp_txn side
USER_TRANSACTION_NUMBER
AUTHORIZATION_TUPLE_INDEX
+ macro/
    - chainid
    - delegation_address
    - authority_nonce
    - signature (r, s, y)

- liste non vide
- chaque item est de taille fixée

- pour TXN_DATA il faut qu'on connaisse le nombre total d'items dans la delegation_list

RLP_TXN -> AUTH -> HUB -> RLP_TXN

# implem

dans le hub il faut ajouter un entier à ce qui identifie le CFI
impact on the ROM_LEX
