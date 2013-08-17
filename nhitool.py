#!/usr/bin/env python
import sys, argparse
import re, csv, xlrd

OUTPUT_CHARSET = 'utf-8'

def export_sheet(sheet_name, inputfile, outputfile):
    if outputfile is None: outputfile = sys.stdout
    else: outputfile = file(outputfile, 'wb')

    wb = xlrd.open_workbook(inputfile)
    sheet_names = [name.encode(OUTPUT_CHARSET) for name in wb.sheet_names()]
    try:
	match = sheet_names.index(sheet_name)
    except:
	print >>sys.stderr, 'no such sheet: %s' % sheet_name
	sys.exit(1)
    sheet = wb.sheet_by_index(match)
    writer = csv.writer(outputfile)
    for n in xrange(sheet.nrows):
	writer.writerow([value.encode(OUTPUT_CHARSET) for value in sheet.row_values(n)])

def fix_icd9(fix_method, inputfile, outputfile):
    if inputfile is None: inputfile = sys.stdin
    else: inputfile = file(inputfile)
    if outputfile is None: outputfile = sys.stdout
    else: outputfile = file(outputfile, 'wb')

    reader = csv.reader(inputfile)
    writer = csv.writer(outputfile)
    writer.writerow(['code', 'valid', 'desc'])

    if fix_method == 'diagnosis': punc_pos = 3
    elif fix_method == 'procedure': punc_pos = 2

    skip_count = 2
    for row in reader:
	if skip_count > 0:
	    skip_count = skip_count - 1
	    continue
	if row[1] == '': continue

	# column 0: Code
	n = len(row[0])
	if n > punc_pos: code = row[0][0:punc_pos] + '.' + row[0][punc_pos:]
	elif n == punc_pos: code = row[0]
	else: raise

	# column 1: Valid
	if row[1] == 'Y': valid = 1
	elif row[1] == 'N': valid = 0
	else: raise

	# column 3: Description
	desc = re.sub(r'(?<=,)(\S)', r' \1', row[3])
	desc = re.sub(r',$', '', desc)

	writer.writerow((code, valid, desc))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Toolkit for processing NHI Taiwan data')
    parser.add_argument('--export-sheet', metavar='NAME', dest='export_sheet',
	    help='export the sheet to CSV output')
    parser.add_argument('--fix-icd9', metavar='METHOD', dest='fix_icd9',
	    help="fix the ICD-9 codes in the CSV input; METHOD is either 'diagnosis' or 'procedure'")
    parser.add_argument('input', nargs='?', help='the input file (STDIN if omitted)')
    parser.add_argument('output', nargs='?', help='the output file (STDOUT if omitted)')
    args = parser.parse_args()

    if args.export_sheet:
	export_sheet(args.export_sheet, args.input, args.output)
    elif args.fix_icd9:
	fix_icd9(args.fix_icd9, args.input, args.output)
