cd /Users/cervas/Library/Mobile\ Documents/com\~apple\~CloudDocs/Downloads/FL

mkdir -p cleaned_csvs

for f in data/*.csv; do
  out="./cleaned_csvs/$(basename "$f")"
  awk -F',' '
    NR==1 { print; next }
    {
      id = $1
      gsub(/^ *"|" *$/, "", id)
      if (id != "" && id != "Un") print
    }
  ' "$f" > "$out"
done
