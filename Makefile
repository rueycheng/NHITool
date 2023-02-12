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
	@echo "  json
	@echo "  csv
	@echo "  (or 'make all' for everything)"

all: csv json

csv: $(CSV_FILE)

json: $(JSON_FILE)

clean:
	rm -f ICD-9-CM_diagnosis_*.csv ICD-9-CM_procedure_*.csv $(JSON_FILE)

ICD-9-CM_1992.xls:
	wget --user-agent $(USER_AGENT) -O $@ 'http://www.nhi.gov.tw/Resource/webdata/Attach_3468_1_ICD1992.xls'
ICD-9-CM_2001.xls:
	wget --user-agent $(USER_AGENT) -O $@ 'http://www.nhi.gov.tw/Resource/webdata/Attach_3469_1_ICD2001-%E6%9B%B4%E6%96%B0%E7%89%88.xls'
ICD-9-CM_2001-to-ICD-10-CM.xlsx:
	wget --user-agent $(USER_AGENT) -O $@ 'http://www.nhi.gov.tw/Resource/webdata/23348_1_ICD-10-CM.xlsx'
ICD-9-CM_2001-to-ICD-10-PCS.xlsx:
	wget --user-agent $(USER_AGENT) -O $@ 'http://www.nhi.gov.tw/Resource/webdata/23349_1_ICD-10-PCS.xlsx'

ICD-9-CM_diagnosis_1992.csv: ICD-9-CM_1992.xls
	(python nhitool.py --export-sheet 'ICD-9-CM1992疾病碼' $^ | python nhitool.py --fix-icd9 diagnosis) > $@ 
ICD-9-CM_procedure_1992.csv: ICD-9-CM_1992.xls
	(python nhitool.py --export-sheet 'ICD-9-CM1992-處置碼' $^ | python nhitool.py --fix-icd9 procedure) > $@ 
ICD-9-CM_diagnosis_2001.csv: ICD-9-CM_diagnosis_2001_en.csv ICD-9-CM_diagnosis_2001_zh.csv
	(csvjoin -c 1 --left $^ | csvcut -c 1,2,3,5) > $@
ICD-9-CM_procedure_2001.csv: ICD-9-CM_procedure_2001_en.csv ICD-9-CM_procedure_2001_zh.csv
	(csvjoin -c 1 --left $^ | csvcut -c 1,2,3,5) > $@
ICD-9-CM_diagnosis_2001_en.csv: ICD-9-CM_2001.xls
	(python nhitool.py --export-sheet 'ICD2001-疾病碼' $^ | python nhitool.py --fix-icd9 diagnosis) > $@ 
ICD-9-CM_diagnosis_2001_zh.csv: ICD-9-CM_2001-to-ICD-10-CM.xlsx
	echo "code,desc_zh" > $@
	(in2csv -f xlsx $^ | csvcut -c 1,3 | uniq | tail -n +2) >> $@
ICD-9-CM_procedure_2001_en.csv: ICD-9-CM_2001.xls
	(python nhitool.py --export-sheet 'ICD-9-CM2001處置碼' $^ | python nhitool.py --fix-icd9 procedure) >$@ 
ICD-9-CM_procedure_2001_zh.csv: ICD-9-CM_2001-to-ICD-10-PCS.xlsx
	echo "code,desc_zh" > $@
	in2csv -f xlsx $^ | csvcut -c 1,3 | uniq | tail -n +2 >> $@

%.json: %.csv
	csvjson $^ > $@
