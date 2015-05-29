TARGET=hwstatediagram

all: $(TARGET).pdf

auto:
	while [ 1 ]; do make all; inotifywait $(TARGET).txt; done

$(TARGET).pdf: $(TARGET).svg

# Files with these extensions are to be automatically "compiled" by make
.SUFFIXES: .pdf .svg .txt

# This suffix rule explains to make how to create a pdf from a svg file
.svg.pdf:
	inkscape --export-pdf=$@ $<

.txt.svg:
	plantuml -tsvg $(TARGET).txt
