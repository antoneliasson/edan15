#!/bin/bash
pdflatex report.tex && bibtex report && pdflatex report.tex
