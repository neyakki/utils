#!/usr/bin/bash

show_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] SOURCE_DIR DEST_DIR

Convert all PDF files in SOURCE_DIR to text files in DEST_DIR.

Arguments:
    SOURCE_DIR    Directory containing PDF files
    DEST_DIR      Directory for output text files (will be created if doesn't exist)

Options:
    -h, --help    Show this help message and exit

Example:
    $(basename "$0") pdf-resume text
    $(basename "$0") /path/to/pdfs /path/to/output

EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
  exit 0
fi

if [[ $# -ne 2 ]]; then
  echo "Error: Exactly 2 arguments required" >&2
  echo "" >&2
  show_help
  exit 1
fi

PDF_FOLDER="$1"
TXT_FOLDER="$2"

if [[ ! -d "$PDF_FOLDER" ]]; then
  echo "Error: Source directory '$PDF_FOLDER' does not exist" >&2
  exit 1
fi

if [[ ! -d "$TXT_FOLDER" ]]; then
  mkdir -p "$TXT_FOLDER"
fi

shopt -s nullglob
pdf_files=("$PDF_FOLDER"/*.pdf)
if [[ ${#pdf_files[@]} -eq 0 ]]; then
  echo "Warning: No PDF files found in '$PDF_FOLDER'" >&2
  exit 0
fi

for res in "${pdf_files[@]}"; do
  filename=$(basename "$res" .pdf)
  txt_file="${TXT_FOLDER}/${filename}.txt"

  echo "Convert $res to $txt_file"

  pdftotext -enc UTF-8 "$res" "$txt_file"
done

echo "Done! Converted ${#pdf_files[@]} file(s)"
