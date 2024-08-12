@olivier (improved yet again, final form ?)
lead_log =
	 |	IF  min_cutoff ≤ 16:                                                  
	 |	⟦ ⇒ we are trimming the raw_lead_hi ⟧
	 |		IF  trim_acc = 0:  lead_log = 0
	 |		IF  trim_acc ≠ 0:  lead_log = padded_base_2_log - 8 * (16 - ebs_cutoff)
	 |	IF  min_cutoff > 16:
	 |		IF  raw_lead_hi_is_zero = 1:                                      
	 |		⟦ ⇒ we are trimming the raw_lead_lo ⟧
	 |			IF  trim_acc = 0:  lead_log = 0
	 |			IF  trim_acc ≠ 0:  lead_log = padded_base_2_log - 8 * (32 - ebs_cutoff)
	 |		IF  raw_lead_hi_is_zero = 0:                                      
	 |		⟦ ⇒ we are trimming the raw_lead_hi, and trimming doesn't trim anything⟧
	 |			lead_log = padded_base_2_log + 8 * (ebs_cutoff - 16)

@olivier (improved yet again)
lead_log =
	 |	IF  min_cutoff ≤ 16:                                                  
	 |	⟦ ⇒ we are trimming the raw_lead_hi ⟧
	 |		IF  ebs_cutoff ≤ 16:
	 |			IF  trim_acc = 0:  lead_log = 0
	 |			IF  trim_acc ≠ 0:  lead_log = padded_base_2_log - 8 * (16 - ebs_cutoff)
	 |		IF  ebs_cutoff > 16:
	 |			IF  trim_acc = 0:  lead_log = 0
	 |			IF  trim_acc ≠ 0:  lead_log = padded_base_2_log + 8 * (ebs_cutoff - 16)
	 |	IF  min_cutoff > 16:
	 |		IF  raw_lead_hi_is_zero = 1:                                      
	 |		⟦ ⇒ we are trimming the raw_lead_lo ⟧
	 |			IF  trim_acc = 0:  lead_log = 0
	 |			IF  trim_acc ≠ 0:  lead_log = padded_base_2_log - 8 * (32 - ebs_cutoff)
	 |		IF  raw_lead_hi_is_zero = 0:                                      
	 |		⟦ ⇒ we are trimming the raw_lead_hi, and trimming is trivial⟧
	 |			lead_log = padded_base_2_log + 8 * (ebs_cutoff - 16)



@olivier (improved again)
lead_log =
	 |	IF  trivial_trim = 1:
	 |      ⟦ ⇒ trim_lead ∈ {0, 1} ⟧
	 |		IF  min_cutoff ≤ 16:
	 |			⟦ ⇒ we will be trimming the raw_lead_hi ⟧
	 |			IF  trim_lead = 0:  lead_log = 0
	 |			IF  trim_lead = 1:
	 |				IF  ebs_cutoff ≤ 16:  lead_log = 0.
	 |				IF  ebs_cutoff > 16:  lead_log = 8 * (ebs_cutoff - 16)
	 |		IF  min_cutoff > 16:
	 |			IF  raw_lead_hi_is_zero = 1:  lead_log = 8 * (ebs_cutoff - 16)   ⟦ ⇒ we will be trimming the raw_lead_lo ⟧
	 |			IF  raw_lead_hi_is_zero = 0:  lead_log = 0                       ⟦ ⇒ we will be trimming the raw_lead_hi ⟧
	 |
	 |	IF  trivial_trim = 0:
	 |		IF  min_cutoff ≤ 16:
	 |			⟦ ⇒ we will be trimming the raw_lead_hi ⟧
	 |			IF  ebs_cutoff ≤ 16:  lead_log = padded_base_2_log - 8 * (16 - ebs_cutoff)
	 |			IF  ebs_cutoff > 16:  lead_log = padded_base_2_log + 8 * (ebs_cutoff - 16)
	 |		IF  min_cutoff > 16:
	 |			IF  raw_lead_hi_is_zero = 1: lead_log = padded_base_2_log - 8 * (32 - ebs_cutoff)  ⟦ ⇒ we are trimming the raw_lead_lo ⟧
	 |			IF  raw_lead_hi_is_zero = 0: lead_log = padded_base_2_log + 8 * (ebs_cutoff - 16)  ⟦ ⇒ we are trimming the raw_lead_hi ⟧


@olivier:
lead_log =
	 |	trivial_trim = 1:
	 |		min_cutoff ≤ 16:
	 |			[NOTE: raw_lead_hi ⇒ trim_lead]
	 |			trim_lead = 0: 0
	 |			trim_lead ≠ 0: then trim_lead ≡ 1 and
	 |				if ebs_cutoff ≤ 16: 0
	 |				if ebs_cutoff > 16: 8 * (ebs_cutoff - 16)
	 |		min_cutoff > 16:
	 |			raw_lead_hi ≠ 0: 8 * (ebs_cutoff - 16)   [raw_lead_hi ⇒ trim_lead, and raw_lead_hi ≡ 1, NECESSARILY]
	 |			raw_lead_hi = 0: 0                       [raw_lead_lo ⇒ trim_lead]
	 |
	 |	trivial_trim = 0:
	 |		as before


@Lorenzo:
lead_log =
	 |	trivial_trim = 1:
	 |		ebs_cutoff ≤ 16: lead_log = 0
	 |		ebs_cutoff > 16:
	 |			raw_lead_hi = 0:
	 |				lead_log = 0
	 |			raw_lead_hi != 0:
	 |				cds_cutoff < index_leading_byte:
	 |					lead_log = 0
	 |				cds_cutoff >= index_leading_byte:
	 |					lead_log = 8 * (ebs_cutoff - 16)





trivial_trim = 1:
	ebs_cutoff ≤ 16: lead_log = 0
	ebs_cutoff > 16:
		trim_lead ≠ 0:
			lead_log = 8 * (ebs_cutoff - 16)
		trim_lead_hi = 0:



trivial_trim = 1:
	ebs_cutoff ≤ 16: lead_log = 0
	ebs_cutoff > 16:
		min_cutoff ≤ 16: lead_log = 
