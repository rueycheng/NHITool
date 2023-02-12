USER_AGENT = "Mozilla/5.0"
CSV_FILE = $(patsubst %,ICD-9-CM_%.csv,diagnosis_1992 procedure_1992 diagnosis_2001 procedure_2001)
JSON_FILE = $(patsubst %.csv,%.json,$(CSV_FILE))

.PHONY: help all csv json

help:
	@echo "Available targets:"
	@echo
	@echo "  ICD-9-CM_diagnosis_1992.{csv,json}"
	@echo "  ICD-9-CM_procedure_1992.{csv,json}"
	@echo "  ICD-9-CM_diagnosis_2001.{csv,json}"
	@echo "  ICD-9-CM_procedure_2001.{csv,json}"
	@echo
	@echo "  (or 'make all' for everything)"

all: csv json

csv: $(CSV_FILE)

json: $(JSON_FILE)

clean:
	rm -f $(CSV_FILE) $(JSON_FILE)

ICD-9-CM_1992.xls:
	wget --user-agent $(USER_AGENT) -O $@ 'http://www.nhi.gov.tw/Resource/webdata/Attach_3468_1_ICD1992.xls'
ICD-9-CM_2001.xls:
	wget --user-agent $(USER_AGENT) -O $@ 'http://www.nhi.gov.tw/Resource/webdata/Attach_3469_1_ICD2001-%E6%9B%B4%E6%96%B0%E7%89%88.xls'

ICD-9-CM_diagnosis_1992.csv: ICD-9-CM_1992.xls
	(python nhitool.py --export-sheet 'ICD-9-CM1992疾病碼' $^ | python nhitool.py --fix-icd9 diagnosis) > $@ 
ICD-9-CM_procedure_1992.csv: ICD-9-CM_1992.xls
	(python nhitool.py --export-sheet 'ICD-9-CM1992-處置碼' $^ | python nhitool.py --fix-icd9 procedure) > $@ 
ICD-9-CM_diagnosis_2001.csv: ICD-9-CM_2001.xls
	(python nhitool.py --export-sheet 'ICD2001-疾病碼' $^ | python nhitool.py --fix-icd9 diagnosis) > $@ 
ICD-9-CM_procedure_2001.csv: ICD-9-CM_2001.xls
	(python nhitool.py --export-sheet 'ICD-9-CM2001處置碼' $^ | python nhitool.py --fix-icd9 procedure) >$@ 
%.json: %.csv
	csvjson $^ > $@
