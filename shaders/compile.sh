for filename in *.vert.hlsl; do
    if [ -f "$filename" ]; then
        shadercross "$filename" -o "./SPIRV/${filename/.hlsl/.spv}"
        shadercross "$filename" -o "./MSL/${filename/.hlsl/.msl}"
    fi
done

for filename in *.frag.hlsl; do
    if [ -f "$filename" ]; then
        shadercross "$filename" -o "./SPIRV/${filename/.hlsl/.spv}"
        shadercross "$filename" -o "./MSL/${filename/.hlsl/.msl}"
    fi
done
