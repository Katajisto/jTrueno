rm -rf SPIRV
rm -rf MSL
mkdir SPIRV
mkdir MSL

set -e

for filename in *.vert.slang; do
    if [ -f "$filename" ]; then
        slangc -stage vertex -entry mainf -o "./SPIRV/${filename/.slang/.spv}"  "$filename"
        slangc -stage vertex -entry mainf -o "./MSL/${filename/.slang/.metal}"    "$filename" 
    fi
done

for filename in *.frag.slang; do
    if [ -f "$filename" ]; then
        slangc -stage fragment -entry mainf -o "./SPIRV/${filename/.slang/.spv}" "$filename"
        slangc -stage fragment -entry mainf -o "./MSL/${filename/.slang/.metal}" "$filename"
    fi
done
