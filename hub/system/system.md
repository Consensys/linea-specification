# Binary constraints

We impose the following general constraints

```python
flag_sum = SYSI + USER + SYSF
```

We impose that

```python
flag_sum.isBinary()
flag_sum[0] = 0
If ABS_BLOCK_NUM == 0 Then flag_sum = 0
If ABS_BLOCK_NUM != 0 Then flag_sum = 1

sanityCheck:
	If flag_sum == 1 Then flag_sum.next() == 1 
```

We impose

```python
ABS_BLOCK_NUM.next() = ABS_BLOCK_NUM + SYSI.not() ∧ SYSI.next()
```

