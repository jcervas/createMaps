mkdir -p cleaned_csvs

for f in *.csv; do
  awk -F',' '
    NR==1 { print; next }
    {
      id = $1
      gsub(/^ *"|" *$/, "", id)  # remove surrounding quotes and spaces
      if (id != "" && id != "Un") print
    }
  ' "$f" > "cleaned_csvs/$f"
done
